//
//  BlockWrapper.h
//  AirbnbViewController
//
//  Created by pixyzehn on 1/26/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^airHandler)();

@interface AirbnbHelper: NSObject

+ (id) usingClosureWrapper:(airHandler)closure;
+ (airHandler) usingAnyObjectWrapper:(id)any;

@end
