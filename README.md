
# Meetup OAuth2 Client

MeetupOAuth2Client is an HTTP OAuth2 authentication client specifically for use with the Meetup.com API. This small library is completely self-contained–no dependencies. It features a nice pop-out animating web view to display the Meetup authorization page.

##Installation

Add the contents of the `MUOAuth2Client/src` folder to your project.

##Use and Flow

At the point in your application where you need to access the user's resources, the flow should be like the following:

``` objective-c

// Grab a reference to the shared instance of `MUOAuth2Client`.
MUOAuth2Client *client = [MUOAuth2Client sharedClient];

// Attempt to unarchive an existing credential.
self.credential = [client credentialWithClientID:@"YOUR_CLIENT_ID"];

if (!self.credential) {

  // Here you should show the pre-logged in state of your application.
  // where the user may be presented with a "log in" button.
  // (See the "authorization" snippet)
  
} else if (self.credential.isExpired) {
  
    // Refresh the credential.
	[client refreshCredential:self.credential success:^(MUOAuth2Credential *credential) {
  
        // Hang on to this new credential.
        self.credential = credential;
    
	} failure:^(NSError *error) {
  
        // Handle the error.
		NSLog(@"Authorization error -> %@", error);
	}];

} else {

    // The credential should be valid. 
    // Proceed with accessing the Meetup API and loading the user's resources.
}

```

### Authorization
The following will trigger a web view presentation of the Meetup.com mobile log-in/authorization page allowing the user to authorize your application:


``` objective-c

// Grab a reference to the shared instance of `MUOAuth2Client`.
MUOAuth2Client *client = [MUOAuth2Client sharedClient];

// Authorize your client application with the client ID, secret, and redirect URI you set up with Meetup.com.
[client authorizeClientWithID:@"YOUR_CLIENT_ID" secret:@"SECRET" redirectURI:@"REDIRECT" success:^(MUOAuth2Credential *credential) {
  
    // Hang on the credential.
    self.credential = credential;
	
	// Proceed with accessing the Meetup API and loading the user's resources.
	
} failure:^(NSError *error) {
	
    // Handle the error.
	NSLog(@"Authorization error -> %@", error);
}];
    
````

### Using the credential
Once you have obtained a valid `MUOAuth2Credential` object, you can use it's `accessToken` property to append to your requests to the Meetup.com API: `credential.accessToken`.

### Using the MUAPIRequest class
The MUAPIRequest class provides a convenient way to access Meetup API endpoints, and parse JSON response bodies. For example:

``` objective-c
- (void)accessMemberSelf
{
    MUOAuth2Credential* credential = [[MUOAuth2Client sharedClient] credentialWithClientID:@"oauth-consumer-key"];
    [MUAPIRequest getRequestWithURL:@"https://api.meetup.com/2/member/self.json"
                         parameters:@{}
                      andCredential:credential
                         completion:^(MUAPIRequest *request) {
                             NSLog(@"Response = %@", request.response); // response object
                             NSLog(@"Error = %@", request.error); // set if there was an error
                             NSLog(@"JSON = %@", request.responseBody); // JSON Decoded to NSDictionary
                         }];
  
}
```

##Requirements
MUOAuth2Client requires iOS 5.0 or higher and uses ARC.

##Notes
This library does not communicate with Meetup.com other than to authorize client applications and obtain and refresh access tokens. Further communication with the Meetup.com API could be done with a library such as [AFNetworking](https://github.com/AFNetworking/AFNetworking).
This library is intentionally simple, but no doubt there is room for improvement. Contributions are welcome.

## Demo App
Included in the project is a sample application to illustrate the flow of the authorization and refreshing of tokens.