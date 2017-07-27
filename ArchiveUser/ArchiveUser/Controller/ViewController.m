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
//void myCallbackFunction(
//                        ConstFSEventStreamRef streamRef,
//                        void *clientCallBackInfo,
//                        size_t numEvents,
//                        void *eventPaths,
//                        const FSEventStreamEventFlags eventFlags[],
//                        const FSEventStreamEventId eventIds[])
//{
//    int i;
//    char **paths = eventPaths;
//
//    // printf("Callback called\n");
//    for (i=0; i<numEvents; i++) {
//        int count;
//        /* flags are unsigned long, IDs are uint64_t */
//        printf("Change %llu in %s, flags %lu\n", eventIds, paths, eventFlags);
//    }
//}

//- (void)monitorFolder {
//    /* Create the stream, passing in a callback */
//    CFStringRef mypath = CFStringCreateWithCString(NULL, argv[1], kCFStringEncodingUTF8);
//    CFArrayRef pathsToWatch = CFArrayCreate(NULL, (const void **)&mypath, 1, NULL);
//    void *callbackInfo = NULL; // could put stream-specific data here.
//    FSEventStreamRef stream;
//    CFAbsoluteTime latency = 3.0; /* Latency in seconds */
//
//    stream = FSEventStreamCreate(NULL,
//                                 &myCallbackFunction,
//                                 callbackInfo,
//                                 pathsToWatch,
//                                 kFSEventStreamEventIdSinceNow, /* Or a previous event ID */
//                                 latency,
//                                 kFSEventStreamCreateFlagFileEvents /* Flags explained in reference */
//                                 );
//    FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
//    FSEventStreamStart(stream);
//    CFRunLoopRun();
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeSystemSettings];
    self.currentPath.delegateobj = self;
    [self getDirectoryItems:self.currentPath.URL];
    self.tableView.doubleAction = @selector(doubleClickAction:);
    self.tableView.allowsMultipleSelection = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sieteReader: ) name:NSFileHandleReadCompletionNotification object:nil];
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
    [self.filePathArray removeAllObjects];
    NSIndexSet *set = self.tableView.selectedRowIndexes;
    [self.compressBtn setEnabled:YES];
    __block BOOL hiddenButton = NO;
    [set enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        Model *model = self.directoryItems[idx];
        [self.filePathArray addObject:model.url];
        NSString *extdrop = [[model.url pathExtension] lowercaseString];
        if (!([extdrop isEqual:@"7z"]) && !([extdrop isEqual:@"001"]) && !([extdrop isEqual:@"r00"]) && !([extdrop isEqual:@"c00"]) && !([extdrop isEqual:@"zip"]) && !([extdrop isEqual:@"tar"]) && !([extdrop isEqual:@"gz"]) && !([extdrop isEqual:@"tgz"]) && !([extdrop isEqual:@"bz2"]) && !([extdrop isEqual:@"tbz2"]) && !([extdrop isEqual:@"tbz"]) && !([extdrop isEqual:@"cpgz"]) && !([extdrop isEqual:@"cpio"]) && !([extdrop isEqual:@"cab"]) && !([extdrop isEqual:@"rar"]) && !([extdrop isEqual:@"ace"]) && !([extdrop isEqual:@"lzma"]) && !([extdrop isEqual:@"pax"]) && !([extdrop isEqual:@"xz"])) {
            hiddenButton = NO;
        }else if (([extdrop isEqual:@"7z"]) || ([extdrop isEqual:@"001"]) || ([extdrop isEqual:@"r00"]) || ([extdrop isEqual:@"c00"]) || ([extdrop isEqual:@"zip"]) || ([extdrop isEqual:@"tar"]) || ([extdrop isEqual:@"gz"]) || ([extdrop isEqual:@"tgz"]) || ([extdrop isEqual:@"bz2"]) || ([extdrop isEqual:@"tbz2"]) || ([extdrop isEqual:@"tbz"]) || ([extdrop isEqual:@"cpgz"]) || ([extdrop isEqual:@"cpio"]) || ([extdrop isEqual:@"cab"]) || ([extdrop isEqual:@"rar"]) || ([extdrop isEqual:@"ace"]) || ([extdrop isEqual:@"lzma"]) || ([extdrop isEqual:@"pax"]) || ([extdrop isEqual:@"xz"])) {
            hiddenButton = YES;
        }
    }];
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

