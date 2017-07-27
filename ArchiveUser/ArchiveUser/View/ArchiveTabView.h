//
//  ArchiveTabView.h
//  ArchiveUser
//
//  Created by 徐子文 on 2017/6/23.
//  Copyright © 2017年 徐子文. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ArchiveTabView : NSTabView

//tabView属性
//custom
@property (weak) IBOutlet NSButton *z7Selectbtn;
@property (weak) IBOutlet NSButton *zipSelectbtn;
@property (weak) IBOutlet NSButton *tarSelectbtn;
@property (weak) IBOutlet NSButton *gzipSelectbtn;
@property (weak) IBOutlet NSButton *bzip2Selectbtn;
@property (weak) IBOutlet NSButton *rarSelectbtn;

@property (weak) IBOutlet NSButton *passwordSelectBtn;
@property (weak) IBOutlet NSButton *segmentationSelectBtn;

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

@end
