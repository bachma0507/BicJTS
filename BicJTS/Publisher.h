//
//  Publisher.h
//  BicJTS
//
//  Created by Barry on 12/23/13.
//  Copyright (c) 2013 BICSI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NewsstandKit/NewsstandKit.h>

extern  NSString *PublisherDidUpdateNotification;
extern  NSString *PublisherFailedUpdateNotification;

@interface Publisher : NSObject {
    NSArray *issues;
    
}

@property (nonatomic,readonly,getter = isReady) BOOL ready;

-(void)addIssuesInNewsstand;
-(void)getIssuesList;
-(NSInteger)numberOfIssues;
-(NSString *)titleOfIssueAtIndex:(NSInteger)index;
-(NSString *)nameOfIssueAtIndex:(NSInteger)index;
-(void)setCoverOfIssueAtIndex:(NSInteger)index completionBlock:(void(^)(UIImage *img))block;
-(NSURL *)contentURLForIssueWithName:(NSString *)name;
-(NSString *)downloadPathForIssue:(NKIssue *)nkIssue;
-(UIImage *)coverImageForIssue:(NKIssue *)nkIssue;


@end
