#import "PdftronFlutterPlugin.h"
#import "PTFlutterDocumentController.h"
#import "DocumentViewFactory.h"

#include <objc/runtime.h>

static BOOL PT_addMethod(Class cls, SEL selector, void (^block)(id))
{
    const IMP implementation = imp_implementationWithBlock(block);

    const BOOL added = class_addMethod(cls, selector, implementation, "v@:");
    if (!added) {
        imp_removeBlock(implementation);
        return NO;
    }

    return YES;
}

@interface PTFlutterDocumentController()

@property (nonatomic, strong, nullable) UIBarButtonItem *leadingNavButtonItem;

// Array of wrapped PTExtendedAnnotTypes.
@property (nonatomic, strong, nullable) NSArray<NSNumber *> *hideAnnotMenuToolsAnnotTypes;

@end

@implementation PTFlutterDocumentController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Workaround to ensure thumbnail slider is hidden at launch.
    self.thumbnailSliderHidden = YES;
    self.thumbnailSliderController.view.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // bottomToolBar / thumbnailSlider enabling
    self.thumbnailSliderEnabled = ![self isBottomToolbarHidden];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    if (self.needsDocumentLoaded) {
        self.needsDocumentLoaded = NO;
        self.needsRemoteDocumentLoaded = NO;
        self.documentLoaded = YES;

        if (self.initialPageNumber > 0) {
            [self.pdfViewCtrl SetCurrentPage:self.initialPageNumber];
        }
        
        [self applyLayoutMode];
        
        if (self.base64) {
            NSString *filePath = self.coordinatedDocument.fileURL.path;
            [self.plugin documentController:self documentLoadedFromFilePath:filePath];
        } else {
            [self.plugin documentController:self documentLoadedFromFilePath:nil];
        }
    }
    
    if (![self.toolManager isReadonly] && self.readOnly) {
        self.toolManager.readonly = YES;
    }
    
    [self.plugin.tabbedDocumentViewController.tabManager saveItems];
}

- (void)setThumbnailSliderHidden:(BOOL)hidden animated:(BOOL)animated
{
    // Prevent the thumbnail slider from being shown.
    // NOTE: This method will be called with hidden=NO when the bottomToolbarEnabled property is
    // enabled (which is just a convenience property for the thumbnailSliderEnabled property).
    if (!hidden) {
        return;
    }
    [super setThumbnailSliderHidden:hidden animated:animated];
}

- (void)openDocumentWithURL:(NSURL *)url password:(NSString *)password
{
    self.local = [url isFileURL];
    self.documentLoaded = NO;
    self.needsDocumentLoaded = NO;
    self.needsRemoteDocumentLoaded = NO;

    [super openDocumentWithURL:url password:password];
}

- (void)openDocumentWithPDFDoc:(PTPDFDoc *)document
{
    self.local = YES;
    self.documentLoaded = NO;
    self.needsDocumentLoaded = NO;
    self.needsRemoteDocumentLoaded = NO;

    [super openDocumentWithPDFDoc:document];
}

- (BOOL)isTopToolbarEnabled
{
    return (!self.topAppNavBarHidden && !self.topToolbarsHidden);
}

- (BOOL)areTopToolbarsEnabled
{
    return !self.topToolbarsHidden;
}

- (BOOL)isNavigationBarEnabled
{
    return !self.topAppNavBarHidden;;
}

- (BOOL)controlsHidden
{
    if (self.navigationController) {
        if ([self isTopToolbarEnabled]) {
            return [self.navigationController isNavigationBarHidden];
        }
        if ([self isBottomToolbarEnabled]) {
            return [self.navigationController isToolbarHidden];
        }
    }
    return [super controlsHidden];
}

- (void)setControlsHidden:(BOOL)controlsHidden animated:(BOOL)animated
{
    [super setControlsHidden:controlsHidden animated:animated];
    
    // When the top toolbars are enabled...
    if ([self areTopToolbarsEnabled] &&
        // ... but the navigation bar (app nav. bar) is disabled...
        ![self isNavigationBarEnabled] &&
        // ... and we are in a tabbed viewer...
        self.tabbedDocumentViewController.tabsEnabled) {
        // ... then manually toggle the tabbed viewer's tab bar visibility.
        [self.tabbedDocumentViewController setTabBarHidden:controlsHidden animated:animated];
    }
}

- (void)setUneditableAnnotTypes:(NSArray<NSString *> *)uneditableAnnotTypes
{
    [self setAnnotationEditingPermission:uneditableAnnotTypes toValue:NO];
}

- (void)setAnnotationEditingPermission:(NSArray *)stringsArray toValue:(BOOL)value
{
    PTToolManager *toolManager = self.toolManager;

    for (NSObject *item in stringsArray) {
        if ([item isKindOfClass:[NSString class]]) {
            NSString *string = (NSString *)item;
            PTExtendedAnnotType typeToSetPermission = [self convertAnnotationNameToAnnotType:string];

            [toolManager annotationOptionsForAnnotType:typeToSetPermission].canEdit = value;
        }
    }
}

#pragma mark - <PTBookmarkViewControllerDelegate>

- (void)bookmarkViewController:(PTBookmarkViewController *)bookmarkViewController didAddBookmark:(PTUserBookmark *)bookmark
{
    [super bookmarkViewController:bookmarkViewController didAddBookmark:bookmark];
    [self bookmarksModified];
}

- (void)bookmarkViewController:(PTBookmarkViewController *)bookmarkViewController didRemoveBookmark:(PTUserBookmark *)bookmark
{
    [super bookmarkViewController:bookmarkViewController didRemoveBookmark:bookmark];
    [self bookmarksModified];
}

- (void)bookmarkViewController:(PTBookmarkViewController *)bookmarkViewController didModifyBookmark:(PTUserBookmark *)bookmark
{
    [super bookmarkViewController:bookmarkViewController didModifyBookmark:bookmark];
    [self bookmarksModified];
}

-(void)bookmarksModified
{
    __block NSString* json;
    NSError* error;
    BOOL exceptionOccurred = [self.pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * _Nullable doc) {
        json = [PTBookmarkManager.defaultManager exportBookmarksFromDoc:doc];
    } error:&error];
    
    if(exceptionOccurred)
    {
        NSLog(@"Error: %@", error.description);
    }

    [self.plugin documentController:self bookmarksDidChange:json];
}

