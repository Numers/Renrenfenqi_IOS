//
//  PartTimeGoodsViewController.m
//  renrenfenqi
//
//  Created by DY on 15/2/8.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "PartTimeGoodsViewController.h"
#import "CommonTools.h"
#import "CommonVariable.h"
#import "OnlyPartTimeViewController.h"
#import "GoodsDetailSpecViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "JSONKit.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "GoodsCollectionViewCell.h"
#import "JobsCollectionViewCell.h"
#import "OrderWebViewController.h"

@interface PartTimeGoodsViewController ()
{
    int             _pageIndex;
    int             _pageTotal;
    BOOL            _isFirstLoad;
    UIStoryboard   *_mainStoryboard;
    CGSize          _mainScreenSize; // 屏幕尺寸
    float           _goodsViewHeight;// 兼职购物商品界面高度
    float           _jobViewHeight;  // 兼职工种界面高度
    CGSize          _goodsCardSize;  // 商品卡牌尺寸
    UIEdgeInsets    _goodsEdgeInsets;
    CGSize          _jobCardSiz;     // 工种卡牌尺寸
    UIEdgeInsets    _jobEdgeInsets;
    NSMutableArray *_parttimeGoodsArr;
    NSMutableArray *_parttimeJobsArr;
    NSInteger       _goodsIndex;
}

@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UICollectionView *goodsCollectionView;
@property (strong, nonatomic) UICollectionView *jobCollectionView;

@property (strong, nonatomic) UIView *errorView;
@property (strong, nonatomic) UIImageView *errorImageView;
@property (strong, nonatomic) UIButton *refreshButton;

@end

static NSString *goodsCellIdentifier = @"goodsCellIdentifier";
static NSString *jobCellIdentifier = @"jobCellIdentifier";

@implementation PartTimeGoodsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViewData];
    [self initUI];
    [self requestParttimeGoods:_pageIndex];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark 数据处理

- (void)initViewData {
    _mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _parttimeGoodsArr = [NSMutableArray array];
    _parttimeJobsArr = [NSMutableArray array];
    _pageIndex = 1;
    _pageTotal = 1;
    _isFirstLoad = YES;
    _mainScreenSize = _MainScreenFrame.size;

    float top = 15.0f;
    float bottom = 15.0f;
    float scale = _mainScreenSize.width / Iphone5Width;
    if (_mainScreenSize.height < Iphone5Height) {
        _goodsViewHeight = 110.0f;
        _goodsEdgeInsets = UIEdgeInsetsMake(0, 24.0f, 0, 24.0f);
        _goodsCardSize = CGSizeMake(60.0f, _goodsViewHeight - _goodsEdgeInsets.top);
        top = 15.0f;
        bottom = 15.0f;
        _jobViewHeight = _mainScreenSize.height - 64.0f - 48.0f - _goodsViewHeight;
        _jobEdgeInsets = UIEdgeInsetsMake(top, 15.0f, bottom, 15.0f);
        _jobCardSiz = CGSizeMake(200.0f, _jobViewHeight - (top + bottom));
    }else{
        _goodsViewHeight = ceilf(scale*110.0f);
        _goodsEdgeInsets = UIEdgeInsetsMake(0, 24.0f, 0, 24.0f);
        _goodsCardSize = CGSizeMake(60.0f, _goodsViewHeight - _goodsEdgeInsets.top);
        top = ceilf(scale*42.0f);
        bottom = ceilf(scale*42.0f);
        _jobViewHeight = _mainScreenSize.height - 64.0f - 48.0f - _goodsViewHeight;
        _jobEdgeInsets = UIEdgeInsetsMake(top, 15.0f, bottom, 15.0f);
        _jobCardSiz = CGSizeMake(ceilf(scale*200.0f), _jobViewHeight - (top + bottom));
    }
}

- (void)requestParttimeGoods:(int)pageIndex {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    NSDictionary *parameters = @{@"page":[NSString stringWithFormat:@"%d", pageIndex]};
    [AppUtils showLoadIng];
    [manager GET:[NSString stringWithFormat:@"%@%@", JOB_BASE, GET_PARTTIME_GOODS] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils hideLoadIng];
            [self handleParttimeGoods:[jsonData objectForKey:@"data"]];
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
        self.refreshButton.enabled = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.refreshButton.enabled = YES;
        self.errorImageView.image = [UIImage imageNamed:@"no_wifi@2x.png"];
        [self.refreshButton setTitle:@"请检查网络，重新点击刷新" forState:UIControlStateNormal];
        self.errorView.hidden = NO;
        self.goodsCollectionView.hidden = YES;
        self.jobCollectionView.hidden = YES;
        
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
    }];
}

