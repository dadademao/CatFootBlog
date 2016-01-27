//
//  AddFilterToImageOrVoideo.h
//  FilterTest
//
//  Created by fuyuan on 1/22/16.
//  Copyright © 2016 fuyuan. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GPUImage.h"

/**
 *  滤镜种类
 */
typedef NS_ENUM(NSUInteger, FilterType) {

    /**
     *  锐化
     */
    Sharpen = 0,
    /**
     *  Tone Cure
     */
    ToneCurve,
    /**
     *  miss Etikate
     */
    MissEtikate,
    /**
     *  amatorka
     */
    Amatorka,
    /**
     *  soft Elegance
     */
    SoftElegance
};


typedef void(^compeleteFiltering)(BOOL result);







@interface AddFilterToImageOrVoideo : NSObject

/**
 *  单例
 *
 *  @return <#return value description#>
 */
+ (instancetype)shareManager;

/**
 *  使用相应的滤镜制作照片
 *
 *  @param image 原始照片
 *  @param type  滤镜类型
 */
- (UIImage *) filteringImageWithImage:(UIImage *)image filterType:(FilterType)type;

/**
 *  使用所有滤镜制作照片数组
 *
 *  @param image 原始照片
 *
 *  @return UIImage数组
 */
- (NSMutableArray *) filteringImagesWithImage:(UIImage *)image;

/**
 *  使用相应的滤镜制作视频
 *
 *  @param sourcePath 视频源路径
 *  @param exportPath 视频输出路径
 *  @param type       滤镜类型
 *  @param complete   完成block
 */
- (void) filteringVideoWithsourcePath:(NSString *)sourcePath andExportPath:(NSString *)exportPath withFilterType:(FilterType)type compelete:(compeleteFiltering)complete ;

/**
 *  实时滤镜效果
 *
 *  @param sourcePath 视频源路径
 *  @param view       输出视图
 *  @param type       滤镜类型
 */
- (void) filteringVideoWithSourcePath:(NSString *)sourcePath andPresentView:(GPUImageView *)view withFilterType:(FilterType)type;
@end
