//
//  StoreViewController.h
//  BicJTS
//
//  Created by Barry on 12/23/13.
//  Copyright (c) 2013 BICSI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Publisher.h"
#import <NewsstandKit/NewsstandKit.h>
#import <QuickLook/QuickLook.h>
#import <StoreKit/StoreKit.h>

@class MBProgressHUD;
@class Reachability;


@interface StoreViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,NSURLConnectionDownloadDelegate,
QLPreviewControllerDelegate,QLPreviewControllerDataSource,SKRequestDelegate,SKProductsRequestDelegate,SKPaymentTransactionObserver,NSURLConnectionDelegate> {
    Publisher *publisher;
    UIBarButtonItem *waitButton;
    UIBarButtonItem *refreshButton;
    
    MBProgressHUD *HUD;
    Reachability *internetReach;
}

@property (retain, nonatomic) IBOutlet UITableView *table;
@property (retain, nonatomic) IBOutlet UITableViewCell *issueCell;

// In App Purchase
@property (nonatomic,assign) BOOL purchasing;

//-(void)downloadIssueAtIndex:(NSInteger)index;

-(void)trashContent;
- (IBAction)freeSubscription:(id)sender;
- (IBAction)paid1Month:(id)sender;
- (IBAction)paid1Year:(id)sender;
//- (IBAction)checkReceipts:(id)sender;

@end

