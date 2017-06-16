//
//  ReactPathControl.h
//  ArchiveUser
//
//  Created by 徐子文 on 2017/6/15.
//  Copyright © 2017年 徐子文. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ReactPathControl;
@protocol ReactPathControlDelegate <NSObject>
@required
- (void)reactPathCompantCellDelegate:(ReactPathControl *)pathControl;
@end

@interface ReactPathControl : NSPathControl
@property (nonatomic, weak)id<ReactPathControlDelegate> delegateobj;
@end


