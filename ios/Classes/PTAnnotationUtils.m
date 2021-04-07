#import "PTAnnotationUtils.h"
#import "PdftronFlutterPlugin.h"

@implementation PTAnnotationUtils

+ (PTAnnot *)getAnnotFromDict:(NSDictionary *)annotationDict document:(PTPDFDoc *)document
{
    if (!annotationDict) {
        return nil;
    }
    
    if (![PdftronFlutterPlugin dictHasKeys:annotationDict keys:@[PTAnnotPageNumberKey, PTAnnotRectKey, PTAnnotMarkupKey]]) {
        return nil;
    }
    
    NSNumber* pageNumber = [PdftronFlutterPlugin PT_idAsNSNumber:annotationDict[PTAnnotPageNumberKey]];
    
    PTPage* page = [document GetPage:[pageNumber unsignedIntValue]];
    
    if (!page || ![page IsValid]) {
        return nil;
    }
    
    bool markup = [PdftronFlutterPlugin PT_idAsBool:annotationDict[PTAnnotMarkupKey]];
    
    PTAnnot* annot;
    
    if (markup) {
        annot = [self getMarkupFromDict:annotationDict document:document];
        if (!annot) {
            return nil;
        }
    } else {
        return nil;
    }
    
    if ([PdftronFlutterPlugin dictHasKeys:annotationDict keys:@[PTAnnotIdKey]]) {
        NSString* uniqueId = [PdftronFlutterPlugin PT_idAsNSString:annotationDict[PTAnnotIdKey]];
        [annot SetUniqueID:uniqueId id_buf_sz:(int)[uniqueId length]];
    } else {
        NSString* uniqueId = [[NSUUID UUID] UUIDString];
        [annot SetUniqueID:uniqueId id_buf_sz:(int)[uniqueId length]];
    }
    
    if ([PdftronFlutterPlugin dictHasKeys:annotationDict keys:@[PTAnnotBorderStyleObjectKey]]) {
        PTBorderStyle* borderStyleObject = [self getBorderStyleObjectFromDict:[PdftronFlutterPlugin PT_idAsNSDict:annotationDict[PTAnnotBorderStyleObjectKey]]];
        
        if (borderStyleObject) {
            [annot SetBorderStyle:borderStyleObject oldStyleOnly:NO];
        }
    }
    
    if ([PdftronFlutterPlugin dictHasKeys:annotationDict keys:@[PTAnnotRotationKey]]) {
        int rotation = [[PdftronFlutterPlugin PT_idAsNSNumber:annotationDict[PTAnnotRotationKey]] intValue];
        [annot SetRotation:rotation];
    }
    
    if ([PdftronFlutterPlugin dictHasKeys:annotationDict keys:@[PTAnnotCustomDataKey]]) {
        NSDictionary* customData = [PdftronFlutterPlugin PT_idAsNSDict:annotationDict[PTAnnotCustomDataKey]];
        
        for (NSString* key in [customData allKeys]) {
            [annot SetCustomData:key value:customData[key]];
        }
    }
    
    if ([PdftronFlutterPlugin dictHasKeys:annotationDict keys:@[PTAnnotContentsKey]]) {
        NSString* contents = [PdftronFlutterPlugin PT_idAsNSString:annotationDict[PTAnnotContentsKey]];
        [annot SetContents:contents];
    }

    if ([PdftronFlutterPlugin dictHasKeys:annotationDict keys:@[PTAnnotColorKey]]) {
        PTColorPt *color = [self getColorPtFromDict:[PdftronFlutterPlugin PT_idAsNSDict:annotationDict[PTAnnotColorKey]]];
        
        if (color) {
            [annot SetColor:color numcomp:PTNumColorSpace];
        }
    }
    
    [annot SetPage:page];
    
    return annot;
}

