//
//  QMChatAssociationInputView.m
//  IMSDK
//
//  Created by lishuijiao on 2020/10/15.
//

#import "QMChatAssociationInputView.h"
#import "QMChatUI.h"
@implementation QMChatAssociationInputView {
    
    NSArray *_questions;
    
    UITableView *_tableView;
    
    UILabel *_lineLabel;
    
    NSString *_inputText;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Nav_Bg_Dark : QMColor_Nav_Bg_Light];
        [self createView];
    }
    return  self;
}

- (void)createView {
    _tableView = [[UITableView alloc] init];
    _tableView.frame = self.bounds;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.scrollEnabled = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self addSubview:_tableView];
    
    _lineLabel = [[UILabel alloc] init];
    _lineLabel.frame = CGRectMake(0, 0, QM_kScreenWidth, 0.6);
    _lineLabel.backgroundColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1];
    [self addSubview:_lineLabel];
}

- (void)showData:(NSArray *)array andInputText:(NSString *)text {
    _inputText = text;
    _questions = array;
    _tableView.frame = CGRectMake(0, 0, QM_kScreenWidth, array.count*50);
    [_tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _questions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"associationInputCell";
    QMChatAssociationInputCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[QMChatAssociationInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
//    cell.questionLabel.text = _questions[indexPath.row];
    [cell setText:_questions[indexPath.row] withSelectText:_inputText];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    NSString *question = _questions[indexPath.row];
    self.questionsSelect(question);
}

@end

@implementation QMChatAssociationInputCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI {
    self.backgroundColor = [UIColor clearColor];
    
    self.questionLabel = [[UILabel alloc] init];
    self.questionLabel.frame = CGRectMake(15, 15, QM_kScreenWidth - 30, 20);
    self.questionLabel.text = @"";
    self.questionLabel.font = [UIFont systemFontOfSize:15];
    self.questionLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_FFFFFF_text : QMColor_666666_text];
    [self.contentView addSubview:self.questionLabel];
}

- (void)setText:(NSString *)text withSelectText:(NSString *)selectText {
    
    NSAttributedString *attrStr = [QMLabelText colorAttributeString:text sourceSringColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_FFFFFF_text : QMColor_666666_text] sourceFont:[UIFont systemFontOfSize:15] keyWordArray:@[selectText] keyWordColor:[UIColor orangeColor] keyWordFont:[UIFont systemFontOfSize:15]];
    self.questionLabel.attributedText = attrStr;
}

@end
