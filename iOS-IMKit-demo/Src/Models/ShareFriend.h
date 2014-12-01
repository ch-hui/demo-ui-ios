//
//  ShareFriend.h
//  iOS-IMKit-demo
//
//  Created by Liv on 14/11/26.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareFriend : NSObject
+(id) shareInstance;
@property (strong,nonatomic) NSArray *friendList;
@end
