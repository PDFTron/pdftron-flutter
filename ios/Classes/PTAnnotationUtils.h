#import <Flutter/Flutter.h>
#import <PDFNet/PDFNet.h>
#import <Tools/Tools.h>
#import "PTAnnotationUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface PTAnnotationUtils : NSObject

+ (PTAnnot *)getAnnotFromDict:(NSDictionary *)annotationDict document:(PTPDFDoc *)document;

@end

NS_ASSUME_NONNULL_END