//代码抽离保存pathControlURLString到本地plist文件中
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
        self.gzipSelectbtn.enabled = NO;
        self.bzip2Selectbtn.enabled = NO;
        self.gzbzAlertLabel.hidden = NO;
        if (self.gzipSelectbtn.state || self.bzip2Selectbtn.state) {
            self.z7Selectbtn.state = NSOnState;
            self.gzipSelectbtn.state = NSOffState;
            self.bzip2Selectbtn.state = NSOffState;
            self.solidMode.enabled = YES;
            self.z7PasswordHead.enabled = YES;
            self.passwordSelectBtn.enabled = YES;
            self.archiveaMethod.enabled = YES;
        }
    }else {
        NSString *fileName = [[[[[NSString stringWithFormat:@"%@",[self.filePathArray firstObject]] stringByDeletingPathExtension] lastPathComponent] stringByRemovingPercentEncoding] stringByAppendingString:@" "];
        [panel setNameFieldStringValue:fileName];
        self.gzipSelectbtn.enabled = YES;
        self.bzip2Selectbtn.enabled = YES;
        self.gzbzAlertLabel.hidden = YES;
    }
    NSString *defaultSavePath = [[NSString stringWithFormat:@"%@",[self.filePathArray firstObject]] stringByDeletingLastPathComponent];
    
    [panel setDirectoryURL:[NSURL URLWithString:defaultSavePath]];//设置默认打开路径
    [panel setAllowsOtherFileTypes:YES];
    [panel setExtensionHidden:YES];
    [panel setCanCreateDirectories:YES];
    [panel setAccessoryView:self.tabView];
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            [self compressFileArray:self.filePathArray withSavelocation:[panel.URL.path stringByRemovingPercentEncoding] withPassword:self.passwordTextField.stringValue withz7passwod:!self.z7PasswordHead.state withCompressType:[self getCompressType]];
        }
    }];
}

- (IBAction)unArchieve:(NSButton *)sender {
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    NSString *defaultSavePath = [[NSString stringWithFormat:@"%@",[self.filePathArray firstObject]] stringByDeletingLastPathComponent];
    [panel setDirectoryURL:[NSURL URLWithString:defaultSavePath]];//设置默认打开路径
    panel.prompt = @"解压缩到此处";
    [panel setCanCreateDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel setExtensionHidden:YES];
    [panel setCanChooseDirectories:YES];
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            [self unArchieveFileArray:self.filePathArray withSaveloCation:[panel.URL.path stringByRemovingPercentEncoding]];
        }
    }];
}

