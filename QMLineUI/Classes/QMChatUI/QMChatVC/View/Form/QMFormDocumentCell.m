//
//  QMFormDocumentCell.m
//  IMSDK
//
//  Created by lishuijiao on 2021/1/12.
//

#import "QMFormDocumentCell.h"
#import "QMFileManagerController.h"
#import <Photos/Photos.h>
#import "QMChatRoomViewController.h"
#import "QMChatShowRichTextController.h"
#import "QiniuSDK.h"
#import "QMChatUI.h"

@interface QMFormDocumentCell ()

@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) UIButton *uploadButton;

@property (nonatomic, strong) NSDictionary *dataDic;

@property (nonatomic, strong) UIView *fileView;

@property (nonatomic, strong) UIView *sendView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UIView *progressView;

@property (nonatomic, strong) UIView *progressCView;

@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) NSArray *filelist;

@property (nonatomic, strong) NSArray *cancelOption;//取消上传用到
@end

@implementation QMFormDocumentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.dataDic = [[NSDictionary alloc] init];
        self.filelist = [[NSArray alloc] init];
        self.cancelOption = [[NSArray alloc] init];
        
        [self.contentView addSubview:self.coverView];
        [self.coverView addSubview:self.uploadButton];
        
        [self.uploadButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.coverView.mas_bottom).offset(-40);
            make.left.right.bottom.equalTo(self.coverView);
            make.height.mas_equalTo(40);
        }];
        
        
        [self.fileView addSubview:self.sendView];
        [self.sendView addSubview:self.nameLabel];
        [self.sendView addSubview:self.cancelButton];
        [self.sendView addSubview:self.progressView];
        
        [self.sendView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.fileView).offset(QM_kScreenHeight/2-50);
            make.left.equalTo(self.fileView).offset(50);
            make.right.equalTo(self.fileView).offset(-50);
            make.height.mas_equalTo(100);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.sendView).offset(10);
            make.left.equalTo(self.sendView).offset(30);
            make.right.equalTo(self.sendView).offset(-30);
            make.height.mas_equalTo(30);
        }];
        
        [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.sendView).offset(10);
            make.left.equalTo(self.sendView.mas_right).offset(-25);
            make.width.height.mas_equalTo(15);
        }];
        
        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(20);
            make.left.equalTo(self.sendView).offset(10);
            make.right.equalTo(self.sendView).offset(-10);
            make.height.mas_equalTo(10);
        }];
        
        [self.progressView addSubview:self.progressCView];

        
        [self.progressCView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self.progressView);
            make.height.mas_equalTo(10);
            make.width.mas_equalTo(0);
        }];

    }
    return self;
}

- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [[UIView alloc] init];
        _coverView.backgroundColor = [UIColor whiteColor];
        _coverView.tag = 301;
    }
    return _coverView;
}

- (UIButton *)uploadButton {
    if (!_uploadButton) {
        _uploadButton = [[UIButton alloc] init];
        _uploadButton.tag = 401;
        _uploadButton.layer.masksToBounds = YES;
        _uploadButton.layer.cornerRadius = 8;
        _uploadButton.layer.borderWidth = 0.5;
        _uploadButton.layer.borderColor = [UIColor colorWithHexString:@"#CACACA"].CGColor;
        _uploadButton.titleLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:15];
        [_uploadButton setImage:[UIImage imageNamed:@"QMForm_upload"] forState:UIControlStateNormal];
        [_uploadButton setTitle:@"选择文件 (50M 以内)" forState:UIControlStateNormal];
        [_uploadButton setTitleColor:[UIColor colorWithHexString:QMColor_333333_text] forState:UIControlStateNormal];
        [_uploadButton setBackgroundColor:[UIColor colorWithHexString:QMColor_FFFFFF_text]];
        [_uploadButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, -20, 0.0, 0.0)];
        [_uploadButton addTarget:self action:@selector(uploadAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _uploadButton;
}

- (UIView *)fileView {
    if (!_fileView) {
        _fileView = [[UIView alloc] init];
        _fileView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _fileView;
}

- (UIView *)sendView {
    if (!_sendView) {
        _sendView = [[UIView alloc] init];
        _sendView.backgroundColor = UIColor.whiteColor;
    }
    return _sendView;
}

- (UIView *)progressView {
    if (!_progressView) {
        _progressView = [[UIView alloc] init];
        _progressView.backgroundColor = UIColor.clearColor;
        _progressView.layer.borderWidth = 1;
        _progressView.layer.borderColor = [UIColor colorWithHexString:QMColor_News_Custom].CGColor;
    }
    return _progressView;
}

- (UIView *)progressCView {
    if (!_progressCView) {
        _progressCView = [[UIView alloc] init];
        _progressCView.backgroundColor = [UIColor colorWithHexString:QMColor_News_Custom];
    }
    return _progressCView;
}


- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor colorWithHexString:QMColor_666666_text];
        _nameLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:13];
    }
    return _nameLabel;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] init];
        [_cancelButton setImage:[UIImage imageNamed:@"qm_common_cancel"] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (void)setModel:(NSDictionary *)model {
    [super setModel:model];
    
    self.dataDic = model;
    
    self.filelist = model[@"filelist"];
    CGFloat viewHeight = _filelist.count ? _filelist.count * 50 + 40 : 40;
    
    [self.coverView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(11);
        make.left.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
        make.height.mas_equalTo(viewHeight);
        make.bottom.equalTo(self.contentView).offset(0);
    }];
    
    for (id item in self.coverView.subviews) {
        if ([item isKindOfClass:[UIButton class]]) {
            if (((UIButton *)item).tag != 401) {
                [item removeFromSuperview];
            }
        }
    }

    [self createButton:self.filelist];
}

