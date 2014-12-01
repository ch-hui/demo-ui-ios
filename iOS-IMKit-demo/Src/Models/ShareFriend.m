//
//  ShareFriend.m
//  iOS-IMKit-demo
//
//  Created by Liv on 14/11/26.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "ShareFriend.h"

@implementation ShareFriend
+(id) shareInstance
{
    static ShareFriend *shareFriend = nil;
    if (shareFriend == nil) {
        shareFriend = [[ShareFriend alloc] init];
    }
    return shareFriend;
}
@end