- (void)unArchieveFileArray:(NSArray *)fileArray withSaveloCation:(NSString *)saveLocation{
    self.progressStatusText.stringValue = @"操作正在进行中......";
    self.progressTimerStatusText.stringValue = @"等待中......";
    [self.progressViewIndicator startAnimation:self];
    [self.progressWindow orderFront:nil];
    for (int i=0; i<fileArray.count; i++) {
        
        [self singleunArchievefile:fileArray[i] withSaveloCation:saveLocation];
    }
}
- (void)singleunArchievefile:(NSURL *)fileurl withSaveloCation:(NSString *)saveLocation{
    _savePathLocationString = [self unarchieveTemporarySavePath:saveLocation];
    _unArchiveFileUrlString = fileurl.path.stringByRemovingPercentEncoding;
    
    self.archiveTask = [[NSTask alloc] init];
    self.pipeOut = [[NSPipe alloc] init];
    
    if ([[[fileurl pathExtension] lowercaseString] isEqual:@"rar"]){
        NSLog(@"Using unrar");
        [self.archiveTask setLaunchPath:[[NSBundle mainBundle] pathForResource:@"kekaunrar" ofType:@""]];
    }else if ([[[fileurl pathExtension] lowercaseString] isEqual:@"ace"]) {
        NSLog(@"Using unace");
        [self.archiveTask setLaunchPath:[[NSBundle mainBundle] pathForResource:@"kekaunace" ofType:@""]];
    }else if (([[[fileurl pathExtension] lowercaseString] isEqual:@"tar"]) || ([[[fileurl pathExtension] lowercaseString] isEqual:@"tbz"]) || ([[[fileurl pathExtension] lowercaseString] isEqual:@"tgz"])){
        NSLog(@"Using gnutar");
        [self.archiveTask setLaunchPath:@"/usr/bin/gnutar"];
    } else {
        NSLog(@"Using p7zip");
        [self.archiveTask setLaunchPath:[[NSBundle mainBundle] pathForResource:@"keka7z" ofType:@""]];
    }
    NSString *savePath;
    if ([[[self.archiveTask launchPath] lastPathComponent] isEqual:@"kekaunrar"]) {
        savePath = [_savePathLocationString stringByAppendingString:@"/"];
        [self.archiveTask setStandardError:self.pipeOut];
    }else if ([[[self.archiveTask launchPath] lastPathComponent] isEqual:@"kekaunace"] || [[[self.archiveTask launchPath] lastPathComponent] isEqual:@"gnutar"]) {
        savePath = [_savePathLocationString stringByAppendingString:@"/"];
        [self.archiveTask setStandardOutput:self.pipeOut];
    } else {
        savePath = [@"-o" stringByAppendingString:_savePathLocationString];
        [self.archiveTask setStandardOutput:self.pipeOut];
    }
    self.handleOut = [self.pipeOut fileHandleForReading];
    [self.handleOut readInBackgroundAndNotify];
    
    NSMutableArray *sietezipExtArgs = [NSMutableArray array];
    if ([[self.archiveTask launchPath] isEqual:@"/usr/bin/gnutar"]) {
        
        [[NSFileManager defaultManager] createDirectoryAtPath:saveLocation withIntermediateDirectories:YES attributes:nil error:nil];
        
        [sietezipExtArgs addObject:@"-C"];
        [sietezipExtArgs addObject:savePath];
        [sietezipExtArgs addObject:@"-xf"];
        [sietezipExtArgs addObject:fileurl.path.stringByRemovingPercentEncoding];
        [sietezipExtArgs addObject:@"--exclude=__MACOSX"];
    }else {
        [sietezipExtArgs addObject:@"x"];
        [sietezipExtArgs addObject:fileurl.path.stringByRemovingPercentEncoding];
        [sietezipExtArgs addObject:savePath];
        [sietezipExtArgs addObject:@"-aou"];
        [sietezipExtArgs addObject:@"-xr!__MACOSX"];
    }
    [self.archiveTask setArguments:sietezipExtArgs];
    [self.archiveTask launch];
    
    // Launching timer to control the process
    _seconds = 1;
    _minutes = 0;
    _hours = 0;
    self.timeCounterVar = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeCounter:) userInfo:nil repeats:YES];
    self.sieteTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(unarchieveProgress:) userInfo:nil repeats:YES];
    
}
- (NSString *)unarchieveTemporarySavePath:(NSString *)saveLocation {
    NSMutableString * InputModified;
    int generated = (random() % 100) * 123;
    
    InputModified = [[NSMutableString alloc] initWithString:saveLocation];
    [InputModified appendString:[NSString stringWithFormat:@"/.unarchieve_temp_%d",generated]];
    
    // Look for existing folder, and rename if folder alredy exist
    while([[NSFileManager defaultManager] fileExistsAtPath:InputModified]){
        generated = (random() % 100) * 123;
        InputModified = [[NSMutableString alloc] initWithString:saveLocation];
        [InputModified appendString:[NSString stringWithFormat:@"/.unarchieve_temp_%d",generated]];
    }
    return InputModified;
}
//
- (IBAction)segmentation:(NSButton *)sender {
    self.segmentationView.hidden = !sender.state;
}

- (IBAction)passwordSelect:(NSButton *)sender {
    self.passwordView.hidden = !sender.state;
}

