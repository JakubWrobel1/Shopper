// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDACTGRecT1b3JUbYZNsDPlSNGgfwbrZt8',
    appId: '1:832084020926:web:5f00a516f25116effe58ef',
    messagingSenderId: '832084020926',
    projectId: 'shopper-fcf73',
    authDomain: 'shopper-fcf73.firebaseapp.com',
    storageBucket: 'shopper-fcf73.appspot.com',
    measurementId: 'G-8HQ6PHE1FQ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCz6xUMjz31Nx2_7md1DKWZPuY-pi0R9HU',
    appId: '1:832084020926:android:0903d753593c7e90fe58ef',
    messagingSenderId: '832084020926',
    projectId: 'shopper-fcf73',
    storageBucket: 'shopper-fcf73.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCuyGsj0UeUl7gt4Ags85M9s0KhVWQ6Lw8',
    appId: '1:832084020926:ios:b5c81178c9980f93fe58ef',
    messagingSenderId: '832084020926',
    projectId: 'shopper-fcf73',
    storageBucket: 'shopper-fcf73.appspot.com',
    iosClientId: '832084020926-ohj57hmp6pkudrqvdt77jacfld7g6ckm.apps.googleusercontent.com',
    iosBundleId: 'com.example.shopper',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCuyGsj0UeUl7gt4Ags85M9s0KhVWQ6Lw8',
    appId: '1:832084020926:ios:b5c81178c9980f93fe58ef',
    messagingSenderId: '832084020926',
    projectId: 'shopper-fcf73',
    storageBucket: 'shopper-fcf73.appspot.com',
    iosClientId: '832084020926-ohj57hmp6pkudrqvdt77jacfld7g6ckm.apps.googleusercontent.com',
    iosBundleId: 'com.example.shopper',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDACTGRecT1b3JUbYZNsDPlSNGgfwbrZt8',
    appId: '1:832084020926:web:8fa0b09c77fb9b7bfe58ef',
    messagingSenderId: '832084020926',
    projectId: 'shopper-fcf73',
    authDomain: 'shopper-fcf73.firebaseapp.com',
    storageBucket: 'shopper-fcf73.appspot.com',
    measurementId: 'G-5X1N4B76LF',
  );

}