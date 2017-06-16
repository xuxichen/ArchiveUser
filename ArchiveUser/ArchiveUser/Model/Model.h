//
//  Model.h
//  ArchiveUser
//
//  Created by 徐子文 on 2017/6/15.
//  Copyright © 2017年 徐子文. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) int64_t size;
@property (nonatomic, strong) NSImage *icon;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) BOOL isFolder;
@end
