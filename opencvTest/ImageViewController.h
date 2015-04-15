//
//  ImageViewController.h
//  opencvTest
//
//  Created by opcom on 2015/4/15.
//  Copyright (c) 2015年 opcom. All rights reserved.
//

#ifndef __IPHONE_8_1

#warning “This project uses features only availablein iOS SDK 5.0 and later."

#endif

#ifdef __cplusplus

#import<opencv2/opencv.hpp>

#endif

#ifdef __OBJC__

#import<UIKit/UIKit.h>

#import<Foundation/Foundation.h>

#endif

#import <opencv2/highgui/cap_ios.h>
using namespace cv;

//#import <UIKit/UIKit.h>

static UIImage* MattoUIImage(const cv::Mat& m);

static void UIImagetoMat(const UIImage* image, cv::Mat& m);

@interface ImageViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIButton *loadBtn;
- (IBAction)loadBtnPressed:(id)sender;

@end
