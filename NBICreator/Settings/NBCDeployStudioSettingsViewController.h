//
//  NBCDSViewController.h
//  NBICreator
//
//  Created by Erik Berglund.
//  Copyright (c) 2015 NBICreator. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "NBCAlerts.h"
#import <Cocoa/Cocoa.h>

#import "NBCApplicationSourceDeployStudio.h"
#import "NBCSource.h"
#import "NBCTarget.h"
#import "NBCTemplatesController.h"

#import "NBCBonjourBrowser.h"
#import "NBCDownloader.h"
#import "NBCDownloaderDeployStudio.h"
#import "NBCImageDropViewController.h"
#import "NBCSourceDropViewController.h"

@interface NBCDeployStudioSettingsViewController : NSViewController <NSTabViewDelegate, NSComboBoxDataSource, NBCDownloaderDelegate, NBCDownloaderDeployStudioDelegate, NBCTemplatesDelegate,
                                                                     NBCAlertDelegate, NBCSourceDropViewDelegate, NBCImageDropViewIconDelegate, NBCImageDropViewBackgroundDelegate>

// ------------------------------------------------------
//  Properties
// ------------------------------------------------------
@property (weak) IBOutlet NSTextField *textFieldDeployStudioVersion;
@property BOOL deployStudioDownloadButtonHidden;

// ------------------------------------------------------
//  Bonjour
// ------------------------------------------------------
@property NSMutableArray *discoveredServers;
@property BOOL isSearching;

// ------------------------------------------------------
//  Class Instance Properties
// ------------------------------------------------------
@property NBCSource *source;
@property NBCTarget *target;
@property NBCApplicationSourceDeployStudio *dsSource;
@property NBCBonjourBrowser *bonjourBrowser;
@property NBCTemplatesController *templates;
@property NBCDownloader *deployStudioDownloader;

@property (weak) IBOutlet NSPopUpButton *popUpButtonTool;

// ------------------------------------------------------
//  Templates
// ------------------------------------------------------
@property NSURL *templatesFolderURL;
@property NSString *selectedTemplate;
@property NSMutableDictionary *templatesDict;
@property (weak) IBOutlet NSPopUpButton *popUpButtonTemplates;
- (IBAction)popUpButtonTemplates:(id)sender;

// ------------------------------------------------------
//  DeployStudio Version
// ------------------------------------------------------
@property (copy) NSString *deployStudioLatestVersion;
@property (copy) NSArray *deployStudioVersions;
@property (copy) NSDictionary *deployStudioVersionsDownloadLinks;
@property (weak) IBOutlet NSPopUpButton *popUpButtonDeployStudioVersion;
@property (weak) IBOutlet NSTextField *textFieldUpdateAvailable;
@property (weak) IBOutlet NSButton *buttonDownloadDeployStudio;
- (IBAction)buttonDownloadDeployStudio:(id)sender;

@property (strong) IBOutlet NSWindow *windowDeployStudioDownload;
@property (weak) IBOutlet NSPopUpButton *popUpButtonDeployStudioDownload;
@property (weak) IBOutlet NSButton *buttonDeployStudioDownloadDownload;
- (IBAction)buttonDeployStudioDownloadDownload:(id)sender;
@property (weak) IBOutlet NSButton *buttonDeployStudioDownloadCancel;
- (IBAction)buttonDeployStudioDownloadCancel:(id)sender;

@property (strong) IBOutlet NSWindow *windowDeployStudioDownloadProgress;
@property (weak) IBOutlet NSButton *buttonDeployStudioDownloadProgressCancel;
- (IBAction)buttonDeployStudioDownloadProgressCancel:(id)sender;
@property (weak) IBOutlet NSProgressIndicator *progressIndicatorDeployStudioDownloadProgress;
@property (weak) IBOutlet NSTextField *textFieldDeployStudioDownloadProgress;
@property (weak) IBOutlet NSTextField *textFieldDeployStudioDownloadProgressTitle;

// ------------------------------------------------------
// TabView View
// ------------------------------------------------------
@property (weak) IBOutlet NSTabView *tabViewSettings;

// ------------------------------------------------------
//  TabView General
// ------------------------------------------------------
@property (weak) IBOutlet NBCImageDropViewIcon *imageViewIcon;
@property (weak) IBOutlet NSTextField *textFieldNBIName;
@property (weak) IBOutlet NSTextField *textFieldNBINamePreview;
@property (weak) IBOutlet NSTextField *textFieldIndex;
@property (weak) IBOutlet NSTextField *textFieldIndexPreview;
@property (weak) IBOutlet NSTextField *textFieldNBIDescription;
@property (weak) IBOutlet NSTextField *textFieldNBIDescriptionPreview;
@property (weak) IBOutlet NSTextField *textFieldDestinationFolder;
@property (weak) IBOutlet NSPopUpButton *popUpButtonProtocol;
@property (weak) IBOutlet NSPopUpButton *popUpButtonLanguage;
@property (weak) IBOutlet NSButton *checkboxAvailabilityEnabled;
@property (weak) IBOutlet NSButton *checkboxAvailabilityDefault;
- (IBAction)buttonChooseDestinationFolder:(id)sender;

// ------------------------------------------------------
//  TabView Runtime
// ------------------------------------------------------
@property (weak) IBOutlet NSComboBox *comboBoxServerURL1;
@property (weak) IBOutlet NSComboBox *comboBoxServerURL2;
@property (weak) IBOutlet NSTextField *textFieldSleepDelayMinutes;
@property (weak) IBOutlet NSTextField *textFieldRebootDelaySeconds;
@property (weak) IBOutlet NSButton *checkboxUseCustomRuntimeTitle;
@property (weak) IBOutlet NSTextField *textFieldCustomRuntimeTitle;
@property (weak) IBOutlet NSButton *checkboxDisableVersionMismatchAlerts;
@property (weak) IBOutlet NSButton *checkboxDisplayLogWindow;
@property (weak) IBOutlet NSButton *checboxSleep;
@property (weak) IBOutlet NSButton *checkboxReboot;
@property (weak) IBOutlet NSMatrix *matrixUseCustomServers;
- (IBAction)matrixUseCustomServers:(id)sender;

