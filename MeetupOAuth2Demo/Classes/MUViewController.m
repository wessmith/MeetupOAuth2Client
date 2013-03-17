//
//  MUViewController.m
//  MeetupOAuth2Client
//
//  Created by Wesley Smith on 9/20/12.
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


#import "MUViewController.h"
#import "MUOAuth2Client.h"
#import "MUProfileViewController.h"

#error You need to enter you own consumer detials here.
static NSString *const kClientID = @"<YOUR CLIENT ID>";
static NSString *const kClientSecret = @"<YOUR CLIENT SECRET>";
static NSString *const kRedirectURI = @"<YOUR REDIRECT URL>";

@interface MUViewController() <MUProfileViewControllerDelegate>
@property (nonatomic, strong) MUOAuth2Credential *credential;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@end

@implementation MUViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MUOAuth2Client *client = [MUOAuth2Client sharedClient];
    
    // Attempt to unarchive an existing credential.
    self.credential = [client credentialWithClientID:kClientID];
    NSLog(@"credential unarchived: %@", self.credential);
    
    if (!self.credential) {
        
        // Show the login view (in this case do nothing).
        
    } else if (self.credential.isExpired) {
        
        // Refresh the credential.
        [client refreshCredential:self.credential success:^(MUOAuth2Credential *credential) {
            
            NSLog(@"\nRefreshed Credential: \n%@\n", [credential description]);
            
            self.credential = credential;
            
        } failure:^(NSError *error) {
            
            NSLog(@"Authorization error -> %@", error);
        }];
        
    } else {
        
        // Show the profile view.
        [self loadProfileView:NO];
    }
}

- (void)loadProfileView:(BOOL)animated
{
    MUProfileViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"MUProfileView"];
    controller.delegate = self;
    controller.credential = self.credential;
    [self.navigationController presentViewController:controller animated:animated completion:NULL];
}

- (IBAction)authenticateAction:(id)sender
{
    MUOAuth2Client *client = [MUOAuth2Client sharedClient];
    
    [client authorizeClientWithID:kClientID secret:kClientSecret redirectURI:kRedirectURI success:^(MUOAuth2Credential *credential) {
        
        self.credential = credential;
        
        NSLog(@"\nNew Credential: \n%@\n", [self.credential description]);
        
        [self loadProfileView:YES];
        
    } failure:^(NSError *error) {
        
        NSLog(@"Authorization error -> %@", error);
    }];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Profile View Delegate -

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)profileViewControllerDidRequestLogout:(MUProfileViewController *)sender
{
    NSLog(@"Logging out...");
    
    MUOAuth2Client *client = [MUOAuth2Client sharedClient];
    [client forgetCredentialWithClientID:kClientID];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

@end
