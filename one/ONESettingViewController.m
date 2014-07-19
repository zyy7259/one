//
//  ONESettingViewController.m
//  one
//
//  Created by zyy on 14-7-19.
//  Copyright (c) 2014年 bird. All rights reserved.
//

#import "ONESettingViewController.h"
#import "ONEAboutUsViewController.h"

@interface ONESettingViewController () <UITableViewDataSource, UITableViewDelegate>

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
    
    [self initCellInfos];
}

- (void)initCellInfos
{
    self.cellInfos = [NSArray arrayWithObjects:
                      @{@"imageName": @"404.jpg",
                        @"title": @"关于我们"},
                      @{@"imageName": @"404.jpg",
                        @"title": @"推荐给朋友"},
                      @{@"imageName": @"404.jpg",
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
    cell.imageView.image = [UIImage imageNamed:self.cellInfos[row][@"imageName"]];
    cell.textLabel.text = self.cellInfos[row][@"title"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            ONEAboutUsViewController *aboutUsController = [[ONEAboutUsViewController alloc] initWithNibName:NSStringFromClass([ONEAboutUsViewController class]) bundle:nil];
            [self.navigationController pushViewController:aboutUsController animated:YES];
        }
            break;
            
        default:
            break;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
