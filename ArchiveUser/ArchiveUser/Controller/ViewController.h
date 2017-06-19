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

//tabView属性
//custom
@property (strong) IBOutlet NSView *tabView;

@property (weak) IBOutlet NSButton *z7Selectbtn;
@property (weak) IBOutlet NSButton *zipSelectbtn;
@property (weak) IBOutlet NSButton *tarSelectbtn;
@property (weak) IBOutlet NSButton *gzipSelectbtn;
@property (weak) IBOutlet NSButton *bzip2Selectbtn;
@property (weak) IBOutlet NSButton *rarSelectbtn;
@property (weak) IBOutlet NSBox *segmentationView;
@property (weak) IBOutlet NSTextField *segmentationText;
@property (weak) IBOutlet NSPopUpButton *segmentationType;

@property (weak) IBOutlet NSBox *passwordView;
@property (weak) IBOutlet NSSecureTextField *passwordTextField;
@property (weak) IBOutlet NSButton *z7PasswordHead;

//extesion
@property (weak) IBOutlet NSPopUpButton *archiveaMethod;
@property (weak) IBOutlet NSButton *solidMode;
@property (weak) IBOutlet NSButton *excludeMacForks;
@property (weak) IBOutlet NSButton *openSavePath;



//首页压缩解压点击事件方法
- (IBAction)archieve:(NSButton *)sender;
- (IBAction)unArchieve:(NSButton *)sender;

//tabView方法
- (IBAction)segmentation:(NSButton *)sender;
- (IBAction)passwordSelect:(NSButton *)sender;

@end

