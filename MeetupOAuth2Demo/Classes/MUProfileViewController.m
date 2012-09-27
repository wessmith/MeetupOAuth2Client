//
//  MUProfileViewController.m
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


#import "MUProfileViewController.h"
#import "NSString+Query.h"

@interface MUProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoView;
@property (weak, nonatomic) IBOutlet UILabel *memberNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *memberLocationLabel;
@property (weak, nonatomic) IBOutlet UITextView *memberBioTextView;
@end

@implementation MUProfileViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Clear the dummy text.
    self.memberNameLabel.text = nil;
    self.memberLocationLabel.text = nil;
    self.memberBioTextView.text = nil;
    
    [self fetchProfile];
}

- (IBAction)logOutAction:(UIBarButtonItem *)sender
{
    if ([self.delegate respondsToSelector:@selector(profileViewControllerDidRequestLogout:)])
        [self.delegate profileViewControllerDidRequestLogout:self];
}

- (void)fetchProfile
{
    NSDictionary *params = @{ @"member_id" : @"self", @"access_token" : self.credential.accessToken };
    
    NSString *query = [NSString stringWithFormat:@"https://api.meetup.com/2/members?%@", [NSString queryStringWithDictionary:params]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:query]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLResponse *response = nil; NSError *error = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if (!error) {
            
            NSError *error = nil;
            id json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
            if (error) NSLog(@"JSON Parsing error -> %@", error);
            
            NSDictionary *results = [[json valueForKey:@"results"] objectAtIndex:0];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.memberNameLabel.text = [results valueForKey:@"name"];
                NSString *city = [results valueForKey:@"city"];
                NSString *state = [results valueForKey:@"state"];
                self.memberLocationLabel.text = [NSString stringWithFormat:@"%@, %@", city, state];
                self.memberBioTextView.text = [results valueForKey:@"bio"];
                
                NSURL *photoURL = [NSURL URLWithString:[results valueForKeyPath:@"photo.photo_link"]];
                [self fetchProfilePhotoAtURL:photoURL];
            });
            
        } else {
            
            NSLog(@"Connection error -> %@", error);
        }
    });
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)fetchProfilePhotoAtURL:(NSURL *)photoURL
{    
    if (!photoURL) return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *imageData = [NSData dataWithContentsOfURL:photoURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.profilePhotoView.image = [UIImage imageWithData:imageData];
        });
    });
}

@end
