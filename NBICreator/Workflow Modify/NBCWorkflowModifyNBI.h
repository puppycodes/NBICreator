//
//  NBCWorkflowModifyNBI.h
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

#import "NBCInstallerPackageController.h"
#import "NBCWorkflowProgressDelegate.h"
#import <Foundation/Foundation.h>
@class NBCWorkflowItem;

@interface NBCWorkflowModifyNBI : NSObject <NBCInstallerPackageDelegate>
@property NBCWorkflowItem *workflowItem;
@property (nonatomic, weak) id delegate;
@property BOOL isNBI;

@property NSString *currentVolume;
@property NSURL *currentVolumeURL;
@property NSDictionary *currentVolumeResources;
@property NSDictionary *userSettingsChanged;

@property BOOL modificationsApplied;
@property BOOL updatedKernelCache;
@property BOOL addedUsers;
@property NSString *creationTool;
@property int workflowType;

@property double progressPercentage;
@property double progressOffset;

// Methods

- (id)initWithDelegate:(id<NBCWorkflowProgressDelegate>)delegate;
- (void)modifyNBI:(NBCWorkflowItem *)workflowItem;

@end
