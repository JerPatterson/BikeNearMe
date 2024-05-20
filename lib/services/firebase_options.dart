import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyCXeVCjs541wZW-UfWIGBOyAkHUgGf4o0o',
    appId: '1:911301890092:web:e890d12d417ab7ce898189',
    messagingSenderId: '911301890092',
    projectId: 'bikenearme-a33ac',
    authDomain: 'bikenearme-a33ac.firebaseapp.com',
    databaseURL: 'https://bikenearme-a33ac-default-rtdb.firebaseio.com',
    storageBucket: 'bikenearme-a33ac.appspot.com',
    measurementId: 'G-GY1TLBC777',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCQUiPNlt4S6noSWswbIlBpblET7wvDEnU',
    appId: '1:911301890092:android:08536bb1a0431a3c898189',
    messagingSenderId: '911301890092',
    projectId: 'bikenearme-a33ac',
    databaseURL: 'https://bikenearme-a33ac-default-rtdb.firebaseio.com',
    storageBucket: 'bikenearme-a33ac.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAoUgp7uPsLWVAEI373v33n2PxwSuzLwh0',
    appId: '1:911301890092:ios:27febcf60e9eb75f898189',
    messagingSenderId: '911301890092',
    projectId: 'bikenearme-a33ac',
    databaseURL: 'https://bikenearme-a33ac-default-rtdb.firebaseio.com',
    storageBucket: 'bikenearme-a33ac.appspot.com',
    iosBundleId: 'com.example.bikeNearMe',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAoUgp7uPsLWVAEI373v33n2PxwSuzLwh0',
    appId: '1:911301890092:ios:27febcf60e9eb75f898189',
    messagingSenderId: '911301890092',
    projectId: 'bikenearme-a33ac',
    databaseURL: 'https://bikenearme-a33ac-default-rtdb.firebaseio.com',
    storageBucket: 'bikenearme-a33ac.appspot.com',
    iosBundleId: 'com.example.bikeNearMe',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCXeVCjs541wZW-UfWIGBOyAkHUgGf4o0o',
    appId: '1:911301890092:web:2ab18bd02530fdfa898189',
    messagingSenderId: '911301890092',
    projectId: 'bikenearme-a33ac',
    authDomain: 'bikenearme-a33ac.firebaseapp.com',
    databaseURL: 'https://bikenearme-a33ac-default-rtdb.firebaseio.com',
    storageBucket: 'bikenearme-a33ac.appspot.com',
    measurementId: 'G-WQK4B4HFBG',
  );
}
