//
//  ViewController.h
//  ArchiveUser
//
//  Created by 徐子文 on 2017/6/15.
//  Copyright © 2017年 徐子文. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ReactPathControl.h"
#import "Model.h"

#define PREFERENCES_FOLDER @"~/Library/Application Support/ArchiveUser"
#define PREFERENCES_FILE @"~/Library/Application Support/ArchiveUser/ArchiveUser.plist"
@interface ViewController : NSViewController<NSTableViewDataSource,NSTableViewDelegate,ReactPathControlDelegate>

@property (nonatomic, copy) NSMutableArray *filePathArray;
@property (nonatomic, copy) NSMutableArray *directoryItems;
@property (nonatomic, strong)NSByteCountFormatter *sizeFormatter;

//首页属性
@property (weak) IBOutlet NSButton *compressBtn;
@property (weak) IBOutlet NSButton *unCompressBtn;
@property (weak) IBOutlet ReactPathControl *currentPath;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *fileNumberLabel;

//首页点击事件方法
- (IBAction)archieve:(NSButton *)sender;
- (IBAction)unArchieve:(NSButton *)sender;


@end