- (void)bookmarkViewControllerDidCancel:(PTBookmarkViewController *)bookmarkViewController
{
    [bookmarkViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - <PTToolManagerDelegate>

- (void)toolManagerToolChanged:(PTToolManager *)toolManager
{
    PTTool *tool = toolManager.tool;
    
    const BOOL backToPan = tool.backToPanToolAfterUse;
    
    [super toolManagerToolChanged:toolManager];
    
    if (tool.backToPanToolAfterUse != backToPan) {
        tool.backToPanToolAfterUse = backToPan;
    }
}

-(void)toolManager:(PTToolManager*)toolManager willRemoveAnnotation:(nonnull PTAnnot *)annotation onPageNumber:(int)pageNumber
{
    NSString* annotationsWithActionString = [self generateAnnotationsWithActionString:@[annotation] onPageNumber:pageNumber action:PTDeleteActionKey];
    if (annotationsWithActionString) {
        [self.plugin documentController:self annotationsChangedWithActionString:annotationsWithActionString];
    }
    
    NSString* xfdf = [self generateXfdfCommandWithAdded:Nil modified:Nil removed:@[annotation]];
    [self.plugin documentController:self annotationsAsXFDFCommand:xfdf];
    
}

- (void)toolManager:(PTToolManager *)toolManager annotationAdded:(PTAnnot *)annotation onPageNumber:(unsigned long)pageNumber
{
    NSString* annotationsWithActionString = [self generateAnnotationsWithActionString:@[annotation] onPageNumber:pageNumber action:PTAddActionKey];
    if (annotationsWithActionString) {
        [self.plugin documentController:self annotationsChangedWithActionString:annotationsWithActionString];
    }
    
    NSString* xfdf = [self generateXfdfCommandWithAdded:@[annotation] modified:Nil removed:Nil];
    [self.plugin documentController:self annotationsAsXFDFCommand:xfdf];
}

- (void)toolManager:(PTToolManager *)toolManager annotationModified:(PTAnnot *)annotation onPageNumber:(unsigned long)pageNumber
{
    NSString* annotationsWithActionString = [self generateAnnotationsWithActionString:@[annotation] onPageNumber:pageNumber action:PTModifyActionKey];
    if (annotationsWithActionString) {
        [self.plugin documentController:self annotationsChangedWithActionString:annotationsWithActionString];
    }
  
    NSString* xfdf = [self generateXfdfCommandWithAdded:Nil modified:@[annotation] removed:Nil];
    [self.plugin documentController:self annotationsAsXFDFCommand:xfdf];
}

- (void)toolManager:(PTToolManager *)toolManager didSelectAnnotation:(PTAnnot *)annotation onPageNumber:(unsigned long)pageNumber
{
    if (annotation.IsValid) {
        
        __block NSString *uniqueId;
        __block PTPDFRect *screenRect;
        
        NSError *error;
        [self.pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * _Nullable doc) {
            PTObj *uniqueIdObj = [annotation GetUniqueID];
            if ([uniqueIdObj IsValid] && [uniqueIdObj IsString]) {
                uniqueId = [uniqueIdObj GetAsPDFText];
            }
            screenRect = [self.pdfViewCtrl GetScreenRectForAnnot:annotation
                                                                   page_num:(int)pageNumber];
        } error:&error];
        
        if (error) {
            NSLog(@"An error occurred: %@", error);
            return;
        }
        
        NSDictionary *annotDict = @{
            PTAnnotationIdKey: uniqueId ?: @"",
            PTAnnotationPageNumberKey: [NSNumber numberWithLong:pageNumber],
            PTRectKey: @{
                    PTX1Key: @([screenRect GetX1]),
                    PTY1Key: @([screenRect GetY1]),
                    PTX2Key: @([screenRect GetX2]),
                    PTY2Key: @([screenRect GetY2]),
                    PTWidthKey: @([screenRect Width]),
                    PTHeightKey: @([screenRect Height]),
            },
        };
        
        [self.plugin documentController:self annotationsSelected:[PdftronFlutterPlugin PT_idToJSONString:@[annotDict]]];
    }
}

- (void)toolManager:(PTToolManager *)toolManager formFieldDataModified:(PTAnnot *)annotation onPageNumber:(unsigned long)pageNumber {
    if (annotation.GetType == e_ptWidget) {
        NSError *error;
        
        __block NSString *fieldName;
        __block NSString *fieldValue;
        
        [self.pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * _Nullable doc) {
            PTWidget *widget = [[PTWidget alloc] initWithAnn:annotation];
            PTField *field = [widget GetField];
            fieldName = [field IsValid] ? [field GetName] : @"";
            fieldValue = [field IsValid] ? [field GetValueAsString] : @"";
        } error:&error];
        if (error) {
            NSLog(@"An error occurred: %@", error);
            return;
        }
        
        if (fieldName && fieldValue) {
            NSDictionary *fieldDict = @{
                PTFormFieldNameKey: fieldName,
                PTFormFieldValueKey: fieldValue,
            };
            
            [self.plugin documentController:self formFieldValueChanged:[PdftronFlutterPlugin PT_idToJSONString:@[fieldDict]]];
        }
        // TODO: collab manager
        /*
         copied from RN
         
         if (!self.collaborationManager) {
             PTVectorAnnot *annots = [[PTVectorAnnot alloc] init];
             [annots add:annot];
             [self rnt_sendExportAnnotationCommandWithAction:PTModifyAnnotationActionKey xfdfCommand:[self generateXfdfCommand:[[PTVectorAnnot alloc] init] modified:annots deleted:[[PTVectorAnnot alloc] init]]];
         }
         */
    }
}

- (BOOL)toolManager:(PTToolManager *)toolManager shouldShowMenu:(UIMenuController *)menuController forAnnotation:(PTAnnot *)annotation onPageNumber:(unsigned long)pageNumber
{
    BOOL result = [super toolManager:toolManager shouldShowMenu:menuController forAnnotation:annotation onPageNumber:pageNumber];
    if (!result) {
        return NO;
    }

    BOOL showMenu = YES;
    if (annotation) {
        showMenu = [self filterMenuItemsForAnnotationSelectionMenu:menuController forAnnotation:annotation];
    } else {
        showMenu = [self filterMenuItemsForLongPressMenu:menuController];
    }

    return showMenu;
}

