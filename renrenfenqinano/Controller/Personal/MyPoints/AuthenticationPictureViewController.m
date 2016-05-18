//
//  AuthenticationPictureViewController.m
//  renrenfenqi
//
//  Created by DY on 14/11/29.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "AuthenticationPictureViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

#import "AppUtils.h"
#import "URLManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "AppDelegate.h"
#import "PersonalInfoViewController.h"

#define IDENTITY_PIC_UPLOAD 1000           //身份证照片上传
#define STUDENT_PIC_UPLOAD  1001           //学生证照片上传

@interface AuthenticationPictureViewController ()
{
    BOOL _isUpload_SFZ;
    BOOL _isUpload_XSZ;
}

@property(assign, nonatomic) NSInteger sheetTag;
@property (nonatomic, strong) UIImage* imageIndentity;
@property (nonatomic, strong) UIImage* imageStudent;

@end

@implementation AuthenticationPictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.commitBtn.enabled = NO;
    _isUpload_SFZ = NO;
    _isUpload_XSZ = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma -mark 按钮响应

- (IBAction)back:(UIButton *)sender
{
    [AppUtils goBack:self];
}

- (IBAction)commit:(id)sender
{
    // 向服务器发送身份证照
    [self upLoadPic:self.imageIndentity imageType:@"SFZ_Z"];
    // 向服务器发送学生证照
    [self upLoadPic:self.imageStudent imageType:@"XSZ_Z"];
}

- (IBAction)identityPic:(UIButton *)sender
{
    NSLog(@"选择上传身份证照片");
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册选择", nil];
    sheet.tag = IDENTITY_PIC_UPLOAD;
    [sheet showInView:self.view];
}

- (IBAction)studentIdPic:(UIButton *)sender
{
    NSLog(@"选择学生证照片");
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册选择", nil];
    sheet.tag = STUDENT_PIC_UPLOAD;
    [sheet showInView:self.view];
}

#pragma mark UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.sheetTag = actionSheet.tag;
    NSString* btn = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([btn isEqualToString:@"从手机相册选择"]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        [self presentViewController:imagePicker animated:YES completion:^{}];
        
    } else if ([btn isEqualToString:@"拍照"]) {
        BOOL isCam = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
        if (isCam == NO) {
            NSLog(@"no camera");
            return;
        }
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
        imagePicker.mediaTypes = [NSArray arrayWithObjects:( NSString *)kUTTypeImage, nil];
        
        [self presentViewController:imagePicker animated:YES completion:^{}];
    }
    
}

#pragma mark - 相册 选取图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"选取相册 照片完成 info=%@",info);
    //获取资源属于哪种类型
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    //判断不支持录像资源上传
    [picker dismissViewControllerAnimated:YES completion:nil];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSLog(@"不支持资源上传");
        return ;
    }
    
    if (self.sheetTag == IDENTITY_PIC_UPLOAD) {
        self.imageIndentity = [info objectForKey:UIImagePickerControllerEditedImage];
        [self.identityCardBtn setImage:self.imageIndentity forState:UIControlStateNormal];
    }else if (self.sheetTag == STUDENT_PIC_UPLOAD){
        self.imageStudent = [info objectForKey:UIImagePickerControllerEditedImage];
        [self.studentIDBtn setImage:self.imageStudent forState:UIControlStateNormal];
    }
    
    
    if (self.imageIndentity != nil && self.imageStudent != nil) {
        self.commitBtn.enabled = YES;
    }
}

#pragma mark 向服务器上传图片 目前支持一张上传
- (void)upLoadPic:(UIImage *)image imageType:(NSString *)type{
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"uid":userId,
                                 @"type":type};
    
    [manager POST:[NSString stringWithFormat:@"%@%@", API_BASE, UPLOAD_STUDENT_PIC] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        [formData appendPartWithFileData:imageData name:@"userfile1" fileName:@"filename.jpg" mimeType:@"image/jpeg"];
    } success:^
     (AFHTTPRequestOperation *operation, id responseObject) {
         
         NSDictionary* jsonData = [operation.responseString objectFromJSONString];
         if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
             [self handleSuccessMessage:type];
         }else{
             [self handleFailureMessage:type];
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [AppUtils showLoadInfo:@"网络异常，请求超时"];
     }];
}

- (void)handleSuccessMessage:(NSString *)type{
    
    if ([type isEqual:@"SFZ_Z"]) {
        _isUpload_SFZ = YES;
    }else if ([type isEqual:@"XSZ_Z"]){
        _isUpload_XSZ = YES;
    }
    
    if (_isUpload_XSZ && _isUpload_SFZ) {
        
        [AppUtils showLoadSuceess:@"照片上传成功"];
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_AUTH_INFO object:nil];
        
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[PersonalInfoViewController class]]) {
                [AppUtils popToPage:self targetVC:controller];
            }
        }
    }
    
}

- (void)handleFailureMessage:(NSString *)type{
    
    if ([type isEqual:@"SFZ_Z"]) {
        [AppUtils showLoadInfo:@"身份证照片上传失败，请稍后再试！"];
    }else if ([type isEqual:@"XSZ_Z"]){
       [AppUtils showLoadInfo:@"学生证照片上传失败，请稍后再试！"];
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
