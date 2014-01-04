//
//  NSString+Base64.h
//  BicJTS
//
//  Created by Barry on 12/23/13.
//  Copyright (c) 2013 BICSI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Base64)

+ (NSString *) base64StringFromData:(NSData *)data length:(NSUInteger)length;
//+ (NSString *) base64StringFromData:(NSData *)data length:(int)length;

@end
