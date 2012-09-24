//
//  MUOAuth2LoginView.h
//  Gander
//
//  Created by Wes on 9/16/12.
//  Copyright (c) 2012 Wesley Smith. All rights reserved.
//

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


