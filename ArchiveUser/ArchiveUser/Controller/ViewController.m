//
//  ViewController.m
//  ArchiveUser
//
//  Created by 徐子文 on 2017/6/15.
//  Copyright © 2017年 徐子文. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (NSByteCountFormatter *)sizeFormatter {
    if (!_sizeFormatter) {
        _sizeFormatter = [[NSByteCountFormatter alloc] init];
    }
    return _sizeFormatter;
}
- (NSMutableArray *)directoryItems {
    if (!_directoryItems) {
        _directoryItems = [NSMutableArray array];
    }
    return _directoryItems;
}
- (NSMutableArray *)filePathArray {
    if (!_filePathArray) {
        _filePathArray = [NSMutableArray array];
    }
    return _filePathArray;
}
- (void)initializeSystemSettings {
    
    NSMutableDictionary *prefsDict = [self getArchiveUserPreferences];
    if (prefsDict) {
        [self archiveUserPreferencesSetting:prefsDict];
    }else {
        [self archiveUserPreferencesCreate];
    }
}

- (void)archiveUserPreferencesCreate{
    
    BOOL isCreated = [[NSFileManager defaultManager] createDirectoryAtPath:[PREFERENCES_FOLDER stringByExpandingTildeInPath] withIntermediateDirectories:NO attributes:nil error:nil];
    if (isCreated) {
        NSMutableDictionary * prefs = [NSMutableDictionary dictionary].mutableCopy;
        
        [prefs setObject:@"0.0.0.1" forKey:@"Version"];
        [prefs setObject:[NSString stringWithFormat:@"%@",self.currentPath.URL] forKey:@"pathControlURLString"];
        [prefs setObject:@"-tzip" forKey:@"Format"];
        [prefs setObject:@"ZIP" forKey:@"FormatName"];
        [prefs setObject:@"zip" forKey:@"Extension"];
        [prefs setObject:@"-mx5" forKey:@"Method"];
        [prefs setObject:@"3" forKey:@"DefaultMethod"];
        [prefs setObject:NSLocalizedString(@"Next to original file",nil) forKey:@"DefaultSaveLocation"];
        [prefs setObject:@"" forKey:@"DefaultSaveLocationSet"];
        [prefs setObject:@"2" forKey:@"DefaultSaveLocationController"];
        [prefs setObject:NSLocalizedString(@"Same as original file",nil) forKey:@"DefaultName"];
        [prefs setObject:@"" forKey:@"DefaultNameSet"];
        [prefs setObject:@"1" forKey:@"DefaultNameController"];
        [prefs setObject:@"2" forKey:@"DefaultExtractLocationController"];
        [prefs setObject:@"" forKey:@"DefaultExtractLocationSet"];
        [prefs setObject:@"1" forKey:@"CloseController"];
        [prefs setObject:@"0" forKey:@"DefaultActionToPerform"];
        [prefs setObject:@"1" forKey:@"ExitStatus"];
        [prefs setObject:@"0" forKey:@"DeleteAfterCompression"];
        [prefs setObject:@"0" forKey:@"DeleteAfterExtraction"];
        [prefs setObject:@"0" forKey:@"FinderAfterCompression"];
        [prefs setObject:@"0" forKey:@"FinderAfterExtraction"];
        [prefs setObject:@"1" forKey:@"ExcludeMacForks"];
        
        //[self kekaDefaultProgram:self]; // Setting keka the default app
        // Save file
        BOOL success = [prefs writeToFile:[PREFERENCES_FILE stringByExpandingTildeInPath] atomically: TRUE];
        if (!success) {
            NSLog(@"Cannot create preferences file!");
        } else {
            [self archiveUserPreferencesSetting:prefs];
        }
    }
}

- (void)archiveUserPreferencesSetting:(NSDictionary *)dict {
    self.currentPath.URL = [NSURL URLWithString:[dict objectForKey:@"pathControlURLString"]];
}

