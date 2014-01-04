//
//  StoreViewController.m
//  BicJTS
//
//  Created by Barry on 12/23/13.
//  Copyright (c) 2013 BICSI. All rights reserved.
//

#import "StoreViewController.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>


@interface StoreViewController (Private)

-(void)showIssues;
-(void)loadIssues;
-(void)readIssue:(NKIssue *)nkIssue;
-(void)downloadIssueAtIndex:(NSInteger)index;

-(void)errorWithTransaction:(SKPaymentTransaction *)transaction;
-(void)finishedTransaction:(SKPaymentTransaction *)transaction;
-(void)checkReceipt:(NSData *)receipt;

- (NSString *)decodeBase64:(NSString *)input;

@end

@implementation StoreViewController
//@synthesize table=table_;
@synthesize table = _table;
@synthesize issueCell;
@synthesize purchasing=purchasing_;

static NSString *issueTableCellId = @"IssueTableCell";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        publisher = [[Publisher alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"Loading Issues...";
    //HUD.detailsLabelText = @"Just relax";
    HUD.mode = MBProgressHUDAnimationFade;
    [self.view addSubview:HUD];
    [HUD showWhileExecuting:@selector(showIssues) onTarget:self withObject:nil animated:YES];
    
    
    
    
    // define right bar button items
    refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadIssues)];
    UIActivityIndicatorView *loadingActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingActivity startAnimating];
    waitButton = [[UIBarButtonItem alloc] initWithCustomView:loadingActivity];
    [waitButton setTarget:nil];
    [waitButton setAction:nil];
    
    // left bar button item
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashContent)];
    
    // table
    [_table registerNib:[UINib nibWithNibName:@"IssueTableCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:issueTableCellId];
    
    
    if([publisher isReady]) {
        [self showIssues];
    } else {
        [self loadIssues];
    }
}

- (void)viewDidUnload
{
    [self setTable:nil];
    [self setIssueCell:nil];
    [super viewDidUnload];
    //[waitButton release];
    //[refreshButton release];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {
    //table_ release];
    //[issueCell release];
    //[super dealloc];
}

#pragma mark - Publisher interaction

-(void)loadIssues {
    _table.alpha=0.0;
    [self.navigationItem setRightBarButtonItem:waitButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publisherReady:) name:PublisherDidUpdateNotification object:publisher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publisherFailed:) name:PublisherFailedUpdateNotification object:publisher];
    [publisher getIssuesList];
}

-(void)publisherReady:(NSNotification *)not {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PublisherDidUpdateNotification object:publisher];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PublisherFailedUpdateNotification object:publisher];
    [self showIssues];
}

-(void)showIssues {
    [self.navigationItem setRightBarButtonItem:refreshButton];
    _table.alpha=1.0;
    [_table reloadData];
}

-(void)publisherFailed:(NSNotification *)not {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PublisherDidUpdateNotification object:publisher];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PublisherFailedUpdateNotification object:publisher];
    NSLog(@"%@",not);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Cannot get issues from publisher server."
                                                   delegate:nil
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles:nil];
    [alert show];
    //[alert release];
    [self.navigationItem setRightBarButtonItem:refreshButton];
}

#pragma mark - UITableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [publisher numberOfIssues];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:issueTableCellId];
    
    [_table setBackgroundView:nil];
    [_table setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellbkgnd.jpg"]]];
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"cellbkgnd.jpg"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0]];
    
    NSLog(@"%@",cell);
    NSInteger index = indexPath.row;
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:101];
    titleLabel.text=[publisher titleOfIssueAtIndex:index];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    imageView.image=nil; // reset image as it will be retrieved asychronously
    
    __unsafe_unretained typeof(self) weakSelf = self;
    
    [publisher setCoverOfIssueAtIndex:index completionBlock:^(UIImage *img) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //__unsafe_unretained typeof(self) weakSelf = self;
            //__weak typeof(self) weakSelf = self;
            UITableViewCell *cell = [weakSelf.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
            //UITableViewCell *cell = [_table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
            imageView.image=img;
            
            CALayer *layer = imageView.layer;
            layer.masksToBounds = NO;
            layer.shadowRadius = 3.0f;
            layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
            layer.shadowOpacity = 0.5f;
            layer.shouldRasterize = YES;
            
        });
    }];
    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    NKIssue *nkIssue = [nkLib issueWithName:[publisher nameOfIssueAtIndex:index]];
    UIProgressView *downloadProgress = (UIProgressView *)[cell viewWithTag:102];
    UILabel *tapLabel = (UILabel *)[cell viewWithTag:103];
    if(nkIssue.status==NKIssueContentStatusAvailable) {
        tapLabel.text=@"TAP TO READ";
        tapLabel.alpha=1.0;
        downloadProgress.alpha=0.0;
    } else {
        if(nkIssue.status==NKIssueContentStatusDownloading) {
            downloadProgress.alpha=1.0;
            tapLabel.alpha=0.0;
        } else {
            downloadProgress.alpha=0.0;
            tapLabel.alpha=1.0;
            tapLabel.text=@"TAP TO DOWNLOAD";
        }
        
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // possible actions: read or download
    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    NKIssue *nkIssue = [nkLib issueWithName:[publisher nameOfIssueAtIndex:indexPath.row]];
    // NSURL *downloadURL = [nkIssue contentURL];
    if(nkIssue.status==NKIssueContentStatusAvailable) {
        [self readIssue:nkIssue];
    } else if(nkIssue.status==NKIssueContentStatusNone) {
        [self downloadIssueAtIndex:indexPath.row];
    }
}

