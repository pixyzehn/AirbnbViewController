//
//  BlockWrapper.m
//  AirbnbViewController
//
//  Created by pixyzehn on 1/26/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

#import "AirbnbHelper.h"

@interface AirbnbHelper()
@end

@implementation AirbnbHelper

+ (id) usingClosureWrapper:(airHandler)closure {
    return (id)closure;
}

+ (airHandler) usingAnyObjectWrapper:(id)any {
    return (airHandler)any;
}

@end