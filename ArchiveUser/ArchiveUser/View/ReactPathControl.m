//
//  ReactPathControl.m
//  ArchiveUser
//
//  Created by 徐子文 on 2017/6/15.
//  Copyright © 2017年 徐子文. All rights reserved.
//

#import "ReactPathControl.h"

@implementation ReactPathControl

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setAction:@selector(reactPathControlCell)];
}

- (void)reactPathControlCell {
    if ([self.delegateobj respondsToSelector:@selector(reactPathCompantCellDelegate:)]) {
        [self.delegateobj reactPathCompantCellDelegate:self];
    }
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
