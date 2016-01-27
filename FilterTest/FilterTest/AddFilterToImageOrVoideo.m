//
//  AddFilterToImageOrVoideo.m
//  FilterTest
//
//  Created by fuyuan on 1/22/16.
//  Copyright © 2016 fuyuan. All rights reserved.
//

#import "AddFilterToImageOrVoideo.h"
@implementation AddFilterToImageOrVoideo {
    GPUImageMovie *moviefile;
    GPUImageMovieWriter *videoCamera;
    AVAssetExportSession *_exportSession;
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
    NSString *outPutPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/bigMovie.mov"];
    unlink([outPutPath UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:outPutPath];
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
    __unsafe_unretained typeof(self) weakSelf = self;
    [videoCamera setCompletionBlock:^{
        if ((NSNull*)stillImageFilter != [NSNull null] && stillImageFilter != nil)
        {
            [stillImageFilter removeTarget:weakVideoCamera];
//            [moviefile removeTarget:stillImageFilter];
        }
        else
        {
            [stillImageFilter removeTarget:weakVideoCamera];
        }
        
        [weakVideoCamera finishRecordingWithCompletionHandler:^{
            
            // Closer timer
            unlink([exportPath UTF8String]);
            [weakSelf compressVideoToMP4WithInputUrl:movieURL outPutFiled:exportPath compelete:complete];
        }];
    }];
    
    [videoCamera setFailureBlock:^(NSError *error) {
        NSLog(@"error%@",error);
        complete(NO);
    }];


}

/**
 *  实时滤镜效果
 *
 *  @param sourcePath 视频源路径
 *  @param view       输出视图
 *  @param type       滤镜类型
 */
- (void) filteringVideoWithSourcePath:(NSString *)sourcePath andPresentView:(GPUImageView *)view withFilterType:(FilterType)type {
    moviefile = [[GPUImageMovie alloc] initWithURL:[NSURL fileURLWithPath:sourcePath]];
    moviefile.runBenchmark = YES;
    moviefile.playAtActualSpeed = NO;
    id stillImageFilter = [self getGPUImageFilterByType:type];
    [moviefile addTarget:stillImageFilter];
    [stillImageFilter addTarget:view];
    [moviefile startProcessing];
//
//    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
//    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
//    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
//    
//    videoCamera = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640.0, 480.0)];
//    [stillImageFilter addTarget:videoCamera];
//    
//    // Configure this for video from the movie file, where we want to preserve all video frames and audio samples
//    videoCamera.shouldPassthroughAudio = YES;
//    moviefile.audioEncodingTarget = videoCamera;
//    [moviefile enableSynchronizedEncodingUsingMovieWriter:videoCamera];
//    
//    [videoCamera startRecording];
//    [moviefile startProcessing];
// 
//    __unsafe_unretained typeof(videoCamera) weakCamera = videoCamera;
//    [videoCamera setCompletionBlock:^{
//        [stillImageFilter removeTarget:weakCamera];
//        [weakCamera finishRecording];
//
//    }];


}

/**
 *  视频通过滤镜后内容被放大，需要进行压缩
 *
 *  @param inputVideoURL   传入需要压缩的视频路径
 *  @param exportVideoFile 传出压缩后视频路径
 *  @param compelete       完成
 */
- (void) compressVideoToMP4WithInputUrl:(NSURL *)inputVideoURL outPutFiled:(NSString *)exportVideoFile compelete:(compeleteFiltering)compelete {
    if (!inputVideoURL || ![inputVideoURL isFileURL] || !exportVideoFile || [exportVideoFile isEqualToString:@""])
    {
        NSLog(@"Input filename or Output filename is invalied for convert to Mp4!");
        return ;
    }

    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:inputVideoURL options:nil];
    NSParameterAssert(asset);
    if(asset ==nil || [[asset tracksWithMediaType:AVMediaTypeVideo] count]<1)
    {
        NSLog(@"Input video is invalid!");
        return ;
    }
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    NSArray *assetVideoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if (assetVideoTracks.count <= 0)
    {
        // Retry once
        if (asset)
        {
            asset = nil;
        }
        
        asset = [[AVURLAsset alloc] initWithURL:inputVideoURL options:nil];
        assetVideoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        if ([assetVideoTracks count] <= 0)
        {
            if (asset)
            {
                asset = nil;
            }
            
            NSLog(@"Error reading the transformed video track");
            return ;
        }
    }
    
    // 3. Insert the tracks in the composition's tracks
    AVAssetTrack *assetVideoTrack = [assetVideoTracks firstObject];
    [videoTrack insertTimeRange:assetVideoTrack.timeRange ofTrack:assetVideoTrack atTime:CMTimeMake(0, 1) error:nil];
    [videoTrack setPreferredTransform:assetVideoTrack.preferredTransform];
    
    if ([[asset tracksWithMediaType:AVMediaTypeAudio] count]>0)
    {
        AVAssetTrack *assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        [audioTrack insertTimeRange:assetAudioTrack.timeRange ofTrack:assetAudioTrack atTime:CMTimeMake(0, 1) error:nil];
    }
    else
    {
        NSLog(@"Reminder: video hasn't audio!");
    }
    
    
    NSString *mp4Quality = AVAssetExportPresetMediumQuality; //AVAssetExportPresetPassthrough
    NSString *exportPath = exportVideoFile;
    NSURL *exportUrl = [NSURL fileURLWithPath:exportPath];
    
    _exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:mp4Quality];
    _exportSession.outputURL = exportUrl;
    _exportSession.outputFileType = [[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0 ? AVFileTypeMPEG4 : AVFileTypeQuickTimeMovie;
    
    _exportSession.shouldOptimizeForNetworkUse = YES;
    
    [_exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch ([_exportSession status])
        {
            case AVAssetExportSessionStatusCompleted:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // Close timer
                    compelete(YES);
                    
                                     // Write to photo album
                    //                    [self writeExportedVideoToAssetsLibrary:exportVideoFile];
                });
                
                break;
            }
            case AVAssetExportSessionStatusFailed:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // Close timer
                   compelete(NO);
                });
                
                NSLog(@"Export failed: %@", [[_exportSession error] localizedDescription]);
                
                break;
            }
            case AVAssetExportSessionStatusCancelled:
            {
                NSLog(@"Export canceled");
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // Close timer
                    compelete(NO);
                });
                break;
            }
            case AVAssetExportSessionStatusWaiting:
            {
                NSLog(@"Export Waiting");
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // Close timer
                    compelete(NO);
                });
                break;
            }
            case AVAssetExportSessionStatusExporting:
            {
                NSLog(@"Export Exporting");
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // Close timer
                    compelete(NO);
                });
                break;
            }
            default:
                break;
        }
        
        _exportSession = nil;
        
 
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
