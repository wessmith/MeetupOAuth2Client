//
//  MeetupOAuth2Client
//
//  Created by Wesley Smith on 1/25/14.
//  Copyright (c) 2014 Wesley Smith. All rights reserved.
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


function removeNode(node) { node.parentNode.removeChild(node); }                                

function getElementByAttributeValue(attribute, value) {
  var allElements = document.getElementsByTagName('a');
  for (var i = 0; i < allElements.length; i++)
   {
    if (allElements[i].getAttribute(attribute) == value)
    {
      return allElements[i];
    }
  }
}

// Remove elements that conflict with App Store requirements (section 11.13).
removeNode(document.getElementById('top-nav-wrapper'));
removeNode(document.querySelector('footer'));
removeNode(getElementByAttributeValue('href', 'https://secure.meetup.com/register/'));

// Fix Facebook connect font size.
document.querySelector('.fb-button-title').style.fontSize = '15px';
                                