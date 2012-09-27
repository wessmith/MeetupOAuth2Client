//
//  MUOAuth2LoginView.h
//  MeetupOAuth2Client
//
//  Created by Wesley Smith on 9/16/12.
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


#import <UIKit/UIKit.h>

@protocol MUOAuth2LoginViewDelegate;


@interface MUOAuth2LoginView : UIView

- (id)initWithRequest:(NSURLRequest *)request delegate:(id <MUOAuth2LoginViewDelegate>)delegate;

- (void)show;

- (void)close;

@end


@protocol MUOAuth2LoginViewDelegate <NSObject>

- (void)loginView:(MUOAuth2LoginView *)sender didFailLoadWithError:(NSError *)error inWebView:(UIWebView *)webView;

- (BOOL)loginView:(MUOAuth2LoginView *)sender shouldStartLoadWithRequest:(NSURLRequest *)request;

@end


