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
@interface ViewController : NSViewController<NSTableViewDataSource,NSTableViewDelegate,ReactPathControlDelegate> {
    
    NSInteger _seconds;
    NSInteger _minutes;
    NSInteger _hours;
    NSString *_savePathLocationString;
    NSString *_unArchiveFileUrlString;
}

//全局属性
@property (nonatomic, copy) NSMutableArray *filePathArray;
@property (nonatomic, copy) NSMutableArray *directoryItems;
@property (nonatomic, strong) NSByteCountFormatter *sizeFormatter;
@property (nonatomic, copy) NSString *solidModeString;
@property (nonatomic, copy) NSString *compressFormatString;
@property (nonatomic, copy) NSString *compressMethodString;
@property (nonatomic, copy) NSString *compressExtensionString;

@property (nonatomic, strong) NSTimer *timeCounterVar;
@property (nonatomic, strong) NSTimer *sieteTimer;
//关键全局属性
@property (nonatomic, strong)NSTask *archiveTask;
@property (nonatomic, strong)NSPipe *pipeOut;
@property (nonatomic, strong)NSFileHandle *handleOut;
@property (nonatomic, strong)NSData *dataOut;
@property (nonatomic, copy) NSString *stringOut;
//首页属性
@property (weak) IBOutlet NSButton *compressBtn;
@property (weak) IBOutlet NSButton *unCompressBtn;
@property (weak) IBOutlet ReactPathControl *currentPath;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *fileNumberLabel;

//tabView属性
//custom
@property (strong) IBOutlet NSView *tabView;
@property (weak) IBOutlet NSTextField *gzbzAlertLabel;

@property (weak) IBOutlet NSButton *z7Selectbtn;
@property (weak) IBOutlet NSButton *zipSelectbtn;
@property (weak) IBOutlet NSButton *tarSelectbtn;
@property (weak) IBOutlet NSButton *gzipSelectbtn;
@property (weak) IBOutlet NSButton *bzip2Selectbtn;
@property (weak) IBOutlet NSButton *rarSelectbtn;
@property (weak) IBOutlet NSBox *segmentationView;
@property (weak) IBOutlet NSTextField *segmentationText;
@property (weak) IBOutlet NSPopUpButton *segmentationType;
@property (weak) IBOutlet NSButton *passwordSelectBtn;
@property (weak) IBOutlet NSButton *segmentationSelectBtn;

@property (weak) IBOutlet NSBox *passwordView;
@property (weak) IBOutlet NSSecureTextField *passwordTextField;
@property (weak) IBOutlet NSButton *z7PasswordHead;

//extesion
@property (weak) IBOutlet NSPopUpButton *archiveaMethod;
@property (weak) IBOutlet NSButton *solidMode;
@property (weak) IBOutlet NSButton *excludeMacForks;
@property (weak) IBOutlet NSButton *openSavePath;

//progressWindow
@property (strong) IBOutlet NSWindow *progressWindow;
@property (weak) IBOutlet NSProgressIndicator *progressViewIndicator;
@property (weak) IBOutlet NSImageView *progressIcon;
@property (weak) IBOutlet NSTextField *progressStatusText;
@property (weak) IBOutlet NSTextField *progressTimerStatusText;
@property (weak) IBOutlet NSButton *progressPauseButton;

//Password Panel
@property (strong) IBOutlet NSPanel *passwordCheckPanel;
@property (weak) IBOutlet NSSecureTextField *passwordToExtract;
@property (weak) IBOutlet NSTextField *passwordNeedAdvice;


//首页压缩解压点击事件方法
- (IBAction)archieve:(NSButton *)sender;
- (IBAction)unArchieve:(NSButton *)sender;

//tabView方法
- (IBAction)segmentation:(NSButton *)sender;
- (IBAction)passwordSelect:(NSButton *)sender;

//压缩格式（zip，7z。。。）
- (IBAction)compressType:(NSButton *)sender;
//压缩方式（正常，最快。。。）
- (IBAction)compressMethod:(NSPopUpButton *)sender;


//progressWindow Action
- (IBAction)pauseProgressWindowAction:(NSButton *)sender;
- (IBAction)stopProgressWindowAction:(NSButton *)sender;

//Panel Action
- (IBAction)passwordSend:(NSButton *)sender;

@end

