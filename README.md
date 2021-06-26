## About PDFTron Flutter
PDFTron's Flutter PDF library brings smooth, flexible, and stand-alone document viewing and editing solutions using Flutter codebases for iOS and Android applications.

- Direct MS Office document viewing and conversion
- Fully customizable open source UI to improve app engagement
- Document reflow to increase readability and accessibility on mobile
- File streaming to view remote and complex documents faster
- Night mode to improve viewing in low-light environments
- And much more...

More information can be found at https://www.pdftron.com/documentation/guides/flutter

**Android**|**iOS**
:--:|:--:
<img src="https://pdftron.s3.amazonaws.com/custom/websitefiles/flutter/flutter-pdftron-demo-android.gif" alt="A gif showcasing the UI and some features on Android"/>|<img src="https://pdftron.s3.amazonaws.com/custom/websitefiles/flutter/flutter-pdftron-demo-ios.gif" alt="A gif showcasing the UI and some features on iOS"/>

## Contents

- [API](#api)
- [Prerequisites](#prerequisites)
- [Legacy UI](#legacy-ui)
- [Installation](#installation)
- [Widget or Plugin](#widget-or-plugin)
- [Usage](#usage)
- [Changelog](#changelog)
- [Contributing](#contributing)
- [License](#license)

## API
API documentation is available on:
- [GitHub](https://github.com/PDFTron/pdftron-flutter/blob/publish-prep-nullsafe/doc/api/API.md)
- [pub.dev](https://pub.dev/documentation/pdftron_flutter/latest/pdftron/pdftron-library.html)

## Prerequisites
- No license key is required for trial. However, a valid commercial license key is required after trial.
- PDFTron SDK >= 6.9.0
- Flutter >= 1.12.0

## Legacy UI

Version `0.0.6` is the last stable release for the legacy UI.

The release can be found here: https://github.com/PDFTron/pdftron-flutter/releases/tag/legacy-ui.

## Installation

1. First follow the Flutter getting started guides to [install](https://flutter.io/docs/get-started/install), [set up an editor](https://flutter.io/docs/get-started/editor), and [create a Flutter Project](https://flutter.io/docs/get-started/test-drive?tab=terminal#create-app). The rest of this guide assumes your project is created by running `flutter create myapp`.

2. Add the following dependency to your Flutter project in `myapp/pubspec.yaml` file:
  - If you want to use specific releases from pub.dev: 
    ```diff
    dependencies:
        flutter:
          sdk: flutter
    +   pdftron_flutter: ^1.0.0-beta.1 
    # To use a specific version from pub.dev, replace ^1.0.0-beta.1
    ```
  - If you want to use the latest features from GitHub:
    ```diff
    dependencies:
        flutter:
          sdk: flutter
    +   pdftron_flutter:
    +     git:
    +       url: git://github.com/PDFTron/pdftron-flutter.git
    ```

### Android

The following instructions are only applicable to Android development; click here for the [iOS counterpart](#ios).

3. Now add the following items in your `myapp/android/app/build.gradle` file:
	```diff
	android {
	    compileSdkVersion 29

	    lintOptions {
		disable 'InvalidPackage'
	    }

	    defaultConfig {
		applicationId "com.example.myapp"
	-       minSdkVersion 16
	+       minSdkVersion 21
		targetSdkVersion 29
	+       multiDexEnabled true
	+       manifestPlaceholders = [pdftronLicenseKey:PDFTRON_LICENSE_KEY]
		versionCode flutterVersionCode.toInteger()
		versionName flutterVersionName
		testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
	    }
		...
	}
	```

4. In your `myapp/android/gradle.properties` file, add the following line:
    ``` diff
    # Add the PDFTRON_LICENSE_KEY variable here. 
    # For trial purposes leave it blank.
    # For production add a valid commercial license key.
    PDFTRON_LICENSE_KEY=
    ```
    
5. In your `myapp/android/app/src/main/AndroidManifest.xml` file, add the following lines to the `<application>` tag:
	```diff
	...
	<application
		android:name="io.flutter.app.FlutterApplication"
		android:label="myapp"
		android:icon="@mipmap/ic_launcher"
	+	android:largeHeap="true"
	+	android:usesCleartextTraffic="true">
	
	    	<!-- Add license key in meta-data tag here. This should be inside the application tag. -->
	+	<meta-data
	+		android:name="pdftron_license_key"
	+		android:value="${pdftronLicenseKey}"/>
	...
	```
	
	Additionally, add the required permissions for your app in the `<manifest>` tag:
	```diff
		...
	+	<uses-permission android:name="android.permission.INTERNET" />
		<!-- Required to read and write documents from device storage -->
	+	<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
		<!-- Required if you want to record audio annotations -->
	+	<uses-permission android:name="android.permission.RECORD_AUDIO" />
		...
	```

    If you are using the `DocumentView` widget, change the parent class of your `MainActivity` file (either Kotlin or Java) to `FlutterFragmentActivity`:
    ```kotlin
    import androidx.annotation.NonNull
    import io.flutter.embedding.android.FlutterFragmentActivity
    import io.flutter.embedding.engine.FlutterEngine
    import io.flutter.plugins.GeneratedPluginRegistrant

    class MainActivity : FlutterFragmentActivity() {
        override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
            GeneratedPluginRegistrant.registerWith(flutterEngine);
        }
    }
    ```

6. Follow the instructions outlined [in the Usage section](#usage).
7. Check that your Android device is running by running the command `flutter devices`. If none are available, follow the device set up instructions in the [Install](https://flutter.io/docs/get-started/install) guides for your platform.
8. Run the app with the command `flutter run`.

### iOS

The following instructions are only applicable to iOS development; click here for the [Android counterpart](#android).

3. Run `flutter packages get`
4. Open `myapp/ios/Podfile` file and add:
	```diff
	 # Uncomment this line to define a global platform for your project
	-# platform :ios, '9.0'
	+platform :ios, '10.0'
	...
	 target 'Runner' do
	   ...
	+  # PDFTron Pods
	+  use_frameworks!
	+  pod 'PDFNet', podspec: 'https://www.pdftron.com/downloads/ios/cocoapods/xcframeworks/pdfnet/latest.podspec'
	 end
	```
5. To ensure integration process is successful, run `flutter build ios --no-codesign` 
6. Follow the instructions outlined [in the Usage section](#usage).
7. Run `flutter emulators --launch apple_ios_simulator`
8. Run `flutter run`

## Widget or Plugin

There are 2 different ways to use PDFTron Flutter API:  
* Present a document via a plugin. 
* Show a PDFTron document view via a Widget.

You must choose either the widget or plugin, and use it for all APIs. Mixing widget and plugin APIs will not function correctly. 

For iOS, whether you choose widget or plugin is personal preference.

For Android, the plugin version is strongly recommended. The widget version (`DocumentView`) contains existing issues such as menu popups not opening, see issue: https://github.com/flutter/flutter/issues/58273


## Usage

1. If you want to use local files on Android, add the following dependency to `myapp/pubspec.yaml`:

  ```yaml
    permission_handler: ^8.1.1
  ```

2. Open `lib/main.dart`, replace the entire file with the following:

  ```dart
    import 'dart:async';
    import 'dart:io' show Platform;

    import 'package:flutter/material.dart';
    import 'package:flutter/services.dart';
    import 'package:pdftron_flutter/pdftron_flutter.dart';
    // Uncomment this if you are using local files
    // import 'package:permission_handler/permission_handler.dart';

    void main() => runApp(MyApp());

    class MyApp extends StatelessWidget {
      @override
      Widget build(BuildContext context) {
        return MaterialApp(
          home: Viewer(),
        );
      }
    }

    class Viewer extends StatefulWidget {
      @override
      _ViewerState createState() => _ViewerState();
    }

    class _ViewerState extends State<Viewer> {
      String _version = 'Unknown';
      String _document =
          "https://pdftron.s3.amazonaws.com/downloads/pl/PDFTRON_mobile_about.pdf";
      bool _showViewer = true;

      @override
      void initState() {
        super.initState();
        initPlatformState();

        showViewer();

        // If you are using local files delete the line above, change the _document field
        // appropriately and uncomment the section below.
        // if (Platform.isIOS) {
          // // Open the document for iOS, no need for permission.
          // showViewer();
        // } else {
          // // Request permission for Android before opening document.
          // launchWithPermission();
        // }
      }

      // Future<void> launchWithPermission() async {
      //  PermissionStatus permission = await Permission.storage.request();
      //  if (permission.isGranted) {
      //    showViewer();
      //  }
      // }

      // Platform messages are asynchronous, so initialize in an async method.
      Future<void> initPlatformState() async {
        String version;
        // Platform messages may fail, so use a try/catch PlatformException.
        try {
          // Initializes the PDFTron SDK, it must be called before you can use any functionality.
          PdftronFlutter.initialize("your_pdftron_license_key");

          version = await PdftronFlutter.version;
        } on PlatformException {
          version = 'Failed to get platform version.';
        }

        // If the widget was removed from the tree while the asynchronous platform
        // message was in flight, you want to discard the reply rather than calling
        // setState to update our non-existent appearance.
        if (!mounted) return;

        setState(() {
          _version = version;
        });
      }

      void showViewer() async {
        // opening without a config file will have all functionality enabled.
        // await PdftronFlutter.openDocument(_document);

        var config = Config();
        // How to disable functionality:
        //      config.disabledElements = [Buttons.shareButton, Buttons.searchButton];
        //      config.disabledTools = [Tools.annotationCreateLine, Tools.annotationCreateRectangle];
        //      config.multiTabEnabled = true;
        //      config.customHeaders = {'headerName': 'headerValue'};

        // An event listener for document loading
        var documentLoadedCancel = startDocumentLoadedListener((filePath) {
          print("document loaded: $filePath");
        });

        await PdftronFlutter.openDocument(_document, config: config);

        try {
          // The imported command is in XFDF format and tells whether to add, modify or delete annotations in the current document.
          PdftronFlutter.importAnnotationCommand(
              "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
                  "    <xfdf xmlns=\"http://ns.adobe.com/xfdf/\" xml:space=\"preserve\">\n" +
                  "      <add>\n" +
                  "        <square style=\"solid\" width=\"5\" color=\"#E44234\" opacity=\"1\" creationdate=\"D:20200619203211Z\" flags=\"print\" date=\"D:20200619203211Z\" name=\"c684da06-12d2-4ccd-9361-0a1bf2e089e3\" page=\"1\" rect=\"113.312,277.056,235.43,350.173\" title=\"\" />\n" +
                  "      </add>\n" +
                  "      <modify />\n" +
                  "      <delete />\n" +
                  "      <pdf-info import-version=\"3\" version=\"2\" xmlns=\"http://www.pdftron.com/pdfinfo\" />\n" +
                  "    </xfdf>");
        } on PlatformException catch (e) {
          print("Failed to importAnnotationCommand '${e.message}'.");
        }

        try {
          // Adds a bookmark into the document.
          PdftronFlutter.importBookmarkJson('{"0":"Page 1"}');
        } on PlatformException catch (e) {
          print("Failed to importBookmarkJson '${e.message}'.");
        }

        // An event listener for when local annotation changes are committed to the document.
        // xfdfCommand is the XFDF Command of the annotation that was last changed.
        var annotCancel = startExportAnnotationCommandListener((xfdfCommand) {
          String command = xfdfCommand;
          print("flutter xfdfCommand:\n");
          // Dart limits how many characters are printed onto the console. 
          // The code below ensures that all of the XFDF command is printed.
          if (command.length > 1024) {
            int start = 0;
            int end = 1023;
            while (end < command.length) {
              print(command.substring(start, end) + "\n");
              start += 1024;
              end += 1024;
            }
            print(command.substring(start));
          } else {
            print("flutter xfdfCommand:\n $command");
          }
        });

        // An event listener for when local bookmark changes are committed to the document.
        // bookmarkJson is JSON string containing all the bookmarks that exist when the change was made.
        var bookmarkCancel = startExportBookmarkListener((bookmarkJson) {
          print("flutter bookmark: $bookmarkJson");
        });

        var path = await PdftronFlutter.saveDocument();
        print("flutter save: $path");

        // To cancel event:
        // annotCancel();
        // bookmarkCancel();
        // documentLoadedCancel();
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            child:
                // Uncomment this to use Widget version of the viewer.
                // _showViewer
                // ? DocumentView(
                //     onCreated: _onDocumentViewCreated,
                //   ):
                Container(),
          ),
        );
      }

      // This function is used to control the DocumentView widget after it has been created.
      // The widget will not work without a void Function(DocumentViewController controller) being passed to it.
      void _onDocumentViewCreated(DocumentViewController controller) async {
        Config config = new Config();

        var leadingNavCancel = startLeadingNavButtonPressedListener(() {
          // Uncomment this to quit the viewer when leading navigation button is pressed.
          // this.setState(() {
          //   _showViewer = !_showViewer;
          // });

          // Show a dialog when leading navigation button is pressed.
          _showMyDialog();
        });

        controller.openDocument(_document, config: config);
      }

      Future<void> _showMyDialog() async {
        print('hello');
        return showDialog<void>(
          context: context,
          barrierDismissible: false, // User must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('AlertDialog'),
              content: SingleChildScrollView(
                child: Text('Leading navigation button has been pressed.'),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  ```

## Changelog
See [Changelog](https://github.com/PDFTron/pdftron-flutter/blob/publish-prep-nullsafe/CHANGELOG.md)

## Contributing
See [Contributing](https://github.com/PDFTron/pdftron-flutter/blob/publish-prep-nullsafe/CONTRIBUTING.md)

## License
See [License](https://github.com/PDFTron/pdftron-flutter/blob/publish-prep-nullsafe/LICENSE)
![](https://onepixel.pdftron.com/pdftron-flutter)