- (BOOL)filterMenuItemsForAnnotationSelectionMenu:(UIMenuController *)menuController forAnnotation:(PTAnnot *)annot
{
    __block PTExtendedAnnotType annotType = PTExtendedAnnotTypeUnknown;

    NSError *error = nil;
    [self.pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc *doc) {
        if ([annot IsValid]) {
            annotType = annot.extendedAnnotType;
        }
    } error:&error];
    if (error) {
        NSLog(@"%@", error);
    }

    if ([self.hideAnnotMenuToolsAnnotTypes containsObject:@(annotType)]) {
        return NO;
    }

    NSString *editString = ([annot GetType] == e_ptFreeText) ? PTEditTextMenuItemIdentifierKey : PTEditInkMenuItemIdentifierKey;

    // Mapping from menu item title to identifier.
    NSDictionary<NSString *, NSString *> *map = @{
        PTStyleMenuItemTitleKey: PTStyleMenuItemIdentifierKey,
        PTNoteMenuItemTitleKey: PTNoteMenuItemIdentifierKey,
        PTCopyMenuItemTitleKey: PTCopyMenuItemIdentifierKey,
        PTDeleteMenuItemTitleKey: PTDeleteMenuItemIdentifierKey,
        PTTypeMenuItemTitleKey: PTTypeMenuItemIdentifierKey,
        PTSearchMenuItemTitleKey: PTSearchMenuItemIdentifierKey,
        PTEditMenuItemTitleKey: editString,
        PTFlattenMenuItemTitleKey: PTFlattenMenuItemIdentifierKey,
        PTOpenMenuItemTitleKey: PTOpenMenuItemIdentifierKey,
        PTCalibrateMenuItemTitleKey: PTCalibrateMenuItemIdentifierKey,
    };
    // Get the localized title for each menu item.
    NSMutableDictionary<NSString *, NSString *> *localizedMap = [NSMutableDictionary dictionary];
    for (NSString *key in map) {
        NSString *localizedKey = PTLocalizedString(key, nil);
        if (!localizedKey) {
            localizedKey = key;
        }
        localizedMap[localizedKey] = map[key];
    }

    NSMutableArray<UIMenuItem *> *permittedItems = [NSMutableArray array];

    for (UIMenuItem *menuItem in menuController.menuItems) {
        NSString *menuItemId = localizedMap[menuItem.title];

        if (!self.annotationMenuItems) {
            [permittedItems addObject:menuItem];
        }
        else {
            if (menuItemId && [self.annotationMenuItems containsObject:menuItemId]) {
                [permittedItems addObject:menuItem];
            }
        }

        // Override action of of overridden annotation menu items.
        if (menuItemId && [self.overrideAnnotationMenuBehavior containsObject:menuItemId]) {
            NSString *actionName = [NSString stringWithFormat:@"overriddenPressed_%@",
                                    menuItemId];
            const SEL selector = NSSelectorFromString(actionName);

            PT_addMethod([self class], selector, ^(id self) {
                [self overriddenAnnotationMenuItemPressed:menuItemId];
            });

            menuItem.action = selector;
        }
    }

    menuController.menuItems = [permittedItems copy];

    return YES;
}

- (BOOL)filterMenuItemsForLongPressMenu:(UIMenuController *)menuController {
    if (!self.longPressMenuEnabled) {
        menuController.menuItems = nil;
        return NO;
    }
    // Mapping from menu item title to identifier.
    NSDictionary<NSString *, NSString *> *map = @{
        PTCopyMenuItemTitleKey: PTCopyMenuItemIdentifierKey,
        PTSearchMenuItemTitleKey: PTSearchMenuItemIdentifierKey,
        PTShareMenuItemTitleKey: PTShareMenuItemIdentifierKey,
        PTReadMenuItemTitleKey: PTReadMenuItemIdentifierKey,
    };

    // Get the localized title for each menu item.
    NSMutableDictionary<NSString *, NSString *> *localizedMap = [NSMutableDictionary dictionary];
    for (NSString *key in map) {
        NSString *localizedKey = PTLocalizedString(key, nil);
        if (!localizedKey) {
            localizedKey = key;
        }
        localizedMap[localizedKey] = map[key];
    }

    NSMutableArray<UIMenuItem *> *permittedItems = [NSMutableArray array];
    for (UIMenuItem *menuItem in menuController.menuItems) {
        NSString *menuItemId = localizedMap[menuItem.title];

        if (!self.longPressMenuItems) {
            [permittedItems addObject:menuItem];
        }
        else {
            if (!menuItemId) {
                // If it is not one of copy, search, share and read, then it should be added
                [permittedItems addObject:menuItem];
            } else if ([self.longPressMenuItems containsObject:menuItemId]) {
                [permittedItems addObject:menuItem];
            }
        }

        // Override action of of overridden annotation menu items.
        if (menuItemId && [self.overrideLongPressMenuBehavior containsObject:menuItemId]) {

            NSString *actionName = [NSString stringWithFormat:@"overriddenPressed_%@",
                                    menuItemId];
            const SEL selector = NSSelectorFromString(actionName);

            PT_addMethod([self class], selector, ^(id self) {
                [self overriddenLongPressMenuItemPressed:menuItemId];
            });

            menuItem.action = selector;
        }
    }

    menuController.menuItems = [permittedItems copy];

    return YES;
}

