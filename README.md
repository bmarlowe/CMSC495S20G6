# pantry

A new Flutter application for CMSC 495 Spring 2020 Group 6.

Demo1:
https://imgur.com/4EesYq3.gif
Demo2:
https://imgur.com/MalO5sA.gif
Demo3:
https://imgur.com/4s3Xdox.gif

## Getting Started

This project is a starting point for a Flutter Pantry Mobile Application.

This branch has all of the created flutter files for the UI portion of the project.

## Downloaded Items: 
	Flutter
	Android Studio
	Xcode / VS Code

Research how to use Flutter and program application:

### home_screen.dart:  
Flutter packages added:
Flutter specifics: uses-material-design 

https://blog.brainsandbeards.com/bottom-navigation-with-a-list-screen-in-flutter-d517dc6f22f1
Much of the beginning of the project programming came from this article

@ Files produced as a result: main.dart, home_screen.dart, pantry_list.dart
@ Files edited as a result:  pubspec.yaml (added dependencies)

### login_screen.dart:  
Flutter packages added: flutter_login

https://pub.dev/packages/flutter_login
Followed documentation from link altering it.

@ Files produced as a result: login_screen.dart, users.dart (to be utilized better without constant when API is available), fade_route.dart
@ Files edited as a result:  pubspec.yaml (updates in comments on file), main.dart (added routes)

### camera.dart:
Flutter packages added: camera

https://blog.brainsandbeards.com/how-to-add-camera-support-to-a-flutter-app-c1dfd6b78823
https://pub.dev/packages/camera
All of the programming came from this site for the camera...I had a hard time getting the camera to work at first, but after reloading flutter and ensuring all dependencies were set correctly, it started working.  I blew all programs and files away and used back-up files from GitHub to recreate.  

Found that the text wasn't quite inputting correctly, upon more research I found that the text input controllers were not input correctly.  This led to a revamp of how the controllers were input into the widget and showed state.  This allows for future use to be able to put into JSON as well as a get from JSON and editable once received.

@ Files produced as a result:  camera.dart
@ Files edited as a result:  pubspec.yaml (updates in comments on file), home_screen.dart (added CameraWidget()), android/app/build.gradle (updates in comments on file), android/build.gradle(update kotlin version, and both classpath dependencies), ios/runner/info.plist (updates in comments on file)

### Found issue was not building iOS at all:

Terminal commands:
cd /Users/tara/AndroidStudio/pantry/ios <<<Your Path to your project ios file>>>
pod install

If you get the following error:
[!] CocoaPods did not set the base configuration of your project because your project already has a custom config set. In order for CocoaPods integration to work at all, please either set the base configurations of the target `Runner` to `Target Support Files/Pods-Runner/Pods-Runner.profile.xcconfig` or include the `Target Support Files/Pods-Runner/Pods-Runner.profile.xcconfig` in your build configuration (`Flutter/Release.xcconfig`).

Add command to file in project:  ios/Flutter/Release.xcconfig: 
#include "Target Support Files/Pods-Runner/Pods-Runner.profile.xcconfig"

Found issue not building in Android:

Place the following commands in project folder without the quotes:  /pantry/android/app/src/profile/AndroidManifest.xml

"<activity android:name="com.apptreesoftware.barcodescan.BarcodeScannerActivity"/>"
"<uses-permission android:name="android.permission.CAMERA" />"

### Pantry_list.dart:
Flutter packages added: http, json_annotation, build_runner, json_serializable

Found a fake back end, to simulate database input with JSON:  jsonplaceholder.typicode.com/
My link is:  https://my-json-server.typicode.com/taracell/
This is not working...I have to find something else.

Cleared up parsing from simple Json using postman, as suggested by Tony...my postman link is:  'https://2c0fb3de-8d5e-4930-aed7-35d266bb88b7.mock.pstmn.io'

Using:  https://medium.com/@diegoveloper/flutter-fetching-parsing-json-data-c019ddddaa34
https://bezkoder.com/dart-flutter-parse-json-string-array-to-object-list/#DartFlutter_parse_JSON_string_into_Object

#Note! The files produced from the build_runner are listed as file_name.g.dart...this produces the boilerplate for toJson and fromJson for your built classes.  This ensures your stuff works and makes the program work better than attempts from other websites.

@ Files produced as a result:  pantry_list.dart, pantry_list.g.dart
@ Files edited as a result:  pubspec.yaml (updates in comments on file), android/app/build.gradle (updates in comments on file)

### scan_screen.dart: 
Flutter packages added: barcode_scan_fix: ^1.0.2 and barcode_scan, intl

