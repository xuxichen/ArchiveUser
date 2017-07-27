//
//  WindowStudy.h
//  WindowStudy
//
//  Created by 徐子文 on 2017/6/26.
//  Copyright © 2017年 徐子文. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WindowStudy : NSWindow
@property (strong) IBOutlet WindowStudy *ViewWindow;

- (NSWindow *)loadWithNibNamed:(NSString *)nibNamed owner:(id)owner loadClass:(Class)loadClass;
@end