#pragma mark - Issue actions

-(void)readIssue:(NKIssue *)nkIssue {
    [[NKLibrary sharedLibrary] setCurrentlyReadingIssue:nkIssue];
    QLPreviewController *previewController = [[QLPreviewController alloc] init];
    previewController.delegate=self;
    previewController.dataSource=self;
    //[self presentModalViewController:previewController animated:YES];
    [self presentViewController:previewController animated:YES completion:nil];
}

-(void)downloadIssueAtIndex:(NSInteger)index {
    // let's retrieve the NKIssue
    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    NKIssue *nkIssue = [nkLib issueWithName:[publisher nameOfIssueAtIndex:index]];
    // let's get the publisher's server URL (stored in the issues plist)
    NSURL *downloadURL = [publisher contentURLForIssueWithName:nkIssue.name];
    if(!downloadURL) return;
    // let's create a request and the NKAssetDownload object
    NSURLRequest *req = [NSURLRequest requestWithURL:downloadURL];
    NKAssetDownload *assetDownload = [nkIssue addAssetWithRequest:req];
    //[assetDownload downloadWithDelegate:self];
    [assetDownload setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
//                                [NSNumber numberWithInt:index],@"Index",
//                                nil]];
                                [NSNumber numberWithInt:index],@"Index",
                                nil]];
     // let's start download
    [assetDownload downloadWithDelegate:self];
}

#pragma mark - NSURLConnectionDownloadDelegate

-(void)updateProgressOfConnection:(NSURLConnection *)connection withTotalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    // get asset
    NKAssetDownload *dnl = connection.newsstandAssetDownload;
    UITableViewCell *cell = [_table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[[dnl.userInfo objectForKey:@"Index"] intValue] inSection:0]];
    UIProgressView *progressView = (UIProgressView *)[cell viewWithTag:102];
    progressView.alpha=1.0;
    [[cell viewWithTag:103] setAlpha:0.0];
    progressView.progress=1.f*totalBytesWritten/expectedTotalBytes;
}

-(void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    [self updateProgressOfConnection:connection withTotalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
}

-(void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    NSLog(@"Resume downloading %f",1.f*totalBytesWritten/expectedTotalBytes);
    [self updateProgressOfConnection:connection withTotalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
}

-(void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL {
    // copy file to destination URL
    NKAssetDownload *dnl = connection.newsstandAssetDownload;
    NKIssue *nkIssue = dnl.issue;
    NSString *contentPath = [publisher downloadPathForIssue:nkIssue];
    NSError *moveError=nil;
    NSLog(@"File is being copied to %@",contentPath);
    
    if([[NSFileManager defaultManager] moveItemAtPath:[destinationURL path] toPath:contentPath error:&moveError]==NO) {
        NSLog(@"Error copying file from %@ to %@",destinationURL,contentPath);
    }
    
    // update the Newsstand icon
    UIImage *img = [publisher coverImageForIssue:nkIssue];
    if(img) {
        [[UIApplication sharedApplication] setNewsstandIconImage:img];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    }
    
    [_table reloadData];
}



#pragma mark - QuickLook

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller {
    return 1;
}

- (id <QLPreviewItem>) previewController: (QLPreviewController *) controller previewItemAtIndex: (NSInteger) index {
    NKIssue *nkIssue = [[NKLibrary sharedLibrary] currentlyReadingIssue];
    NSURL *issueURL = [NSURL fileURLWithPath:[publisher downloadPathForIssue:nkIssue]];
    NSLog(@"Issue URL: %@",issueURL);
    return issueURL;
}

#pragma mark - Trash content

// remove all downloaded magazines
-(void)trashContent {
    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    NSLog(@"%@",nkLib.issues);
    [nkLib.issues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [nkLib removeIssue:(NKIssue *)obj];
    }];
    [publisher addIssuesInNewsstand];
    [_table reloadData];
}

#pragma mark StoreKit

- (IBAction)subscription:(NSString *)productId {
    if(purchasing_==YES) {
        return;
    }
    purchasing_=YES;
    // product request
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:productId]];
    productsRequest.delegate=self;
    [productsRequest start];
}

// 1 month subscription button callback
- (IBAction)paid1Month:(id)sender {
    [self subscription:@"jitsmagapp1mthsub"];
}


// 1year subscription button callback
- (IBAction)paid1Year:(id)sender {
    [self subscription:@"jitsmagapp1yrsub"];
}


// "free subscription" button callback
- (IBAction)freeSubscription:(id)sender {
    [self subscription:@"com.viggiosoft.tutorial.NewsstandTutorial.001"];
}

