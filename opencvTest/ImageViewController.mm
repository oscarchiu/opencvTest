//
//  ImageViewController.m
//  opencvTest
//
//  Created by opcom on 2015/4/15.
//  Copyright (c) 2015年 opcom. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

- (IBAction)loadBtnPressed:(id)sender {
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];

    picker.delegate = self;

    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])

        return;

    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [self presentViewController:picker animated:YES completion:nil];
}
@end
