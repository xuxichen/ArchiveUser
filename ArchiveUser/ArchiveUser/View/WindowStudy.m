//
//  WindowStudy.m
//  WindowStudy
//
//  Created by 徐子文 on 2017/6/26.
//  Copyright © 2017年 徐子文. All rights reserved.
//

#import "WindowStudy.h"

@implementation WindowStudy

- (instancetype) init{
    self = [super init];
    if (self) {
        
        [self addChildWindow:[self loadWithNibNamed:@"WindowStudy" owner:self loadClass:[self class]] ordered:NSWindowAbove];
    }
    return  self;
}
- (NSWindow *)loadWithNibNamed:(NSString *)nibNamed owner:(id)owner loadClass:(Class)loadClass {
    
    NSArray * objects;
    if (![[NSBundle mainBundle] loadNibNamed:nibNamed owner:owner topLevelObjects:&objects]) {
        
        NSLog(@"Couldn't load nib named %@", nibNamed);
        return nil;
    }
    
    for (id object in objects) {
        if ([object isKindOfClass:loadClass]) {
            
            return object;
        }
    }
    
    return nil;
}
- (IBAction)outWindow:(NSButton *)sender {
    
}
@end
