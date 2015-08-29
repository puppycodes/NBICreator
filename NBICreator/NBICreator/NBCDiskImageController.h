//
//  NBCDiskImageController.h
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

#import <Foundation/Foundation.h>
@class NBCDisk;

@protocol NBCDiskImageDelegate
@optional
- (void)diskImageOperationStatus:(BOOL)status imageInfo:(NSDictionary *)imageInfo;
@end

@interface NBCDiskImageController : NSObject {
    id _delegate;
}

- (id)initWithDelegate:(id<NBCDiskImageDelegate>)delegate;

// Attaching
+ (BOOL)attachDiskImageAndReturnPropertyList:(id *)propertyList dmgPath:(NSURL *)dmgPath options:(NSArray *)options error:(NSError **)error;
+ (BOOL)attachDiskImageVolumeByOffsetAndReturnPropertyList:(id *)propertyList dmgPath:(NSURL *)dmgPath options:(NSArray *)options offset:(NSString *)offset error:(NSError **)error;

// Mounting
+ (BOOL)mountDiskImageVolumeByDeviceAndReturnMountURL:(id *)mountURL deviceName:(NSString *)devName error:(NSError **)error;

// Detaching
+ (BOOL)detachDiskImageAtPath:(NSString *)mountPath;
+ (BOOL)detachDiskImageDevice:(NSString *)devName;

// Unmounting
+ (BOOL)unmountVolumeAtPath:(NSString *)mountPath;

// Resizing
+ (BOOL)resizeDiskImageAtURL:(NSURL *)diskImageURL shadowImagePath:(NSString *)shadowImagePath;

// Converting
+ (BOOL)convertDiskImageAtPath:(NSString *)diskImagePath shadowImagePath:(NSString *)shadowImagePath;
+ (BOOL)compactDiskImageAtPath:(NSString *)diskImagePath shadowImagePath:(NSString *)shadowImagePath;

// Getting information
+ (BOOL)getOffsetForRecoveryPartitionOnImageDevice:(id *)offset diskIdentifier:(NSString *)diskIdentifier;
+ (NSURL *)getMountURLFromHdiutilOutputPropertyList:(NSDictionary *)propertyList;
+ (NSString *)getRecoveryPartitionIdentifierFromHdiutilOutputPropertyList:(NSDictionary *)propertyList;
+ (NSString *)getRecoveryPartitionIdentifierFromVolumeMountURL:(NSURL *)mountURL;
+ (BOOL)mountAtPath:(NSString *)path withArguments:(NSArray *)args forDisk:(NSString *)diskID;
+ (NSURL *)getDiskImageURLFromMountURL:(NSURL *)mountURL;
+ (NBCDisk *)checkDiskImageAlreadyMounted:(NSURL *)diskImageURL imageType:(NSString *)imageType;

@end
