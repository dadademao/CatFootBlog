//
//  ViewController.m
//  FilterTest
//
//  Created by fuyuan on 1/19/16.
//  Copyright © 2016 fuyuan. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    [super drawLayer:layer inContext:ctx];
}
@end
