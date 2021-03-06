//
//  NBCWorkflowProgressViewController.m
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

#import "NBCConstants.h"
#import "NBCError.h"
#import "NBCLog.h"
#import "NBCWorkflowManager.h"
#import "NBCWorkflowProgressViewController.h"

@interface NBCWorkflowProgressViewController ()

@end

@implementation NBCWorkflowProgressViewController

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initialization
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (id)init {
    self = [super initWithNibName:@"NBCWorkflowProgressViewController" bundle:nil];
    if (self != nil) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(workflowCompleteNBI:) name:NBCNotificationWorkflowCompleteNBI object:nil];
        [center addObserver:self selector:@selector(workflowCompleteResources:) name:NBCNotificationWorkflowCompleteResources object:nil];
    }
    return self;
} // init

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setWorkflowComplete:NO];
    [self setWorkflowFailed:NO];
    [self updateProgressStatus:@"Waiting..." workflow:self];
} // viewDidLoad

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NBCNotificationWorkflowCompleteNBI object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NBCNotificationWorkflowCompleteResources object:nil];

    // -------------------------------------------------------------
    //  Destroy the privileged session reference
    // -------------------------------------------------------------
    NSData *authData = [_workflowItem authData];
    if (authData != nil) {
        DDLogInfo(@"Destroying authorized session...");
        AuthorizationRef authRef;
        OSStatus err = AuthorizationCreateFromExternalForm([authData bytes], &authRef);

        if (err == errAuthorizationSuccess) {
            AuthorizationFree(authRef, 0);
        } else {
            DDLogError(@"[ERROR] %@", CFBridgingRelease(SecCopyErrorMessageString(err, NULL)));
        }
    }
} // dealloc

- (void)workflowStartedForItem:(NBCWorkflowItem *)workflowItem {
    [self setWorkflowItem:workflowItem];
    [self setNbiURL:[_workflowItem nbiURL]];
    [self setIsRunning:YES];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:NBCUserDefaultsWorkflowTimerEnabled] boolValue]) {
        [self setTimer:[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick) userInfo:nil repeats:YES]];
        [_textFieldTimer setHidden:NO];
    }
    [_layoutContraintStatusInfoLeading setConstant:24.0];
} // workflowStartedForItem

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Notification Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)workflowCompleteNBI:(NSNotification *)notification {
#pragma unused(notification)
    [self setWorkflowNBIComplete:YES];
    if (!_workflowNBIResourcesComplete) {
        if ([_workflowNBIResourcesLastStatus length] == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
              [self updateProgressStatus:@"Preparing Resources to be added to NBI..." workflow:self];
              [self updateProgressBar:60.0];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
              [self updateProgressStatus:self->_workflowNBIResourcesLastStatus workflow:self];
            });
        }
    }
} // workflowCompleteNBI

- (void)workflowCompleteResources:(NSNotification *)notification {
#pragma unused(notification)
    [self setWorkflowNBIResourcesComplete:YES];
} // workflowCompleteResources

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark IBActions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (IBAction)buttonCancel:(id)sender {
#pragma unused(sender)
    if (_isRunning) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Don't Cancel"]; // NSAlertFirstButton
        [alert addButtonWithTitle:@"Cancel Workflow"]; // NSAlertSecondButton
        [alert setMessageText:@"Cancel Running Workflow?"];
        [alert setInformativeText:[NSString stringWithFormat:@"Are you sure you want to cancel the running workflow:\n\n• %@\n", [_textFieldTitle stringValue]]];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert beginSheetModalForWindow:[[[NBCWorkflowManager sharedManager] workflowPanel] window]
                      completionHandler:^(NSInteger returnCode) {
                        if (returnCode == NSAlertSecondButtonReturn) { // Cancel Workflow
                            DDLogWarn(@"[WARN] User canceled workflow...");

                            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                            [nc postNotificationName:NBCNotificationRemoveWorkflowItemUserInfoWorkflowItem
                                              object:self
                                            userInfo:@{NBCNotificationAddWorkflowItemToQueueUserInfoWorkflowItem : self->_workflowItem}];

                            [nc postNotificationName:NBCNotificationWorkflowFailed object:self userInfo:@{ NBCUserInfoNSErrorKey : [NBCError errorWithDescription:@"User Canceled"] }];
                        }
                      }];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:NBCNotificationRemoveWorkflowItemUserInfoWorkflowItem
                                                            object:self
                                                          userInfo:@{NBCNotificationAddWorkflowItemToQueueUserInfoWorkflowItem : _workflowItem}];
    }
} // buttonCancel

