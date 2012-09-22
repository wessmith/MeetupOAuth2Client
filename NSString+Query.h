//
//  NSString+Query.h
//  Gander
//
//  Created by Wes on 9/17/12.
//  Copyright (c) 2012 Wesley Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Query)

+ (NSString *)queryStringWithDictionary:(NSDictionary *)params;

- (NSDictionary *)dictionaryFromQueryString;

@end