#Note! The barcode API is free and is acquired by using the following link within the application: 'https://api.upcitemdb.com/prod/trial/lookup?upc=' + barcode)’  the barcode is scanned by the application and stored in a string variable for use within the get http command

To see a typical JSON output go to:  https://www.upcitemdb.com/api/explorer#!/lookup/get_trial_lookup and input the following UPC:  0024000162865

#Note! The JSON output is complex and advanced for my knowledge, so I’m researching how to get the title from the standard output from the UPC scanned within the application.

Used for advanced JSON parsing...Looking for how to parse more complex JSON in flutter!
https://www.youtube.com/watch?v=NnY4B7VK6e4.  

Interesting find today...makes my dart classes for me from the raw json input, need to alter a lot to create factories for use but the base classes are there for use:  https://javiercbk.github.io/json_to_dart/

#Note! Found that JSON does not have a DateTime object it only possesses strings for this.  To make the parsing easier, created a formatter in main.dart to parse all DateTime to strings in MM/dd/yyyy format this should make things easier once the API is created and usable for all DateTime objects 

#Note! To POST to API must include headers in the request.  24 Hours to figure that out.  Main reference: https://stackoverflow.com/questions/50278258/http-post-with-json-on-body-flutter-dart/50295533

#Note!Testing with different OS on simulators to server on local machine: 
Android: http://10.0.0.2:<PORT>/<URL>
iOS: http://localhost:<PORT>/<URL>
	
With the backend up it is time to tackle post applications, I have the classes to parse the inventory from the get so post shouldn’t be so hard.  

Nope I have a success and transfer pop-up showing but it will not actually show on the screen.  I can’t figure out what is wrong.  

My educated guess is that it needs some sort of authentication to post?  This capability is not available yet.  So I will ask tonight about authentication.

Nope...I had the date incorrectly formatted and the wrong json information Brad had this the whole time, I feel bad for changing it.  Once I got this straight with Tony, Joe and Brad during the Authentication conversation, I was able to produce a successful transfer of information.  I also saw the updated pantry listing on the simulator for both iOS and emulator for Android...YAY!

@ Files produced as a result:  scan_screen.dart, upc_base_response.dart, upc_base_response.g.dart
@ Files edited as a result:  application/android build.gradle, and pubspec.yaml, main.dart

### basic authentication available on back end
Experimented with actual authentication, Tony input basic auth into a workable back end for us to use.  This enabled us to alter the login_screen to us an actual authentication instead of using constants for authentication from another class.

Brad found that the authentication is using Base64, and auth logic I attempted to use the link he found to authenticate: https://stackoverflow.com/questions/50244416/how-to-pass-basic-auth-credentials-in-api-call-for-a-flutter-mobile-application.  I had no success, and working with Brad on the issue also nothing for quite a few hours.

During the conversation, I found that all authentication for basic authentication is held in the headers of a http get request encoded as indicated above.  This one fact I did not know as I was attempting to post username/password to the server...lesson learned.

### Restructure the prototype

Under the assets folder the following two files have been placed as holders for information.  These files should, in theory be local to the device once the application is loaded onto a device. The camera.dart file is not needed so it was erased from the project.  
IN THEORY:
Assets(Flutter File Structure)
local_inventory.json - theory is this file will be written to when connection is unavailable
server_inventory.json - theory is this file will be written as soon as the database is online and available.
difference_inventory.json - theory is this file will be written with a merge of files then local and server inventory and server inventory can be updated

New file structure as follows under the library: 

main.dart
data (File)
connect_repository.dart - holds all functions for outside application connections
local_repository.dart - holds all functions to read and write files to local OS
models (File)
inventory.dart/inventory.g.dart - holds the json parsing class for the inventory as acquired from the Application API and local files when raw json data is downloaded to the local file
upc_base_response.dart/upc_base_response.g.dart - holds the json parsing class for the barcode as acquired from the UPC API
users.dart/users.g.dart - holds the user information for possible future use with OAuth.
screens(File)
Home_screen - now incorporates widgets from old pantry_list.dart
login_screen
scan_screen
search_screen - placeholder for search logic widgets
Utils(File)
fade_route.dart 

This restructure caused a need for three global variables to be used throughout the application.  I placed those variables within the home_screen.dart.
Removed these variables from the home screen and placed them into the connect_repository file, there was no need for global variables at this time

### search_screen.dart: 
Flutter packages added: none

Files produced as a result:  search_screen.dart, 
Files edited as a result:  none

### view_item.dart
Flutter packages added: none

Files produced as a result:  view_item.dart,
Files edited as a result:  home_screen.dart

### Update item functionality was built into the scan screen logic.  This created a need for global variables
Flutter packages added: none

Files produced as a result:  globals.dart
Files edited as a result:  scan_screen.dart