- (void)createButton:(NSArray *)array {
    for (int i = 0; i < array.count; i++) {
        UIButton *button = [[UIButton alloc] init];
        button.tag = 500 + i;
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 8;
        button.layer.borderWidth = 0.5;
        button.layer.borderColor = [UIColor colorWithHexString:@"#CACACA"].CGColor;
        button.titleLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:14];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
        NSString *name = array[i][@"name"];
        [button setImage:[UIImage imageNamed:[self matchImageWithFileNameExtension: name.pathExtension.lowercaseString]] forState:UIControlStateNormal];
        [button setTitle:array[i][@"name"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHexString:QMColor_999999_text] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(senderAction:) forControlEvents:UIControlEventTouchUpInside];

        [self.coverView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.coverView).offset(50*i);
            make.left.right.equalTo(self.coverView);
            make.height.mas_equalTo(40);
        }];
        
        UIButton *deleteBtn = [[UIButton alloc] init];
        deleteBtn.tag = 600 + i;
        deleteBtn.layer.masksToBounds = YES;
        deleteBtn.layer.cornerRadius = 7.5;
        [deleteBtn setImage:[UIImage imageNamed:@"QMForm_delete"] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.coverView addSubview:deleteBtn];
        
        [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.coverView).offset(50*i - 7.5);
//            make.left.equalTo(self.coverView.mas_right).offset(-7.5);
            make.left.equalTo(self.coverView.mas_right).offset(-9);
            make.width.height.mas_equalTo(15);
        }];

    }
}

- (NSString *)matchImageWithFileNameExtension:(NSString *)fileName {
    NSString * str;
    if ([fileName isEqualToString:@"doc"]||[fileName isEqualToString:@"docx"]) {
        str = @"doc";
    }else if ([fileName isEqualToString:@"xlsx"]||[fileName isEqualToString:@"xls"]) {
        str = @"xls";
    }else if ([fileName isEqualToString:@"ppt"]||[fileName isEqualToString:@"pptx"]) {
        str = @"pptx";
    }else if ([fileName isEqualToString:@"pdf"]) {
        str = @"pdf";
    }else if ([fileName isEqualToString:@"mp3"]) {
        str = @"mp3";
    }else if ([fileName isEqualToString:@"mov"]||[fileName isEqualToString:@"mp4"]) {
        str = @"mov";
    }else if ([fileName isEqualToString:@"png"]||[fileName isEqualToString:@"jpg"]||[fileName isEqualToString:@"bmp"]||[fileName isEqualToString:@"jpeg"]) {
        str = @"png";
    }else {
        str = @"other";
    }
    return [NSString stringWithFormat:@"qm_file_%@", str];
}


- (void)senderAction:(UIButton *)button {
    NSInteger number = button.tag - 500;
    NSDictionary *dic = self.filelist[number];
    QMChatShowRichTextController *showFile = [[QMChatShowRichTextController alloc] init];
    showFile.modalPresentationStyle = UIModalPresentationFullScreen;
    showFile.urlStr = dic[@"url"];
    showFile.isForm = YES;
    UIViewController *vc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [vc presentViewController:showFile animated:YES completion:nil];
}

