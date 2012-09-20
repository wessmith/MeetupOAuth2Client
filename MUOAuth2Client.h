//
//  MUOAuth2Client.h
//  Gander
//
//  Created by smith-work on 9/17/12.
//  Copyright (c) 2012 W5mith. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MUOAuth2Credential;

@interface MUOAuth2Client : NSObject

+ (MUOAuth2Client *)sharedClient;

- (void)authorizeClientWithID:(NSString *)clientID
                       secret:(NSString *)secret
                  redirectURI:(NSString *)redirectURI
                      success:(void(^)(MUOAuth2Credential *credential))success
                      failure:(void(^)(NSError *error))failure;

- (void)refreshAccessTokenWithCredential:(MUOAuth2Credential *)credential
                                 success:(void(^)(MUOAuth2Credential *credential))success
                                 failure:(void(^)(NSError *error))failure;

@end
