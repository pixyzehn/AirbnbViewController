//
//  BlockWrapper.h
//  AirbnbViewController
//
//  Created by pixyzehn on 1/26/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^BlockHandler)();

@interface BlockWrapper: NSObject

+ (id) usingBlockWrapper:(BlockHandler)block;
+ (BlockHandler) usingAnyObjectWrapper:(id)obj;

@end
