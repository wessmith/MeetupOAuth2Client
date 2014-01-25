//
//  MUOAuth2Client.m
//  MeetupOAuth2Client
//
//  Created by Wesley Smith on 9/17/12.
//  Copyright (c) 2012 Wesley Smith. All rights reserved.
//
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.



#import "MUOAuth2Client.h"
#import "MUOAuth2LoginView.h"
#import "NSString+Query.h"

static NSString *const kMeetupAuthorizationEndpoint = @"https://secure.meetup.com/oauth2/authorize";
static NSString *const kMeetupAccessEndpoint = @"https://secure.meetup.com/oauth2/access";

typedef void(^SuccessBlock)(MUOAuth2Credential *credential);
typedef void(^FailureBlock)(NSError *error);

NSString *CredentialSavePath(NSString *clientID) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheName = [NSString stringWithFormat:@"com.%@.OAuth2.cache", clientID];
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:cacheName];
}

@interface MUOAuth2Credential() <NSCoding>

@property (copy, nonatomic) NSString *clientID;
@property (copy, nonatomic) NSString *clientSecret;
@property (copy, nonatomic, readwrite) NSString *accessToken;
@property (copy, nonatomic) NSString *refreshToken;
@property (strong, nonatomic) NSDate *expiry;

@end

@interface MUOAuth2Client() <MUOAuth2LoginViewDelegate>

@property (nonatomic, strong) MUOAuth2Credential *credential;
@property (nonatomic, copy) NSString *redirectURI;
@property (nonatomic, strong) MUOAuth2LoginView *loginView;
@property (nonatomic, strong) SuccessBlock successBlock;
@property (nonatomic, strong) FailureBlock failureBlock;

@end


@implementation MUOAuth2Client


+ (MUOAuth2Client *)sharedClient
{
    static MUOAuth2Client *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[MUOAuth2Client alloc] init];
    });
    
    return _sharedClient;
}

- (MUOAuth2Credential *)credentialWithClientID:(NSString *)clientID
{
    self.credential = [NSKeyedUnarchiver unarchiveObjectWithFile:CredentialSavePath(clientID)];
    return self.credential;
}

- (void)forgetCredentialWithClientID:(NSString *)clientID
{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSString *cachePath = CredentialSavePath(clientID);
    if ([defaultManager fileExistsAtPath:cachePath]) {
        NSError *error = nil;
        [defaultManager removeItemAtPath:cachePath error:&error];
        if (error) NSLog(@"Error removing cache -> %@", error);
    }
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
}

- (void)authorizeClientWithID:(NSString *)clientID
                       secret:(NSString *)secret
                  redirectURI:(NSString *)redirectURI
                      success:(void(^)(MUOAuth2Credential *credential))success
                      failure:(void(^)(NSError *error))failure
{
    self.redirectURI = redirectURI;
    
    // Credential.
    self.credential = [[MUOAuth2Credential alloc] init];
    self.credential.clientID = clientID;
    self.credential.clientSecret = secret;
    
    // Result blocks.
    self.successBlock = success;
    self.failureBlock = failure;
    
    // Assemble the authorization url.
    NSString *urlString = [NSString stringWithFormat:
                           @"%@?client_id=%@"
                           @"&response_type=code"
                           @"&redirect_uri=%@"
                           @"&set_mobile=on",
                           kMeetupAuthorizationEndpoint,
                           clientID,
                           redirectURI];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // Show the login web view.
    self.loginView = [[MUOAuth2LoginView alloc] initWithRequest:request delegate:self];
    [self.loginView show];
}

- (void)refreshCredential:(MUOAuth2Credential *)credential
                  success:(void(^)(MUOAuth2Credential *credential))success
                  failure:(void(^)(NSError *error))failure;
{
    NSDictionary *params = @{
        @"client_id" : self.credential.clientID,
        @"client_secret" : self.credential.clientSecret,
        @"grant_type" : @"refresh_token",
        @"refresh_token" : self.credential.refreshToken
    };
    
    [self performRequestWithParameters:params success:^(MUOAuth2Credential *credential) {
        
        self.credential = credential;
        
        if (self.credential)
            [NSKeyedArchiver archiveRootObject:self.credential toFile:CredentialSavePath(self.credential.clientID)];
        
        if (success != NULL) success(self.credential);
        
    } failure:^(NSError *error) {
        
        if (failure != NULL) failure(error);
    }];
}