- (void)overriddenAnnotationMenuItemPressed:(NSString *)menuItemId
{
    NSMutableArray<PTAnnot *> *annotations = [NSMutableArray array];

    if ([self.toolManager.tool isKindOfClass:[PTAnnotEditTool class]]) {
        PTAnnotEditTool *annotEdit = (PTAnnotEditTool *)self.toolManager.tool;
        if (annotEdit.selectedAnnotations.count > 0) {
            [annotations addObjectsFromArray:annotEdit.selectedAnnotations];
        }
    }
    else if (self.toolManager.tool.currentAnnotation) {
        [annotations addObject:self.toolManager.tool.currentAnnotation];
    }

    const int pageNumber = self.toolManager.tool.annotationPageNumber;

    NSArray *annotArray = [self generateAnnotationDictArray:annotations onPageNumber:pageNumber];

    NSDictionary* resultDict = @{
        PTAnnotationMenuItemKey: menuItemId,
        PTAnnotationListKey: annotArray,
    };

    [self.plugin documentController:self annotationMenuPressed:[PdftronFlutterPlugin PT_idToJSONString:resultDict]];
}

- (void)overriddenLongPressMenuItemPressed:(NSString *)menuItemId
{
    NSMutableString *selectedText = [NSMutableString string];

    NSError *error = nil;
    [self.pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc *doc) {
        if (![self.pdfViewCtrl HasSelection]) {
            return;
        }

        const int selectionBeginPage = self.pdfViewCtrl.selectionBeginPage;
        const int selectionEndPage = self.pdfViewCtrl.selectionEndPage;

        for (int pageNumber = selectionBeginPage; pageNumber <= selectionEndPage; pageNumber++) {
            if ([self.pdfViewCtrl HasSelectionOnPage:pageNumber]) {
                PTSelection *selection = [self.pdfViewCtrl GetSelection:pageNumber];
                NSString *selectionText = [selection GetAsUnicode];

                [selectedText appendString:selectionText];
            }
        }
    } error:&error];
    if (error) {
        NSLog(@"%@", error);
    }

    NSDictionary *resultDict = @{
        PTLongPressMenuItemKey: menuItemId,
        PTLongPressTextKey: selectedText,
    };

    [self.plugin documentController:self longPressMenuPressed:[PdftronFlutterPlugin PT_idToJSONString:resultDict]];
}


- (void)pdfViewCtrl:(PTPDFViewCtrl*)pdfViewCtrl pdfScrollViewDidZoom:(UIScrollView *)scrollView
{
    const double zoom = self.pdfViewCtrl.zoom * self.pdfViewCtrl.zoomScale;
    [self.plugin documentController:self zoomChanged:[NSNumber numberWithDouble:zoom]];
}

- (void)pdfViewCtrl:(PTPDFViewCtrl*)pdfViewCtrl pageNumberChangedFrom:(int)oldPageNumber To:(int)newPageNumber
{
    NSDictionary *resultDict = @{
        PTPreviousPageNumberKey: [NSNumber numberWithInt:oldPageNumber],
        PTPageNumberKey: [NSNumber numberWithInt:newPageNumber],
    };

    [self.plugin documentController:self pageChanged:[PdftronFlutterPlugin PT_idToJSONString:resultDict]];
}

-(NSString*)generateXfdfCommandWithAdded:(NSArray<PTAnnot*>*)added modified:(NSArray<PTAnnot*>*)modified removed:(NSArray<PTAnnot*>*)removed
{
    
    PTPDFDoc* pdfDoc = self.document;
    
    if (pdfDoc) {
        PTVectorAnnot* addedV = [[PTVectorAnnot alloc] init];
        for(PTAnnot* annot in added)
        {
            [addedV add:annot];
        }
        
        PTVectorAnnot* modifiedV = [[PTVectorAnnot alloc] init];
        for(PTAnnot* annot in modified)
        {
            [modifiedV add:annot];
        }
        
        PTVectorAnnot* removedV = [[PTVectorAnnot alloc] init];
        for(PTAnnot* annot in removed)
        {
            [removedV add:annot];
        }
        
        NSError *error;
        
        __block PTFDFDoc* fdfDoc;
        [self.pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * _Nullable doc) {
            fdfDoc = [pdfDoc FDFExtractCommand:addedV annot_modified:modifiedV annot_deleted:removedV];
        } error:&error];
        
        if (!error) {
            return [fdfDoc SaveAsXFDFToString];
        }
        NSLog(@"Error: %@", error.description);
    }
    return Nil;
}

-(NSString*)generateAnnotationsWithActionString:(NSArray<PTAnnot *> *)annotations onPageNumber:(unsigned long)pageNumber action:(NSString *)action
{
    
    NSArray<NSDictionary *>* annotDictArray = [self generateAnnotationDictArray:annotations onPageNumber:pageNumber];
    
    NSDictionary<NSString *, NSString *>* resultDict = @{
        PTAnnotationListKey : [PdftronFlutterPlugin PT_idToJSONString:annotDictArray],
        PTActionKey : action,
    };
    
    return [PdftronFlutterPlugin PT_idToJSONString:resultDict];
}

- (NSArray*)generateAnnotationDictArray:(NSArray<PTAnnot *> *)annotations onPageNumber:(unsigned long)pageNumber
{
    
    NSMutableArray<NSDictionary *>* resultArray = [[NSMutableArray alloc] init];
    
    for (PTAnnot * annotation in annotations) {
        if (annotation.IsValid) {
            
            __block NSString *uniqueId;
            
            NSError *error;
            [self.pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * _Nullable doc) {
                PTObj *uniqueIdObj = [annotation GetUniqueID];
                if ([uniqueIdObj IsValid] && [uniqueIdObj IsString]) {
                    uniqueId = [uniqueIdObj GetAsPDFText];
                }
            } error:&error];
            
            if (error) {
                NSLog(@"An error occurred: %@", error);
                return nil;
            }
            
            NSDictionary *annotDict = @{
                PTAnnotationIdKey: uniqueId,
                PTAnnotationPageNumberKey: [NSNumber numberWithLong:pageNumber],
            };
            
            [resultArray addObject:annotDict];
        }
    }
    return [resultArray copy];
}

