//
//  ViewController.m
//  FilterTest
//
//  Created by fuyuan on 1/19/16.
//  Copyright © 2016 fuyuan. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"
#import <AVFoundation/AVFoundation.h>
#import "AddFilterToImageOrVoideo.h"
@interface ViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segement;/**< 选择按钮*/
- (IBAction)segementSelect:(id)sender;


@property (strong, nonatomic)  AVPlayer *player;        //播放视频
@property (strong, nonatomic) UIImageView *imageView;  //展示图片
@property (strong, nonatomic) NSString *outputPath;    //视频输出路径
@property (strong, nonatomic) AVPlayerLayer *layer;     //展示视频控件
@property (strong, nonatomic) NSString *inputPath;      //视频输入路径
@property (strong, nonatomic) UIImage *inputImage;      //原始图片
@property (assign, nonatomic) BOOL isVideo;             //判断是否是图片
@property (strong, nonatomic) UIActivityIndicatorView *activityView;    //小菊花



- (IBAction)photoBtnClick:(id)sender;
- (IBAction)videoBtnClick:(id)sender;




@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    self.inputPath = [[NSBundle mainBundle] pathForResource:@"7a01dff8fb9bd3c1650e2711cee022fc" ofType:@"mp4"];
    self.inputImage = [UIImage imageNamed:@"46.pic.jpg"];
    self.outputPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mov"];

    
    self.layer = [[AVPlayerLayer alloc] init];
    self.layer.frame = self.view.frame;
    self.layer.hidden = YES;
    [self.view.layer insertSublayer:self.layer atIndex:0];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    self.imageView.image = self.inputImage;
    [self.view insertSubview:self.imageView atIndex:0];
    self.player = [[AVPlayer alloc] init];
    self.layer.player = self.player;

    self.isVideo = NO;
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite]; ;
    self.activityView.frame = CGRectMake(0, 0, 88, 88);
    self.activityView.center = self.view.center;
    [self.view addSubview:self.activityView];
    
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
//         [videoCamera startCameraCapture];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    [super drawLayer:layer inContext:ctx];
}


- (IBAction)photoBtnClick:(id)sender {
    self.isVideo = NO;
    [self.player pause];
    self.layer.hidden = YES;
    self.imageView.hidden = NO;
    
}

- (IBAction)videoBtnClick:(id)sender {
    self.isVideo = YES;
    self.layer.hidden = NO;
    AVAsset *assert  = [AVAsset assetWithURL:[NSURL fileURLWithPath:self.outputPath]];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:assert];
    [_player replaceCurrentItemWithPlayerItem:playerItem];
    self.imageView.hidden = YES;
    [_player play];
    
}


- (IBAction)segementSelect:(id)sender {
    UISegmentedControl *segment = sender;
    __unsafe_unretained typeof(self) weakSelf = self;
    
    if (self.isVideo) {
        switch (segment.selectedSegmentIndex) {
            case 0: {
                [self.player pause];
                [self.activityView startAnimating];
                [[AddFilterToImageOrVoideo shareManager] filteringVideoWithsourcePath:self.inputPath andExportPath:self.outputPath withFilterType:Sharpen compelete:^(BOOL result) {
                    [weakSelf videoBtnClick:nil];
                    [weakSelf.activityView stopAnimating];
                }];
            }
                
                break;
            case 1: {
                [self.player pause];
                [self.activityView startAnimating];
                [[AddFilterToImageOrVoideo shareManager] filteringVideoWithsourcePath:self.inputPath andExportPath:self.outputPath withFilterType:ToneCurve compelete:^(BOOL result) {
                    [weakSelf videoBtnClick:nil];
                    [weakSelf.activityView stopAnimating];
                }];
            }
                
                break;
            case 2: {
                [self.player pause];
                [self.activityView startAnimating];
                [[AddFilterToImageOrVoideo shareManager] filteringVideoWithsourcePath:self.inputPath andExportPath:self.outputPath withFilterType:MissEtikate compelete:^(BOOL result) {
                    [weakSelf videoBtnClick:nil];
                    [weakSelf.activityView stopAnimating];
                }];
            }
                
                break;
            case 3: {
                [self.player pause];
                [self.activityView startAnimating];
                [[AddFilterToImageOrVoideo shareManager] filteringVideoWithsourcePath:self.inputPath andExportPath:self.outputPath withFilterType:Amatorka compelete:^(BOOL result) {
                    [weakSelf videoBtnClick:nil];
                    [weakSelf.activityView stopAnimating];
                }];
            }
                
                break;
            case 4: {
                [self.player pause];
                [self.activityView startAnimating];
                [[AddFilterToImageOrVoideo shareManager] filteringVideoWithsourcePath:self.inputPath andExportPath:self.outputPath withFilterType:SoftElegance compelete:^(BOOL result) {
                    [weakSelf videoBtnClick:nil];
                    [weakSelf.activityView stopAnimating];
                }];
            }
                
                break;
                
            default:
                break;
        }
        
    } else {
        
        switch (segment.selectedSegmentIndex) {
            case 0: {
                [self.player pause];
              self.imageView.image = [[AddFilterToImageOrVoideo shareManager] filteringImageWithImage:self.inputImage filterType:Sharpen];
                [weakSelf photoBtnClick:nil];
            }
                
                break;
            case 1: {
                [self.player pause];
               self.imageView.image =  [[AddFilterToImageOrVoideo shareManager] filteringImageWithImage:self.inputImage filterType:ToneCurve];
                [weakSelf photoBtnClick:nil];
            }
                
                break;
            case 2: {
                [self.player pause];
               self.imageView.image =  [[AddFilterToImageOrVoideo shareManager] filteringImageWithImage:self.inputImage filterType:MissEtikate];
                [weakSelf photoBtnClick:nil];
            }
                
                break;
            case 3: {
                [self.player pause];
                self.imageView.image = [[AddFilterToImageOrVoideo shareManager] filteringImageWithImage:self.inputImage filterType:Amatorka];
                [weakSelf photoBtnClick:nil];
            }
                
                break;
            case 4: {
                [self.player pause];
                self.imageView.image = [[AddFilterToImageOrVoideo shareManager] filteringImageWithImage:self.inputImage filterType:SoftElegance];
                [weakSelf photoBtnClick:nil];
            }
                
                break;
            default:
                break;
        }
    
    }

}
@end