+ (PTMarkup *)getMarkupFromDict:(NSDictionary *)annotationDict document:(PTPDFDoc *)document
{
    PTMarkup* markupAnnot;
    
    if (![PdftronFlutterPlugin dictHasKeys:annotationDict keys:@[PTMarkupTypeKey]]) {
        return nil;
    }
    
    NSString *markupType = [PdftronFlutterPlugin PT_idAsNSString:annotationDict[PTMarkupTypeKey]];
    if ([markupType isEqualToString:PTMarkupTypeFreeTextKey]) {
        markupAnnot = [self getFreeTextFromDict:annotationDict document:document];
        if (!markupAnnot) {
            return nil;
        }
    } else {
        return nil;
    }
    
    if ([PdftronFlutterPlugin dictHasKeys:annotationDict keys:@[PTMarkupTitleKey]]) {
        NSString *title = [PdftronFlutterPlugin PT_idAsNSString:annotationDict[PTMarkupTitleKey]];
        [markupAnnot SetTitle:title];
    }
    
    if ([PdftronFlutterPlugin dictHasKeys:annotationDict keys:@[PTMarkupSubjectKey]]) {
        NSString *subject = [PdftronFlutterPlugin PT_idAsNSString:annotationDict[PTMarkupSubjectKey]];
        [markupAnnot SetSubject:subject];
    }
    
    if ([PdftronFlutterPlugin dictHasKeys:annotationDict keys:@[PTMarkupOpacityKey]]) {
        double opacity = [[PdftronFlutterPlugin PT_idAsNSNumber:annotationDict[PTMarkupOpacityKey]] doubleValue];
        [markupAnnot SetOpacity:opacity];
    }
    
    if ([PdftronFlutterPlugin dictHasKeys:annotationDict keys:@[PTMarkupBorderEffectKey]]) {
        NSString *borderEffect = [PdftronFlutterPlugin PT_idAsNSString:annotationDict[PTMarkupBorderEffectKey]];
        
        if ([borderEffect isEqualToString:PTBorderEffectNoneKey]) {
            [markupAnnot SetBorderEffect:e_ptNone];
        } else if ([borderEffect isEqualToString:PTBorderEffectCloudyKey]) {
            [markupAnnot SetBorderEffect:e_ptCloudy];
        }
    }
    
    if ([PdftronFlutterPlugin dictHasKeys:annotationDict keys:@[PTMarkupBorderEffectIntensityKey]]) {
        double borderEffectIntensity = [[PdftronFlutterPlugin PT_idAsNSNumber:annotationDict[PTMarkupBorderEffectIntensityKey]] doubleValue];
        [markupAnnot SetBorderEffectIntensity:borderEffectIntensity];
    }
    
    if ([PdftronFlutterPlugin dictHasKeys:annotationDict keys:@[PTMarkupInteriorColorKey]]) {
        PTColorPt *interiorColor = [self getColorPtFromDict:[PdftronFlutterPlugin PT_idAsNSDict:annotationDict[PTMarkupInteriorColorKey]]];
        
        if (interiorColor) {
            [markupAnnot SetInteriorColor:interiorColor CompNum:PTNumColorSpace];
        }
    }
    
    if ([PdftronFlutterPlugin dictHasKeys:annotationDict keys:@[PTMarkupContentRectKey]]) {
        PTPDFRect* contentRect = [self getRectFromDict:[PdftronFlutterPlugin PT_idAsNSDict:annotationDict[PTMarkupContentRectKey]]];
        
        if (contentRect) {
            [markupAnnot SetContentRect:contentRect];
        }
    }
    
    if ([PdftronFlutterPlugin dictHasKeys:annotationDict keys:@[PTMarkupPaddingRectKey]]) {
        PTPDFRect* paddingRect = [self getRectFromDict:[PdftronFlutterPlugin PT_idAsNSDict:annotationDict[PTMarkupPaddingRectKey]]];
        
        if (paddingRect) {
            [markupAnnot SetPaddingWithRect:paddingRect];
        }
    }
    
    return markupAnnot;
}

+ (PTFreeText *)getFreeTextFromDict:(NSDictionary *)annotationDict document:(PTPDFDoc *)document
{
    PTPDFRect* rect = [self getRectFromDict:[PdftronFlutterPlugin PT_idAsNSDict:annotationDict[PTAnnotRectKey]]];
    
    if (!rect) {
        return nil;
    }
    
    PTFreeText* freeText = [PTFreeText Create:[document GetSDFDoc] pos:rect];
    
    if ([PdftronFlutterPlugin dictHasKeys:annotationDict keys:@[PTFreeTextQuaddingFormatKey]]) {
        NSString *quaddingFormatString = [PdftronFlutterPlugin PT_idAsNSString:annotationDict[PTFreeTextQuaddingFormatKey]];
        
        if ([quaddingFormatString isEqualToString:PTQuaddingFormatLeftJustifiedKey]) {
            [freeText SetQuaddingFormat:0];
        } else if ([quaddingFormatString isEqualToString:PTQuaddingFormatCenteredKey]) {
            [freeText SetQuaddingFormat:1];
        } else if ([quaddingFormatString isEqualToString:PTQuaddingFormatRightJustifiedKey]) {
            [freeText SetQuaddingFormat:2];
        }
    }
    
    if ([PdftronFlutterPlugin dictHasKeys:annotationDict keys:@[PTFreeTextIntentNameKey]]) {
        NSString *intentName = [PdftronFlutterPlugin PT_idAsNSString:annotationDict[PTFreeTextIntentNameKey]];
        
        if ([intentName isEqualToString:PTIntentNameFreeTextKey]) {
            [freeText SetIntentName:e_ptf_FreeText];
        } else if ([intentName isEqualToString:PTIntentNameFreeTextCalloutKey]) {
            [freeText SetIntentName:e_ptFreeTextCallout];
        } else if ([intentName isEqualToString:PTIntentNameFreeTextTypeWriterKey]) {
            [freeText SetIntentName:e_ptFreeTextTypeWriter];
        }
    }
    
    if ([PdftronFlutterPlugin dictHasKeys:annotationDict keys:@[PTFreeTextTextColorKey]]) {
        PTColorPt *textColor = [self getColorPtFromDict:[PdftronFlutterPlugin PT_idAsNSDict:annotationDict[PTFreeTextTextColorKey]]];
        
        if (textColor) {
            [freeText SetTextColor:textColor col_comp:PTNumColorSpace];
        }
    }
    
    if ([PdftronFlutterPlugin dictHasKeys:annotationDict keys:@[PTFreeTextLineColorKey]]) {
        PTColorPt *lineColor = [self getColorPtFromDict:[PdftronFlutterPlugin PT_idAsNSDict:annotationDict[PTFreeTextLineColorKey]]];
        
        if (lineColor) {
            [freeText SetLineColor:lineColor col_comp:PTNumColorSpace];
        }
    }
    
    if ([PdftronFlutterPlugin dictHasKeys:annotationDict keys:@[PTFreeTextFontSizeKey]]) {
        double fontSize = [[PdftronFlutterPlugin PT_idAsNSNumber:annotationDict[PTFreeTextFontSizeKey]] doubleValue];
        
        [freeText SetFontSize:fontSize];
    }
        
    return freeText;
}