- (NSMutableDictionary *)getArchiveUserPreferences {
    NSMutableDictionary *prefsDict = [NSDictionary dictionaryWithContentsOfFile: [PREFERENCES_FILE stringByExpandingTildeInPath]].mutableCopy;
    if (prefsDict) {
        return prefsDict;
    }else {
        return nil;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeSystemSettings];
    self.currentPath.delegateobj = self;
    [self getDirectoryItems:self.currentPath.URL];
    self.tableView.doubleAction = @selector(doubleClickAction:);
    self.tableView.allowsMultipleSelection = YES;
}

- (void)doubleClickAction:(id)sender {
    
    Model *model = self.directoryItems[self.tableView.selectedRow];
    if (model.isFolder == YES) {
        [self getDirectoryItems:model.url];
        self.currentPath.URL = model.url;
        [self savePathControlURL:self.currentPath.URL];
        [self.compressBtn setEnabled:NO];
        [self.unCompressBtn setEnabled:NO];
        [self.tableView reloadData];
    }else {
        [[NSWorkspace sharedWorkspace] openURL:model.url];
    }
}

- (void)getDirectoryItems:(NSURL *)url {
    [self.directoryItems removeAllObjects];
    NSArray *requiredAttributes = @[NSURLLocalizedNameKey, NSURLEffectiveIconKey,
                                    NSURLTypeIdentifierKey, NSURLContentModificationDateKey,
                                    NSURLFileSizeKey, NSURLIsDirectoryKey,
                                    NSURLIsPackageKey];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:url includingPropertiesForKeys:requiredAttributes options:NSDirectoryEnumerationSkipsSubdirectoryDescendants|NSDirectoryEnumerationSkipsPackageDescendants|NSDirectoryEnumerationSkipsHiddenFiles errorHandler:NULL];
    for (NSURL *fileURL in enumerator) {
        Model *model = [[Model alloc] init];
        model.url = fileURL;
        NSString *name;
        NSDate *date;
        NSNumber *size;
        NSImage *image;
        NSNumber *isFolder;
        
        if ([fileURL getResourceValue:&name forKey:NSURLLocalizedNameKey error:NULL]) {
            model.name = name;
        }
        if ([fileURL getResourceValue:&date forKey:NSURLContentModificationDateKey error:NULL]) {
            model.date = date;
        }
        if ([fileURL getResourceValue:&size forKey:NSURLFileSizeKey error:NULL]) {
            model.size = [size intValue];
        }
        if ([fileURL getResourceValue:&image forKey:NSURLEffectiveIconKey error:NULL]) {
            model.icon = image;
        }
        if ([fileURL getResourceValue:&isFolder forKey:NSURLIsDirectoryKey error:NULL]) {
            model.isFolder = [isFolder boolValue];
        }
        [self.directoryItems addObject:model];
    }
    self.fileNumberLabel.stringValue = [NSString stringWithFormat:@"%ld 项",self.directoryItems.count];
}

#pragma mark - NSTableViewDateSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.directoryItems.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSImage *image;
    NSString *text;
    NSString *cellIdentifier;
    
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.dateStyle = kCFDateFormatterMediumStyle;
    dateformatter.timeStyle = kCFDateFormatterMediumStyle;
    
    Model *model = self.directoryItems[row];
    if (tableColumn == tableView.tableColumns[0]) {
        image = model.icon;
        text = model.name;
        cellIdentifier = @"NameCellID";
    }else if (tableColumn == tableView.tableColumns[1]) {
        text = model.isFolder ? @"文件夹" : @"文件";
        cellIdentifier = @"TypeCellID";
    }else if (tableColumn == tableView.tableColumns[2]) {
        text = [self.sizeFormatter stringFromByteCount:model.size];
        cellIdentifier = @"SizeCellID";
    }else if (tableColumn == tableView.tableColumns[3]) {
        text = [dateformatter stringFromDate:model.date];
        cellIdentifier = @"DateCellID";
    }
    NSTableCellView *cell = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    cell.textField.stringValue = text;
    cell.imageView.image = image ? image : nil;
    return cell;
}

