//
//  BlockWrapper.m
//  AirbnbViewController
//
//  Created by pixyzehn on 1/26/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

#import "BlockWrapper.h"
#import "AirbnbViewController-Swift.h"

@interface BlockWrapper()

@end

@implementation BlockWrapper

+ (id) usingBlockWrapper:(BlockHandler)block
{
    return (id)block;
}

+ (BlockHandler) usingAnyObjectWrapper:(id)obj
{
    return (BlockHandler)obj;
}

@end