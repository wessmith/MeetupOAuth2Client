//
//  MUOAuth2LoginView.m
//  Gander
//
//  Created by Wes on 9/16/12.
//  Copyright (c) 2012 Wesley Smith. All rights reserved.
//

#import "MUOAuth2LoginView.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+Query.h"

const CGFloat kPadding = 8.0;
const NSTimeInterval kShowAnimationDuration = 0.2;
const NSTimeInterval kBounceAnimationDuration = 0.15;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Close Button -

@interface MUCloseButton : UIControl
@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MUCloseButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) self.backgroundColor = [UIColor clearColor];
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGRect innerRect = CGRectInset(rect, 11, 11);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context,innerRect);
    
    // Draw the stroked circle.
    CGContextSetLineWidth(context, 4.f);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.0 alpha:0.6].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.97 alpha:1.f].CGColor);
    CGContextFillEllipseInRect(context, innerRect);
    CGContextStrokeEllipseInRect(context, innerRect);

    // Draw the (x).
    CGContextSetLineWidth(context, 2.f);
    CGFloat x1 = innerRect.size.width * 0.30 + rect.size.width/4;
    CGFloat y1 = innerRect.size.height * 0.30 + rect.size.height/4;
    CGFloat x2 = innerRect.size.width * 0.70 + rect.size.width/4;
    CGFloat y2 = innerRect.size.height * 0.70 + rect.size.height/4;
    CGContextMoveToPoint(context, x1, y1);
    CGContextAddLineToPoint(context, x2, y2);
    CGFloat x3 = innerRect.size.width * 0.70 + rect.size.width/4;
    CGFloat y3 = innerRect.size.height * 0.30 + rect.size.height/4;
    CGFloat x4 = innerRect.size.width * 0.30 + rect.size.width/4;
    CGFloat y4 = innerRect.size.height * 0.70 + rect.size.height/4;
    CGContextMoveToPoint(context, x3, y3);
    CGContextAddLineToPoint(context, x4, y4);
    CGContextStrokePath(context);
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Login View -

@interface MUOAuth2LoginView() <UIWebViewDelegate>
@property (nonatomic, weak) id <MUOAuth2LoginViewDelegate> delegate;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) MUCloseButton *closeButton;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MUOAuth2LoginView

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithRequest:(NSURLRequest *)request
             delegate:(id <MUOAuth2LoginViewDelegate>)delegate;
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        
        NSAssert(delegate != nil, @"MUOAuthLoginDelegate must not be nil.");
        self.delegate = delegate;
        
        // Calculate the frame and add to the window.
        UIApplication *app = [UIApplication sharedApplication];
        UIWindow *window = app.keyWindow;
        CGFloat statusBarheight = app.statusBarFrame.size.height;
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(kPadding + statusBarheight,
                                                      kPadding,
                                                      kPadding,
                                                      kPadding);
        
        self.frame = UIEdgeInsetsInsetRect(window.bounds, contentInsets);
        [window addSubview:self];
        
        // Add an off-white background view.
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectInset(self.bounds,
                                                                           kPadding,
                                                                           kPadding)];
        
        backgroundView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.f];
        backgroundView.layer.cornerRadius = 5.f;
        backgroundView.clipsToBounds = YES;
        [self addSubview:backgroundView];
        
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
        self.layer.cornerRadius = 10.f;
        self.alpha = 0.f;
        self.transform = CGAffineTransformMakeScale(0.001, 0.001);
        
        // Load the request.
        [self.webView loadRequest:request];
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc
{
    // Recommended in the Apple docs.
    self.webView.delegate = nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Getters

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIWebView *)webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectInset(self.bounds, kPadding, kPadding)];
        _webView.layer.cornerRadius = 5.f;
        _webView.clipsToBounds = YES;
        _webView.delegate = self;
    }
    return _webView;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIActivityIndicatorView *)activityView
{
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc]
                         initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityView.color = [UIColor grayColor];
        _activityView.center = self.center;
        _activityView.hidesWhenStopped = YES;
    }
    return _activityView;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (MUCloseButton *)closeButton
{
    if (!_closeButton) {
        _closeButton = [[MUCloseButton alloc] initWithFrame:
                        CGRectMake(self.frame.size.width, -14, 44, 44)];
        _closeButton.transform = CGAffineTransformMakeScale(0.001, 0.001);
        [_closeButton addTarget:self action:@selector(close)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)show
{
    // Animate slightly larger than target scale...
    [UIView animateWithDuration:kShowAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveLinear animations:^{
        
        self.transform = CGAffineTransformMakeScale(1.1, 1.1);
        self.alpha = 1.f;
        
    } completion:^(BOOL finished) {
        
        // Show loading activity.
        [self.activityView startAnimating];
        
        // Bounce back to slightly smaller than target scale...
        [UIView animateWithDuration:kBounceAnimationDuration
                              delay:0
                            options:UIViewAnimationOptionCurveLinear animations:^{
            
            self.transform = CGAffineTransformMakeScale(0.9, 0.9);
            
        } completion:^(BOOL finished) {
            
            // Ad the close button.
            [self addSubview:self.closeButton];
            
            // Final bounce to target scale.
            [UIView animateWithDuration:kBounceAnimationDuration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut animations:^{

                self.transform = CGAffineTransformMakeScale(1, 1);
                self.closeButton.transform = CGAffineTransformMakeScale(1, 1);
                
            } completion:NULL];
        }];
    }];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)close
{
    // Bounce slightly larger than target scale...
    [UIView animateWithDuration:kBounceAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut animations:^{
       
        self.transform = CGAffineTransformMakeScale(1.1, 1.1);
       
    } completion:^(BOOL finished) {
        
        // Animate down to target scale.
        [UIView animateWithDuration:kBounceAnimationDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            self.transform = CGAffineTransformMakeScale(0.001, 0.001);
            self.alpha = 0.f;
            
        } completion:^(BOOL finished) {
            
            [self removeFromSuperview];
        }];
    }];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Web View Delegate -

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)webView:(UIWebView *)webView
            shouldStartLoadWithRequest:(NSURLRequest *)request
                        navigationType:(UIWebViewNavigationType)navigationType
{    
    if ([self.delegate conformsToProtocol:@protocol(MUOAuth2LoginViewDelegate)])
        return [self.delegate loginView:self shouldStartLoadWithRequest:request];
    
    return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)webViewDidFinishLoad:(UIWebView *)webView
{    
    [self.activityView stopAnimating];
    
    // Adjust the width of the webview content to fit nicely in the slightly smaller frame.
    NSString *javascript = [NSString stringWithFormat:
                                @"document.body.style.width='%dpx'",
                                (int)self.webView.bounds.size.width];
    
    [self.webView stringByEvaluatingJavaScriptFromString:javascript];
    
    // Add the webView.
    [self insertSubview:webView belowSubview:self.closeButton];
}

////////////////////////////////////////////////////////////////////////////////
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(loginView:didFailLoadWithError:inWebView:)])
        [self.delegate loginView:self didFailLoadWithError:error inWebView:webView];
}

@end
