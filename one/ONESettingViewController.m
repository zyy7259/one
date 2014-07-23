//
//  ONESettingViewController.m
//  one
//
//  Created by zyy on 14-7-19.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONESettingViewController.h"
#import "ONEAboutUsViewController.h"
#import "ONEResourceManager.h"
#import "ONEShareViewController.h"

@interface ONESettingViewController () <UITableViewDataSource, UITableViewDelegate, ONEShareDelegate>

@property (weak, nonatomic) IBOutlet UITableView *settingTableView;
@property NSArray *cellInfos;

@end

@implementation ONESettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.settingTableView.delegate = self;
    self.settingTableView.dataSource = self;
    self.settingTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self initCellInfos];
}

- (void)initCellInfos
{
    ONEResourceManager *resourceManager = [ONEResourceManager sharedManager];
    self.cellInfos = [NSArray arrayWithObjects:
                      @{@"image": resourceManager.aboutUsImage,
                        @"title": @"关于我们"},
                      @{@"image": resourceManager.likeUsImage,
                        @"title": @"推荐给朋友"},
                      @{@"image": resourceManager.scoreUsImage,
                        @"title": @"评个分吧"},
                      nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingPrototypeCell" forIndexPath:indexPath];
    
    NSInteger row = indexPath.row;
    cell.imageView.image = self.cellInfos[row][@"image"];
    cell.textLabel.text = self.cellInfos[row][@"title"];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[ONEResourceManager sharedManager].arrowRightGreyImage];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    // 给当前选中的cell加一个背景色，给用户的点击一个反馈
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:223.0/255.0 green:223.0/255.0 blue:223.0/255.0 alpha:1.0];
    // 不同的cell切换不同的内容
    switch (indexPath.row) {
        case 0:
        {
            // 切换界面
            ONEAboutUsViewController *aboutUsController = [[ONEAboutUsViewController alloc] initWithNibName:NSStringFromClass([ONEAboutUsViewController class]) bundle:nil];
            [self.navigationController pushViewController:aboutUsController animated:YES];
        }
            break;
        case 1:
        {
            [[ONEShareViewController sharedShareViewControllerWithDelegate:self] shareApp];
        }
            break;
        default:
            break;
    }
    // 界面切换大概结束后恢复cell的背景色
    [self performSelector:@selector(resetCellBackgroundColor:) withObject:cell afterDelay:0.1];
}

- (void)resetCellBackgroundColor:(UITableViewCell *)cell
{
    cell.backgroundColor = [UIColor whiteColor];
}

/*
# pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
