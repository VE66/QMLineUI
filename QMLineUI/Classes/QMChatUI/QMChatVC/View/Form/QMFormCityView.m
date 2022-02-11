//
//  QMFormCityView.m
//  IMSDK
//
//  Created by lishuijiao on 2021/1/12.
//

#import "QMFormCityView.h"
#import "QMChatUI.h"

@interface QMFormCityView ()<UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate>

//picker控件数据源
@property(nonatomic,strong)NSMutableArray *showAddressArr;
//picker控件默认展示的元素下标
@property(nonatomic,strong)NSMutableArray *showIndexs;

@property (nonatomic, strong) UIView *pickerContainerView;
@property (nonatomic, strong) UIPickerView *pickerView;

@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) NSDictionary *dataDic;

@end

@implementation QMFormCityView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.pickerContainerView];
        [self.pickerContainerView addSubview:self.toolBar];
        [self.toolBar addSubview:self.titleLabel];
        [self.pickerContainerView addSubview:self.pickerView];
                
        UITapGestureRecognizer * tapPressGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        tapPressGesture.delegate = self;
        [self addGestureRecognizer:tapPressGesture];

        [self.pickerContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(QM_kScreenHeight - 180 - 44);
            make.left.right.equalTo(self);
            make.height.mas_equalTo(180 + 44);
        }];
        
        [self.toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.pickerContainerView);
            make.height.mas_equalTo(44);
        }];

        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.toolBar);
            make.width.mas_equalTo(200);
        }];

        [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.toolBar.mas_bottom);
            make.left.right.equalTo(self.toolBar);
        }];

    }
    return self;
}

- (UIView *)pickerContainerView {
    if (!_pickerContainerView) {
        _pickerContainerView = [[UIView alloc] init];
    }
    return _pickerContainerView;
}

- (UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        _pickerView.backgroundColor = [UIColor whiteColor];
    }
    return _pickerView;
}

- (UIToolbar *)toolBar {
    if (!_toolBar) {
        _toolBar = [[UIToolbar alloc] init];
        _toolBar.barTintColor = UIColor.whiteColor;
        UIBarButtonItem *noSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        noSpace.width=10;

        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(doneAction:)];;
        doneBtn.tintColor = [UIColor grayColor];

        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
        cancelBtn.tintColor = [UIColor grayColor];

        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [_toolBar setItems:[NSArray arrayWithObjects:noSpace,cancelBtn,flexSpace,doneBtn,noSpace, nil]];
    }
    return _toolBar;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.center = _toolBar.center;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor darkTextColor];
        _titleLabel.text = @"省市区选择";
    }
    return _titleLabel;
}

- (NSMutableArray *)showIndexs {
    if (!_showIndexs) {
        _showIndexs = [NSMutableArray array];
    }
    return _showIndexs;
}

- (NSMutableArray *)showAddressArr {
    if (!_showAddressArr) {
        _showAddressArr = [NSMutableArray array];
    }
    return _showAddressArr;
}

- (NSDictionary *)dataDic {
    if (!_dataDic) {
        _dataDic = [NSDictionary dictionary];
    }
    return _dataDic;
}

- (void)setModel:(NSDictionary *)model {
    self.dataDic = model;
    NSString *value = model[@"value"];
    NSArray *newModel = @[@"",@"",@""];
    if (value.length) {
        newModel = [value componentsSeparatedByString:@"-"];
    }
    [self createinitWith:newModel];
}

-(void)createinitWith:(NSArray *)defaultValues {
    //加载本地json数据
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:jsonPath];
    NSError *error = nil;
    NSArray *citysArr = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    //初始化源数据
    [self defaultShowValue:[NSMutableArray arrayWithArray:defaultValues] items:citysArr];
}