- (IBAction)buttonShowInFinder:(id)sender {
#pragma unused(sender)

    dispatch_queue_t taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(taskQueue, ^{

      if (self->_nbiURL) {
          NSError *error = nil;
          NSString *destinationFileName = [self->_nbiURL lastPathComponent];
          if ([destinationFileName containsString:@" "]) {
              destinationFileName = [destinationFileName stringByReplacingOccurrencesOfString:@" " withString:@"-"];
              [self setNbiURL:[[self->_nbiURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:destinationFileName]];
              if (![self->_nbiURL checkResourceIsReachableAndReturnError:&error]) {
                  DDLogError(@"[ERROR] %@", [error localizedDescription]);
                  return;
              }
          }
          [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[ self->_nbiURL ]];
      } else {
          DDLogError(@"[ERROR] ");
      }

    });
} // buttonShowInFinder

- (IBAction)buttonOpenLog:(id)sender {
#pragma unused(sender)

    DDLogDebug(@"[DEBUG] Open Log!");

    dispatch_queue_t taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(taskQueue, ^{

      DDFileLogger *fileLogger = [NBCLog fileLogger];
      if (fileLogger) {
          NSString *logFilePath = [[fileLogger currentLogFileInfo] filePath];
          DDLogDebug(@"[DEBUG] Log file path: %@", logFilePath);

          if ([logFilePath length] != 0) {
              NSError *error = nil;
              NSURL *logFileURL = [NSURL fileURLWithPath:logFilePath];
              if ([logFileURL checkResourceIsReachableAndReturnError:&error]) {
                  [[NSWorkspace sharedWorkspace] openURL:logFileURL];
              } else {
                  DDLogError(@"[ERROR] %@", [error localizedDescription] ?: [NSString stringWithFormat:@"Log file at path: %@ doesn't exist", [logFileURL path]]);
                  return;
              }
          }
      }

    });
} // buttonOpenLog

- (IBAction)buttonWorkflowReport:(id)sender {
#pragma unused(sender)

    DDLogInfo(@"Saving workflow report...");

    NSDictionary *workflowReport = [self workflowReport];

    if ([workflowReport count] != 0) {
        NSSavePanel *panel = [NSSavePanel savePanel];

        [panel setCanCreateDirectories:YES];
        [panel setTitle:@"Save Workflow Report"];
        [panel setPrompt:@"Save"];
        [panel setNameFieldStringValue:[NSString stringWithFormat:@"%@.plist", [[_textFieldTitle stringValue] stringByDeletingPathExtension] ?: @""]];
        [panel beginSheetModalForWindow:[[[NBCWorkflowManager sharedManager] workflowPanel] window]
                      completionHandler:^(NSInteger result) {
                        if (result == NSFileHandlingPanelOKButton) {
                            NSURL *saveURL = [panel URL];
                            if (![workflowReport writeToURL:saveURL atomically:YES]) {
                                DDLogError(@"[ERROR] Saving workflow report failed!");
                            }
                        }
                      }];
    }
} // buttonWorkflowReport

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UI Updates
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)updateProgressStatus:(NSString *)statusMessage workflow:(id)workflow {
    if ([workflow isEqualTo:[_workflowItem workflowNBI]] && !_workflowNBIComplete) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [self->_textFieldStatusInfo setStringValue:statusMessage];
        });
    } else if ([workflow isEqualTo:[_workflowItem workflowResources]] && _workflowNBIComplete) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [self->_textFieldStatusInfo setStringValue:statusMessage];
        });
    } else if ([workflow isEqualTo:[_workflowItem workflowResources]] && !_workflowNBIComplete) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [self setWorkflowNBIResourcesLastStatus:statusMessage];
        });
    } else if ([workflow isEqualTo:[_workflowItem workflowModifyNBI]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [self->_textFieldStatusInfo setStringValue:statusMessage];
        });
    } else if (![workflow isEqualTo:[_workflowItem workflowNBI]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [self->_textFieldStatusInfo setStringValue:statusMessage];
        });
    }
} // updateProgressStatus

