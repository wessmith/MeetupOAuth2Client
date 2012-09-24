//
//  MUViewController.m
//  MeetupOAuth2Client
//
//  Created by Wes on 9/20/12.
//  Copyright (c) 2012 Wesley Smith. All rights reserved.
//

#import "MUViewController.h"
#import "MUOAuth2Client.h"
#import "MUProfileViewController.h"

#error You need to enter you own consumer detials here.
static NSString *const kClientID = @"";
static NSString *const kClientSecret = @"";
static NSString *const kRedirectURI = @"";

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
