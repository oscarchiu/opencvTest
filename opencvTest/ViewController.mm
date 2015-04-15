//
//  ViewController.m
//  opencvTest
//
//  Created by opcom on 2015/4/10.
//  Copyright (c) 2015年 opcom. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:_imageView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
//    self.videoCamera.grayscale = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    if (image != nil)
        [self operateWithOpenCV:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

static UIImage* MattoUIImage(const cv::Mat& m)
{
    
    if (m.depth() != CV_8U)
        
        return nil;
    
    NSData* data = [NSData dataWithBytes:m.data length:m.elemSize()*m.total()];
    
    CGColorSpaceRef colorSpace = m.channels() ==1 ? CGColorSpaceCreateDeviceGray():CGColorSpaceCreateDeviceRGB();
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    CGImageRef imageRef = CGImageCreate(m.cols, m.rows, m.elemSize1()*8, m.elemSize()*8, m.step[0], colorSpace, kCGImageAlphaNoneSkipLast|kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
    
    UIImage* finalImage = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    
    CGDataProviderRelease(provider);
    
    CGColorSpaceRelease(colorSpace);
    
    return  finalImage;
    
}

static void UIImagetoMat(const UIImage* image, cv::Mat& m)
{
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    
    CGFloat cols = image.size.width;
    
    CGFloat rows = image.size.height;
    
    m.create(rows, cols, CV_8UC4);
    
    CGContextRef contextRef = CGBitmapContextCreate(m.data, cols, rows, 8, m.step[0], colorSpace, kCGImageAlphaNoneSkipLast|kCGBitmapByteOrderDefault);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    
    CGContextRelease(contextRef);
    
}

-(void)operateWithOpenCV:(UIImage*)image{
    
    if (image == nil)
        
        return;
    
    cv::Mat m, gray;
    
    UIImagetoMat(image, m);
    
    cv::cvtColor(m, gray, CV_BGR2GRAY);
    
    cv::GaussianBlur(gray, gray, cv::Size(5,5), 1.2,1.2);
    
    cv::Canny(gray, gray, 0, 50);
    
    m = cv::Scalar::all(255);
    
    m.setTo(cv::Scalar(0, 128, 255, 255), gray);
    
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    _imageView.image = MattoUIImage(m);
    
}

#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus
- (void)processImage:(Mat&)image;
{
//    // Do some OpenCV stuff with the image
//    Mat image_copy;
//    cvtColor(image, image_copy, CV_BGRA2BGR);
//    
//    // invert image
//    bitwise_not(image_copy, image_copy);
//    cvtColor(image_copy, image, CV_BGR2BGRA);
    
    cv::Mat gray;
    cv::cvtColor(image, gray, CV_BGRA2GRAY);
    cv::GaussianBlur(gray, gray, cv::Size(5,5), 1.2,1.2);
    cv::Canny(gray, gray, 0, 50);
    
    image = cv::Scalar::all(255);
    image.setTo(cv::Scalar(128, 255, 0, 255), gray);
}
#endif

- (IBAction)loadButtonPressed:(id)sender {
    [self.videoCamera start];
    
//    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
//    
//    picker.delegate = self;
//    
//    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
//        
//        return;
//    
//    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    
//    [self presentViewController:picker animated:YES completion:nil];
}
@end