-(PTExtendedAnnotType)convertAnnotationNameToAnnotType:(NSString*)annotationName
{
    NSDictionary<NSString *, NSNumber *>* typeMap = @{
        PTAnnotationCreateStickyToolKey : @(PTExtendedAnnotTypeText),
        PTStickyToolButtonKey : @(PTExtendedAnnotTypeText),
        PTAnnotationCreateFreeHandToolKey : @(PTExtendedAnnotTypeInk),
        PTAnnotationCreateTextHighlightToolKey : @(PTExtendedAnnotTypeHighlight),
        PTAnnotationCreateTextUnderlineToolKey : @(PTExtendedAnnotTypeUnderline),
        PTAnnotationCreateTextSquigglyToolKey : @(PTExtendedAnnotTypeSquiggly),
        PTAnnotationCreateTextStrikeoutToolKey : @(PTExtendedAnnotTypeStrikeOut),
        PTAnnotationCreateFreeTextToolKey : @(PTExtendedAnnotTypeFreeText),
        PTAnnotationCreateCalloutToolKey : @(PTExtendedAnnotTypeCallout),
        PTAnnotationCreateSignatureToolKey : @(PTExtendedAnnotTypeSignature),
        PTAnnotationCreateLineToolKey : @(PTExtendedAnnotTypeLine),
        PTAnnotationCreateArrowToolKey : @(PTExtendedAnnotTypeArrow),
        PTAnnotationCreatePolylineToolKey : @(PTExtendedAnnotTypePolyline),
        PTAnnotationCreateStampToolKey : @(PTExtendedAnnotTypeImageStamp),
        PTAnnotationCreateRectangleToolKey : @(PTExtendedAnnotTypeSquare),
        PTAnnotationCreateEllipseToolKey : @(PTExtendedAnnotTypeCircle),
        PTAnnotationCreatePolygonToolKey : @(PTExtendedAnnotTypePolygon),
        PTAnnotationCreatePolygonCloudToolKey : @(PTExtendedAnnotTypeCloudy),
        PTAnnotationCreateDistanceMeasurementToolKey : @(PTExtendedAnnotTypeRuler),
        PTAnnotationCreatePerimeterMeasurementToolKey : @(PTExtendedAnnotTypePerimeter),
        PTAnnotationCreateAreaMeasurementToolKey : @(PTExtendedAnnotTypeArea),
        PTAnnotationCreateFileAttachmentToolKey : @(PTExtendedAnnotTypeFileAttachment),
        PTAnnotationCreateSoundToolKey : @(PTExtendedAnnotTypeSound),
        PTAnnotationCreateFreeHighlighterToolKey : @(PTExtendedAnnotTypeFreehandHighlight),
//        @"FormCreateTextField" : @(),
//        @"FormCreateCheckboxField" : @(),
//        @"FormCreateRadioField" : @(),
//        @"FormCreateComboBoxField" : @(),
//        @"FormCreateListBoxField" : @()
    };

    PTExtendedAnnotType annotType = PTExtendedAnnotTypeUnknown;

    if( typeMap[annotationName] )
    {
        annotType = [typeMap[annotationName] unsignedIntValue];
    }

    return annotType;

}

- (BOOL)toolManager:(PTToolManager *)toolManager shouldHandleLinkAnnotation:(PTAnnot *)annotation orLinkInfo:(PTLinkInfo *)linkInfo onPageNumber:(unsigned long)pageNumber
{
    if (![self.overrideBehavior containsObject:PTLinkPressLinkAnnotationKey]) {
        return YES;
    }

    PTPDFViewCtrl *pdfViewCtrl = self.pdfViewCtrl;

    __block NSString *url = nil;

    NSError *error = nil;
    [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * _Nullable doc) {
        // Check for a valid link annotation.
        if (![annotation IsValid] ||
            annotation.extendedAnnotType != PTExtendedAnnotTypeLink) {
            return;
        }

        PTLink *linkAnnot = [[PTLink alloc] initWithAnn:annotation];

        // Check for a valid URI action.
        PTAction *action = [linkAnnot GetAction];
        if (![action IsValid] ||
            [action GetType] != e_ptURI) {
            return;
        }

        PTObj *actionObj = [action GetSDFObj];
        if (![actionObj IsValid]) {
            return;
        }

        // Get the action's URI.
        PTObj *uriObj = [actionObj FindObj:PTURILinkAnnotationKey];
        if ([uriObj IsValid] && [uriObj IsString]) {
            url = [uriObj GetAsPDFText];
        }
    } error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    if (url) {

        NSDictionary* behaviorDict = @{
            PTActionLinkAnnotationKey: PTLinkPressLinkAnnotationKey,
            PTDataLinkAnnotationKey: @{
                PTURLLinkAnnotationKey: url,
            },
        };

        [self.plugin documentController:self behaviorActivated:[PdftronFlutterPlugin PT_idToJSONString: behaviorDict]];
        // Link handled.
        return NO;
    }

    return YES;
}

#pragma mark - <PTPDFViewCtrlDelegate>

- (void)pdfViewCtrl:(PTPDFViewCtrl *)pdfViewCtrl onSetDoc:(PTPDFDoc *)doc
{
    [super pdfViewCtrl:pdfViewCtrl onSetDoc:doc];
    // to align with Android's document-opened-event timing.
    if (self.local && !self.documentLoaded) {
        self.needsDocumentLoaded = YES;
    }
    else if (!self.local && !self.documentLoaded && self.needsRemoteDocumentLoaded) {
        self.needsDocumentLoaded = YES;
    }
    else if (!self.local && !self.documentLoaded && self.coordinatedDocument.fileURL) {
        self.needsDocumentLoaded = YES;
    }
}

- (void)pdfViewCtrl:(PTPDFViewCtrl *)pdfViewCtrl downloadEventType:(PTDownloadedType)type pageNumber:(int)pageNum message:(NSString *)message
{
    if (type == e_ptdownloadedtype_finished && !self.documentLoaded) {
        self.needsRemoteDocumentLoaded = YES;
    }

    [super pdfViewCtrl:pdfViewCtrl downloadEventType:type pageNumber:pageNum message:message];
}

#pragma mark - <PTOutlineViewControllerDelegate>

