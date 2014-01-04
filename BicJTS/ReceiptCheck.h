//
//  ReceiptCheck.h
//  BicJTS
//
//  Created by Barry on 12/23/13.
//  Copyright (c) 2013 BICSI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReceiptCheck : NSObject<NSURLConnectionDelegate> {
    NSMutableData *receivedData;
}

+(ReceiptCheck *)validateReceiptWithData:(NSData *)receiptData completionHandler:(void(^)(BOOL,NSString *))handler;

@property (nonatomic,copy) void(^completionBlock)(BOOL,NSString *);
@property (nonatomic,copy) NSData *receiptData;

//-(void)checkReceipt;

@end
