//
//  DSCallInfo.h
//  dsbridge
//
//  Created by du on 2018/1/30.
//  Copyright © 2018年 杜文. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSCallInfo : NSObject
@property (nullable, nonatomic) NSString* method;
@property (nullable, nonatomic) NSNumber* id;
@property (nullable,nonatomic) NSArray * args;
@end