// ------------------------------------------------------
//  TabView Authentication
// ------------------------------------------------------
@property (weak) IBOutlet NSTextField *textFieldRuntimeLogin;
@property (weak) IBOutlet NSTextField *textFieldRuntimePassword;
@property (weak) IBOutlet NSTextField *textFieldARDLogin;
@property (weak) IBOutlet NSTextField *textFieldARDPassword;
@property (weak) IBOutlet NSSecureTextField *secureTextFieldARDPassword;
@property (weak) IBOutlet NSSecureTextField *secureTextFieldRuntimePassword;
@property (weak) IBOutlet NSTextField *textFieldNetworkTimeServer;

// ------------------------------------------------------
//  TabView Options
// ------------------------------------------------------
@property (weak) IBOutlet NBCImageDropViewBackground *imageViewBackgroundImage;
@property (weak) IBOutlet NSButton *checkboxUseCustomBackgroundImage;
@property (weak) IBOutlet NSButton *checkboxIncludePython;
@property (weak) IBOutlet NSButton *checkboxIncludeRuby;
@property (weak) IBOutlet NSButton *checkboxCustomTCPStack;
@property (weak) IBOutlet NSButton *checkboxDisableWirelessSupport;
@property (weak) IBOutlet NSButton *checkboxUseSMB1;

// ------------------------------------------------------
//  TabView Post-Workflow
// ------------------------------------------------------
@property (weak) IBOutlet NSPopUpButton *popUpButtonUSBDevices;
@property (weak) IBOutlet NSButton *checkboxCreateUSBDevice;
@property BOOL createUSBDevice;
@property NSMutableDictionary *usbDevicesDict;
@property (weak) IBOutlet NSView *superViewPostWorkflowScripts;
@property NSMutableArray *postWorkflowScripts;
@property (strong) NSView *viewOverlayPostWorkflowScripts;
@property (weak) IBOutlet NSTableView *tableViewPostWorkflowScripts;
@property (weak) IBOutlet NSButton *buttonAddPostWorkflowScript;
- (IBAction)buttonAddPostWorkflowScript:(id)sender;
@property (weak) IBOutlet NSButton *buttonRemovePostWorkflowScript;
- (IBAction)buttonRemovePostWorkflowScript:(id)sender;
@property (weak) IBOutlet NSTextField *textFieldUSBDeviceLabel;
@property NSString *usbLabel;

// Pop Over
@property (weak) IBOutlet NSPopover *popOverVariables;
- (IBAction)buttonPopOver:(id)sender;

// ------------------------------------------------------
//  UI Binding Properties
// ------------------------------------------------------
@property NSString *deployStudioVersion;
@property NSString *nbiCreationTool;

@property BOOL isNBI;

@property BOOL nbiEnabled;
@property BOOL nbiDefault;
@property NSString *nbiName;
@property NSString *nbiIcon;
@property NSString *nbiIconPath;
@property NSString *nbiIndex;
@property NSString *nbiProtocol;
@property NSString *nbiLanguage;
@property NSString *nbiDescription;
@property NSString *destinationFolder;

@property BOOL useCustomServers;
@property NSString *serverURL1;
@property NSString *serverURL2;
@property BOOL disableVersionMismatchAlerts;
@property NSString *networkTimeServer;

@property BOOL showRuntimePassword;
@property BOOL showARDPassword;
@property NSString *dsRuntimeLogin;
@property NSString *dsRuntimePassword;
@property NSString *ardLogin;
@property NSString *ardPassword;
@property BOOL sleep;
@property NSString *sleepDelayMinutes;
@property BOOL reboot;
@property NSString *rebootDelaySeconds;
@property BOOL displayLogWindow;

@property BOOL includePython;
@property BOOL includeRuby;
@property BOOL useCustomTCPStack;
@property BOOL disableWirelessSupport;
@property BOOL useSMB1;
@property BOOL useCustomRuntimeTitle;
@property NSString *customRuntimeTitle;
@property BOOL useCustomBackgroundImage;
@property NSString *imageBackgroundURL;
@property NSString *imageBackground;

@property NSString *popOverOSVersion;
@property NSString *popOverOSMajor;
@property NSString *popOverOSMinor;
@property NSString *popOverOSPatch;
@property NSString *popOverOSBuild;
@property NSString *popOverDate;
@property NSString *popOverIndexCounter;
@property NSString *popOverOSIndex;
@property NSString *nbcVersion;
@property NSString *popOverDSVersion;

// ------------------------------------------------------
//  Instance Methods
// ------------------------------------------------------
- (void)removedSource;
- (void)buildNBI:(NSDictionary *)preWorkflowTasks;
- (void)verifyBuildButton;
- (BOOL)haveSettingsChanged;
- (void)updateUISettingsFromDict:(NSDictionary *)settingsDict;
- (void)updateUISettingsFromURL:(NSURL *)url;
- (void)saveUISettingsWithName:(NSString *)name atUrl:(NSURL *)settingsURL;
- (void)expandVariablesForCurrentSettings;
- (void)updateDeployStudioVersion;
- (void)importTemplateAtURL:(NSURL *)url templateInfo:(NSDictionary *)templateInfo;
- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox;
- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index;

@end
