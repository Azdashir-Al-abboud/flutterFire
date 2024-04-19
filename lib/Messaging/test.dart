import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firstflutterfireproject/chat.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Messaging extends StatefulWidget {
  const Messaging({super.key});
  @override
  State<StatefulWidget> createState() => _messaging();
}

class _messaging extends State<Messaging> {
  getToken() async {
    String? myToken = await FirebaseMessaging.instance.getToken();
    print("My Token ====================");
    print(myToken);
  }

/*
 * This for web and Ios .... (see https://firebase.flutter.dev/docs/messaging/permissions)

  myrequestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }
*/

  getInit() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
// عند الضغط على الإشعار والتطبيق مغلق بشكل نهائي
    if (initialMessage != null && initialMessage.notification != null) {
      String? title = initialMessage.notification!.title;
      String? body = initialMessage.notification!.body;
      if (initialMessage.data['type'] == 'chat') {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => Chat(title: title!, body: body!)));
      }
    }
  }

  @override
  void initState() {
    getToken();
    getInit();
    // Foreground Notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print("Foreground Message ==========================");
        print(message.notification!.title);
        print(message.notification!.body);
        print(
            'Message data: ${message.data}'); //Message data: ${message.data["name"]}
        print("Foreground Message ==========================");

        AwesomeDialog(
          context: context,
          title: message.notification!.title,
          body: Text("${message.notification!.body}"),
          dialogType: DialogType.info,
        )..show();

        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   content: Text("${message.notification!.body}"),
        // ));
      }
    });

// عند الضغط على الإشعار والتطبيق في الخلفية
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("=================== onMessageOpenApp");
      print("=================== the app in background");

      if (message.data['type'] == 'chat' && message.notification != null) {
        String? title = message.notification!.title;
        String? body = message.notification!.body;
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Chat(title: title!, body: body!),
        ));
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Messaging"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MaterialButton(
              color: Colors.red,
              textColor: Colors.white,
              onPressed: () async {
                await FirebaseMessaging.instance.subscribeToTopic('weather');
              },
              child: Text("subscribe"),
            ),
            MaterialButton(
              color: Colors.red,
              textColor: Colors.white,
              onPressed: () async {
                await FirebaseMessaging.instance
                    .unsubscribeFromTopic('weather');
              },
              child: Text("unsubscribe"),
            ),
            MaterialButton(
              color: Colors.red,
              textColor: Colors.white,
              onPressed: () async {
                await sendMessageToTopic("hi", "ahmad", "weather");
              },
              child: Text("send message topic"),
            ),
          ],
        ),
      ),
    );
  }
}

sendMessage(title, message) async {
  var headersList = {
    'Accept': '*/*',
    'User-Agent': 'Thunder Client (https://www.thunderclient.com)',
    'Content-Type': 'application/json',
    'Authorization':
        'key=AAAAVj32-LI:APA91bGHl6tfVWayz77DFBxrEeRkdxcZn68HgC0IolHrhaj12Yk75jDvIG_Dc7HecSdC4F3yLcWVK50XcYBwycZijt7rqSanecgZIJA3zfXG9O27wFaYi8t3vkdTXkWwvuxJEMzGYnJO'
  };
  var url = Uri.parse('https://fcm.googleapis.com/fcm/send');

  var body = {
    "to":
        "c938OOzyRMy8JGhpWKMImc:APA91bHl_tV9BXCmyZaf070T4kbHyeBlme0AWrSp6MTQghlknyq6g4r6ReXB19xc7a3Hj3CL24bVMLuqQoRIFc2VEhqy_Byauk4jX0KsNnVPyN8enEAQIQmRWpIdd970jMvIOD3AAfW_",
    "notification": {"title": title, "body": message},
    "data": {"id": 1, "name": "azdashir"}
  };

  var req = http.Request('POST', url);
  req.headers.addAll(headersList);
  req.body = json.encode(body);

  var res = await req.send();
  final resBody = await res.stream.bytesToString();

  if (res.statusCode >= 200 && res.statusCode < 300) {
    print(resBody);
  } else {
    print(res.reasonPhrase);
  }
}

sendMessageToTopic(title, message, topic) async {
  var headersList = {
    'Accept': '*/*',
    'User-Agent': 'Thunder Client (https://www.thunderclient.com)',
    'Content-Type': 'application/json',
    'Authorization':
        'key=AAAAVj32-LI:APA91bGHl6tfVWayz77DFBxrEeRkdxcZn68HgC0IolHrhaj12Yk75jDvIG_Dc7HecSdC4F3yLcWVK50XcYBwycZijt7rqSanecgZIJA3zfXG9O27wFaYi8t3vkdTXkWwvuxJEMzGYnJO'
  };
  var url = Uri.parse('https://fcm.googleapis.com/fcm/send');

  var body = {
    "to": "/topics/$topic",
    "notification": {"title": title, "body": message},
    "data": {"id": 1, "name": "azdashir"}
  };

  var req = http.Request('POST', url);
  req.headers.addAll(headersList);
  req.body = json.encode(body);

  var res = await req.send();
  final resBody = await res.stream.bytesToString();

  if (res.statusCode >= 200 && res.statusCode < 300) {
    print(resBody);
  } else {
    print(res.reasonPhrase);
  }
}