-(void)defaultShowValue:(NSMutableArray *)values items:(NSArray *)items {
    [items enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([@"" isEqualToString:[values firstObject]])
        {
            //values中没有默认值的时候values中的元素目前为@""空字符
            [self.showIndexs addObject:@(0)];
            [values removeObjectAtIndex:0];
            [self.showAddressArr addObject:items];
            [self defaultShowValue:values items:obj[@"children"]];
            
        }
        else if ([obj[@"label"] isEqualToString:[values firstObject]])
        {
            [self.showIndexs addObject:@(idx)];
            [values removeObjectAtIndex:0];
            [self.showAddressArr addObject:items];
            [self defaultShowValue:values items:obj[@"children"]];
        }
    }];
    
    [self selectedIndex];
}

- (void)selectedIndex {
    for (NSInteger index = 0; index < [self.showIndexs count]; index ++) {
        
        [self.pickerView selectRow:[[self.showIndexs objectAtIndex:index] integerValue] inComponent:index animated:NO];
    }
}

#pragma mark - tapPressGesture
- (void)tapAction {
    [self removeFromSuperview];
}

#pragma mark -- buttonAction
-(void)doneAction:(UIButton *)button {

    if (self.selectValue) {
        NSMutableArray *resultArr = [NSMutableArray array];
        [self.showAddressArr enumerateObjectsUsingBlock:^(NSArray *objArr, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *selectedItem = [objArr objectAtIndex:[[self.showIndexs objectAtIndex:idx] integerValue]];
            [resultArr addObject:selectedItem];
        }];
        
        NSString *province = [resultArr objectAtIndex:0][@"label"];
        NSString *city = [resultArr objectAtIndex:1][@"label"];
        NSString *county = [resultArr objectAtIndex:2][@"label"];
        NSString *value = [NSString stringWithFormat:@"%@-%@-%@",province,city,county];

        NSMutableDictionary *newDic = self.dataDic.mutableCopy;
        [newDic setValue:value forKey:@"value"];
        
        self.selectValue(newDic);
    }
    [self tapAction];
}

-(void)cancelAction:(UIButton *)button {
    [self tapAction];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UIPickerTableViewWrapperCell"]) {
        return NO;
    }else if ([NSStringFromClass([touch.view class]) isEqualToString:@"UIButton"]) {
        return NO;
    }else if ([NSStringFromClass([touch.view class]) isEqualToString:@"UIButtonBarStackView"]) {
        return NO;
    }
    
    return YES;
}

#pragma mark-- UIPickerViewDataSource
//列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return [self.showIndexs count];
}

//每列个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[self.showAddressArr objectAtIndex:component] count];
}


#pragma mark-- UIPickerViewDelegate
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = (id)view;
    if (!label) {
        label= [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView rowSizeForComponent:component].width, [pickerView rowSizeForComponent:component].height)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        NSDictionary *dic = [[self.showAddressArr objectAtIndex:component] objectAtIndex:row];
        label.text = dic[@"label"];
    }
    return label;
}

//点击选择
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSArray *columnItems = [self.showAddressArr objectAtIndex:component];
    NSDictionary *selectedItem = [columnItems objectAtIndex:row];
    
    if ([selectedItem[@"children"] count] == 0) {
        //此时为最后一列可能就一列或多列的最后一列
        [self.showIndexs replaceObjectAtIndex:component withObject:@(row)];
    }else{
        
        NSUInteger replaceIdx = component;
        BOOL next = true;
        while (next) {
            if (component == replaceIdx) {
                [self.showIndexs replaceObjectAtIndex:replaceIdx withObject:@(row)];
            }else{
                
                if (replaceIdx < [self.showIndexs count]) {
                    
                    [self.showAddressArr replaceObjectAtIndex:replaceIdx withObject:selectedItem[@"children"]];
                    [self.showIndexs replaceObjectAtIndex:replaceIdx withObject:@(0)];
                    selectedItem = [selectedItem[@"children"] firstObject];
                }else{
                    next = false;
                }
            }
            
            replaceIdx ++;
        }
        
    }
    [pickerView reloadAllComponents];
    //实时更新选择数据及联数据
    for (NSInteger index = 0; index < [self.showIndexs count]; index ++) {
        
        [self.pickerView selectRow:[[self.showIndexs objectAtIndex:index] integerValue] inComponent:index animated:NO];
    }
}


@end
