//
//  XYImageTransformer.h
//  CodeTest
//
//  Created by 万晓迪 on 2026/3/28.
//  实现降采样（防 OOM）和圆角 / 裁剪（避免离屏渲染）

#import <Foundation/Foundation.h>
#import <SDWebImage/SDWebImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface XYImageDownsamplingTransformer : NSObject <SDImageTransformer>


/// 初始化降采样变换器
/// @param targetSize 目标尺寸（单位：pt，内部会自动乘以屏幕 Scale）
+ (instancetype)transformerWithTargetSize:(CGSize)targetSize;

@end

@interface XYImageCornerTransformer : NSObject <SDImageTransformer>

/// 初始化圆角变换器
/// @param cornerRadius 圆角半径（单位：pt）
/// @param targetSize 目标尺寸（单位：pt，先裁剪到目标尺寸再画圆角，避免离屏渲染）
+ (instancetype)transformerWithCornerRadius:(CGFloat)cornerRadius targetSize:(CGSize)targetSize;


/// 初始化圆角+边框变换器
/// @param cornerRadius 圆角半径
/// @param targetSize 目标尺寸
/// @param borderWidth 边框宽度
/// @param borderColor 边框颜色
+ (instancetype)transformerWithCornerRadius:(CGFloat)cornerRadius
                                   targetSize:(CGSize)targetSize
                                  borderWidth:(CGFloat)borderWidth
                                  borderColor:(UIColor *)borderColor;


@end

@interface XYImageTransformer : NSObject

@end

NS_ASSUME_NONNULL_END
