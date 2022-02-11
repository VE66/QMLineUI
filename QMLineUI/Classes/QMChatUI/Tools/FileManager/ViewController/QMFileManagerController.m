//
//  QMFileManagerController.m
//  IMSDK-OC
//
//  Created by HCF on 16/8/10.
//  Copyright © 2016年 HCF. All rights reserved.
//

#import "QMFileManagerController.h"
#import "QMItemCollectionCell.h"

#import "QMPickedPhotoViewController.h"
#import "QMPickedVideoViewController.h"
#import "QMPickedDocViewController.h"
#import "QMPickedAudioViewController.h"
#import "QMPickedOtherViewController.h"
#import "QMChatUI.h"


/**
 
 */
@interface QMFileManagerController ()<UICollectionViewDelegate, UICollectionViewDataSource> {
    UICollectionView *_collectionView;
    NSArray *_items;
}

@end

@implementation QMFileManagerController

- (void)viewDidLoad {
    [super viewDidLoad];
//    _items = @[NSLocalizedString(@"button.chat_file", nil), NSLocalizedString(@"button.chat_img", nil), NSLocalizedString(@"button.chat_music", nil), NSLocalizedString(@"button.chat_video", nil), NSLocalizedString(@"button.chat_other", nil)];
    _items = @[@"QM_ToolBar_File_File", @"QM_ToolBar_File_Picture", @"QM_ToolBar_File_Music", @"QM_ToolBar_File_Video", @"QM_ToolBar_File_Other"];

    [self createUI];
}

- (void)changeUserInfaceStyle {
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Nav_Bg_Dark : QMColor_Nav_Bg_Light];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_ECECEC_BG : QMColor_News_Custom];

    self.view.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_Main_Bg_Light];
    _collectionView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_Main_Bg_Light];
    
    [_collectionView reloadData];
}

- (void)dealloc {
    
}

- (void)createUI {
    self.view.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_Main_Bg_Light];
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((QM_kScreenWidth-100)/3, (QM_kScreenWidth-100)/3);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(25, 25, 25, 25);
    layout.minimumLineSpacing = 20;
    layout.minimumInteritemSpacing = 1.0;
    layout.headerReferenceSize = CGSizeMake(0, 0);

    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, QM_kScreenWidth, QM_kScreenHeight-64) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_Main_Bg_Light];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.layer.masksToBounds = YES;
    _collectionView.layer.cornerRadius = 5;
    [self.view addSubview:_collectionView];
    
    [_collectionView registerClass:[QMItemCollectionCell self] forCellWithReuseIdentifier:NSStringFromClass(QMItemCollectionCell.self)];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString * name = _items[indexPath.item];
    if ([cell isKindOfClass:[QMItemCollectionCell class]]) {
        QMItemCollectionCell * displayCell = (QMItemCollectionCell *)cell;
        [displayCell configureWithName:name];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QMItemCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(QMItemCollectionCell.self) forIndexPath:indexPath];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {    
    switch (indexPath.item) {
        case 0: {
            QMPickedDocViewController *viewController = [[QMPickedDocViewController alloc] init];
            viewController.isForm = self.isForm;
            viewController.callBackBlock = ^(NSString *name, NSString *size, NSString *path) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.callBackBlock(name, size, path);
                });
            };
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        case 1: {
            QMPickedPhotoViewController *viewController = [[QMPickedPhotoViewController alloc] init];
            viewController.isForm = self.isForm;
            viewController.callBackBlock = ^(NSString *name, NSString *size, NSString *path) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.callBackBlock(name, size, path);
                });
            };
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        case 2: {
            QMPickedAudioViewController *viewController = [[QMPickedAudioViewController  alloc] init];
            viewController.isForm = self.isForm;
            viewController.callBackBlock = ^(NSString *name, NSString *size, NSString *path) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.callBackBlock(name, size, path);
                });
            };
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        case 3: {
            QMPickedVideoViewController *viewController = [[QMPickedVideoViewController alloc] init];
            viewController.isForm = self.isForm;
            viewController.callBackBlock = ^(NSString *name, NSString *size, NSString *path) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.callBackBlock(name, size, path);
                });
            };
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        case 4: {
            QMPickedOtherViewController *viewController = [[QMPickedOtherViewController alloc] init];
            viewController.isForm = self.isForm;
            viewController.callBackBlock = ^(NSString *name, NSString *size, NSString *path) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.callBackBlock(name, size, path);
                });
            };
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end