//压缩相关
- (NSInteger )getCompressType  {
    
    if (self.z7Selectbtn.state) {
        return 0;
    }else if (self.zipSelectbtn.state) {
        return 1;
    }else if (self.tarSelectbtn.state) {
        return 2;
    }else if (self.gzipSelectbtn.state) {
        return 3;
    }else if (self.bzip2Selectbtn.state) {
        return 4;
    }else if (self.rarSelectbtn.state) {
        return 5;
    }else {
        return 10;
    }
}
- (void)compressFileArray:(NSArray *)urlArray
         withSavelocation:(NSString *)saveLocation
             withPassword:(NSString *)password
            withz7passwod:(BOOL)isZ7Password
         withCompressType:(NSInteger)compressType {
    
    self.progressStatusText.stringValue = @"操作正在进行中......";
    self.progressTimerStatusText.stringValue = @"等待中......";
    [self.progressViewIndicator startAnimation:self];
    
    [self.progressWindow orderFront:nil];
    
    self.archiveTask = [[NSTask alloc] init];
    self.pipeOut = [[NSPipe alloc] init];
    [self.archiveTask setStandardOutput:self.pipeOut];
    self.handleOut = [self.pipeOut fileHandleForReading];
    [self.handleOut readInBackgroundAndNotify];
    [self.archiveTask setLaunchPath:[[NSBundle mainBundle] pathForResource:@"keka7z" ofType:@""]];
    
    NSMutableArray *compressArgsArray = [NSMutableArray array];
    [compressArgsArray addObject:@"a"];
    
    switch (compressType) {
        case 0: {
            _savePathLocationString = [NSString stringWithFormat:@"%@.7z",[saveLocation substringToIndex:saveLocation.length-1]];
            self.progressStatusText.stringValue = [NSString stringWithFormat:@"创建 7z 文件..."];
            [compressArgsArray addObject:@"-t7z"];
        }
            break;
        case 1: {
            _savePathLocationString = [NSString stringWithFormat:@"%@.zip",[saveLocation substringToIndex:saveLocation.length-1]];
            self.progressStatusText.stringValue = [NSString stringWithFormat:@"创建 zip 文件..."];
            [compressArgsArray addObject:@"-tzip"];
        }
            break;
        case 2: {
            _savePathLocationString = [NSString stringWithFormat:@"%@.tar",[saveLocation substringToIndex:saveLocation.length-1]];
            self.progressStatusText.stringValue = [NSString stringWithFormat:@"创建 tar 文件..."];
            [compressArgsArray addObject:@"-ttar"];
        }
            break;
        case 3: {
            _savePathLocationString = [NSString stringWithFormat:@"%@.gz",[saveLocation substringToIndex:saveLocation.length-1]];
            self.progressStatusText.stringValue = [NSString stringWithFormat:@"创建 gzip 文件..."];
            [compressArgsArray addObject:@"-tgzip"];
        }
            
            break;
        case 4: {
            _savePathLocationString = [NSString stringWithFormat:@"%@.bz2",[saveLocation substringToIndex:saveLocation.length-1]];
            self.progressStatusText.stringValue = [NSString stringWithFormat:@"创建 bzip2 文件..."];
            [compressArgsArray addObject:@"-tbzip2"];
        }
            break;
        case 5: {
            _savePathLocationString = [NSString stringWithFormat:@"%@.rar",[saveLocation substringToIndex:saveLocation.length-1]];
        }
            break;
        default:
            break;
    }
    
    if (self.segmentationSelectBtn.state && self.segmentationText.stringValue.length != 0) {
        NSString *segmenString;
        switch ([self.segmentationType indexOfSelectedItem]) {
            case 0:
                segmenString = [NSString stringWithFormat:@"-v%@m",self.segmentationText.stringValue];
                break;
            case 1:
                segmenString = [NSString stringWithFormat:@"-v%@kb",self.segmentationText.stringValue];
                break;
            case 2:
                segmenString = [NSString stringWithFormat:@"-v%@g",self.segmentationText.stringValue];
                break;
            case 3:
                segmenString = [NSString stringWithFormat:@"-v%@b",self.segmentationText.stringValue];
                break;
            default:
                break;
        }
        [compressArgsArray addObject:segmenString];
    }
    
    [compressArgsArray addObject:_savePathLocationString];
    
    for (int i=0; i<urlArray.count; i++) {
        [compressArgsArray addObject:[urlArray[i] path]];
    }
    
    NSString *archiveMethodString;
    switch ([self.archiveaMethod indexOfSelectedItem]) {
        case 0: //STORE
            archiveMethodString = @"-mx0";
            break;
        case 1: //FASTEST
            archiveMethodString = @"-mx1";
            break;
        case 2: //FAST
            archiveMethodString = @"-mx3";
            break;
        case 3: //NORMAL
            archiveMethodString = @"-mx5";
            break;
        case 4: //MAXIMUM
            archiveMethodString = @"-mx7";
            break;
        case 5: //ULTRA
            archiveMethodString = @"-mx9";
            break;
    }
    [compressArgsArray addObject:archiveMethodString];
     NSLog(@"%ld",self.solidMode.state);
    if (self.solidMode.enabled && self.solidMode.state) {
        [compressArgsArray addObject:@"-ms=on"];
    }else {
        [compressArgsArray addObject:@""];
    }
    
    password = [@"-p" stringByAppendingString:password];
    if ([password isEqualToString:@"-p"]) {
        password = @"";
    }
    [compressArgsArray addObject:password];
    
    if (isZ7Password) {
        [compressArgsArray addObject:@""];
    }else {
        [compressArgsArray addObject:@"-mhe"];
    }
    
    if (self.excludeMacForks.state) {
        [compressArgsArray addObject:@"-xr!.DS_Store"];
        [compressArgsArray addObject:@"-xr!.localized"];
        [compressArgsArray addObject:@"-xr!._*"];
        [compressArgsArray addObject:@"-xr!.FBC*"];
        [compressArgsArray addObject:@"-xr!.Spotlight-V100"];
        [compressArgsArray addObject:@"-xr!.Trash"];
        [compressArgsArray addObject:@"-xr!.Trashes"];
        [compressArgsArray addObject:@"-xr!.background"];
        [compressArgsArray addObject:@"-xr!.TemporaryItems"];
        [compressArgsArray addObject:@"-xr!.fseventsd"];
        [compressArgsArray addObject:@"-xr!.com.apple.timemachine.*"];
        [compressArgsArray addObject:@"-xr!.VolumeIcon.icns"];
    }
    
    [self.archiveTask setArguments:compressArgsArray];
    NSLog(@"compressArgsArray === %@",compressArgsArray);
    
    [self.archiveTask launch];
    
    _seconds = 1;
    _minutes = 0;
    _hours = 0;
    
    self.timeCounterVar = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeCounter:) userInfo:nil repeats:YES];
    self.sieteTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(sietezipProgress:) userInfo:nil repeats:YES];
    
}

