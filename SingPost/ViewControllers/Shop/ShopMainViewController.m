//
//  ShopMainViewController.m
//  SingPost
//
//  Created by Edward Soetiono on 9/10/13.
//  Copyright (c) 2013 Codigo. All rights reserved.
//

#import "ShopMainViewController.h"
#import "AppDelegate.h"
#import "SampleArticleContentViewController.h"

@interface ShopMainViewController ()

@end

@implementation ShopMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setPageTitle:@"Shop"];
    [self setIsRootLevel:YES];
    
    NSArray *data = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Shop" ofType:@"plist"]];
    [self setItems:[data valueForKey:@"category"]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int dataRow = floorf(indexPath.row / 2.0f);
    SampleArticleContentViewController *viewController = [[SampleArticleContentViewController alloc] initWithNibName:nil bundle:nil];
    [viewController setPageTitle:self.items[dataRow]];
    [[AppDelegate sharedAppDelegate].rootViewController cPushViewController:viewController];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
