//
//  PIOBeaconRegion.h
//  PushIOManager
//
//  Created by Kendall Helmstetter Gelner on 8/29/13.
//  Copyright (c) 2013 Push IO Inc. All rights reserved.
//

#import "PIORegion.h"

@interface PIOBeaconRegion : PIORegion

@property (nonatomic, strong) NSString *beaconUUID;
@property (nonatomic, assign) uint16_t majorID;
@property (nonatomic, assign) uint16_t minorID;

// returns created objects populated with the given ID's, plus a unique identifer for
// identifying the region you are trying to detect.
+ (PIOBeaconRegion *) regionForBeaconUUID:(NSString *)beaconUUID identifier:(NSString *)identifier;
+ (PIOBeaconRegion *) regionForBeaconUUID:(NSString *)beaconUUID major:(uint16_t)majorID identifier:(NSString *)identifier;
+ (PIOBeaconRegion *) regionForBeaconUUID:(NSString *)beaconUUID major:(uint16_t)majorID minor:(uint16_t)minorID identifier:(NSString *)identifier;


@end
