//
//  AddFilterToImageOrVoideo.m
//  FilterTest
//
//  Created by fuyuan on 1/22/16.
//  Copyright © 2016 fuyuan. All rights reserved.
//

#import "AddFilterToImageOrVoideo.h"
#import "GPUImage.h"
@implementation AddFilterToImageOrVoideo {
    GPUImageMovie *moviefile;
    GPUImageMovieWriter *videoCamera;
}



/**
 *  单例
 *
 *  @return 单例
 */
+ (instancetype)shareManager {
    static AddFilterToImageOrVoideo *manager;
    static dispatch_once_t queue;
    dispatch_once(&queue, ^{
        if (!manager) {
            manager = [[AddFilterToImageOrVoideo alloc] init];
        }
    });
    return manager;
}

/**
 *  使用相应的滤镜制作照片
 *
 *  @param image 原始照片
 *  @param type  滤镜类型
 */
- (UIImage *) filteringImageWithImage:(UIImage *)image filterType:(FilterType)type {
    
    UIImage *inputImage = image;
    
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];
    id stillImageFilter = [self getGPUImageFilterByType:type];
    
    [stillImageSource addTarget:stillImageFilter];
    [stillImageFilter useNextFrameForImageCapture];
    [stillImageSource processImage];
    
    UIImage *currentFilteredVideoFrame = [stillImageFilter imageFromCurrentFramebuffer];
    
    return currentFilteredVideoFrame;
    
}

/**
 *  使用所有滤镜制作照片数组
 *
 *  @param image 原始照片
 *
 *  @return UIImage数组
 */
- (NSMutableArray *) filteringImagesWithImage:(UIImage *)image {
    return nil;
}

/**
 *  使用相应的滤镜制作视频
 *
 *  @param sourcePath 视频源路径
 *  @param exportPath 视频输出路径
 *  @param type       滤镜类型
 *  @param complete   完成block
 */
- (void) filteringVideoWithsourcePath:(NSString *)sourcePath andExportPath:(NSString *)exportPath withFilterType:(FilterType)type compelete:(compeleteFiltering)complete  {
    NSURL *url = [NSURL fileURLWithPath:sourcePath];
    moviefile  = [[GPUImageMovie alloc] initWithURL:url];
    moviefile.runBenchmark = NO;
    moviefile.playAtActualSpeed = NO;
    id stillImageFilter = [self getGPUImageFilterByType:type];
    [moviefile addTarget:stillImageFilter];
    unlink([exportPath UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:exportPath];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSArray *assetVideoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if (assetVideoTracks.count <= 0)
    {
        NSLog(@"Video track is empty!");
        return;
    }
    AVAssetTrack *videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    // If this if from system camera, it will rotate 90c, and swap width and height
    CGSize sizeVideo = CGSizeMake(videoAssetTrack.naturalSize.width, videoAssetTrack.naturalSize.height);

    videoCamera = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:sizeVideo];
    [stillImageFilter addTarget:videoCamera];
    videoCamera.shouldPassthroughAudio = YES;
    moviefile.audioEncodingTarget = videoCamera;
    [moviefile enableSynchronizedEncodingUsingMovieWriter:videoCamera];
    [videoCamera startRecording];
    [moviefile startProcessing];
    __unsafe_unretained typeof(videoCamera) weakVideoCamera = videoCamera;
    [videoCamera setCompletionBlock:^{
        if ((NSNull*)stillImageFilter != [NSNull null] && stillImageFilter != nil)
        {
            [stillImageFilter removeTarget:weakVideoCamera];
            [moviefile removeTarget:stillImageFilter];
        }
        else
        {
            [stillImageFilter removeTarget:weakVideoCamera];
        }
        [weakVideoCamera finishRecordingWithCompletionHandler:^{
            
            // Closer timer
            complete(YES);
        }];
    }];
    
    [videoCamera setFailureBlock:^(NSError *error) {
        NSLog(@"error%@",error);
        complete(NO);
    }];


}

/**
 *  通过滤镜名获取滤镜对象
 *
 *  @param type 滤镜名
 *
 *  @return 滤镜对象
 */
- (id<GPUImageInput>) getGPUImageFilterByType:(FilterType)type {
    switch (type) {
        case Sharpen: {
            GPUImageSharpenFilter *filter = [[GPUImageSharpenFilter alloc] init];
            filter.sharpness = 2;
            return filter;
        }
            break;
        case ToneCurve: {
            GPUImageToneCurveFilter *filter = [[GPUImageToneCurveFilter alloc] init];
            return filter;
        
        }
        case MissEtikate: {
            GPUImageMissEtikateFilter *filter = [[GPUImageMissEtikateFilter alloc] init];
            return filter;
        }
        case Amatorka: {
            GPUImageAmatorkaFilter *filter = [[GPUImageAmatorkaFilter alloc] init];
            return filter;
        }
        case SoftElegance: {
            GPUImageSoftEleganceFilter *filter = [[GPUImageSoftEleganceFilter alloc] init];
            return filter;
        }
        default:
            break;
    }
    return nil;
}

/**
 *  获取所有滤镜名
 *
 *  @return 所有滤镜名
 */
- (NSArray *) getAllFilterType {
    return nil;
}
@end