- (void)timeCounter:(NSTimer *)theTimer {
    
    NSString* zeroSec;
    NSString* zeroMin;
    if (_seconds == 60) {
        _minutes = (_minutes + 1);
        _seconds = 0;
    }
    if (_minutes == 60) {
        _hours = (_hours + 1);
        _minutes = 0;
        }
    if ((_seconds <= 59) && (_minutes == 0) && (_hours == 0)) {
        [self.progressTimerStatusText setStringValue:[NSString stringWithFormat:@"已消耗时间： %ld 秒",_seconds]];
        }
    if ((_minutes > 0) && (_hours == 0)) {
        if (_seconds < 10) zeroSec = @"0";
        else zeroSec = @"";
        [self.progressTimerStatusText setStringValue:[NSString stringWithFormat:@"已消耗时间： %ld:%@%ld 分钟",_minutes,zeroSec,_seconds]];
    }
    if (_hours > 0) {
        if (_seconds < 10) zeroSec = @"0";
        else zeroSec = @"";
        if (_minutes < 10) zeroMin = @"0";
        else zeroMin = @"";
        [self.progressTimerStatusText setStringValue:[NSString stringWithFormat:@"已消耗时间：  %ld:%@%ld:%@%ld 小时",_hours,zeroMin,_minutes,zeroSec,_seconds]];
    }
    _seconds = _seconds + 1;
}

- (void)sietezipProgress:(NSTimer *)theTimer {
    
    if (![self.archiveTask isRunning]) {
        [self archiveEndProcess];
    }
}