-(void)requestDidFinish:(SKRequest *)request {
    purchasing_=NO;
    NSLog(@"Request: %@",request);
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    purchasing_=NO;
    NSLog(@"Request %@ failed with error %@",request,error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
    //[alert release];
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    //NSLog(@"Request: %@ -- Response: %@",request,response);
    //NSLog(@"Products: %@",response.products);
    NSLog(@"Request: %@ -- Response: %@",request,response);
    NSArray * skProducts = response.products;
    NSLog(@"Products: %@",response.products);
    
    for (SKProduct * skProduct in skProducts) {
        NSLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    
//    for(SKProduct *product in response.products) {
//        NSLog(@"Found product: %@ %@ %0.2f",
//              product.productIdentifier,
//              product.localizedTitle,
//              product.price.floatValue);
    
        SKPayment *payment = [SKPayment paymentWithProduct:skProduct];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}



-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for(SKPaymentTransaction *transaction in transactions) {
        NSLog(@"Updated transaction %@",transaction);
        switch (transaction.transactionState) {
            case SKPaymentTransactionStateFailed:
                [self errorWithTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"Purchasing...");
                break;
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored:
                [self finishedTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    NSLog(@"Restored all completed transactions");
}

//-(void)finishedTransaction:(SKPaymentTransaction *)transaction {
//    NSLog(@"Finished transaction");
//    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//    /*
//     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Subscription done"
//     message:[NSString stringWithFormat:@"Receipt to be sent: %@\nTransaction ID: %@",transaction.transactionReceipt,transaction.transactionIdentifier]
//     delegate:nil
//     cancelButtonTitle:@"Close"
//     otherButtonTitles:nil];
//     [alert show];
//     [alert release];
//     */
//    // save receipt
//    [[NSUserDefaults standardUserDefaults] setObject:transaction.transactionIdentifier forKey:@"receipt"];
//    // check receipt
//    
//    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
//        // iOS 6.1 or earlier.
//        // Use SKPaymentTransaction's transactionReceipt.
//        [self checkReceipt:transaction.transactionReceipt];
//        
//    }
//    
//    else {
//        // iOS 7 or later.
//        
//        NSURL *receiptFileURL = nil;
//        NSBundle *bundle = [NSBundle mainBundle];
//        if ([bundle respondsToSelector:@selector(appStoreReceiptURL)]) {
//            
//            // Get the transaction receipt file path location in the app bundle.
//            receiptFileURL = [bundle appStoreReceiptURL];
//            
//            // Read in the contents of the transaction file.
//            
//        }else {
//            // Fall back to deprecated transaction receipt,
//            // which is still available in iOS 7.
//            
//            // Use SKPaymentTransaction's transactionReceipt.
//            [self checkReceipt:transaction.transactionReceipt];
//        }
//    }
//}

//-(void)errorWithTransaction:(SKPaymentTransaction *)transaction {
//    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Subscription failure"
//                                                    message:[transaction.error localizedDescription]
//                                                   delegate:nil
//                                          cancelButtonTitle:@"Close"
//                                          otherButtonTitles:nil];
//    [alert show];
//    //[alert release];
//}

//-(void)checkReceipt:(NSData *)receipt {
//    // save receipt
//    NSString *receiptStorageFile = [DocumentsDirectory stringByAppendingPathComponent:@"receipts.plist"];
//    NSMutableArray *receiptStorage = [[NSMutableArray alloc] initWithContentsOfFile:receiptStorageFile];
//    if(!receiptStorage) {
//        receiptStorage = [[NSMutableArray alloc] init];
//    }
//    [receiptStorage addObject:receipt];
//    [receiptStorage writeToFile:receiptStorageFile atomically:YES];
//    //[receiptStorage release];
//    [ReceiptCheck validateReceiptWithData:receipt completionHandler:^(BOOL success,NSString *answer){
//        if(success==YES) {
//            NSLog(@"Receipt has been validated: %@",answer);
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase OK" message:nil delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
//            [alert show];
//            //[alert release];
//        } else {
//            NSLog(@"Receipt not validated! Error: %@",answer);
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase Error" message:@"Cannot validate receipt" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
//            [alert show];
//            //[alert release];
//        };
//    }];
//}
//
//#pragma mark - Check all saved receipts
//
//-(void)checkReceipts:(id)sender {
//    // open receipts
//    NSArray *receipts = [[NSArray alloc] initWithContentsOfFile:[DocumentsDirectory stringByAppendingPathComponent:@"receipts.plist"]];
//    if(!receipts || [receipts count]==0) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No receipts" message:nil delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
//        [alert show];
//        //[alert release];
//        return;
//    }
//    for(NSData *aReceipt in receipts) {
//        [ReceiptCheck validateReceiptWithData:aReceipt completionHandler:^(BOOL success, NSString *message) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Receipt validation"
//                                                            message:[NSString stringWithFormat:@"Success:%d - Message:%@",success,message]
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"Close"
//                                                  otherButtonTitles:nil];
//            [alert show];
//            //[alert release];
//        }
//         ];
//    }
//}


@end
