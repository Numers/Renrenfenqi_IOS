//
//  PersonalInfoViewController.m
//  renrenfenqi
//
//  Created by DY on 14/12/2.
//  Copyright (c) 2014年 RenRenFenQi. All rights reserved.
//

#import "PersonalInfoViewController.h"
#import "AppUtils.h"
#import "URLManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "OrderAddressAddViewController.h"

#import "AppDelegate.h"
#import "AuthenticationViewController.h"
#import "UIImageView+WebCache.h"
#import "OrderAddressViewController.h"

#import "StudentAuthViewController.h"

@interface PersonalInfoViewController ()
{
    float _theWidth;
    BOOL  _isRequesting;
    NSMutableDictionary *_userInfoDic;
}

@property (nonatomic, strong) UIImage *headImage;

@end

static NSString *cellIdentifiler = @"Cell";

@implementation PersonalInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化数据
    [self initData];
    // 监听更新玩家信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo) name:UPDATE_AUTH_INFO object:nil];
    
    self.infoTableView.delegate = self;
    self.infoTableView.dataSource = self;
    self.infoTableView.scrollEnabled = NO;
    self.infoTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.infoTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifiler];
    
    if ([self.infoTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.infoTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.infoTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.infoTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self getUserInfo];
}

- (void)updateUserInfo{
    [self getUserInfo];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initData {
    self.headImage = [UIImage imageNamed:@"my_body_headportrait_n@2x.png"];
    _userInfoDic = [NSMutableDictionary dictionary];
     _theWidth = self.view.bounds.size.width;
    _isRequesting = NO;
}

#pragma mark - 数据处理
// 获取用户信息
- (void)getUserInfo
{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    NSString *token = [app.store getStringById:USER_TOKEN fromTable:USER_TABLE];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:userId forKey:@"uid"];
    [parameters setValue:token forKey:@"token"];
    NSString *signStr = [AppUtils makeSignStr:parameters];
    [parameters setValue:signStr forKey:@"sign"];
    [AppUtils showLoadIng:@""];
    [manager GET:[NSString stringWithFormat:@"%@%@", SECURE_BASE, GET_USER_INFO] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils showLoadInfo:@""];
            _userInfoDic = [[jsonData objectForKey:@"data"] mutableCopy];
            [self.infoTableView reloadData];
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
    }];
}
// 修改头像
- (void)modifyHeadPic:(UIImage *)imageHead
{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userId = [app.store getStringById:USER_ID fromTable:USER_TABLE];
    NSString *token = [app.store getStringById:USER_TOKEN fromTable:USER_TABLE];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:userId forKey:@"uid"];
    [parameters setValue:token forKey:@"token"];
    
    
    [AppUtils showLoadIng:@""];
    [manager POST:[NSString stringWithFormat:@"%@%@", SECURE_BASE, MODIFY_HEADPIC] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        NSData *imageData = UIImageJPEGRepresentation(imageHead, 0.5);
        [formData appendPartWithFileData:imageData name:@"avatar" fileName:@"filename.jpg" mimeType:@"image/jpeg"];
    } success:^
     (AFHTTPRequestOperation *operation, id responseObject) {
         
         NSDictionary* jsonData = [operation.responseString objectFromJSONString];
         if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
             [AppUtils showLoadInfo:@"头像设置成功"];
             [self handleHeadPic:[[jsonData objectForKey:@"data"] objectForKey:@"img_path"]];
         }else{
             [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [AppUtils showLoadInfo:@"网络异常，请求超时"];
     }];
}

