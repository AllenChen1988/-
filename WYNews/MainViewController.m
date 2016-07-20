//
//  MainViewController.m
//  WYNews
//
//  Created by Allen on 16/7/20.
//  Copyright © 2016年 Allen. All rights reserved.
//

#import "MainViewController.h"
#import "Header.h"

@interface MainViewController ()<UIScrollViewDelegate>
{
    NSMutableArray *LabArr;
}
@property (nonatomic,strong)UILabel *secLab;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    LabArr = [[NSMutableArray alloc] init];
    //设置标题
    self.title = @"艾伦新闻";
    self.view.backgroundColor = [UIColor whiteColor];
    //设置两个UIScrollView的属性
    self.TitleSc = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, WIDTH, 44)];
    self.ContentSc = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.TitleSc.frame), WIDTH, HEIGHT - CGRectGetMaxY(self.TitleSc.frame))];
    self.TitleSc.backgroundColor = [UIColor greenColor];
    
    [self.view addSubview:self.TitleSc];
    [self.view addSubview:self.ContentSc];
    
    
    //self.TitleSc.delegate = self;
    self.ContentSc.delegate = self;
    //添加子控制器
    [self AL_addChildViewController];
    
    //设置TitleSc栏目标题
    [self AL_setTitleScTitle];
    //ios7会给导航控制器下的UIScorllView顶部添加额外的滚动区域
    //设置为不添加
    self.automaticallyAdjustsScrollViewInsets = NO;
    
}
//设置TitleSc栏目标题
- (void)AL_setTitleScTitle
{
    
    NSArray *Titlec_name = @[@"头条",@"热点",@"视频",@"社会",@"订阅",@"科技"];
    for(NSInteger i = 0; i < Titlec_name.count; i ++)
    {
        //设置子控制器标题
        UIViewController *con = self.childViewControllers[i];
        con.title = Titlec_name[i];
        
        //添加lab
        UILabel  *lab = [[UILabel alloc] initWithFrame:CGRectMake(0 + i * 100, 0, 100, 44)];
        lab.text = Titlec_name[i];
        lab.textColor = [UIColor blackColor];
        [self.TitleSc addSubview:lab];
        
        lab.tag = i;
        lab.textAlignment = NSTextAlignmentCenter;
                //打开用户交互
        lab.userInteractionEnabled = YES;
        //TitleSc标题点击事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(AL_titleClick:)];
        [lab addGestureRecognizer:tap];
        //默认选中第0个
        if(i ==0)
        {
            [self AL_titleClick:tap];
        }

        //设置文字高亮
        lab.highlightedTextColor = [UIColor redColor];
        [LabArr addObject:lab];
        
    }
    //标题
    self.TitleSc.contentSize = CGSizeMake(Titlec_name.count * 100, 0);
    self.TitleSc.showsHorizontalScrollIndicator = NO;
    //内容
    self.ContentSc.contentSize = CGSizeMake(Titlec_name.count * WIDTH, 0);
    self.ContentSc.pagingEnabled = YES;
    self.ContentSc.bounces = NO;
    self.ContentSc.showsHorizontalScrollIndicator = NO;
}

//设置标题剧中
- (void)AL_setTitleCenter:(UILabel *)lab
{
    //计算偏移量
    CGFloat offsetX = lab.center.x - WIDTH*0.5;
    //min
    if(offsetX < 0)
    {
        offsetX = 0;
    }
    //max
    if(offsetX > self.TitleSc.contentSize.width - WIDTH)
    {
        offsetX = self.TitleSc.contentSize.width - WIDTH;
    }
        
    [self.TitleSc setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat curPage = scrollView.contentOffset.x/scrollView.bounds.size.width;
    //左边的角标
    NSInteger leftIndex = curPage;
    //右边
    NSInteger rightIndex = leftIndex + 1;
    //取左边lab
    UILabel *leftLab = LabArr[leftIndex];
    //右边lab
    UILabel *rightLab;
    if(rightIndex<LabArr.count-1)
    {
       rightLab = LabArr[rightIndex];
    }
    
    //计算形变的缩放比例
    CGFloat rightScale = curPage - leftIndex;
    CGFloat leftScale = 1-rightScale;
    
    //缩放
    leftLab.transform = CGAffineTransformMakeScale(leftScale*0.3+1, leftScale*0.3+1);
    rightLab.transform = CGAffineTransformMakeScale(rightScale*0.3+1, rightScale*0.3+1);
    
    //颜色渐变
    leftLab.textColor = [UIColor colorWithRed:leftScale green:0 blue:0 alpha:1];
    rightLab.textColor = [UIColor colorWithRed:rightScale green:0 blue:0 alpha:1];
   
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //计算滚动哪一页
    NSInteger index = scrollView.contentOffset.x/scrollView.bounds.size.width;
    //对应的标题选中
    UILabel *lab = LabArr[index];
    [self AL_selectLab:lab];
    
    [self AL_showView:index];
    
    [self AL_setTitleCenter:lab];
    
    
    
}
//添加子控制器view
- (void)AL_showView:(NSInteger)index
{
    //取控制器
    UIViewController *vc = self.childViewControllers[index];
    //判断加载没
    if(vc.isViewLoaded) return;
    vc.view.frame = CGRectMake(index *WIDTH, 0, WIDTH, self.ContentSc.bounds.size.height);
    
    //添加控制器
    [self.ContentSc addSubview:vc.view];
}

//TitleSc标题点击事件
-(void)AL_titleClick:(UITapGestureRecognizer *)tap
{
    //获取当前被点击的lab
    
    UILabel *lab = (UILabel *)tap.view;
    NSLog(@"%@lab被点击",lab.text);
    /*
     1.设置标题字体颜色变红,并加高亮
     2.滚动到相应位置   1'计算滚动距离
     3.给对应的位置添加控制器
     */
    //1
    [self AL_selectLab:lab];
    //2.1
    CGFloat offsetX = lab.tag * WIDTH;
    //2.2
    self.ContentSc.contentOffset = CGPointMake(offsetX, 0);
    //3取控制器
    [self AL_showView:lab.tag];
    
    [self AL_setTitleCenter:lab];
    
    
}
//设置lab
-(void)AL_selectLab:(UILabel *)lab
{
    //回复原样
    _secLab.highlighted = NO;
    _secLab.transform = CGAffineTransformIdentity;
    _secLab.textColor = [UIColor blackColor];
    lab.highlighted = YES;
    //放大
    lab.transform = CGAffineTransformMakeScale(1.3, 1.3);
    _secLab = lab;
}
//添加子控制器
- (void)AL_addChildViewController
{
    //头条
    TopViewController *top = [[TopViewController alloc]init];
    [self addChildViewController:top];
    
    //热点
    HotViewController *hot = [[HotViewController alloc]init];
    [self addChildViewController:hot];
    
    //视频
    VideoViewController *video = [[VideoViewController alloc]init];
    [self addChildViewController:video];
    
    //社会
    SocietyViewController *Soci = [[SocietyViewController alloc]init];
    [self addChildViewController:Soci];
    
    //订阅
    ReadViewController *read = [[ReadViewController alloc]init];
    [self addChildViewController:read];
    
    //科技
    TecViewController *tec = [[TecViewController alloc]init];
    [self addChildViewController:tec];
    
}


@end























