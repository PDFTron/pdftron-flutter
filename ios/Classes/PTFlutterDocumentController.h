#import <Flutter/Flutter.h>
#import <PDFNet/PDFNet.h>
#import <Tools/Tools.h>
#import "PdftronFlutterPlugin.h"

NS_ASSUME_NONNULL_BEGIN

@interface PTFlutterDocumentController : PTDocumentController

@property (nonatomic, strong) FlutterResult openResult;
@property (nonatomic, weak) PdftronFlutterPlugin* plugin;

@property (nonatomic) BOOL local;
@property (nonatomic) BOOL needsDocumentLoaded;
@property (nonatomic) BOOL needsRemoteDocumentLoaded;
@property (nonatomic) BOOL documentLoaded;

// viewer options
@property (nonatomic, copy, nullable) NSString* layoutMode;
@property (nonatomic, copy, nullable) NSString* fitMode;
@property (nonatomic, assign) int initialPageNumber;
@property (nonatomic, assign, getter=isBase64) BOOL base64;
@property (nonatomic, copy, nullable) NSArray <NSString *> *hideThumbnailFilterModes;

// long-press menu customization
@property (nonatomic, assign, getter=isLongPressMenuEnabled) BOOL longPressMenuEnabled;
@property (nonatomic, copy, nullable) NSArray<NSString*>* longPressMenuItems;
@property (nonatomic, copy, nullable) NSArray<NSString*>* overrideLongPressMenuBehavior;

// annotation selection menu customization
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *hideAnnotMenuTools;
@property (nonatomic, copy, nullable) NSArray<NSString*>* annotationMenuItems;
@property (nonatomic, copy, nullable) NSArray<NSString*>* overrideAnnotationMenuBehavior;

@property (nonatomic, assign, getter=isAutoSaveEnabled) BOOL autoSaveEnabled;
@property (nonatomic, assign) BOOL pageChangesOnTap;
@property (nonatomic, assign) BOOL useStylusAsPen;
@property (nonatomic, assign) BOOL showSavedSignatures;
@property (nonatomic, assign) BOOL signSignatureFieldsWithStamps;
@property (nonatomic, assign) BOOL selectAnnotationAfterCreation;
@property (nonatomic, assign, getter=isBottomToolbarOn) BOOL bottomToolbarOn;

@property (nonatomic, copy, nullable) NSArray<NSString *> * annotationToolbars;
@property (nonatomic, copy, nullable) NSArray<NSString *> * hideDefaultAnnotationToolbars;
@property (nonatomic, assign, getter=isAnnotationToolbarSwitcherHidden) BOOL annotationToolbarSwitcherHidden; // hideAnnotationToolbarSwitcher configuration option
@property (nonatomic, assign, getter=isTopToolbarsHidden) BOOL topToolbarsHidden; // hideTopToolbars configuration option
@property (nonatomic, assign, getter=isTopAppNavBarHidden) BOOL topAppNavBarHidden; // hideTopAppNavBar configuration option
@property (nonatomic, assign, getter=isBottomToolbarHidden) BOOL bottomToolbarHidden; // bottomToolbarEnabled configuration option
@property (nonatomic, assign) BOOL showNavButton;

@property (nonatomic, assign, getter=isReadOnly) BOOL readOnly;
@property (nonatomic, assign, getter=isThumbnailEditingEnabled) BOOL thumbnailEditingEnabled;
@property (nonatomic, assign, getter=isContinuousAnnotationEditingEnabled) BOOL continuousAnnotationEditingEnabled; // continuousAnnotationEditing configuration option

@property (nonatomic, copy, nullable) NSString* annotationAuthor;

@property (nonatomic, assign, getter=isAnnotationPermissionCheckEnabled) BOOL annotationPermissionCheckEnabled;

@property (nonatomic, copy, nullable) NSArray<NSString *> *overrideBehavior;

@property (nonatomic, copy, nullable) NSString* leadingNavButtonIcon;

@property (nonatomic, copy, nullable) NSString* tabTitle;

@property (nonatomic, copy, nullable) NSArray<NSString*>* uneditableAnnotTypes;

- (void)initViewerSettings;
- (void)applyViewerSettings;

- (void)setLeadingNavButtonIcon:(NSString *)leadingNavButtonIcon;

- (BOOL)shouldSetNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated;
- (BOOL)shouldSetToolbarHidden:(BOOL)toolbarHidden animated:(BOOL)animated;

@end

@interface FLThumbnailsViewController : PTThumbnailsViewController

@end

@interface PTFlutterTabbedDocumentController: PTTabbedDocumentViewController

@property (nonatomic, retain) NSMutableArray *tempFiles;
@end

NS_ASSUME_NONNULL_END