- (void)handleHeadPic:(NSString *)imgPath
{
    [_userInfoDic setValue:imgPath forKey:@"avatar"];
    // 保存头像的图片地址到本地，用于登录后个人中心做显示用
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [app.store putString:[AppUtils filterNull:imgPath] withId:USER_HEAD_PIC intoTable:USER_TABLE];

    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_PERSONNAL_INFO object:nil];
    
    [self.infoTableView reloadData];
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifiler forIndexPath:indexPath];
    
    cell.textLabel.font = GENERAL_FONT15;
    
    UILabel *infolabel = (UILabel *)[cell viewWithTag:10];
    if (infolabel == nil) {
        infolabel = [[UILabel alloc] initWithFrame:CGRectMake(_theWidth - 230.0f, 0, 200.0f, 44.0f)];
        infolabel.font = GENERAL_FONT15;
        infolabel.tag = 10;
        infolabel.textColor = GENERAL_COLOR_GRAY;
        infolabel.textAlignment = NSTextAlignmentRight;
        [cell addSubview:infolabel];
    }
    
    UIImageView *headImageView = (UIImageView *)[cell viewWithTag:11];
    if (headImageView == nil) {
        headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_theWidth - 80.0f, 2.0f, 50.0f, 50.0f)];
        headImageView.layer.cornerRadius = 25.0f;
        headImageView.layer.masksToBounds = YES;
        headImageView.tag = 11;
        [cell addSubview:headImageView];
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"头像";
        [headImageView sd_setImageWithURL:[NSURL URLWithString:[_userInfoDic objectForKey:@"avatar"]] placeholderImage:self.headImage];
        headImageView.hidden = NO;
        infolabel.hidden = YES;
    }else if (indexPath.row == 1){
        cell.textLabel.text = @"昵称";
        headImageView.hidden = YES;
        infolabel.hidden = NO;
        infolabel.text = [_userInfoDic objectForKey:@"nikename"];
    }else if (indexPath.row == 3){
        cell.textLabel.text = @"收货地址";
        headImageView.hidden = YES;
        infolabel.hidden = NO;
        infolabel.text = [_userInfoDic objectForKey:@"address"];
    }else if (indexPath.row == 4){
        cell.textLabel.text = @"学生认证";
        headImageView.hidden = YES;
        infolabel.hidden = NO;
        infolabel.text = [_userInfoDic objectForKey:@"auth_msg"];
    }else{
        cell.textLabel.text = @"";
        headImageView.hidden = YES;
        infolabel.hidden = YES;
    }
    
    return cell;
}

#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 55;
    }else if (indexPath.row == 2){
        return 15;
    }else{
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
    cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == 2){
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = GENERAL_COLOR_GRAY2;
    }
    
    if (indexPath.row != 0 && indexPath.row != 3) {
        
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册选择", nil];
        [sheet showInView:self.view];
    }else if (indexPath.row == 1){
        ModifierNickNameViewController *vc = [self.storyboard  instantiateViewControllerWithIdentifier:@"ModifierNickNameIdentifier"];
        vc.nickNameString = [_userInfoDic objectForKey:@"nikename"];
        vc.delegate = self;
        [AppUtils pushPage:self targetVC:vc];
    }else if (indexPath.row == 3){
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        NSString *addressStr = [_userInfoDic objectForKey:@"address"];
        if ([self canEnterAddressAddView:addressStr]) {
            OrderAddressAddViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"OrderAddressAddIdentifier"];
            vc.isNeedJudge = YES;
            [AppUtils pushPage:self targetVC:vc];
        }else{
            OrderAddressViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"OrderAddressIdentifier"];
            vc.isSubmitHidden = YES;
            [AppUtils pushPage:self targetVC:vc];
        }

    }else if (indexPath.row == 4){
        if (_isRequesting) {
            return;
        }else{
            _isRequesting = YES;
            [self auth];
        }
    }
}

- (void)auth{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    NSDictionary *parameters = @{@"appVersions":[NSString stringWithFormat:@"%@", [AppUtils appVersion]]};
    
    [manager GET:[NSString stringWithFormat:@"%@%@", SECURE_BASE, APP_AUTH] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"1" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            
            if ([self canEnterAuthVC:[_userInfoDic objectForKey:@"auth_msg"]]) {
                AuthenticationViewController *vc = [self.storyboard  instantiateViewControllerWithIdentifier:@"AuthenticationIdentifier"];
                [AppUtils pushPage:self targetVC:vc];
            }
        }else{
            StudentAuthViewController *vc = [self.storyboard  instantiateViewControllerWithIdentifier:@"StudentAuthIdentifier"];
            [AppUtils pushPage:self targetVC:vc];
        }
        _isRequesting = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
        _isRequesting = NO;
    }];
}

- (BOOL)canEnterAuthVC:(NSString *)status
{
    if ([status isEqual:@"认证成功"]) {
        return NO;
    }else if ([status isEqual:@"认证中"]){
        return NO;
    }
    
    return YES;
}

- (BOOL)canEnterAddressAddView:(NSString *)str{
    
    if ([str isEqual:@"已填写"]) {
        return NO;
    }else{
        return YES;
    }
    
}

#pragma mark UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
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
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
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
    
    self.headImage = [info objectForKey:UIImagePickerControllerEditedImage];
    [self modifyHeadPic:self.headImage];
}


#pragma mark 按钮响应

- (IBAction)back:(UIButton *)sender {
    
    [AppUtils goBack:self];
}

#pragma mark ModifyNickNameDelegate

- (void)saveNewNickName:(NSString *)name
{
    [_userInfoDic setValue:name forKey:@"nikename"];
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [app.store putString:[AppUtils filterNull:name] withId:USER_NICKNAME intoTable:USER_TABLE];
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_PERSONNAL_INFO object:nil];
    
    [self.infoTableView reloadData];
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
