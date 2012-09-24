//
//  MUOAuth2Client.h
//  Gander
//
//  Created by Wesley Smith on 9/17/12.
//  Copyright (c) 2012 Wesley Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MUOAuth2Credential;

@interface MUOAuth2Client : NSObject

/**
 * Initializes a single shared instance of a `MUOAuth2Client` object.
 *
 *      @return             An instance of `MUOAuth2Client`.
 */
+ (MUOAuth2Client *)sharedClient;

/**
 * Restores any archived credential object, if one exists.
 *
 *      @param clientID     The client ID (key) of the consumer registered with Meetup.
 *      
 *      @return             An instance of `MUOAuth2Credential` or nil.
 */
- (MUOAuth2Credential *)credentialWithClientID:(NSString *)clientID;

/**
 * Deletes the cached credential.
 *
 *      @param clientID     The client ID (key) of the consumer registered with Meetup.com.
 */
- (void)forgetCredentialWithClientID:(NSString *)clientID;

/**
 * Authorizes the client to communicate with the Meetup API on behalf of the user.
 *
 *      @param clientID     The client ID (key) of the consumer registered with Meetup.com.
 *      @param secret       The client secret of the consumer registered with Meetup.com.
 *      
 *      @param success      A block object to be executed when the request finishes successfully.
 *                          This block has no return value and takes one argument: the credential.
 *      
 *      @param failure      A block object to be executed when the request operation finishes unsuccessfully,
 *                          or that finishes successfully, but encountered an error while parsing the response data,
 *                          or failed to authorize with the Meetup API. This block has no return value and takes one
 *                          argument: the `NSError` object describing the network, parsing, or API error that occurred.
 */
- (void)authorizeClientWithID:(NSString *)clientID
                       secret:(NSString *)secret
                  redirectURI:(NSString *)redirectURI
                      success:(void(^)(MUOAuth2Credential *credential))success
                      failure:(void(^)(NSError *error))failure;

/**
 * Refreshes the client to communicate with the Meetup API on behalf of the user.
 *
 *      @param credential   The credential object that has expired and needs to be refreshed.
 *
 *      @param success      A block object to be executed when the request finishes successfully.
 *                          This block has no return value and takes one argument: the credential.
 *
 *      @param failure      A block object to be executed when the request operation finishes unsuccessfully,
 *                          or that finishes successfully, but encountered an error while parsing the response data,
 *                          or failed to authorize with the Meetup API. This block has no return value and takes one
 *                          argument: the `NSError` object describing the network, parsing, or API error that occurred.
 */
- (void)refreshCredential:(MUOAuth2Credential *)credential
                  success:(void(^)(MUOAuth2Credential *credential))success
                  failure:(void(^)(NSError *error))failure;

@end

/**
 * An object used to store authentication information for a Meetup.com consumer application.
 */
@interface MUOAuth2Credential : NSObject

/**
 * The access token used to make API calls to Meetup.com.
 */
@property (copy, nonatomic, readonly) NSString *accessToken;

/**
 * Indicates whether the access token has expired.
 */
@property (readonly, nonatomic, getter = isExpired) BOOL expired;

@end