#pragma mark ***** Notifications *****
//鼠标左键选中调用单元格
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSIndexSet *set = self.tableView.selectedRowIndexes;
    [self.compressBtn setEnabled:YES];
    __block BOOL hiddenButton = NO;
    [set enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        Model *model = self.directoryItems[idx];
        [self.filePathArray addObject:model.url];
        NSString *extdrop = [[model.url pathExtension] lowercaseString];
        if (([extdrop isEqual:@"7z"]) || ([extdrop isEqual:@"001"]) || ([extdrop isEqual:@"r00"]) || ([extdrop isEqual:@"c00"]) || ([extdrop isEqual:@"zip"]) || ([extdrop isEqual:@"tar"]) || ([extdrop isEqual:@"gz"]) || ([extdrop isEqual:@"tgz"]) || ([extdrop isEqual:@"bz2"]) || ([extdrop isEqual:@"tbz2"]) || ([extdrop isEqual:@"tbz"]) || ([extdrop isEqual:@"cpgz"]) || ([extdrop isEqual:@"cpio"]) || ([extdrop isEqual:@"cab"]) || ([extdrop isEqual:@"rar"]) || ([extdrop isEqual:@"ace"]) || ([extdrop isEqual:@"lzma"]) || ([extdrop isEqual:@"pax"]) || ([extdrop isEqual:@"xz"])) {
            hiddenButton = YES;
        }
    }];
    //此处先用隐藏模式来做，后期完善用按钮变灰不可点击来做。
    [self.unCompressBtn setEnabled:hiddenButton];
}

#pragma mark -- NSPathControlClickDelegate 代理协议方法实现
- (void)reactPathCompantCellDelegate:(ReactPathControl *)pathControl {
    [self.compressBtn setEnabled:NO];
    [self.unCompressBtn setEnabled:NO];
    
    NSURL *clickedURL = [self.currentPath.clickedPathComponentCell URL];
    self.currentPath.URL = clickedURL;
    [self getDirectoryItems:clickedURL];
    [self savePathControlURL:self.currentPath.URL];
    [self.tableView reloadData];
}

//代码抽离保存pathControlURLString
- (void)savePathControlURL:(NSURL *)url {
    NSMutableDictionary *prefsDict = [self getArchiveUserPreferences];
    if (prefsDict) {
        [prefsDict setObject:[NSString stringWithFormat:@"%@",url] forKey:@"pathControlURLString"];
        BOOL isSuccess = [prefsDict writeToFile:[PREFERENCES_FILE stringByExpandingTildeInPath] atomically: TRUE];
        if (!isSuccess) {
            NSLog(@"Cannot setting preferences file!");
        }
    }
}

#pragma makr -- 首页点击事件方法
- (IBAction)archieve:(NSButton *)sender {
    NSSavePanel *panel = [NSSavePanel savePanel];
    if (self.filePathArray.count > 1) {
        [panel setNameFieldStringValue:@"Archive"];
    }else {
        NSString *fileName = [[[NSString stringWithFormat:@"%@",[self.filePathArray firstObject]] stringByDeletingPathExtension] lastPathComponent];
        [panel setNameFieldStringValue:fileName];
    }
//    [panel setDirectoryURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"]]];//设置默认打开路径
    [panel setAllowsOtherFileTypes:YES];
//    [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"rar",@"zip",@"7z",@"tbz2",@"tgz",@"tar",@"lzma", nil]];
    [panel setExtensionHidden:YES];
    [panel setCanCreateDirectories:YES];
    [panel setAccessoryView:self.tabView];
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSString *path = [[panel URL] path];
            
        }
    }];
}
- (IBAction)unArchieve:(NSButton *)sender {
}



//
- (IBAction)segmentation:(NSButton *)sender {
    self.segmentationView.hidden = !sender.state;
}

- (IBAction)passwordSelect:(NSButton *)sender {

    self.passwordView.hidden = !sender.state;
}


@end
