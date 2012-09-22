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

- (BOOL)loginView:(MUOAuth2LoginView *)loginView shouldStartLoadWithRequest:(NSURLRequest *)request;

@end


