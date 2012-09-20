//
//  MUOAuth2Client.m
//  Gander
//
//  Created by smith-work on 9/17/12.
//  Copyright (c) 2012 W5mith. All rights reserved.
//

#import "MUOAuth2Client.h"
#import "MUOAuth2LoginView.h"
#import "MUOAuth2Credential.h"
#import "NSString+Query.h"

static NSString *const kMeetupAuthorizationEndpoint = @"https://secure.meetup.com/oauth2/authorize";
static NSString *const kMeetupAccessEndpoint = @"https://secure.meetup.com/oauth2/access";

typedef void(^SuccessBlock)(MUOAuth2Credential *credential);
typedef void(^FailureBlock)(NSError *error);

@interface MUOAuth2Client() <MUOAuth2LoginViewDelegate>
@property (nonatomic, strong) MUOAuth2Credential *credential;
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

- (void)authorizeClientWithID:(NSString *)clientID
                       secret:(NSString *)secret
                  redirectURI:(NSString *)redirectURI
                      success:(void(^)(MUOAuth2Credential *credential))success
                      failure:(void(^)(NSError *error))failure
{
    // Credential.
    self.credential = [[MUOAuth2Credential alloc] init];
    self.credential.clientID = clientID;
    self.credential.clientSecret = secret;
    self.credential.redirectURI = redirectURI;
    
    // Result blocks.
    self.successBlock = success;
    self.failureBlock = failure;
    
    // Assemble the authorization url.
    NSString *urlString = [NSString stringWithFormat:@"%@?client_id=%@&response_type=code&redirect_uri=%@&set_mobile=on", kMeetupAuthorizationEndpoint, clientID, redirectURI];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // Create the login web view.
    self.loginView = [[MUOAuth2LoginView alloc] initWithRequest:request delegate:self];
    [self.loginView show];
}

- (void)refreshAccessTokenWithCredential:(MUOAuth2Credential *)credential
                                 success:(void(^)(MUOAuth2Credential *credential))success
                                 failure:(void(^)(NSError *error))failure
{
    self.successBlock = success;
    self.failureBlock = failure;
    
    NSLog(@"Credential: %@", credential);
    
    NSDictionary *params = @{
                              @"client_id" : credential.clientID,
                          @"client_secret" : credential.clientSecret,
                             @"grant_type" : @"refresh_token",
                          @"refresh_token" : credential.refreshToken
                            };
    
    [self performRequestWithParameters:params];
}


#pragma mark - Private Methods

- (void)performRequestWithParameters:(NSDictionary *)params
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kMeetupAccessEndpoint]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[NSString queryStringWithDictionary:params] dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse *response = nil; NSError *error = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if (!error) {
            
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
            if (error) NSLog(@"JSON parsing error -> %@", error);
            
            if ([responseDict valueForKey:@"error"]) {
                
                NSLog(@"Error -> %@", responseDict);
                self.failureBlock(nil);
                return;
            }
            
            NSLog(@"Response: \n%@", responseDict);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.credential.accessToken = [responseDict valueForKey:@"access_token"];
                self.credential.refreshToken = [responseDict valueForKey:@"refresh_token"];
                self.credential.expiry = [NSDate dateWithTimeIntervalSinceNow:[[responseDict valueForKey:@"expires_in"] doubleValue]];
                
                if (self.successBlock != NULL) self.successBlock(self.credential);
            });
            
        } else {
            
            NSLog(@"Connection error -> %@", error);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.failureBlock != NULL) self.failureBlock(error);
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
                           @"redirect_uri" : self.credential.redirectURI,
                                   @"code" : authCode
                            };
    
    [self performRequestWithParameters:params];
}


#pragma mark - Login View Delegate

- (BOOL)loginView:(MUOAuth2LoginView *)loginView shouldStartLoadWithRequest:(NSURLRequest *)request
{
    NSURL *redirectURL = [NSURL URLWithString:self.credential.redirectURI];
    if ([request.URL.scheme isEqualToString:redirectURL.scheme]) {

        [loginView close];
        
        NSDictionary *params = [request.URL.query dictionaryFromQueryString];
        
        NSString *authCode = [params objectForKey:@"code"];
        [self requestAccessTokenWithCode:authCode];
        
        return NO;
    }
    
    return YES;
}

@end