- (void)deleteAction:(UIButton *)button {

    NSLog(@"deleteButton");
    NSInteger number = button.tag - 600;
    NSMutableArray *newArray = self.filelist.mutableCopy;
    if (self.filelist.count >= number) {
        NSDictionary *dic = newArray[number];
        NSString *fileUrl = dic[@"url"];
        NSString *fileName = dic[@"name"];
        NSString *str = [NSString stringWithFormat:@"<a href='%@'target='_blank'>%@</a>",fileUrl, fileName];

        NSString *value = self.dataDic[@"value"];
        if (value.length) {
            value = [value stringByReplacingOccurrencesOfString:str withString:@""];
            NSLog(@"删除之后的value===%@",value);
        }
        
        
        [newArray removeObjectAtIndex:number];
        NSMutableDictionary *newDict = self.dataDic.mutableCopy;
        [newDict setValue:newArray forKey:@"filelist"];
        [newDict setValue:value forKey:@"value"];
        self.baseSelectValue(newDict);
    }
}

#pragma mark -- buttonAction
- (void)uploadAction {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case PHAuthorizationStatusAuthorized: {
                    QMFileManagerController *fileVC = [[QMFileManagerController alloc] init];
                    fileVC.isForm = YES;
                   
                    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
                    if ([vc isKindOfClass:[UINavigationController class]]) {
                        [(UINavigationController *)vc pushViewController:fileVC animated:true];
                    } else {
                        [vc.navigationController pushViewController:fileVC animated:true];
                    }
                    
                    fileVC.callBackBlock = ^(NSString *name, NSString *size, NSString *path) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSDictionary *dic = @{
                                @"fileName" : name,
                                @"fileSize" : size,
                                @"filePath" : path
                            };
                            [self UploadDataDicWithFile:dic];
                        });
                    };
                }
                    break;
                case PHAuthorizationStatusDenied: {
                    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"title.prompt", nil) message: NSLocalizedString(@"title.photoAuthority", nil) preferredStyle: UIAlertControllerStyleAlert];
                    
                    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"button.set", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        if (UIApplicationOpenSettingsURLString != NULL) {
                            NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                            [[UIApplication sharedApplication] openURL:appSettings];
                        }
                    }];
                    
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"button.cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    [alertController addAction:action];
                    [alertController addAction:cancelAction];
                    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:alertController animated:YES completion:nil];
                }
                    break;
                case PHAuthorizationStatusRestricted:
                    NSLog(@"相册访问受限!");
                    break;
                default:
                    break;
            }
        });
    }];
}

- (void)UploadDataDicWithFile:(NSDictionary *)fileDic {
    [QMConnect sdkSendFile:fileDic progress:^(float progress) {
        @weakify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            [self setProgress:progress];
            
            self.nameLabel.text = fileDic[@"fileName"];
            [[UIApplication sharedApplication].keyWindow addSubview:self.fileView];
            [self.fileView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo([UIApplication sharedApplication].keyWindow);
            }];
        });
    } success:^(NSString *fileUrl) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.fileView removeFromSuperview];
            
            BOOL isCancel = NO;
            NSString *name = @"";
            for (id item in self.cancelOption) {
                if ([fileUrl rangeOfString:item].location != NSNotFound) {
                    name = item;
                    isCancel = YES;
                }
            }
            
            if (!isCancel) {
                NSMutableArray *newArray = [NSMutableArray array];
                if (self.filelist.count) {
                    newArray = self.filelist.mutableCopy;
                }
                NSDictionary *dic = @{
                    @"name" : fileDic[@"fileName"],
                    @"url"  : fileUrl
                };
                [newArray addObject: dic];
                NSMutableDictionary *newDict = self.dataDic.mutableCopy;
                [newDict setValue:newArray forKey:@"filelist"];
                
                NSString *value = self.dataDic[@"value"];
                NSString *str = [NSString stringWithFormat:@"<a href='%@'target='_blank'>%@</a>",fileUrl, fileDic[@"fileName"]];
                if (value.length) {
                    value = [value stringByAppendingFormat:@",%@",str];
                }else {
                    value = str;
                }
                [newDict setValue:value forKey:@"value"];
                self.baseSelectValue(newDict);
            }
            NSMutableArray *array = self.cancelOption.mutableCopy;
            [array removeObject:name];
            self.cancelOption = array;
        });
    } failBlock:^(NSString *reaseon) {
        NSLog(@"reaseon===%@", reaseon);
    }];
}
- (void)cancelAction {
    NSMutableArray *array = _cancelOption.mutableCopy;
    [array addObject:self.nameLabel.text];
    self.cancelOption = array;
    [self.fileView removeFromSuperview];
}

- (void)setProgress: (float)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat pWidth = CGRectGetWidth(self.progressView.frame) * progress;
        [self.progressCView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(pWidth);
        }];
    });
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
