//
//  NSString+Query.m
//  Gander
//
//  Created by Wes on 9/17/12.
//  Copyright (c) 2012 Wesley Smith. All rights reserved.
//

#import "NSString+Query.h"

@implementation NSString (Query)

+ (NSString *)queryStringWithDictionary:(NSDictionary *)params
{
    NSMutableString *query = [NSMutableString string];
    NSArray *keys = [params allKeys];
    NSArray *values = [params allValues];
    [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if (idx == keys.count - 1)
            [query appendFormat:@"%@=%@", obj, [values objectAtIndex:idx]];
        else
            [query appendFormat:@"%@=%@&", obj, [values objectAtIndex:idx]];
        
    }];
    return [query copy];
}

- (NSDictionary *)dictionaryFromQueryString
{
    NSArray *params = [self componentsSeparatedByString:@"&"];
    NSMutableDictionary *paramsDict = [NSMutableDictionary dictionaryWithCapacity:params.count];
    for (NSString *param in params) {
        NSArray *parts = [param componentsSeparatedByString:@"="];
        NSString *key = [parts objectAtIndex:0];
        NSString *value = [parts objectAtIndex:1];
        [paramsDict setObject:value forKey:key];
    }
    return [paramsDict copy];
}

@end