- (void)updateProgressStatus:(NSString *)statusMessage {
    if (![statusMessage hasPrefix:@"update_dyld_shared_cache: Omitting development cache"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [self->_textFieldStatusInfo setStringValue:statusMessage];
        });
    }
} // updateProgressStatus

- (void)updateProgressBar:(double)value {
    if (_progressIndicator) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [self->_progressIndicator setDoubleValue:value];
          [self->_progressIndicator setNeedsDisplay:YES];
        });
    }
} // updateProgressBar

- (void)incrementProgressBar:(double)value {
    if (_progressIndicator) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [self->_progressIndicator setDoubleValue:([self->_progressIndicator doubleValue] + value)];
          [self->_progressIndicator setNeedsDisplay:YES];
        });
    }
} // incrementProgressBar

- (void)timerTick {
    static NSDateComponentsFormatter *dateComponentsFormatter;
    if (!dateComponentsFormatter) {
        dateComponentsFormatter = [[NSDateComponentsFormatter alloc] init];
        dateComponentsFormatter.maximumUnitCount = 4;
        dateComponentsFormatter.allowedUnits = NSCalendarUnitMinute + NSCalendarUnitSecond;
        dateComponentsFormatter.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
        dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;

        NSCalendar *calendarUS = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        calendarUS.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
        dateComponentsFormatter.calendar = calendarUS;
    }

    NSDate *startTime = [_workflowItem startTime];
    if (startTime) {
        NSTimeInterval secondsBetween = [[NSDate date] timeIntervalSinceDate:startTime];
        NSString *workflowTime = [dateComponentsFormatter stringFromTimeInterval:secondsBetween];
        dispatch_async(dispatch_get_main_queue(), ^{
          [self->_textFieldTimer setStringValue:workflowTime];
        });
    } else {
        DDLogError(@"[ERROR] Workflow start time NOT set!");
    }
} // timerTick

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Workflow Report
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSDictionary *)workflowReport {

    DDLogInfo(@"Generating workflow report...");

    NSMutableDictionary *workflowReport = [[NSMutableDictionary alloc] init];

    // --------------------------------------------------------------
    //  Add NBI info
    // --------------------------------------------------------------
    workflowReport[@"NBI"] = @{ @"Name" : [_workflowItem nbiName] ?: @"Unknown" };

    // --------------------------------------------------------------
    //  Add source info
    // --------------------------------------------------------------
    workflowReport[@"Source"] = @{
        @"Version" : [[_workflowItem source] sourceVersion] ?: @"Unknown",
        @"Build" : [[_workflowItem source] sourceBuild] ?: @"Unknown",
        @"Type" : [[_workflowItem source] sourceType] ?: @"Unknown",
    };

    // --------------------------------------------------------------
    //  Add build info
    // --------------------------------------------------------------
    workflowReport[@"Build Info"] = @{ @"Status" : (_workflowComplete && !_workflowFailed) ? @"Success" : @"Failed", @"Time" : [self timeElapsed] ?: @"" };

    // --------------------------------------------------------------
    //  Add build warnings
    // --------------------------------------------------------------
    workflowReport[@"Build Warnings"] = @{ @"Linker Errors" : _linkerErrors ?: @[] };
    return workflowReport;
} // workflowReport

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Helper Logging
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)logDebug:(NSString *)logMessage {
    DDLogDebug(@"[DEBUG] %@", logMessage);
} // logDebug

- (void)logInfo:(NSString *)logMessage {
    DDLogInfo(@"%@", logMessage);
} // logInfo

- (void)logWarn:(NSString *)logMessage {
    DDLogWarn(@"[WARN] %@", logMessage);
} // logWarn

- (void)logError:(NSString *)logMessage {
    DDLogError(@"[ERROR] %@", logMessage);
} // logError

- (void)logStdOut:(NSString *)stdOutString {
    DDLogDebug(@"[stdout] %@", stdOutString);

    // -------------------------------------------------------------------------------------------------------------
    //  If output has prefix NBCWorkflowLogPrefix means it's a script running which means it's the current progress
    // -------------------------------------------------------------------------------------------------------------
    if ([stdOutString hasPrefix:NBCWorkflowLogPrefix]) {
        [self parseLogProgress:stdOutString];
    }
} // logStdOut

