//
//  HomeViewController.m
//  iOS-IMKit-demo
//
//  Created by xugang on 7/24/14.
//  Copyright (c) 2014 Heq.Shinoda. All rights reserved.
//

#import "HomeViewController.h"
#import "UserDataModel.h"
#import "UserInfoViewController.h"
#import "DemoChatListViewController.h"
#import "DemoChatViewController.h"
#import "RCHandShakeMessage.h"
#import "RCGroup.h"
#import "DemoCommonConfig.h"
#import "DemoRichContentMessageViewController.h"
#import "RCHttpRequest.h"
#import "SigninViewController.h"
#import "ShareFriend.h"

@interface HomeViewController ()<RCIMConnectionStatusDelegate,RCIMGroupInfoFetcherDelegate,HttpConnectionDelegate,RCIMUserInfoFetcherDelegagte,RCIMFriendsFetcherDelegate>

@property (strong,nonatomic) NSMutableArray *allFriendsArray;
@property (nonatomic,strong) RCHttpRequest *friendRquest;
@end

@implementation HomeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.groupList = [[NSMutableArray alloc]init];
        
        RCGroup *group001 = [[RCGroup alloc]init];
        group001.groupId = @"group001";
        group001.groupName =@"群组一";
        group001.portraitUri = @"https://i0.wp.com/developer.files.wordpress.com/2013/01/60b40db1e3946a29262eda6c78f33123.jpg?w=100";
        [_groupList addObject:group001];
        
        RCGroup *group002 = [[RCGroup alloc]init];
        group002.groupId = @"group002";
        group002.groupName =@"群组二";
        [_groupList addObject:group002];
        
        RCGroup *group003 = [[RCGroup alloc]init];
        group003.groupId = @"group003";
        group003.groupName =@"群组三";
        [_groupList addObject:group003];
        
        [[RCIMClient sharedRCIMClient]syncGroups:_groupList completion:^{
            
        } error:^(RCErrorCode status) {
            DebugLog(@"同步群数据status%d",(int)status);
        }];
        
        [self requestFriendsList];
        
        
        
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    
    UIView *aView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    [aView setBackgroundColor:[UIColor whiteColor]];
    
    self.view =aView;
    
    //[aView release];
    
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) {
        self.edgesForExtendedLayout =UIRectEdgeNone;
    }
    
    [[RCIM sharedRCIM] setReceiveMessageDelegate:self];
     NSArray *segmentedArray = @[@"默认",@"自定义"];
    self.segment = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    self.segment.selectedSegmentIndex = 0;
    self.segment.tintColor = [UIColor whiteColor];
    self.navigationItem.titleView  = self.segment;
    
    
    [[RCIM sharedRCIM] setUserPortraitClickEvent:^(UIViewController *viewController, RCUserInfo *userInfo) {
        DebugLog(@"%@,%@",viewController,userInfo);
        
        UserInfoViewController *temp = [[UserInfoViewController alloc]init];
        temp.nameLabel.text = userInfo.name;
  
        UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:temp];
        
        //导航和的配色保持一直
        UIImage *image= [viewController.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
        
        [nav.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
        //[nav.navigationBar setBackgroundImage:self.navigationController.navigationBar. forBarMetrics:UIBarMetricsDefault];
        

        [viewController presentViewController:nav animated:YES completion:NULL];

    }];
    [RCIM setGroupInfoFetcherWithDelegate:self];
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.hidden =NO;
    self.dataList = [NSMutableArray array];
    
    for (int i=0; i<8; i++) {
        
        UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        
        if (0==i) {
            //未读消息数
            int count = [[RCIM sharedRCIM] getTotalUnreadCount];
            NSString *txt = [NSString stringWithFormat:@"启动会话列表  未读消息数：%d",count];
            cell.textLabel.text = txt;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if (1==i) {
            cell.textLabel.text = @"启动单聊";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        if (2==i) {
            cell.textLabel.text = @"启动客服";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        if (3 ==i) {
            //group001
            int count = [[RCIM sharedRCIM] getUnreadCount:ConversationType_GROUP targetId:@"group001"];
            NSString *txt = [NSString stringWithFormat:@"启动群组一  未读消息数：%d",count];
            cell.textLabel.text = txt;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        if (4 ==i) {
            cell.textLabel.text = @"启动群组二";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        if (5 ==i) {
            cell.textLabel.text = @"启动群组三";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        if (6 == i) {
            cell.textLabel.text = @"启动图文消息";
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        if (7 == i) {
            cell.textLabel.text = @"注销";
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        

        [self.dataList addObject:cell];
        
    }
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style: UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.autoresizesSubviews  = YES;
    self.tableView.autoresizingMask=UIViewAutoresizingFlexibleHeight;
    self.tableView.rowHeight = 65;
    
    
    [self.view addSubview:self.tableView];
    
    
    
}


-(void)viewWillAppear:(BOOL)animated
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];

    [[RCIM sharedRCIM]setConnectionStatusDelegate:self];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[RCIM sharedRCIM] setConnectionStatusDelegate:nil];
}

-(void)responseConnectionStatus:(RCConnectionStatus)status{
    if (ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT == status) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"" message:@"您已下线，重新连接？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: @"确定",nil];
            alert.tag = 2000;
            [alert show];
        });
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (self.dataList)[indexPath.row];
    
    return  cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //启动会话列表
//    
//    if (0 == self.segment.selectedSegmentIndex) {
//        
//        if (0==indexPath.row) {
//            UIViewController *temp = [[RCIM sharedRCIM]createConversationList:NULL];
//            [self.navigationController pushViewController:temp animated:YES];
//        }
//
//        //启动单聊
//        if (1 == indexPath.row) {
//            
//            UIViewController * temp= [[RCIM sharedRCIM]createPrivateChat: [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo_id"]
// title:@"单聊" completion:NULL];
//            [self.navigationController pushViewController:temp animated:YES];
//        }
//        //启动客户
//        if (2 == indexPath.row) {
//            
//            //线上
//            //[[RCIM sharedRCIM]launchCustomerServiceChat:self customerServiceUserId:@"kefu114" title:@"客服" completion:NULL];
//            
//            //测试
//            [[RCIM sharedRCIM]launchCustomerServiceChat:self customerServiceUserId:[self getKeFuId] title:@"客服" completion:NULL];
//        }
//        
//        if (3 == indexPath.row) {
//            
//            RCGroup *group = _groupList[0];
//            
//            RCChatViewController *temp = [[RCChatViewController alloc]init];
//            temp.currentTarget = group.groupId;
//            temp.conversationType = ConversationType_GROUP;
//            temp.currentTargetName = group.groupName;
//            [self.navigationController pushViewController:temp animated:YES];
//            
//        }
//        
//        if (4 == indexPath.row) {
//            
//            RCGroup *group = _groupList[1];
//            
//            RCChatViewController *temp = [[RCChatViewController alloc]init];
//            temp.currentTarget = group.groupId;
//            temp.conversationType = ConversationType_GROUP;
//            temp.currentTargetName = group.groupName;
//            [self.navigationController pushViewController:temp animated:YES];
//        }
//        
//        if (5 == indexPath.row) {
//            
//            RCGroup *group = _groupList[2];
//            
//            RCChatViewController *temp = [[RCChatViewController alloc]init];
//            temp.currentTarget = group.groupId;
//            temp.conversationType = ConversationType_GROUP;
//            temp.currentTargetName = group.groupName;
//            [self.navigationController pushViewController:temp animated:YES];
//        }
//        
//        //注销
//        if (7 == indexPath.row) {
//            [[RCIM sharedRCIM] disconnect:NO];
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//
//    }
    
    //自定义模式
    if (0 == self.segment.selectedSegmentIndex) {
        
        if (0==indexPath.row) {
            
            DemoChatListViewController *temp = [[DemoChatListViewController alloc]init];
            
            [self.navigationController pushViewController:temp animated:YES];
            temp.portraitStyle = RCUserAvatarCycle;
            
            //[[RCIM sharedRCIM] launchConversationList:self];
        }
        
        
        
        //启动单聊
        if (1 == indexPath.row) {
            
            DemoChatViewController *temp = [[DemoChatViewController alloc]init];
            temp.currentTarget =  [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo_id"]
;
            temp.conversationType = ConversationType_PRIVATE;
            temp.currentTargetName = @"单聊";
            temp.enableSettings = NO;
            temp.portraitStyle = RCUserAvatarCycle;
            
            [self.navigationController pushViewController:temp animated:YES];
        }
        //启动客户
        if (2 == indexPath.row) {
            NSString *customerServiceUserId = [self getKeFuId];
            //线上
            //[[RCIM sharedRCIM]launchCustomerServiceChat:self customerServiceUserId:@"kefu114" title:@"客服" completion:NULL];
            
            //测试
            //[[RCIM sharedRCIM]launchCustomerServiceChat:self customerServiceUserId:customerServiceUserId title:@"客服" completion:NULL];
            
            
            DemoChatViewController *temp = [[DemoChatViewController alloc]init];
            
            temp.currentTarget = [self getKeFuId];
            temp.conversationType = ConversationType_PRIVATE;
            temp.currentTargetName = @"客服";
            temp.enableSettings = NO;
            temp.enableVoIP = YES;
            RCHandShakeMessage* textMsg = [[RCHandShakeMessage alloc] initWithType:1];
            [[RCIM sharedRCIM] sendMessage:ConversationType_PRIVATE targetId:customerServiceUserId content:textMsg delegate:nil];
            
            [self.navigationController pushViewController:temp animated:YES];
            
            
        }
        
        if (3 == indexPath.row) {
            
            RCGroup *group = _groupList[0];
            
            RCChatViewController *temp = [[RCChatViewController alloc]init];
            temp.currentTarget = group.groupId;
            temp.conversationType = ConversationType_GROUP;
            temp.currentTargetName = group.groupName;
            temp.enableUnreadBadge = NO;
            temp.enableVoIP = NO;
            temp.portraitStyle = RCUserAvatarCycle;
            [self.navigationController pushViewController:temp animated:YES];
            
        }
        
        if (4 == indexPath.row) {
            
            RCGroup *group = _groupList[1];
            
            RCChatViewController *temp = [[RCChatViewController alloc]init];
            temp.currentTarget = group.groupId;
            temp.conversationType = ConversationType_GROUP;
            temp.currentTargetName = group.groupName;
            temp.enableUnreadBadge = NO;
            temp.enableVoIP = NO;
            temp.portraitStyle = RCUserAvatarCycle;
            [self.navigationController pushViewController:temp animated:YES];
        }
        
        if (5 == indexPath.row) {
            
            RCGroup *group = _groupList[2];
            
            RCChatViewController *temp = [[RCChatViewController alloc]init];
            temp.currentTarget = group.groupId;
            temp.conversationType = ConversationType_GROUP;
            temp.currentTargetName = group.groupName;
            temp.enableUnreadBadge = NO;
            temp.enableVoIP = NO;
            temp.portraitStyle = RCUserAvatarCycle;
            [self.navigationController pushViewController:temp animated:YES];
        }
        if (6 == indexPath.row) {
            DemoRichContentMessageViewController *temp = [[DemoRichContentMessageViewController alloc]init];
            
            temp.currentTarget =  [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo_id"]
;
            temp.conversationType = ConversationType_PRIVATE;
            temp.currentTargetName = @"单聊";
            temp.enableSettings = NO;
            temp.portraitStyle = RCUserAvatarCycle;
            
            [self.navigationController pushViewController:temp animated:YES];
        }
        
        //注销
        if (7 == indexPath.row) {
            [[RCIM sharedRCIM] disconnect:NO];
            SigninViewController *loginVC = [[SigninViewController alloc] init];
            UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginVC];
            [[[UIApplication sharedApplication] delegate] window].rootViewController = navi;
            
        }
        
    }
}


-(void)didReceivedMessage:(RCMessage *)message left:(int)nLeft
{
    if (0 == nLeft) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber+1;
        });
    }
    
    [[RCIM sharedRCIM] invokeVoIPCall:self message:message];
    //[[RCIM sharedRCIM]invokeVIOPCall:self message:message];
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
-(NSString*)getKeFuId
{
    NSString *pAppKeyPath = [[NSBundle mainBundle] pathForResource:RC_APPKEY_CONFIGFILE ofType:@""];//[documentsDir stringByAppendingPathComponent:RC_APPKEY_CONFIGFILE];
    NSError *error;
    NSString *valueOfKey = [NSString stringWithContentsOfFile:pAppKeyPath encoding:NSUTF8StringEncoding error:&error];
    NSString* keFuId;
    if([valueOfKey intValue] == 0)  //开发环境：0 生产环境：1
        keFuId = @"rongcloud.net.kefu.service112";
    else
        keFuId = @"kefu114";
    return keFuId;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (2000 == alertView.tag) {
        
        if (0 == buttonIndex) {
            
            DebugLog(@"NO");
        }
        
        if (1 == buttonIndex) {
            
            DebugLog(@"YES");
            
            [RCIMClient reconnect:nil];
        }
    }
    
}

-(void)requestFriendsList
{
    NSString *cookie = [[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"];
    //获取好友列表
    NSString *url = [NSString stringWithFormat:@"%@%@",[self getFakeServer],@"friends"];
    NSString* strParams = [NSString stringWithFormat:@"cookie=%@",cookie];
    DebugLog(@"http reuqest body %@",strParams);
    self.friendRquest = [[RCHttpRequest alloc] init];
    
    [self.friendRquest httpConnectionWithURL:url bodyData:[strParams dataUsingEncoding:NSUTF8StringEncoding] delegate:self];
}

#pragma mark - RCIMGroupInfoFetcherDelegate method
-(RCGroup*)getGroupInfoWithGroupId:(NSString*)groupId
{
    RCGroup *group  = nil;
    if([groupId length] == 0)
        return nil;
    for(RCGroup *__g in self.groupList)
    {
        if([__g.groupId isEqualToString:groupId])
        {
            group = __g;
            break;
        }
    }
    return group;
}

#pragma mark - RCIMFriendsFetcherDelegate method
-(NSArray *)getFriends
{
    return self.allFriendsArray;
}

#pragma mark - RCIMUserInfoFetcherDelegagte method
-(RCUserInfo *)getUserInfoWithUserId:(NSString *)userId
{
    RCUserInfo *user  = nil;
    if([userId length] == 0)
        return nil;
    for(RCUserInfo *u in self.allFriendsArray)
    {
        if([u.userId isEqualToString:userId])
        {
            user = u;
            break;
        }
    }
    return user;
}

-(NSString*)getFakeServer
{
    NSString *pAppKeyPath = [[NSBundle mainBundle] pathForResource:RC_APPKEY_CONFIGFILE ofType:@""];
    NSError *error;
    NSString *valueOfKey = [NSString stringWithContentsOfFile:pAppKeyPath encoding:NSUTF8StringEncoding error:&error];
    NSString* fServer;
    if([valueOfKey intValue] == 0)  //开发环境：0 生产环境：1
        fServer = DEV_FAKE_SERVER;
    else
        fServer = PRO_FAKE_SERVER;
    return fServer;
}

#pragma mark - HttpConnectionDelegate
- (void)responseHttpConnectionSuccess:(RCHttpRequest *)request
{
    if(request.response.statusCode == 200)
    {
        NSError* error = nil;
        NSArray * regDataArray = [NSJSONSerialization JSONObjectWithData:request.responseData options:kNilOptions error:&error];
        
        
        self.allFriendsArray = [[NSMutableArray alloc]initWithCapacity:0];
        for(int i= 0;i <regDataArray.count;i++){
            
            NSDictionary *dic = regDataArray[i];
            RCUserInfo *userInfo = [RCUserInfo new];
            NSNumber *idNum = dic[@"id"];
            userInfo.userId = [NSString stringWithFormat:@"%d",idNum.intValue];
            userInfo.portraitUri = dic[@"portrait"];
            userInfo.name = dic[@"username"];
            //----好友列表中将自己排除掉。
            if([[UserManager shareMainUser].mainUser.userId isEqualToString:userInfo.userId])
            {
                continue;
            }
            
            [self.allFriendsArray addObject:userInfo];
        }
        
        [[ShareFriend shareInstance] setFriendList:self.allFriendsArray];
        
        [RCIM setFriendsFetcherWithDelegate:self];
        [RCIM setUserInfoFetcherWithDelegate:self isCacheUserInfo:NO];
    }
    else
    {
        self.allFriendsArray = nil;
    }
    
    
}

-(void)responseHttpConnectionFailed:(RCHttpRequest *)request didFailWithError:(NSError *)error
{
    
}

@end
