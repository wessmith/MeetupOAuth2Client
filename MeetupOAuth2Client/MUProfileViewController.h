//
//  MUProfileViewController.h
//  MeetupOAuth2Client
//
//  Created by Wesley Smith on 9/20/12.
//  Copyright (c) 2012 Wesley Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MUOAuth2Client.h"

@protocol MUProfileViewControllerDelegate;


@interface MUProfileViewController : UIViewController

@property (nonatomic, weak) id <MUProfileViewControllerDelegate> delegate;
@property (nonatomic, strong) MUOAuth2Credential *credential;

@end


@protocol MUProfileViewControllerDelegate <NSObject>

- (void)profileViewControllerDidRequestLogout:(MUProfileViewController *)sender;

@end
