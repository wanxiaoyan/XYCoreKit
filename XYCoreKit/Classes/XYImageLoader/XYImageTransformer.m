//
//  XYImageTransformer.m
//  CodeTest
//
//  Created by 万晓迪 on 2026/3/28.
//

#import "XYImageTransformer.h"
#import "XYImageLoaderConfig.h"

#define XYImageLoaderLog(format, ...) \
    if ([XYImageLoaderConfig shareConfig].enableLog) { \
        NSLog(@"[XYImageLoader] " format, ##__VA_ARGS__); \
    }

@interface XYImageDownsamplingTransformer()

@property (nonatomic, assign) CGSize targetSize;

@end

@implementation XYImageDownsamplingTransformer


+ (instancetype)transformerWithTargetSize:(CGSize)targetSize {
    return  [[self alloc] initWithTargetSize:targetSize];
}

- (instancetype)initWithTargetSize:(CGSize)targetSize {
    self = [super init];
    if (self) {
        _targetSize = targetSize;
    }
    return self;
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key
{
    if (!image) return nil;
    
    if (CGSizeEqualToSize(self.targetSize, CGSizeZero))
    {
        return image;
    }
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize pixelSize = CGSizeMake(self.targetSize.width * scale, self.targetSize.height * scale);
    
    // 计算降采样后的尺寸（保持原图宽高比）
    CGSize imageSize = image.size;
    CGFloat widthRatio = pixelSize.width / imageSize.width;
    CGFloat heightRatio = pixelSize.height / imageSize.height;
    CGFloat ratio = MIN(widthRatio, heightRatio);
    CGSize finalSize = CGSizeMake(imageSize.width * ratio, imageSize.height * ratio);
    
    // 使用ImageIO降低采样（比UIGraphics 更高效）
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    if (!imageData) {
        imageData = UIImagePNGRepresentation(image);
    }
    
    if (!imageData) {
        return image;
    }
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    if (!source) {
        return image;
    }
    
    NSDictionary *options = @{
           (id)kCGImageSourceCreateThumbnailFromImageAlways: @YES,
           (id)kCGImageSourceThumbnailMaxPixelSize: @(MAX(finalSize.width, finalSize.height)),
           (id)kCGImageSourceCreateThumbnailWithTransform: @YES
       };
    
    CGImageRef thumbnailRef = CGImageSourceCreateImageAtIndex(source, 0, (__bridge  CFDictionaryRef)options);
    CFRelease(source);
    
    if (!thumbnailRef) {
        return image;
    }
    
    UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailRef];
    CGImageRelease(thumbnailRef);
    XYImageLoaderLog(@"降采样完成：原图尺寸 %@ → 目标尺寸 %@",
                          NSStringFromCGSize(imageSize),
                          NSStringFromCGSize(finalSize));
    
    return thumbnail;
}

- (NSString *)transformerKey {
    return [NSString stringWithFormat:@"com.xyimageloader.downsampling.%@",
            NSStringFromCGSize(self.targetSize)];
}

@end

@implementation XYImageCornerTransformer

+ (instancetype)transformerWithCornerRadius:(CGFloat)cornerRadius targetSize:(CGSize)targetSize {
    return [self transformerWithCornerRadius:cornerRadius targetSize:targetSize borderWidth:0 borderColor:nil];
}

+ (instancetype)transformerWithCornerRadius:(CGFloat)cornerRadius
                                   targetSize:(CGSize)targetSize
                                  borderWidth:(CGFloat)borderWidth
                                  borderColor:(UIColor *)borderColor {
    XYImageCornerTransformer *transformer = [[self alloc] init];
//    transformer.cornerRadius = cornerRadius;
//    transformer.targetSize = targetSize;
//    transformer.borderWidth = borderWidth;
//    transformer.borderColor = borderColor;
    return transformer;
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) return nil;
    
//    CGSize targetSize = self.targetSize;
//    if (CGSizeEqualToSize(targetSize, CGSizeZero)) {
//        return image;
//    }
//
//    CGFloat scale = [UIScreen mainScreen].scale;
//    CGFloat cornerRadius = self.cornerRadius * scale;
//    CGFloat borderWidth = self.borderWidth * scale;
//    UIColor *borderColor = self.borderColor ?: [UIColor clearColor];
//
//    // 先裁剪到目标尺寸，再画圆角和边框（避免离屏渲染）
//    CGRect drawRect = CGRectMake(0, 0, targetSize.width * scale, targetSize.height * scale);
//    UIGraphicsBeginImageContextWithOptions(drawRect.size, NO, scale);
//
//    // 画圆角
//    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:drawRect cornerRadius:cornerRadius];
//    [path addClip];
//
//    // 画图片
//    [image drawInRect:drawRect];
//
//    // 画边框
//    if (borderWidth > 0) {
//        [borderColor setStroke];
//        path.lineWidth = borderWidth;
//        [path stroke];
//    }
//
//    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//    XYImageLoaderLog(@"圆角处理完成：圆角半径 %.1fpt，目标尺寸 %@",
//                      self.cornerRadius,
//                      NSStringFromCGSize(targetSize));
//
//    return resultImage;
    return image;
}

- (NSString *)transformerKey {
    
    return @"";
//    return [NSString stringWithFormat:@"com.hyimageloader.corner.%.1f.%@.%.1f",
//            self.cornerRadius,
//            NSStringFromCGSize(self.targetSize),
//            self.borderWidth];
}

@end


@implementation XYImageTransformer

@end
