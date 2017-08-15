//
//  NSString+OAURLEncodingAdditions.h
//  ArchiveUser
//
//  Created by 徐子文 on 2017/7/28.
//  Copyright © 2017年 徐子文. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (OAURLEncodingAdditions)

- (NSString *)URLEncodedString;
- (NSString *)URLDecodedString;

@end
