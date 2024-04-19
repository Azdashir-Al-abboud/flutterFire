import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firstflutterfireproject/Filtering&stream&batch&transaction/file&image&video.dart';
import 'package:firstflutterfireproject/Filtering&stream&batch&transaction/streamBuilder.dart';
import 'package:firstflutterfireproject/Messaging/test.dart';
import 'package:firstflutterfireproject/auth/signup.dart';
import 'package:firstflutterfireproject/categories/add.dart';
import 'package:firstflutterfireproject/homepage.dart';
import 'package:firstflutterfireproject/Filtering&stream&batch&transaction/testFiltering.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firstflutterfireproject/auth/login.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // print("Handling a background message: ${message.messageId}");
  print("Background or terminated message ==========");
  print(message.notification!.title);
  print(message.notification!.body);
  print('Message data: ${message.data}');
  print("Background or terminated message ==========");
}

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //  يخبر WidgetsFlutterBinding.ensureInitialized() Flutter بعدم بدء تشغيل كود عنصر واجهة المستخدم حتى يتم تشغيل إطار عمل Flutter بالكامل. يستخدم Firebase قنوات النظام الأساسي الأصلية، والتي تتطلب تشغيل إطار العمل.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // يقوم Firebase.initializeApp بإعداد اتصال بين تطبيق Flutter ومشروع Firebase الخاص بك. يتم استيراد DefaultFirebaseOptions.currentPlatform من ملف firebase_options.dart الذي تم إنشاؤه. تكتشف هذه القيمة الثابتة النظام الأساسي الذي تعمل عليه، وتمرر مفاتيح Firebase المقابلة.

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseAppCheck.instance.activate(
    // You can also use a `ReCaptchaEnterpriseProvider` provider instance as an
    // argument for `webProvider`
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Safety Net provider
    // 3. Play Integrity provider
    androidProvider: AndroidProvider.debug,
    // Default provider for iOS/macOS is the Device Check provider. You can use the "AppleProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Device Check provider
    // 3. App Attest provider
    // 4. App Attest provider with fallback to Device Check provider (App Attest provider is only available on iOS 14.0+, macOS 14.0+)
    appleProvider: AppleProvider.appAttest,
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('============================= User is currently signed out!');
      } else {
        print('============================= User is signed in!');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[400],
          titleTextStyle: TextStyle(
            color: Colors.orange,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.orange),
        ),
      ),

      debugShowCheckedModeBanner: false,

      // home: (FirebaseAuth.instance.currentUser != null &&
      //         FirebaseAuth.instance.currentUser!.emailVerified)
      //     ? HomePage()
      //     : Login(),

      // home: Filtering(),
      // home: Streamm(),
      // home: FileStorage(),
      home: Messaging(),

      routes: {
        "signup": (context) => SignUp(),
        "login": (context) => Login(),
        "homepage": (context) => HomePage(),
        "addCategory": (context) => AddCategory(),
        "Filtering": (context) => Filtering(),
      },
    );
  }
}