- (void)unarchieveProgress:(NSTimer *)timer {
    if (![self.archiveTask isRunning]) {
        [self unarchieveEndProcess];
    }
}
- (void)unarchieveEndProcess {
    if ([self.sieteTimer isValid]) {
        [self.sieteTimer invalidate];
    }
    if ([self.timeCounterVar isValid]) {
        [self.timeCounterVar invalidate];
    }
    
    if ([self.archiveTask terminationStatus] == 0) {
        [self.progressWindow orderOut:nil];
            
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *items = [fileManager contentsOfDirectoryAtPath:_savePathLocationString error:nil];

        if (items.count == 1) { // Just one file/folder, then delete temporary folder
            NSMutableString *newTempLocation;
            NSMutableString *actualLocation;
            NSString *temporaryFolder;
            
            temporaryFolder = _savePathLocationString;
            
            actualLocation = [[NSMutableString alloc] initWithString:temporaryFolder];
            [actualLocation appendString:@"/"];
            [actualLocation appendString:[items objectAtIndex:0]];
            
            NSMutableString *newLocation = [[NSMutableString alloc] initWithString:[temporaryFolder stringByDeletingLastPathComponent]];
            [newLocation appendString:@"/"];
            [newLocation appendString:[items objectAtIndex:0]];
            
            // Look for existing folder, and rename if folder alredy exist
            int n=2;
            newTempLocation = newLocation;
            while([fileManager fileExistsAtPath:newTempLocation]){
                newTempLocation = nil;
                newTempLocation = [[NSMutableString alloc] initWithString:[newLocation stringByDeletingPathExtension]];
                [newTempLocation appendString:[NSString stringWithFormat:@" %d",n++]];
                if (([newLocation pathExtension] != nil) && ([newLocation pathExtension].length != 0)) {
                    [newTempLocation appendString:@"."];
                    [newTempLocation appendString:[newLocation pathExtension]];
                }
            
            }
            newLocation = newTempLocation;
            
            [fileManager moveItemAtPath:actualLocation toPath:newLocation error:nil];
            NSArray *items = [fileManager contentsOfDirectoryAtPath:temporaryFolder error:nil];
            NSInteger countingFiles = [items count];
            if (countingFiles == 0) [[NSFileManager defaultManager] removeItemAtPath:temporaryFolder error:nil];
            
            else [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation source:[temporaryFolder stringByDeletingLastPathComponent] destination:nil files:[NSArray arrayWithObject:[temporaryFolder lastPathComponent]] tag:nil];
            _savePathLocationString = newLocation;        } else {
            NSMutableString *newTempLocation;
            NSString *temporaryFolder;
            temporaryFolder = _savePathLocationString;
            NSMutableString *newLocation = [[NSMutableString alloc] initWithString:[[_savePathLocationString stringByDeletingLastPathComponent] stringByAppendingPathComponent:[[_unArchiveFileUrlString lastPathComponent] stringByDeletingPathExtension]]];
            int n=2;
            newTempLocation = newLocation;
            while([[NSFileManager defaultManager] fileExistsAtPath:newTempLocation])
                {
                newTempLocation = nil;
                newTempLocation = [[NSMutableString alloc] initWithString:newLocation];
                [newTempLocation appendString:[NSString stringWithFormat:@" %d",n++]];
                }
            newLocation = newTempLocation;
            [fileManager moveItemAtPath:temporaryFolder toPath:newLocation error:nil]; // Changing folder name
            _savePathLocationString = newLocation; // Now new location is the correct path
        }
            
    
    }else {
        NSLog(@"错误码 %d",[self.archiveTask terminationStatus]);
        NSImage *icon = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns"]];
        [icon setSize:[self.progressIcon frame].size];
        [self.progressIcon setImage:icon];
        [self.progressViewIndicator stopAnimation:self];
        [self.progressViewIndicator setHidden:YES];
        [self.progressStatusText setStringValue:[NSString stringWithFormat:@"解压缩失败",nil]];
        [self.progressStatusText setTextColor:[NSColor redColor]];
        [self.progressTimerStatusText setStringValue:[NSString stringWithFormat:@"操作失败错误码 %d",[self.archiveTask terminationStatus]]];
        [self.progressPauseButton setHidden:YES];
    }
}
- (void)archiveEndProcess {
    if ([self.sieteTimer isValid]) {
        [self.sieteTimer invalidate];
    }
    if ([self.timeCounterVar isValid]) {
        [self.timeCounterVar invalidate];
    }
    
    if ([self.archiveTask terminationStatus] == 0) {
        [self.progressWindow orderOut:nil];
        if (self.openSavePath.state == NSOnState) {
            [[NSWorkspace sharedWorkspace] selectFile:_savePathLocationString inFileViewerRootedAtPath:[_savePathLocationString stringByDeletingLastPathComponent]];
        }
    }else {
        NSLog(@"错误码 %d",[self.archiveTask terminationStatus]);
        NSImage *icon = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns"]];
        [icon setSize:[self.progressIcon frame].size];
        [self.progressIcon setImage:icon];
        [self.progressViewIndicator stopAnimation:self];
        [self.progressViewIndicator setHidden:YES];
        [self.progressStatusText setStringValue:[NSString stringWithFormat:@"压缩失败",nil]];
        [self.progressStatusText setTextColor:[NSColor redColor]];
        [self.progressTimerStatusText setStringValue:[NSString stringWithFormat:@"操作失败错误码 %d",[self.archiveTask terminationStatus]]];
        [self.progressPauseButton setHidden:YES];
    }
}

