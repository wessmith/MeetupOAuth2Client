//
//  MUOAuth2Credential
//  Gander
//
//  Created by smith-work on 9/17/12.
//  Copyright (c) 2012 W5mith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUOAuth2Credential : NSObject <NSCoding>

@property (copy, nonatomic) NSString *clientID;
@property (copy, nonatomic) NSString *clientSecret;
@property (copy, nonatomic) NSString *redirectURI;
@property (copy, nonatomic) NSString *accessToken;
@property (copy, nonatomic) NSString *refreshToken;
@property (strong, nonatomic) NSDate *expiry;

@property (readonly, nonatomic, assign, getter = isExpired) BOOL expired;

@end