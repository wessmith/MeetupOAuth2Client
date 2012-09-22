//
//  MUProfileViewController.m
//  MeetupOAuth2Client
//
//  Created by Wesley Smith on 9/20/12.
//  Copyright (c) 2012 Wesley Smith. All rights reserved.
//

#import "MUProfileViewController.h"

@interface MUProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoView;
@property (weak, nonatomic) IBOutlet UILabel *memberNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *memberLocationLabel;
@property (weak, nonatomic) IBOutlet UITextView *memberBioTextView;
@end

@implementation MUProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