-(void)sieteReader:(NSNotification *)notification {
    
    self.dataOut = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    self.stringOut = [[NSString alloc] initWithData:self.dataOut encoding:NSASCIIStringEncoding];
    
    if ([_stringOut rangeOfString:@"Enter password"].length > 0) {
        [self passwordCheck];
    }
    if ([self.archiveTask isRunning]) {
        [self.handleOut readInBackgroundAndNotify];
    }
}

- (void)passwordCheck {
    [self.sieteTimer invalidate];
    [self.timeCounterVar invalidate];
    [self.archiveTask terminate];
    [NSApp beginSheet:self.passwordCheckPanel modalForWindow:self.progressWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (IBAction)compressType:(NSButton *)sender {
    switch (sender.tag) {
        case 10:{
            self.solidMode.enabled = YES;
            self.z7PasswordHead.enabled = YES;
            self.passwordSelectBtn.enabled = YES;
            self.archiveaMethod.enabled = YES;
            
            self.z7Selectbtn.state = NSOnState;
            self.zipSelectbtn.state = NSOffState;
            self.tarSelectbtn.state = NSOffState;
            self.gzipSelectbtn.state = NSOffState;
            self.bzip2Selectbtn.state = NSOffState;
            self.rarSelectbtn.state = NSOffState;
        }
            break;
        case 11:{
            self.solidMode.enabled = NO;
            self.solidMode.state = NSOffState;
            self.z7PasswordHead.enabled = NO;
            self.passwordSelectBtn.enabled = YES;
            self.archiveaMethod.enabled = YES;
            
            self.z7Selectbtn.state = NSOffState;
            self.zipSelectbtn.state = NSOnState;
            self.tarSelectbtn.state = NSOffState;
            self.gzipSelectbtn.state = NSOffState;
            self.bzip2Selectbtn.state = NSOffState;
            self.rarSelectbtn.state = NSOffState;
        }
            break;
        case 12:{
            self.solidMode.enabled = NO;
            self.solidMode.state = NSOffState;
            self.z7PasswordHead.enabled = NO;
            self.passwordSelectBtn.enabled = NO;
            self.passwordSelectBtn.state = NSOffState;
            self.passwordView.hidden = YES;
            self.archiveaMethod.enabled = NO;
            
            self.z7Selectbtn.state = NSOffState;
            self.zipSelectbtn.state = NSOffState;
            self.tarSelectbtn.state = NSOnState;
            self.gzipSelectbtn.state = NSOffState;
            self.bzip2Selectbtn.state = NSOffState;
            self.rarSelectbtn.state = NSOffState;
        }
            break;
            
        case 13:{
            self.solidMode.enabled = NO;
            self.solidMode.state = NSOffState;
            self.z7PasswordHead.enabled = NO;
            self.passwordSelectBtn.enabled = NO;
            self.passwordSelectBtn.state = NSOffState;
            self.passwordView.hidden = YES;
            self.archiveaMethod.enabled = YES;
            
            self.z7Selectbtn.state = NSOffState;
            self.zipSelectbtn.state = NSOffState;
            self.tarSelectbtn.state = NSOffState;
            self.gzipSelectbtn.state = NSOnState;
            self.bzip2Selectbtn.state = NSOffState;
            self.rarSelectbtn.state = NSOffState;
        }
            break;
        case 14:{
            self.solidMode.enabled = NO;
            self.solidMode.state = NSOffState;
            self.z7PasswordHead.enabled = NO;
            self.passwordSelectBtn.enabled = NO;
            self.passwordSelectBtn.state = NSOffState;
            self.passwordView.hidden = YES;
            self.archiveaMethod.enabled = YES;
            
            self.z7Selectbtn.state = NSOffState;
            self.zipSelectbtn.state = NSOffState;
            self.tarSelectbtn.state = NSOffState;
            self.gzipSelectbtn.state = NSOffState;
            self.bzip2Selectbtn.state = NSOnState;
            self.rarSelectbtn.state = NSOffState;
        }
            break;
        case 15:{
            //rar自成体系另外处理
            self.solidMode.enabled = NO;
            self.solidMode.state = NSOffState;
            self.z7PasswordHead.enabled = NO;
            self.passwordSelectBtn.enabled = YES;
            self.archiveaMethod.enabled = YES;
            
            self.z7Selectbtn.state = NSOffState;
            self.zipSelectbtn.state = NSOffState;
            self.tarSelectbtn.state = NSOffState;
            self.gzipSelectbtn.state = NSOffState;
            self.bzip2Selectbtn.state = NSOffState;
            self.rarSelectbtn.state = NSOnState;
        }
            break;
        default:
            break;
    }
}

- (IBAction)compressMethod:(NSPopUpButton *)sender {
}


- (IBAction)pauseProgressWindowAction:(NSButton *)sender {
    if (sender.state) {
        self.progressPauseButton.state = NSOnState;
        [self.archiveTask suspend];
        [self.progressViewIndicator stopAnimation:self];
        [self.sieteTimer invalidate];
        [self.timeCounterVar invalidate];
        [self.progressTimerStatusText setStringValue:@"操作暂停"];
        [self.progressPauseButton setImage:[NSImage imageNamed:@"continue"]];
    }else {
        self.progressPauseButton.state = NSOffState;
        [self.archiveTask resume];
        [self.progressViewIndicator startAnimation:self];
        [self timeCounter:nil];
        self.sieteTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(sietezipProgress:) userInfo:nil repeats:YES];
        self.timeCounterVar = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeCounter:) userInfo:nil repeats:YES];
        [self.progressPauseButton setImage:[NSImage imageNamed:@"pause"]];
    }
}

