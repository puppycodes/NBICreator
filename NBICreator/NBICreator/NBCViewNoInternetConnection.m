//
//  NBCViewNoInternetConnection.m
//  NBICreator
//
//  Created by Erik Berglund on 2015-05-29.
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

#import "NBCViewNoInternetConnection.h"

@implementation NBCViewNoInternetConnection

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // --------------------------------------------------------------
    //  Set background color
    // --------------------------------------------------------------
    CGContextRef context = (CGContextRef) [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetRGBFillColor(context, 0.227,0.251,0.337,0.6);
    CGContextFillRect(context, NSRectToCGRect(dirtyRect));
} // drawRect

@end
