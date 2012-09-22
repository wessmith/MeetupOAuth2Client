//
//  MUViewController.m
//  MeetupOAuth2Client
//
//  Created by Wes on 9/20/12.
//  Copyright (c) 2012 Wesley Smith. All rights reserved.
//

#import "MUViewController.h"
#import "MUOAuth2Client.h"
#import "MUOAuth2Credential.h"
#import "NSString+Query.h"

#error You need to enter you own consumer detials here.
static NSString *const kClientID = @"";
static NSString *const kClientSecret = @"";
static NSString *const kRedirectURI = @"";

@interface MUViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (nonatomic, strong) MUOAuth2Credential *credential;
@end

NSString *CredentialSavePath() {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"OAuthCredential.cache"];
}

@implementation MUViewController

- (MUOAuth2Credential *)credential
{
    if (!_credential) {
        _credential = [NSKeyedUnarchiver unarchiveObjectWithFile:CredentialSavePath()];
    }
    return _credential;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)authenticateAction:(id)sender
{
    MUOAuth2Client *client = [MUOAuth2Client sharedClient];
    
    [client authorizeClientWithID:kClientID secret:kClientSecret redirectURI:kRedirectURI success:^(MUOAuth2Credential *credential) {
        
        // Save the credential.
        [NSKeyedArchiver archiveRootObject:credential toFile:CredentialSavePath()];
        
        self.credential = credential;
        
        NSLog(@"Credential saved: %@", [credential description]);
        
        [self fetchSelf];
        
    } failure:^(NSError *error) {
        
        NSLog(@"Authorization error -> %@", error);
    }];
}

- (IBAction)expireTestAction:(id)sender
{
    self.credential.expiry = [NSDate date];
    [NSKeyedArchiver archiveRootObject:self.credential toFile:CredentialSavePath()];
    
    NSLog(@"Expiration altered in credential.");
}

- (IBAction)refreshAction:(id)sender
{
    MUOAuth2Client *client = [MUOAuth2Client sharedClient];
    
    if (self.credential && self.credential.isExpired) {
        
        [client refreshAccessTokenWithCredential:self.credential success:^(MUOAuth2Credential *credential) {
            
            // Save the credential.
            [NSKeyedArchiver archiveRootObject:credential toFile:CredentialSavePath()];
            
            self.credential = credential;
            
            NSLog(@"Credential saved: %@", [credential description]);
            
        } failure:^(NSError *error) {
            
            NSLog(@"Refresh error -> %@", error);
        }];
    }
}

- (void)fetchSelf
{
    NSLog(@"Fetching self...");
    
    NSDictionary *params = @{ @"member_id" : @"self", @"access_token" : self.credential.accessToken };
    
    NSString *query = [NSString stringWithFormat:@"https://api.meetup.com/2/members?%@", [NSString queryStringWithDictionary:params]];
    NSLog(@"URL = %@", query);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:query]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse *response = nil; NSError *error = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if (!error) {
            
            NSError *error = nil;
            id json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
            if (error) NSLog(@"JSON Parsing error -> %@", error);
            
            NSDictionary *results = [[json valueForKey:@"results"] objectAtIndex:0];
            
            NSLog(@"Result: \n%@", results);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.nameLabel.text = [results valueForKey:@"name"];
                NSString *city = [results valueForKey:@"city"];
                NSString *state = [results valueForKey:@"state"];
                self.locationLabel.text = [NSString stringWithFormat:@"%@, %@", city, state];
            });
            
        } else {
            
            NSLog(@"Connection error -> %@", error);
        }
    });
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
