//
//  NSString+Query.m
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


#import "NSString+Query.h"

@implementation NSString (Query)

+ (NSString *)queryStringWithDictionary:(NSDictionary *)params
{
    NSMutableString *query = [NSMutableString string];
    NSArray *keys = [params allKeys];
    [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString* key = (NSString*)obj;
        NSString* value = params[key];
        key = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        value = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [query appendFormat:@"%@%@=%@", (idx > 0) ? @"&" : @"", key, value];
    }];
    return [query copy];
}

- (NSDictionary *)dictionaryFromQueryString
{
    NSArray *params = [self componentsSeparatedByString:@"&"];
    NSMutableDictionary *paramsDict = [NSMutableDictionary dictionaryWithCapacity:params.count];
    for (NSString *param in params) {
        NSArray *parts = [param componentsSeparatedByString:@"="];
        NSString *key = [[parts objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *value = [[parts objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [paramsDict setObject:value forKey:key];
    }
    return [paramsDict copy];
}

@end