- (IBAction)stopProgressWindowAction:(NSButton *)sender {
    [self.sieteTimer invalidate];
    [self.timeCounterVar invalidate];
    [self.progressViewIndicator stopAnimation:self];
    
    [self.archiveTask terminate];
    [self.progressWindow orderOut:nil];
    [[NSFileManager defaultManager] removeItemAtPath:_savePathLocationString error:nil];
}

- (IBAction)passwordSend:(NSButton *)sender {
    [NSApp endSheet:self.passwordCheckPanel];
    [self.passwordCheckPanel orderOut:nil];
    NSString *spasswordx = [@"-p" stringByAppendingString:[self.passwordToExtract stringValue]];
    [self.passwordToExtract setStringValue:@""];
    self.archiveTask = [[NSTask alloc] init];
    self.pipeOut = [[NSPipe alloc] init];
    if ([[[_unArchiveFileUrlString pathExtension] lowercaseString] isEqual:@"rar"]){
        [self.archiveTask setStandardError:self.pipeOut];
    }else{
        [self.archiveTask setStandardOutput:self.pipeOut];
    }
    self.handleOut = [self.pipeOut fileHandleForReading];
    [self.handleOut readInBackgroundAndNotify];
    if ([[[_unArchiveFileUrlString pathExtension] lowercaseString] isEqual:@"rar"]){
        NSLog(@"Using unrar");
        [self.archiveTask setLaunchPath:[[NSBundle mainBundle] pathForResource:@"kekaunrar" ofType:@""]];
    }else if ([[[_unArchiveFileUrlString pathExtension] lowercaseString] isEqual:@"ace"]) {
        NSLog(@"Using unace");
        [self.archiveTask setLaunchPath:[[NSBundle mainBundle] pathForResource:@"kekaunace" ofType:@""]];
    }else if (([[[_unArchiveFileUrlString pathExtension] lowercaseString] isEqual:@"tar"]) || ([[[_unArchiveFileUrlString  pathExtension] lowercaseString] isEqual:@"tbz"]) || ([[[_unArchiveFileUrlString pathExtension] lowercaseString] isEqual:@"tgz"])){
        NSLog(@"Using gnutar");
        [self.archiveTask setLaunchPath:@"/usr/bin/gnutar"];
    } else {
        NSLog(@"Using p7zip");
        [self.archiveTask setLaunchPath:[[NSBundle mainBundle] pathForResource:@"keka7z" ofType:@""]];
    }

    [self.archiveTask setArguments:[NSArray arrayWithObjects:@"x",@"",_savePathLocationString,@"-y",spasswordx,nil]];
    [self.archiveTask launch];
    self.sieteTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(sietezipProgress:) userInfo:nil repeats:YES];
    self.timeCounterVar = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeCounter:) userInfo:nil repeats:YES];
}
@end