- (void)handleParttimeGoods:(NSDictionary *)dic {
    
    self.errorView.hidden = YES;
    self.goodsCollectionView.hidden = NO;
    self.jobCollectionView.hidden = NO;
    
    _pageTotal = [[NSString stringWithFormat:@"%@", [dic objectForKey:@"total"]] intValue];
    [_parttimeGoodsArr addObjectsFromArray:[dic objectForKey:@"list"]];
    [self.goodsCollectionView reloadData];
    
    if (_isFirstLoad) {
        if (_parttimeGoodsArr.count > 0) {
            _goodsIndex = 0;
            NSString *postionId = [[_parttimeGoodsArr objectAtIndex:_goodsIndex] objectForKey:@"position_id"];
            [self requestParttimeJobs:postionId];
        }
        _isFirstLoad = NO;
    }
}

- (void)requestParttimeJobs:(NSString *)positionId {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSDictionary *parameters = @{@"id":positionId};
    [AppUtils showLoadIng];
    [manager GET:[NSString stringWithFormat:@"%@%@", JOB_BASE, GET_PARTTIME_JOBS] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* jsonData = [operation.responseString objectFromJSONString];
        
        if ([@"200" isEqualToString:[NSString stringWithFormat:@"%@", [jsonData objectForKey:@"status"]]]) {
            [AppUtils hideLoadIng];
            [self handleParttimeJobs:jsonData];
        }else{
            [AppUtils showLoadInfo:[jsonData objectForKey:@"message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppUtils showLoadInfo:@"网络异常，请求超时"];
    }];
}

- (void)handleParttimeJobs:(NSDictionary *)dic {
    _parttimeJobsArr = [[dic objectForKey:@"data"] mutableCopy];
    NSDictionary *specialCard = @{@"cname":@"任意分配"};
    [_parttimeJobsArr addObject:specialCard];
    [self.jobCollectionView reloadData];
    [self.jobCollectionView setContentOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark UI初始化

- (void)initUI {
    self.view.backgroundColor = [CommonVariable grayBackgroundColor];
    self.topView = [CommonTools generateTopBarWiwhOnlyTitle:self title:@"兼职购物"];
    [self.view addSubview:self.topView];
    [self.view bringSubviewToFront:self.topView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.titleLabel.font = GENERAL_FONT15;
    [button setTitle:@"只想兼职" forState:UIControlStateNormal];
    [button setTitleColor:[CommonVariable redFontColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(touchOnlyPartTimeBtn:) forControlEvents:UIControlEventTouchUpInside];
    CGSize textSize = [@"只想兼职" sizeWithAttributes:@{NSFontAttributeName:button.titleLabel.font}];
    button.frame = CGRectMake(self.topView.frame.size.width - (textSize.width + 30.0f), 20.0f, textSize.width + 30.0f, 44.0f);
    [self.topView addSubview:button];
    
    UICollectionViewFlowLayout *goodslayout = [[UICollectionViewFlowLayout alloc] init];
    goodslayout.sectionInset = _goodsEdgeInsets;
    goodslayout.minimumLineSpacing = 24.0f;
    goodslayout.itemSize = _goodsCardSize;
    goodslayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.goodsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:goodslayout];
    [self.goodsCollectionView registerClass:[GoodsCollectionViewCell class] forCellWithReuseIdentifier:goodsCellIdentifier];
    self.goodsCollectionView.backgroundColor = UIColorFromRGB(0xececec);
    self.goodsCollectionView.frame = CGRectMake(0, self.topView.frame.origin.y + self.topView.frame.size.height, self.view.frame.size.width, _goodsViewHeight);
    self.goodsCollectionView.delegate = self;
    self.goodsCollectionView.dataSource = self;
    self.goodsCollectionView.showsHorizontalScrollIndicator = NO;
    self.goodsCollectionView.hidden = NO;
    [self.view addSubview:self.goodsCollectionView];
    
    UICollectionViewFlowLayout *layout2 = [[UICollectionViewFlowLayout alloc] init];
    layout2.sectionInset = _jobEdgeInsets;
    layout2.minimumLineSpacing = 15;
    layout2.itemSize = _jobCardSiz;
    layout2.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.jobCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout2];
    [self.jobCollectionView registerClass:[JobsCollectionViewCell class] forCellWithReuseIdentifier:jobCellIdentifier];
    self.jobCollectionView.backgroundColor = [UIColor whiteColor];
    float yOffset = self.goodsCollectionView.frame.origin.y + self.goodsCollectionView.frame.size.height;
    self.jobCollectionView.frame = CGRectMake(0, yOffset, self.view.frame.size.width, _jobViewHeight);
    self.jobCollectionView.delegate = self;
    self.jobCollectionView.dataSource = self;
    self.jobCollectionView.showsHorizontalScrollIndicator = NO;
    self.jobCollectionView.hidden = NO;
    [self.view addSubview:self.jobCollectionView];
    
    [self initErrorViewUI];
}

- (void)initErrorViewUI {
    CGRect tempFrame = CGRectZero;
    tempFrame.origin = self.goodsCollectionView.frame.origin;
    tempFrame.size.width = self.view.frame.size.width;
    tempFrame.size.height = self.goodsCollectionView.frame.size.height + self.jobCollectionView.frame.size.height;
    self.errorView = [[UIView alloc] initWithFrame:tempFrame];
    self.errorView.backgroundColor = UIColorFromRGB(0xf8f8f8);
    self.errorView.hidden = YES;
    [self.view addSubview:self.errorView];
    
    float imageSide = 120.0f;
    float buttonHeight = 44.0f;
    self.errorImageView = [[UIImageView alloc] init];
    self.errorImageView.backgroundColor = [UIColor clearColor];
    self.errorImageView.frame = CGRectMake(0.5*(tempFrame.size.width - imageSide), 0.5*(tempFrame.size.width - (imageSide + buttonHeight)), imageSide, imageSide);
    [self.errorView addSubview:self.errorImageView];
    
    self.refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.refreshButton.backgroundColor = [CommonVariable grayBackgroundColor];
    self.refreshButton.titleLabel.font = GENERAL_FONT15;
    [self.refreshButton setTitleColor:[CommonVariable redFontColor] forState:UIControlStateNormal];
    [self.refreshButton addTarget:self action:@selector(touchrefreshBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.refreshButton.frame = CGRectMake(15.0f, self.errorImageView.frame.origin.y + self.errorImageView.frame.size.height, self.errorView.frame.size.width - 30.0f, buttonHeight);
    [self.errorView addSubview:self.refreshButton];
}

#pragma mark -- UICollectionViewDataSource

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.goodsCollectionView) {
        return _parttimeGoodsArr.count;
    }else {
        return _parttimeJobsArr.count;
    }
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.goodsCollectionView) {
        GoodsCollectionViewCell * cell = (GoodsCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:goodsCellIdentifier forIndexPath:indexPath];
        if (_parttimeGoodsArr.count <= indexPath.row) {
            return cell;
        }
        if (cell == nil) {
            cell = [[GoodsCollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, _goodsCardSize.width, _goodsCardSize.height)];
        }
        [cell parttimeGoodsData:[_parttimeGoodsArr objectAtIndex:indexPath.row] selectd:_goodsIndex == indexPath.row];
        return cell;
    }else{
        JobsCollectionViewCell * cell = (JobsCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:jobCellIdentifier forIndexPath:indexPath];
        if (_parttimeJobsArr.count <= indexPath.row) {
            return cell;
        }
        if (cell == nil) {
            cell = [[JobsCollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, _jobCardSiz.width, _jobCardSiz.height)];
        }
//        [cell parttimeJobsData:[_parttimeJobsArr objectAtIndex:indexPath.row]];
        [cell parttimeJobsData:[_parttimeJobsArr objectAtIndex:indexPath.row] specialCard:indexPath.row == _parttimeJobsArr.count - 1];
        return cell;
    }
}

#pragma mark --UICollectionViewDelegateFlowLayout

//定义每个UICollectionView 的大小
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return CGSizeMake(96, 100);
//}

//定义每个UICollectionView 的 margin
//-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//
//}

#pragma mark --UICollectionViewDelegate

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.goodsCollectionView) {
        if (_parttimeGoodsArr.count <= indexPath.row) {
            return;
        }
        if (_goodsIndex == indexPath.row) {
            return;
        }
        _goodsIndex = indexPath.row;
        [self.goodsCollectionView reloadData];
        
        NSString *postionId = [[_parttimeGoodsArr objectAtIndex:_goodsIndex] objectForKey:@"position_id"];
        [self requestParttimeJobs:postionId];
    }else if (collectionView == self.jobCollectionView) {
        if (_parttimeJobsArr.count <= indexPath.row) {
            return;
        }
        OrderWebViewController *vc = [_mainStoryboard instantiateViewControllerWithIdentifier:@"OrderWebIdentifier"];
        NSString *goodsId = [NSString stringWithFormat:@"%@", [[_parttimeGoodsArr objectAtIndex:_goodsIndex] objectForKey:@"goods_id"]];
        NSString *jobType = [NSString stringWithFormat:@"%@", [[_parttimeJobsArr objectAtIndex:indexPath.row] objectForKey:@"cname"]];
        vc.goodsID = [AppUtils filterNull:goodsId];
        vc.jobType = [AppUtils filterNull:jobType];
        [AppUtils pushPage:self targetVC:vc];
    }
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark 按钮响应

- (void)touchOnlyPartTimeBtn:(UIButton *)sender {
    OnlyPartTimeViewController *vc = [[OnlyPartTimeViewController alloc] init];
    [AppUtils pushPage:self targetVC:vc];
}

- (void)touchrefreshBtn:(UIButton *)sender {
    self.refreshButton.enabled = NO;
    [self requestParttimeGoods:_pageIndex];
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
