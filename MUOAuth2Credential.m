//
//  MUOAuth2Credential.m
//  Gander
//
//  Created by Wesley Smith on 9/17/12.
//  Copyright (c) 2012 Wesley Smith. All rights reserved.
//

#import "MUOAuth2Credential.h"

@implementation MUOAuth2Credential

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ accessToken:\"%@\" secret:\"%@ refreshToken:\"%@\" expiration:\"%@\">", [self class], self.accessToken, self.clientSecret, self.refreshToken, self.expiry];
}

- (BOOL)isExpired
{
    return [self.expiry compare:[NSDate date]] == NSOrderedAscending;
}

#pragma mark - NSCoder

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        self.clientID = [decoder decodeObjectForKey:@"clientID"];
        self.clientSecret = [decoder decodeObjectForKey:@"clientSecret"];
        self.accessToken = [decoder decodeObjectForKey:@"accessToken"];
        self.refreshToken = [decoder decodeObjectForKey:@"refreshToken"];
        self.expiry = [decoder decodeObjectForKey:@"expiry"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.clientID forKey:@"clientID"];
    [encoder encodeObject:self.clientSecret forKey:@"clientSecret"];
    [encoder encodeObject:self.accessToken forKey:@"accessToken"];
    [encoder encodeObject:self.refreshToken forKey:@"refreshToken"];
    [encoder encodeObject:self.expiry forKey:@"expiry"];
}

@end