- (void)outlineViewControllerDidCancel:(PTOutlineViewController *)outlineViewController
{
    [outlineViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - <PTAnnotationViewControllerDelegate>

- (void)annotationViewControllerDidCancel:(PTAnnotationViewController *)annotationViewController
{
    [annotationViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Viewer Settings

- (void)initViewerSettings
{
    _base64 = NO;
    _readOnly = NO;
    
    _showNavButton = YES;
    _longPressMenuEnabled = true;
    
    _annotationToolbarSwitcherHidden = NO;
    _topToolbarsHidden = NO;
    _topAppNavBarHidden = NO;
    _bottomToolbarHidden = NO;
    
    _readOnly = NO;
    
    _showNavButton = YES;
}

- (void)applyViewerSettings
{
    // Fit mode.
    [self applyFitMode];
    
    // nav icon
    [self applyNavIcon];
    
    // thumbnail filter mode
    [self applyHideThumbnailFilterModes];

    // Use Apple Pencil as a pen
    Class pencilTool = [PTFreeHandCreate class];
    if (@available(iOS 13.1, *)) {
        pencilTool = [PTPencilDrawingCreate class];
    }
    self.toolManager.pencilTool = self.useStylusAsPen ? pencilTool : [PTPanTool class];
    
    const BOOL hideNav = (self.topAppNavBarHidden || self.topToolbarsHidden);
    self.controlsHidden = hideNav;
    
    const BOOL translucent = hideNav;
    self.navigationController.navigationBar.translucent = translucent;
    self.thumbnailSliderController.toolbar.translucent = translucent;
    
    // Always enable the bottom toolbar. This is required for the custom checks in -controlsHidden
    // when the top toolbar(s) are disabled, to be able to still toggle the bottom toolbar.
    self.bottomToolbarEnabled = YES;
    
    // Always allow toggling toolbars on tap.
    BOOL hidesToolbarsOnTap = YES;
    self.hidesControlsOnTap = hidesToolbarsOnTap;
    
    [self applyToolGroupSettings];
}

- (void)applyFitMode
{
    if (!self.fitMode) {
        return;
    }
    
    if ([self.fitMode isEqualToString:PTFitPageKey]) {
        [self.pdfViewCtrl SetPageViewMode:e_trn_fit_page];
        [self.pdfViewCtrl SetPageRefViewMode:e_trn_fit_page];
    }
    else if ([self.fitMode isEqualToString:PTFitWidthKey]) {
        [self.pdfViewCtrl SetPageViewMode:e_trn_fit_width];
        [self.pdfViewCtrl SetPageRefViewMode:e_trn_fit_width];
    }
    else if ([self.fitMode isEqualToString:PTFitHeightKey]) {
        [self.pdfViewCtrl SetPageViewMode:e_trn_fit_height];
        [self.pdfViewCtrl SetPageRefViewMode:e_trn_fit_height];
    }
    else if ([self.fitMode isEqualToString:PTZoomKey]) {
        [self.pdfViewCtrl SetPageViewMode:e_trn_zoom];
        [self.pdfViewCtrl SetPageRefViewMode:e_trn_zoom];
    }
}

- (void)applyLayoutMode
{
    if ([self.layoutMode isEqualToString:PTSingleKey]) {
        [self.pdfViewCtrl SetPagePresentationMode:e_trn_single_page];
    }
    else if ([self.layoutMode isEqualToString:PTContinuousKey]) {
        [self.pdfViewCtrl SetPagePresentationMode:e_trn_single_continuous];
    }
    else if ([self.layoutMode isEqualToString:PTFacingKey]) {
        [self.pdfViewCtrl SetPagePresentationMode:e_trn_facing];
    }
    else if ([self.layoutMode isEqualToString:PTFacingContinuousKey]) {
        [self.pdfViewCtrl SetPagePresentationMode:e_trn_facing_continuous];
    }
    else if ([self.layoutMode isEqualToString:PTFacingCoverKey]) {
        [self.pdfViewCtrl SetPagePresentationMode:e_trn_facing_cover];
    }
    else if ([self.layoutMode isEqualToString:PTFacingCoverContinuousKey]) {
        [self.pdfViewCtrl SetPagePresentationMode:e_trn_facing_continuous_cover];
    }
}

- (void)applyNavIcon
{
    if (self.showNavButton) {
        UIBarButtonItem* navButton = navButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(topLeftButtonPressed:)];
        
        self.leadingNavButtonItem = navButton;
        
        NSArray<UIBarButtonItem *> *compactItems = [self.navigationItem leftBarButtonItemsForSizeClass:UIUserInterfaceSizeClassCompact];
        if (compactItems) {
            NSMutableArray<UIBarButtonItem *> *mutableItems = [compactItems mutableCopy];
            [mutableItems insertObject:navButton atIndex:0];
            compactItems = [mutableItems copy];
        } else {
            compactItems = @[navButton];
        }
        [self.navigationItem setLeftBarButtonItems:compactItems
                                            forSizeClass:UIUserInterfaceSizeClassCompact
                                                animated:NO];
        
        NSArray<UIBarButtonItem *> *regularItems = [self.navigationItem leftBarButtonItemsForSizeClass:UIUserInterfaceSizeClassRegular];
        if (regularItems) {
            NSMutableArray<UIBarButtonItem *> *mutableItems = [regularItems mutableCopy];
            [mutableItems insertObject:navButton atIndex:0];
            regularItems = [mutableItems copy];
        } else {
            regularItems = @[navButton];
        }
        [self.navigationItem setLeftBarButtonItems:regularItems
                                            forSizeClass:UIUserInterfaceSizeClassRegular
                                                animated:NO];
    }
}

- (void)applyHideThumbnailFilterModes
{
    NSMutableArray <PTFilterMode>* filterModeArray = [[NSMutableArray alloc] init];

    [filterModeArray addObject:PTThumbnailFilterAll];
    
    if (![self.hideThumbnailFilterModes containsObject:PTAnnotatedFilterModeKey]) {
        [filterModeArray addObject:PTThumbnailFilterAnnotated];
    }
    
    if (![self.hideThumbnailFilterModes containsObject:PTBookmarkedFilterModeKey]) {
        [filterModeArray addObject:PTThumbnailFilterBookmarked];
    }

    NSOrderedSet* filterModeSet = [[NSOrderedSet alloc] initWithArray:filterModeArray];
    self.thumbnailsViewController.filterModes = filterModeSet;
}

- (void)applyToolGroupSettings
{
    PTToolGroupManager *toolGroupManager = self.toolGroupManager;
    
    self.toolGroupsEnabled = !self.topToolbarsHidden;
    if ([self areToolGroupsEnabled]) {
        NSMutableArray<PTToolGroup *> *toolGroups = [toolGroupManager.groups mutableCopy];
        
        // Handle annotationToolbars.
        if (self.annotationToolbars.count > 0) {
            // Clear default/previous tool groups.
            [toolGroups removeAllObjects];
            
            for (id annotationToolbarValue in self.annotationToolbars) {
                
                if ([annotationToolbarValue isKindOfClass:[NSString class]]) {
                    // Default annotation toolbar key.
                    PTDefaultAnnotationToolbarKey annotationToolbar = (NSString *)annotationToolbarValue;
                    
                    PTToolGroup *toolGroup = [self toolGroupForKey:annotationToolbar
                                                  toolGroupManager:toolGroupManager];
                    if (toolGroup) {
                        [toolGroups addObject:toolGroup];
                    }
                }
                else if ([annotationToolbarValue isKindOfClass:[NSDictionary class]]) {
                    // Custom annotation toolbar dictionary.
                    NSDictionary<NSString *, id> *annotationToolbar = (NSDictionary *)annotationToolbarValue;
                    
                    PTToolGroup *toolGroup = [self createToolGroupWithDictionary:annotationToolbar
                                                                toolGroupManager:toolGroupManager];
                    [toolGroups addObject:toolGroup];
                }
            }
        }
        
        // Handle hideDefaultAnnotationToolbars.
        if (self.hideDefaultAnnotationToolbars.count > 0) {
            NSMutableArray<PTToolGroup *> *toolGroupsToRemove = [NSMutableArray array];
            for (NSString *defaultAnnotationToolbar in self.hideDefaultAnnotationToolbars) {
                if (![defaultAnnotationToolbar isKindOfClass:[NSString class]]) {
                    continue;
                }
                PTToolGroup *matchingGroup = [self toolGroupForKey:defaultAnnotationToolbar
                                                  toolGroupManager:toolGroupManager];
                if (matchingGroup) {
                    [toolGroupsToRemove addObject:matchingGroup];
                }
            }
            // Remove the indicated tool group(s).
            if (toolGroupsToRemove.count > 0) {
                [toolGroups removeObjectsInArray:toolGroupsToRemove];
            }
        }
        
        if (![toolGroupManager.groups isEqualToArray:toolGroups]) {
            toolGroupManager.groups = toolGroups;
        }
    }
    
    if (self.annotationToolbarSwitcherHidden) {
        self.navigationItem.titleView = [[UIView alloc] init];
    } else {
        if ([self areToolGroupsEnabled] && toolGroupManager.groups.count > 0) {
            self.navigationItem.titleView = self.toolGroupIndicatorView;
        } else {
            self.navigationItem.titleView = nil;
        }
    }
}

- (PTToolGroup *)toolGroupForKey:(PTDefaultAnnotationToolbarKey)key toolGroupManager:(PTToolGroupManager *)toolGroupManager
{
    NSDictionary<PTDefaultAnnotationToolbarKey, PTToolGroup *> *toolGroupMap = @{
        PTAnnotationToolbarView: toolGroupManager.viewItemGroup,
        PTAnnotationToolbarAnnotate: toolGroupManager.annotateItemGroup,
        PTAnnotationToolbarDraw: toolGroupManager.drawItemGroup,
        PTAnnotationToolbarInsert: toolGroupManager.insertItemGroup,
        //PTAnnotationToolbarFillAndSign: [NSNull null], // not implemented
        //PTAnnotationToolbarPrepareForm: [NSNull null], // not implemented
        PTAnnotationToolbarMeasure: toolGroupManager.measureItemGroup,
        //PTAnnotationToolbarRedaction: [NSNull null], // not implemented
        PTAnnotationToolbarPens: toolGroupManager.pensItemGroup,
        PTAnnotationToolbarFavorite: toolGroupManager.favoritesItemGroup,
    };

    return toolGroupMap[key];
}

- (PTToolGroup *)createToolGroupWithDictionary:(NSDictionary<NSString *, id> *)dictionary toolGroupManager:(PTToolGroupManager *)toolGroupManager
{
    NSString *toolbarId = dictionary[PTAnnotationToolbarKeyId];
    NSString *toolbarName = dictionary[PTAnnotationToolbarKeyName];
    NSString *toolbarIcon = dictionary[PTAnnotationToolbarKeyIcon];
    NSArray<NSString *> *toolbarItems = [PdftronFlutterPlugin PT_JSONStringToId:dictionary[PTAnnotationToolbarKeyItems]];
    
    UIImage *toolbarImage = nil;
    if (toolbarIcon) {
        PTToolGroup *defaultGroup = [self toolGroupForKey:toolbarIcon
                                         toolGroupManager:toolGroupManager];
        toolbarImage = defaultGroup.image;
    }
    
    NSMutableArray<UIBarButtonItem *> *barButtonItems = [NSMutableArray array];
    
    for (NSString *toolbarItem in toolbarItems) {
        if (![toolbarItem isKindOfClass:[NSString class]]) {
            continue;
        }
        
        Class toolClass = [PdftronFlutterPlugin toolClassForKey:toolbarItem];
        if (!toolClass) {
            continue;
        }
        
        UIBarButtonItem *item = [toolGroupManager createItemForToolClass:toolClass];
        if (item) {
            [barButtonItems addObject:item];
        }
    }
    
    PTToolGroup *toolGroup = [PTToolGroup groupWithTitle:toolbarName
                                                   image:toolbarImage
                                          barButtonItems:[barButtonItems copy]];
    toolGroup.identifier = toolbarId;

    return toolGroup;
}

- (void)setHideAnnotMenuTools:(NSArray<NSNumber *> *)hideAnnotMenuTools
{
    _hideAnnotMenuTools = [hideAnnotMenuTools copy];

    NSMutableArray* hideMenuTools = [[NSMutableArray alloc] init];

    for (NSString* hideMenuTool in hideAnnotMenuTools) {
        PTExtendedAnnotType toolTypeToHide = [self convertAnnotationNameToAnnotType:hideMenuTool];
        [hideMenuTools addObject:@(toolTypeToHide)];
    }

    _hideAnnotMenuToolsAnnotTypes = [hideMenuTools copy];
}

- (void)setAutoSaveEnabled:(BOOL)autoSaveEnabled
{
    self.automaticallySavesDocument = autoSaveEnabled;
}

- (BOOL)isAutoSaveEnabled
{
    return self.automaticallySavesDocument;
}

- (void)setPageChangesOnTap:(BOOL)pageChangesOnTap
{
    self.changesPageOnTap = pageChangesOnTap;
}

- (BOOL)pageChangesOnTap
{
    return self.changesPageOnTap;
}

- (void)setShowSavedSignatures:(BOOL)showSavedSignatures
{
    self.toolManager.showDefaultSignature = showSavedSignatures;
}

- (BOOL)showSavedSignatures
{
    return self.toolManager.showDefaultSignature;
}

- (void)setSignSignatureFieldsWithStamps:(BOOL)signSignatureFieldsWithStamps
{
    self.toolManager.signatureAnnotationOptions.signSignatureFieldsWithStamps = signSignatureFieldsWithStamps;
}

- (BOOL)signSignatureFieldsWithStamps
{
    return self.toolManager.signatureAnnotationOptions.signSignatureFieldsWithStamps;
}

- (void)setSelectAnnotationAfterCreation:(BOOL)selectAnnotationAfterCreation
{
    self.toolManager.selectAnnotationAfterCreation = selectAnnotationAfterCreation;
}

- (BOOL)selectAnnotationAfterCreation
{
    return self.toolManager.selectAnnotationAfterCreation;
}

- (void)setThumbnailEditingEnabled:(BOOL)thumbnailEditingEnabled
{
    self.thumbnailsViewController.editingEnabled = thumbnailEditingEnabled;
}

- (BOOL)isThumbnailEditingEnabled
{
    return self.thumbnailsViewController.editingEnabled;
}

- (void)setContinuousAnnotationEditingEnabled:(BOOL)continuousAnnotationEditing
{
    self.toolManager.tool.backToPanToolAfterUse = !continuousAnnotationEditing;
}

- (BOOL)isContinuousAnnotationEditing
{
    return !self.toolManager.tool.backToPanToolAfterUse;
}

- (NSString *)annotationAuthor
{
    return self.toolManager.annotationAuthor;
}

- (void)setAnnotationAuthor:(NSString *)annotationAuthor
{
    self.toolManager.annotationAuthor = annotationAuthor;
}

- (void)setAnnotationPermissionCheckEnabled:(BOOL)annotationPermissionCheckEnabled
{
    self.toolManager.annotationPermissionCheckEnabled = annotationPermissionCheckEnabled;
}

- (BOOL)isAnnotationPermissionCheckEnabled
{
    return self.toolManager.isAnnotationPermissionCheckEnabled;
}

- (NSString *)tabTitle
{
    return self.documentTabItem.displayName;
}

- (void)setTabTitle:(NSString *)tabTitle
{
    self.documentTabItem.displayName = tabTitle;
}

#pragma mark - Other

- (void)topLeftButtonPressed:(UIBarButtonItem *)barButtonItem
{
    [self.plugin topLeftButtonPressed:barButtonItem];
}

- (void)setLeadingNavButtonIcon:(NSString *)leadingNavButtonIcon
{
    _leadingNavButtonIcon = leadingNavButtonIcon;
    
    if (self.showNavButton) {
        UIImage *navImage = [UIImage imageNamed:leadingNavButtonIcon];
        if (navImage) {
            UIBarButtonItem* navButton = self.leadingNavButtonItem;
            if ([navButton image]) {
                [navButton setImage:navImage];
            } else {
                navButton = [[UIBarButtonItem alloc] initWithImage:navImage
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(topLeftButtonPressed:)];
                
                self.leadingNavButtonItem = navButton;
                
                NSArray<UIBarButtonItem *> *compactItems = [self.navigationItem leftBarButtonItemsForSizeClass:UIUserInterfaceSizeClassCompact];
                if (compactItems) {
                    NSMutableArray<UIBarButtonItem *> *mutableItems = [compactItems mutableCopy];
                    [mutableItems removeObjectAtIndex:0];
                    [mutableItems insertObject:navButton atIndex:0];
                    compactItems = [mutableItems copy];
                } else {
                    compactItems = @[navButton];
                }
                
                [self.navigationItem setLeftBarButtonItems:compactItems
                                                    forSizeClass:UIUserInterfaceSizeClassCompact
                                                        animated:NO];
                
                NSArray<UIBarButtonItem *> *regularItems = [self.navigationItem leftBarButtonItemsForSizeClass:UIUserInterfaceSizeClassRegular];
                if (regularItems) {
                    NSMutableArray<UIBarButtonItem *> *mutableItems = [regularItems mutableCopy];
                    [mutableItems removeObjectAtIndex:0];
                    [mutableItems insertObject:navButton atIndex:0];
                    regularItems = [mutableItems copy];
                } else {
                    regularItems = @[navButton];
                }
                
                [self.navigationItem setLeftBarButtonItems:regularItems
                                                    forSizeClass:UIUserInterfaceSizeClassRegular
                                                        animated:NO];
            }
        }
    }
}

- (BOOL)shouldSetNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated
{
    if (!navigationBarHidden) {
        return [self isTopToolbarEnabled];
    }
    return YES;
}

- (BOOL)shouldSetToolbarHidden:(BOOL)toolbarHidden animated:(BOOL)animated
{
    if (!toolbarHidden) {
        return ![self isBottomToolbarHidden];
    }
    return YES;
}

@end

#pragma mark - FLThumbnailsViewController
@implementation FLThumbnailsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = !self.editingEnabled;
}

@end

#pragma mark - PTFlutterTabbedDocumentController
@implementation PTFlutterTabbedDocumentController

// For base64 temp file deletion
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.tempFiles) {
        for (NSString* path in self.tempFiles) {
            NSError* error;
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];

            if (error) {
                NSLog(@"Error: There was an error while deleting the temporary file for base64. %@", error.localizedDescription);
            }
        }
        [self.tempFiles removeAllObjects];
    }
}

@end