+ (PTPDFRect *)getRectFromDict:(NSDictionary *)rectDict
{
    if (![PdftronFlutterPlugin dictHasKeys:rectDict keys:@[PTX1Key, PTY1Key, PTX2Key, PTY2Key]]) {
        return nil;
    }
    
    double x1 = [[PdftronFlutterPlugin PT_idAsNSNumber:rectDict[PTX1Key]] doubleValue];
    double y1 = [[PdftronFlutterPlugin PT_idAsNSNumber:rectDict[PTY1Key]] doubleValue];
    double x2 = [[PdftronFlutterPlugin PT_idAsNSNumber:rectDict[PTX2Key]] doubleValue];
    double y2 = [[PdftronFlutterPlugin PT_idAsNSNumber:rectDict[PTY2Key]] doubleValue];
    
    return [[PTPDFRect alloc] initWithX1:x1 y1:y1 x2:x2 y2:y2];
}

+ (PTBorderStyle *)getBorderStyleObjectFromDict:(NSDictionary *)borderDict
{
    if (![PdftronFlutterPlugin dictHasKeys:borderDict keys:@[PTBorderStyleObjectStyleKey, PTBorderStyleObjectVerticalCornerRadiusKey, PTBorderStyleObjectVerticalCornerRadiusKey, PTBorderStyleObjectWidthKey]]) {
        return nil;
    }
    
    NSString *style = [PdftronFlutterPlugin PT_idAsNSString:borderDict[PTBorderStyleObjectStyleKey]];
    
    PTBdStyle borderStyle;
    if ([style isEqualToString:PTBorderStyleSolidKey]) {
        borderStyle = e_ptsolid;
    } else if ([style isEqualToString:PTBorderStyleInsetKey]) {
        borderStyle = e_ptinset;
    } else if ([style isEqualToString:PTBorderStyleDashedKey]) {
        borderStyle = e_ptdashed;
    } else if ([style isEqualToString:PTBorderStyleBeveledKey]) {
        borderStyle = e_ptbeveled;
    } else if ([style isEqualToString:PTBorderStyleUnderlineKey]) {
        borderStyle = e_ptunderline;
    } else {
        return nil;
    }
    
    double horizontalRadius = [[PdftronFlutterPlugin PT_idAsNSNumber:borderDict[PTBorderStyleObjectHorizontalCornerRadiusKey]] doubleValue];
    double verticalRadius = [[PdftronFlutterPlugin PT_idAsNSNumber:borderDict[PTBorderStyleObjectVerticalCornerRadiusKey]] doubleValue];
    double width = [[PdftronFlutterPlugin PT_idAsNSNumber:borderDict[PTBorderStyleObjectWidthKey]] doubleValue];
    
    if ([PdftronFlutterPlugin dictHasKeys:borderDict keys:@[PTBorderStyleObjectDashPatternKey]]) {
        NSArray* dashPattern = [PdftronFlutterPlugin
        PT_idAsArray:borderDict[PTBorderStyleObjectDashPatternKey]];
        
        return [[PTBorderStyle alloc] initWithS:borderStyle b_width:width b_hr:horizontalRadius b_vr:verticalRadius b_dash:[dashPattern mutableCopy]];
    }
    return [[PTBorderStyle alloc] initWithS:borderStyle b_width:width b_hr:horizontalRadius b_vr:verticalRadius];
}

+ (PTColorPt *)getColorPtFromDict:(NSDictionary *)colorDict
{
    if (![PdftronFlutterPlugin dictHasKeys:colorDict keys:@[PTColorRedKey, PTColorGreenKey, PTColorBlueKey]]) {
        return nil;
    }
    
    double red = [[PdftronFlutterPlugin PT_idAsNSNumber:colorDict[PTColorRedKey]] doubleValue];
    double green = [[PdftronFlutterPlugin PT_idAsNSNumber:colorDict[PTColorGreenKey]] doubleValue];
    double blue = [[PdftronFlutterPlugin PT_idAsNSNumber:colorDict[PTColorBlueKey]] doubleValue];
    
    return [[PTColorPt alloc] initWithX:red y:green z:blue w:0];
}

@end