- (void)logStdErr:(NSString *)stdErrString {
    DDLogDebug(@"[stderr] %@", stdErrString);

    // -----------------------------------------------------------------------------------------------------------------
    //  If output has prefix 'warning, could not bind' means it's a missing dyld link which needs to be added to report
    // -----------------------------------------------------------------------------------------------------------------
    if ([stdErrString hasPrefix:@"warning, could not bind"]) {
        [self parseDyldError:stdErrString];
    }
} // logStdErr

- (void)logLevel:(void (^)(int))reply {
    reply((int)ddLogLevel);
}

- (void)parseDyldError:(NSString *)stdErrStr {

    NSString *enumerationTmpString;
    NSArray *enumerationTmpArray;
    if (!_linkerErrors) {
        [self setLinkerErrors:[[NSMutableDictionary alloc] init]];
    }

    // Here comes some ugly parsing, could simplify this a bit:
    NSArray *stdErrArray = [stdErrStr componentsSeparatedByString:@", "];
    for (NSString *line in stdErrArray) {
        if ([line hasPrefix:@"could not bind"]) {
            enumerationTmpString = [line stringByReplacingOccurrencesOfString:@"could not bind " withString:@""];
            enumerationTmpString = [enumerationTmpString stringByReplacingOccurrencesOfString:@" because realpath() failed on " withString:@"\n"];
            enumerationTmpArray = [enumerationTmpString componentsSeparatedByString:@"\n"];
            NSMutableArray *sourceArray = [_linkerErrors[enumerationTmpArray[0]] mutableCopy] ?: [[NSMutableArray alloc] init];
            [sourceArray addObject:enumerationTmpArray[1]];
            _linkerErrors[enumerationTmpArray[0]] = [sourceArray copy];
        }
    }
} // parseDyldError

- (void)parseLogProgress:(NSString *)stdOutString {

    // ----------------------------------------------------------------------------------------------
    //  Check for build steps in output, then try to update UI with a meaningful message or progress
    // ----------------------------------------------------------------------------------------------
    NSString *buildStep = [stdOutString componentsSeparatedByString:@"_"][2];

    // -------------------------------------------------------------
    //  "creatingKernelCachex86"
    // -------------------------------------------------------------
    if ([buildStep isEqualToString:@"creatingKernelCachex86"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [self->_textFieldStatusInfo setStringValue:@"Creating pre-linked kernel..."];
        });

        // --------------------------------------------------------------------------------------
        //  "creatingKernelCachei386"
        // --------------------------------------------------------------------------------------
    } else if ([buildStep isEqualToString:@"creatingKernelCachei386"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [self->_textFieldStatusInfo setStringValue:@"Creating pre-linked kernel for arch i386..."];
        });

        // --------------------------------------------------------------------------------------
        //  "updatingDyldCachex86"
        // --------------------------------------------------------------------------------------
    } else if ([buildStep isEqualToString:@"updatingDyldCachex86"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [self->_textFieldStatusInfo setStringValue:@"Updating dyld cache..."];
        });

        // --------------------------------------------------------------------------------------
        //  "updatingDyldCachei386"
        // --------------------------------------------------------------------------------------
    } else if ([buildStep isEqualToString:@"updatingDyldCachei386"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [self->_textFieldStatusInfo setStringValue:@"Updating dyld cache for arch i386..."];
        });
    }
} // parseLogProgress

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Workflow Ended
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)workflowFailedWithError:(NSString *)errorMessage {

    // -------------------------------------------------------------
    //  Destroy the privileged session reference
    // -------------------------------------------------------------
    DDLogInfo(@"Destroying authorized session...");
    NSData *authData = [_workflowItem authData];
    if ((authData == nil) || ([authData length] != sizeof(AuthorizationExternalForm))) {
        DDLogError(@"[ERROR] %@", [[NSError errorWithDomain:NSOSStatusErrorDomain code:paramErr userInfo:nil] localizedDescription]);
    } else {
        AuthorizationRef authRef;
        OSStatus err = AuthorizationCreateFromExternalForm([authData bytes], &authRef);

        if (err == errAuthorizationSuccess) {
            AuthorizationFree(authRef, 0);
        } else {
            DDLogError(@"[ERROR] %@", CFBridgingRelease(SecCopyErrorMessageString(err, NULL)));
        }
    }
    [_workflowItem setAuthData:nil];

    // -------------------------------------------------------------
    //  Make sure the first error encoutered is the one displayed
    // -------------------------------------------------------------
    if (_workflowFailed) {
        DDLogError(@"[ERROR][SILENCED] %@", errorMessage);
        return;
    } else {
        [self setWorkflowFailed:YES];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
      [self->_layoutConstraintButtonOpenLogLeading setConstant:100.0];
      [self->_layoutContraintStatusInfoLeading setConstant:1.0];
      [self->_progressIndicator setHidden:YES];
      [self->_progressIndicator stopAnimation:self];
      [self->_buttonOpenLog setHidden:NO];

      if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"WorkflowReportIncludeLinkerWarnings"] boolValue]) {
          int warnings = (int)[[self->_linkerErrors allKeys] count];
          [self->_textFieldStatusWarnings setStringValue:[NSString stringWithFormat:@"%d warnings:", warnings]];

          if (warnings != 0) {
              [self->_buttonWorkflowReport setHidden:NO];
              [self->_textFieldStatusWarnings setHidden:NO];
          }
      }

      [self setIsRunning:NO];
      if (self->_timer) {
          [self->_timer invalidate];
          [self->_textFieldTimer setHidden:YES];
      }

      [self->_textFieldStatusTitle setStringValue:@"Workflow Failed"];
      [self->_textFieldStatusInfo setStringValue:errorMessage ?: @""];
    });
} // workflowFailedWithError

