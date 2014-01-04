//
//  AppDelegate.h
//  BicJTS
//
//  Created by Barry on 12/23/13.
//  Copyright (c) 2013 BICSI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PushIOManager/PushIOManager.h>


@class StoreViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, PushIOManagerDelegate> {
    UINavigationController *nav;
    
    UIImageView *splashView;
    
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) StoreViewController *store;

@end