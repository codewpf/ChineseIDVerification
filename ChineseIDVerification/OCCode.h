//
//  OCCode.h
//  ChineseIDVerification
//
//  Created by wpf on 2017/3/4.
//  Copyright © 2017年 wpf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCCode : NSObject

- (BOOL)isValidatedChineseID:(NSString *)idcard;

- (NSString *)dateToYear:(NSString *)birthday;

@end