- (void)workflowCompleted {

    // -------------------------------------------------------------
    //  Destroy the privileged session reference
    // -------------------------------------------------------------
    NSData *authData = [_workflowItem authData];
    if ((authData == nil) || ([authData length] != sizeof(AuthorizationExternalForm))) {
        DDLogError(@"[ERROR] %@", [[NSError errorWithDomain:NSOSStatusErrorDomain code:paramErr userInfo:nil] localizedDescription]);
    } else {
        AuthorizationRef authRef;
        OSStatus err = AuthorizationCreateFromExternalForm([authData bytes], &authRef);

        if (err == errAuthorizationSuccess) {
            AuthorizationFree(authRef, 0);
        } else {
            DDLogError(@"[ERROR] %@", CFBridgingRelease(SecCopyErrorMessageString(err, NULL)));
        }
    }
    [_workflowItem setAuthData:nil];

    [_layoutContraintStatusInfoLeading setConstant:1.0];

    NSCalendar *calendarUS = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    calendarUS.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];

    NSDate *startTime = [_workflowItem startTime];
    NSDate *endTime = [NSDate date];
    NSTimeInterval secondsBetween = [endTime timeIntervalSinceDate:startTime];
    NSDateComponentsFormatter *dateComponentsFormatter = [[NSDateComponentsFormatter alloc] init];
    dateComponentsFormatter.maximumUnitCount = 3;
    dateComponentsFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
    dateComponentsFormatter.calendar = calendarUS;

    NSString *workflowTime = [dateComponentsFormatter stringFromTimeInterval:secondsBetween];
    if ([workflowTime length] != 0) {
        [self setTimeElapsed:workflowTime];
        [_workflowItem setWorkflowTime:workflowTime];
    }

    [self setWorkflowComplete:YES];
    [_layoutConstraintButtonCloseTrailing setConstant:40.0f];
    [_buttonOpenLog setHidden:NO];

    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"WorkflowReportIncludeLinkerWarnings"] boolValue]) {
        int warnings = (int)[[_linkerErrors allKeys] count];
        [_textFieldStatusWarnings setStringValue:[NSString stringWithFormat:@"%d warnings:", warnings]];

        if (warnings != 0) {
            [_buttonWorkflowReport setHidden:NO];
            [_textFieldStatusWarnings setHidden:NO];
        }
    }

    [_progressIndicator setHidden:YES];
    [_progressIndicator stopAnimation:self];
    [self setIsRunning:NO];
    if (_timer) {
        [_timer invalidate];
        [_textFieldTimer setHidden:YES];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      [self updateProgressStatus:[NSString stringWithFormat:@"NBI created successfully in %@!", workflowTime] workflow:self];
    });
} // workflowCompleted

@end
