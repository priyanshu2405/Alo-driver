import 'dart:io';

import 'package:alo_ride_driver_app/firebase_api/firebase_api.dart';
import 'package:alo_ride_driver_app/firebase_options.dart';
import 'package:alo_ride_driver_app/screen/splash/view/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alo_ride_driver_app/res/utils/app_responsive.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'services/token_store.dart';


/*void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: true,
      systemStatusBarContrastEnforced: false,

    ),
  );
  // await AppPref.init();
  // final prefs = await SharedPreferences.getInstance();

  try {
    await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization error: $e');
    // Initialize without Firebase for now
    await Firebase.initializeApp();
  }


  // 🔥 REQUIRED: Initialize GetStorage
  await GetStorage.init();

  // 🔥 REQUIRED: Register AuthController once
  Get.put(AuthController(), permanent: true);
  // await ApiClient().init(
  //   baseUrl: 'https://deliverymate.volive.me/alodrive',
  //   pref: AppPref.instance,
  //   enableLogging: kDebugMode,
  // );
  // Get.put(AuthRepository());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // Your Figma screen
      minTextAdapt: true,
      splitScreenMode: true,

      builder: (context, child) {
        return GetMaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1)),
              child: child!,
            );
          },
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          home: const SplashScreen(),
          // home: const DashboardScreen(),
        );
      },
    );
  }
}*/



/// 🔥 REQUIRED background handler
/*Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('📦 Background message: ${message.messageId}');
}*/


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 🔥 Firebase INIT (ONLY ONCE)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// 🔥 Background message handler

  /// System UI
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);


  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  /// Storage
  await GetStorage.init();

  /// Notification service init.
  /// Registers the FCM tap callbacks (including `getInitialMessage`) before the
  /// first frame, so a tap that launched the app from a terminated state is
  /// captured and replayed once `SplashController` finishes routing.
  await NotificationService().initialize();

  /// Auth controller
  Get.put(AuthController(), permanent: true);

  /// 🔥 Notification service init

  HttpOverrides.global = MyHttpOverrides();

  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Alo Driver',
      builder: (context, child) {
        AppResponsive.init(context);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1),
          ),
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}

