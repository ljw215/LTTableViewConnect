//
//  ViewController.m
//  LTTableViewConnect
//
//  Created by 高刘通 on 17/8/2.
//  Copyright © 2017年 LT. All rights reserved.
//

#import "ViewController.h"

#define SECTION_COUNT 20
#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property(strong, nonatomic) UITableView *leftTableView;
@property(strong, nonatomic) UITableView *rightTableView;
@property(assign, nonatomic) CGFloat lastOffsetY;
@property(assign, nonatomic) BOOL scrollDirectionIsDown;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"完美解决tableView联动";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.leftTableView];
    [self selectRowAtIndexPath:0 animated:YES];
    
    [self.view addSubview:self.rightTableView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == self.leftTableView) {
        return 1;
    }
    return SECTION_COUNT;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.leftTableView) {
        return SECTION_COUNT;
    }
    return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([self class])];
    }
    if (tableView == self.leftTableView) {
        cell.textLabel.text = [NSString stringWithFormat:@"分类 %ld",indexPath.row];;
    }else{
        cell.textLabel.text = [NSString stringWithFormat:@"内容 %ld",indexPath.row];;
    }
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor grayColor];
    if (tableView == self.leftTableView) {
        return view;
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    label.text = [NSString stringWithFormat:@"标题--> %ld",section];
    [view addSubview:label];
    return view;
}

#pragma mark - header即将出现 并且滚动方向向上，并且正在拖拽或者正在减速的时候，选中当前
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(nonnull UIView *)view forSection:(NSInteger)section
{
//    NSLog(@"%s", __func__);
    if (tableView == self.rightTableView && !_scrollDirectionIsDown && (self.rightTableView.dragging || _rightTableView.decelerating)){
        [self selectRowAtIndexPath:section animated:YES];
    }
}

#pragma mark - header即将消失 并且滚动方向向下，并且正在拖拽或者正在减速的时候，选中下一个
- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section
{
//    NSLog(@"%s", __func__);
    if (tableView == self.rightTableView && _scrollDirectionIsDown  && (self.rightTableView.dragging || self.rightTableView.decelerating)){
        [self selectRowAtIndexPath:section + 1 animated:YES];
    }
}

#pragma mark -  左边TableView处理
- (void)selectRowAtIndexPath:(NSInteger)index animated:(BOOL)animated{
    [self.leftTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:animated scrollPosition:UITableViewScrollPositionTop];
}

#pragma mark - 点击的时候对rightTableView、leftTableView的处理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (tableView == self.leftTableView){
        
        //处理rightTableView
        CGRect headerRect = [self.rightTableView rectForSection:indexPath.section];
        //self.rightTableView.contentInset.top 处理内边距 不设置则为0
        CGPoint headerY = CGPointMake(0, headerRect.origin.y - self.rightTableView.contentInset.top);
        [self.rightTableView setContentOffset:headerY animated:YES];
        
        //处理leftTableView
        [self.leftTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark -  判断rightTableView的滚动方向
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.rightTableView){
        CGFloat offsetY = scrollView.contentOffset.y;
        self.scrollDirectionIsDown = self.lastOffsetY < offsetY ? YES : NO;
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == self.rightTableView) {
        self.lastOffsetY = scrollView.contentOffset.y;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.leftTableView) {
        return 44.0f;
    }
    return 88.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == self.leftTableView) {
        return 0.0001f;
    }
    return 44.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0001f;
}

-(UITableView *)leftTableView{
    if (!_leftTableView) {
        _leftTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 100, kHeight - 64) style:UITableViewStylePlain];
        [_leftTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([self class])];
        _leftTableView.delegate = self;
        _leftTableView.dataSource = self;
    }
    return _leftTableView;
}

-(UITableView *)rightTableView{
    if (!_rightTableView) {
        _rightTableView = [[UITableView alloc] initWithFrame:CGRectMake(100, 64, kWidth - 100, kHeight - 64) style:UITableViewStylePlain];
        [_rightTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([self class])];
        _rightTableView.delegate = self;
        _rightTableView.dataSource = self;
    }
    return _rightTableView;
}

@end
