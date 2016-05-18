//
//  CategoriesGoodsListViewController.h
//  renrenfenqi
//
//  Created by coco on 15-4-7.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
    商品列表页
 */

enum ListType {
    ListTypeList  = 0,        /**< 列表视图    */
    ListTypeImage = 1,        /**< 图片视图    */
};

@interface CategoriesGoodsListViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITableView *goodsListTable;
@property (weak, nonatomic) IBOutlet UICollectionView *goodsListCollection;
@property (weak, nonatomic) IBOutlet UISegmentedControl *listTypeSegment;

@property (strong, nonatomic) NSString *categoryName;
@property (strong, nonatomic) NSString *brandID;
@property (strong, nonatomic) NSString *type;
- (IBAction)doBack:(id)sender;
- (IBAction)doListTypeChanged:(id)sender;

@end
