//
//  MUAPIRequest.m
//  MeetupOAuth2Demo
//
//  Created by Matt Connolly on 26/03/13.
//  Copyright (c) 2013 Matt Connolly. All rights reserved.
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

#import "MUAPIRequest.h"
#import "NSString+Query.h"
#import "MUOAuth2Client.h"

@interface MUAPIRequest()
{
    NSMutableData* _mutableData;
    NSURLRequest* _request;
    NSURLResponse* _response;
    NSError* _error;
}

@property (nonatomic,copy) void (^completion)(MUAPIRequest *request);
@property (nonatomic,retain) NSURLRequest *request;
@property (nonatomic,retain) NSURLResponse *response;

@end

@implementation MUAPIRequest


+ (MUAPIRequest*)getRequestWithURL:(NSString *)baseURL
                        parameters:(NSDictionary *)parameters
                     andCredential:(MUOAuth2Credential *)credential
                        completion:(void(^)(MUAPIRequest *request))completion;
{
    NSString* token = credential.accessToken;
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",
                                       baseURL,
                                       parameters ? [NSString queryStringWithDictionary:parameters] : @""]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLCacheStorageAllowed
                                                       timeoutInterval:60.0];
    [request addValue:[NSString stringWithFormat:@"bearer %@", token]
   forHTTPHeaderField:@"Authorization"];
    [request addValue:@"utf-8" forHTTPHeaderField:@"Accept-Charset"];
    request.HTTPMethod = @"GET";
    
    MUAPIRequest* result = [[MUAPIRequest alloc] init];
    result.request = request;
    result.completion = completion;
    
    [NSURLConnection connectionWithRequest:request
                                  delegate:result];
    return result;
}

+ (MUAPIRequest *)postRequestWithURL:(NSString *)baseURL
                         parameters:(NSDictionary *)parameters
                      andCredential:(MUOAuth2Credential *)credential
                         completion:(void(^)(MUAPIRequest *request))completion;
{
    NSString *token = credential.accessToken;
    NSURL *url = [NSURL URLWithString:baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLCacheStorageAllowed
                                                       timeoutInterval:60.0];
    [request addValue:[NSString stringWithFormat:@"bearer %@", token]
   forHTTPHeaderField:@"Authorization"];
    [request addValue:@"utf-8" forHTTPHeaderField:@"Accept-Charset"];
    request.HTTPMethod = @"POST";
    
    // TODO: This does not yet handle 'multipart/form-data' posts for photo uploads.
    request.HTTPBody = [[NSString queryStringWithDictionary:parameters] dataUsingEncoding:NSUTF8StringEncoding];
    MUAPIRequest *result = [[MUAPIRequest alloc] init];
    result.request = request;
    result.completion = completion;
    
    [NSURLConnection connectionWithRequest:request
                                  delegate:result];
    return result;
}

+ (MUAPIRequest*)deleteRequestWithURL:(NSString *)baseURL
                           parameters:(NSDictionary *)parameters
                        andCredential:(MUOAuth2Credential *)credential
                           completion:(void(^)(MUAPIRequest *request))completion;
{
    NSString *token = credential.accessToken;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",
                                       baseURL,
                                       parameters ? [NSString queryStringWithDictionary:parameters] : @""]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLCacheStorageAllowed
                                                       timeoutInterval:60.0];
    [request addValue:[NSString stringWithFormat:@"bearer %@", token]
   forHTTPHeaderField:@"Authorization"];
    [request addValue:@"utf-8" forHTTPHeaderField:@"Accept-Charset"];
    request.HTTPMethod = @"DELETE";
    
    MUAPIRequest *result = [[MUAPIRequest alloc] init];
    result.request = request;
    result.completion = completion;
    
    [NSURLConnection connectionWithRequest:request
                                  delegate:result];
    return result;
}

- (id)init
{
    self = [super init];
    if (self) {
        _mutableData = [NSMutableData data];
    }
    return self;
}

#pragma mark NSURLConnectionDelegate protocol methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
{
    [_mutableData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (_completion)
    {
        _completion(self);
        _completion = nil;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (_completion)
    {
        _completion(self);
        _completion = nil;
    }
}

#pragma mark property accessors

- (NSData *)data
{
    return [_mutableData copy];
}

- (NSDictionary *)responseBody
{
    NSDictionary *result = nil;
    if (_mutableData.length > 0)
    {
        NSError *error;
        result = (NSDictionary*) [NSJSONSerialization JSONObjectWithData:self.data
                                                                 options:0
                                                                   error:&error];
        _error = error;
    }
    return result;
}

@end
