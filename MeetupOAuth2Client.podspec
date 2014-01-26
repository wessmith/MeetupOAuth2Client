Pod::Spec.new do |s|
  s.name         = "MeetupOAuth2Client"
  s.version      = "0.0.1"
  s.summary      = "Meetup API OAuth2 client for iOS."
  s.homepage     = "https://github.com/w5mith/MeetupOAuth2Client"
  s.license 	 = { :type => 'Apache License, Version 2.0', :file => 'LICENSE.md' }
  s.authors 	 = { "Wes Smith" => "wes@w5mith.com" }
  s.source       = { :git => "https://github.com/w5mith/MeetupOAuth2Client.git", :tag => s.version.to_s }
  s.platform     = :ios, '5.1'
  s.requires_arc = true
  s.source_files = 'Classes', 'MUOAuth2Client/src/*.{h,m}'
  s.public_header_files = 'MUOAuth2Client/src/MU*.h'
  s.resource_bundle = { 'MeetupOAuth2Client' => 'MUOAuth2Client/src/*.js' }
end