#pragma mark - Connection Management -


- (void)performRequestWithParameters:(NSDictionary *)params
                             success:(void (^)(MUOAuth2Credential *credential))success
                             failure:(void (^)(NSError *error))failure
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:kMeetupAccessEndpoint]];
    
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[NSString queryStringWithDictionary:params]
                        dataUsingEncoding:NSUTF8StringEncoding];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    // Perform the request in a background queue.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSError *error = nil;
        NSURLResponse *response = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&response
                                                                 error:&error];
        
        if (!error) {
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                         options:0
                                                                           error:&error];
            // JSON Parsing error.
            if (error) {
                NSLog(@"JSON parsing error -> %@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failure != NULL) failure(error);
                });
                return;
            }
            
            // Failure response from API.
            if ([responseDict valueForKey:@"error"]) {
                NSLog(@"Error -> %@", responseDict);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failure != NULL) failure(nil); // TODO: Make an error obj to pass here.
                });
                return;
            }
            
            // Call success block on the main thread.
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.credential.accessToken = [responseDict valueForKey:@"access_token"];
                self.credential.refreshToken = [responseDict valueForKey:@"refresh_token"];
                NSTimeInterval expiration = [[responseDict valueForKey:@"expires_in"] doubleValue];
                self.credential.expiry = [NSDate dateWithTimeIntervalSinceNow:expiration];
                
                if (success != NULL) success(self.credential);
            });
            
        } else {
            NSLog(@"Connection error -> %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure != NULL) failure(error);
            });
        }
    });
    
}

- (void)requestAccessTokenWithCode:(NSString *)authCode
{
    NSDictionary *params = @{
        @"client_id" : self.credential.clientID,
        @"client_secret" : self.credential.clientSecret,
        @"grant_type" : @"authorization_code",
        @"redirect_uri" : self.redirectURI,
        @"code" : authCode
    };
    
    [self performRequestWithParameters:params success:^(MUOAuth2Credential *credential) {
        
        // Update the credential with the new data.
        self.credential.accessToken = credential.accessToken;
        self.credential.refreshToken = credential.refreshToken;
        self.credential.expiry = credential.expiry;
        
        if (self.credential)
            [NSKeyedArchiver archiveRootObject:self.credential toFile:CredentialSavePath(self.credential.clientID)];
        
        if (self.successBlock != NULL) self.successBlock(self.credential);
        
    } failure:^(NSError *error) {
        
        if (self.failureBlock != NULL) self.failureBlock(error);
    }];
}


#pragma mark - Login View Delegate


- (void)loginView:(MUOAuth2LoginView *)sender didFailLoadWithError:(NSError *)error inWebView:(UIWebView *)webView;
{
    // Stop loading if the scheme is same as redirect uri.
    NSURL *redirectURL = [NSURL URLWithString:self.redirectURI];
    if ([webView.request.URL.scheme isEqualToString:redirectURL.scheme]) {
        [webView stopLoading];
    }
}

- (BOOL)loginView:(MUOAuth2LoginView *)sender shouldStartLoadWithRequest:(NSURLRequest *)request
{
    NSURL *redirectURL = [NSURL URLWithString:self.redirectURI];
    if ([request.URL.scheme isEqualToString:redirectURL.scheme]) {
        
        [sender close];
        
        NSDictionary *params = [request.URL.query dictionaryFromQueryString];
        
        // Failure response from API.
        if ([params valueForKey:@"error"]) {
            
            NSLog(@"Error -> %@", params);
            self.failureBlock(nil); // TODO: Make an error obj to pass here.
            
        } else {
            NSString *authCode = [params objectForKey:@"code"];
            [self requestAccessTokenWithCode:authCode];
        }
        
        return NO;
    }
    return YES;
}

@end


@implementation MUOAuth2Credential

- (BOOL)isExpired
{
    return [self.expiry compare:[NSDate date]] == NSOrderedAscending;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:
            @"<%@"
            @" accessToken: \"%@\""
            @" secret: \"%@\""
            @" refreshToken: \"%@\""
            @" expires: \"%@\""
            @">",
            [self class],
            self.accessToken,
            self.clientSecret,
            self.refreshToken,
            self.expiry];
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