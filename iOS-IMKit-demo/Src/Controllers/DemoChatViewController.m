//
//  DemoChatViewController.m
//  iOS-IMKit-demo
//
//  Created by xugang on 8/30/14.
//  Copyright (c) 2014 Heq.Shinoda. All rights reserved.
//

#import "DemoChatViewController.h"
#import "DemoChatsettingViewController.h"
#import "DemoPreviewViewController.h"
#import "RCIM.h"


@implementation DemoChatViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [[RCIM sharedRCIM] setReceiveMessageDelegate:self];
    //自定义导航标题颜色
    [self setNavigationTitle:self.currentTargetName textColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor yellowColor]];
    
    //自定义导航左右按钮
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(leftBarButtonItemPressed:)];
    [leftButton setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    
    if (!self.enableSettings) {
        self.navigationItem.rightBarButtonItem = nil;
    }else{
        //自定义导航左右按钮
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"设置" style:UIBarButtonItemStyleBordered target:self action:@selector(rightBarButtonItemPressed:)];
        [rightButton setTintColor:[UIColor whiteColor]];
        self.navigationItem.rightBarButtonItem = rightButton;
    }
    
    //自定义头像点击
    [[RCIM sharedRCIM] setUserPortraitClickEvent:^(UIViewController *viewController, RCUserInfo *userInfo) {
        
        NSLog(@"clicked!");
    }];


}

-(void)didReceivedMessage:(RCMessage *)message left:(int)left
{

}


-(void)leftBarButtonItemPressed:(id)sender
{
    [super leftBarButtonItemPressed:sender];
}
-(void)rightBarButtonItemPressed:(id)sender{
    

    
    UIViewController *viewController = [[UIViewController alloc] init];
    [viewController.view setBackgroundColor:[UIColor whiteColor]];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 120, 44)];
    [btn setBackgroundColor:[UIColor blueColor]];
    [btn setTitle:@"设置" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];
    [viewController.view addSubview:btn];
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void) showSettings
{
    DemoChatsettingViewController *temp = [[DemoChatsettingViewController alloc]init];
    temp.targetId = self.currentTarget;
    temp.conversationType = self.conversationType;
    temp.portraitStyle = RCUserAvatarCycle;
    [self.navigationController pushViewController:temp animated:YES];


}
-(void)showPreviewPictureController:(RCMessage*)rcMessage{
    
    DemoPreviewViewController *temp=[[DemoPreviewViewController alloc]init];
    temp.rcMessage = rcMessage;
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:temp];
    
    //导航和原有的配色保持一直
    UIImage *image= [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    
    [nav.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    [self presentViewController:nav animated:YES completion:nil];
}

-(void)onBeginRecordEvent{
    DebugLog(@"录音开始");
}
-(void)onEndRecordEvent{
    DebugLog(@"录音结束");
}

@end
