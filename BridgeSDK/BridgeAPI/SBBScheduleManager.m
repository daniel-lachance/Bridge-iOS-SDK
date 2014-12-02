//
//  SBBScheduleManager.m
//  BridgeSDK
//
//  Created by Erin Mounts on 10/24/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBScheduleManager.h"
#import "SBBComponentManager.h"
#import "SBBAuthManager.h"
#import "SBBObjectManager.h"
#import "SBBBridgeObjects.h"

@implementation SBBScheduleManager

+ (instancetype)defaultComponent
{
  static SBBScheduleManager *shared;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [self instanceWithRegisteredDependencies];
  });
  
  return shared;
}

- (NSURLSessionDataTask *)getSchedulesWithCompletion:(SBBScheduleManagerGetCompletionBlock)completion
{
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [self.authManager addAuthHeaderToHeaders:headers];
  return [self.networkManager get:@"/api/v1/schedules" headers:headers parameters:nil completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    // temporary, until "type" field is added to response from this api
    if ([responseObject isKindOfClass:[NSDictionary class]] && ![responseObject objectForKey:@"type"]) {
      responseObject = [responseObject mutableCopy];
      [responseObject setObject:@"ResourceList" forKey:@"type"];
    }
    SBBResourceList *schedules = [self.objectManager objectFromBridgeJSON:responseObject];
    if (completion) {
      completion(schedules, error);
    }
  }];
}

@end