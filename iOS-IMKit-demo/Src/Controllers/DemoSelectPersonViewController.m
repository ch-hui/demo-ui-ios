//
//  DemoSelectPersonViewController.m
//  iOS-IMKit-demo
//
//  Created by Liv on 14/11/26.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "DemoSelectPersonViewController.h"
#import "ShareFriend.h"

@interface DemoSelectPersonViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSMutableArray *userList;
@property (nonatomic,strong) NSMutableArray *selectedUsers;

@end

@implementation DemoSelectPersonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doDone:)];
    
    self.personTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 640) style:UITableViewStylePlain];
    self.personTableView.dataSource = self;
    self.personTableView.delegate = self;
    
    self.selectedUsers = [NSMutableArray new];
}
-(void) doDone:(id) sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.delegate didSelectedPersons:self.selectedUsers viewController:self];


}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[ShareFriend shareInstance] friendList] count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ssCell"];
    RCUserInfo *userInfo = [[ShareFriend shareInstance] friendList][indexPath.row];
    cell.textLabel.text = userInfo.name;
    return cell;
}



#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCUserInfo *userInfo = [[ShareFriend shareInstance] friendList][indexPath.row];
    if([self.selectedUsers containsObject:userInfo])
        [self.selectedUsers removeObject:userInfo];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.editing = YES;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    RCUserInfo *userInfo = [[ShareFriend shareInstance] friendList][indexPath.row];
    
    if (cell.selected) {
        [self.selectedUsers addObject:userInfo];
    }

    NSLog(@"selected !");
}
@end
