//
//  MUAPIRequest.h
//  MeetupOAuth2Demo
//
//  Created by Matt Connolly on 26/03/13.
//  Copyright (c) 2012 Matt Connolly. All rights reserved.
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
//

#import <Foundation/Foundation.h>

@class MUOAuth2Credential;

@interface MUAPIRequest : NSObject <NSURLConnectionDataDelegate,NSURLConnectionDelegate>

{
    NSMutableData* _mutableData;
    NSURLRequest* _request;
    NSURLResponse* _response;
    NSError* _error;
}

// a copy of the request that was started
@property (nonatomic, readonly) NSURLRequest* request;

// set when the request is finished
@property (nonatomic, readonly) NSURLResponse* response;

// an immutable copy of the response data.
@property (nonatomic, readonly) NSData* data;

// set if the request failed, or JSON parsing failed.
@property (nonatomic, readonly) NSError* error;

// This dictionary is created by deserialising the JSON response data.
@property (nonatomic, readonly) NSDictionary* responseBody;

+ (MUAPIRequest*)getRequestWithURL:(NSString*)baseURL
                        parameters:(NSDictionary*)parameters
                     andCredential:(MUOAuth2Credential*)credential
                        completion:(void(^)(MUAPIRequest* request))completion;


+ (MUAPIRequest*)postRequestWithURL:(NSString*)baseURL
                         parameters:(NSDictionary*)parameters
                      andCredential:(MUOAuth2Credential*)credential
                         completion:(void(^)(MUAPIRequest* request))completion;


+ (MUAPIRequest*)deleteRequestWithURL:(NSString*)baseURL
                           parameters:(NSDictionary*)parameters
                        andCredential:(MUOAuth2Credential*)credential
                           completion:(void(^)(MUAPIRequest* request))completion;

@end
