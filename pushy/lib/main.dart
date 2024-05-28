import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pushy/constants.dart';
import 'package:pushy/set_token.dart';
import 'firebase_options.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) {
    showNotificationAndroid(
        message.notification!.title!, message.notification!.body!);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.requestPermission();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );
  runApp(const MyApp());
}

void showNotificationAndroid(String title, String value) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'important', 
    'Important Channel', 
    channelDescription: 'Channel Description',
    importance: Importance.max, 
    priority: Priority.high, 
    ticker: 'Ticker',
  );

  int notificationId = 1;
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);

  await flutterLocalNotificationsPlugin.show(
    notificationId,
    title,
    value,
    notificationDetails,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? userId;
  String? deviceToken;
  late WebViewController _controller;
  late FirebaseMessaging _messaging;

  @override
  void initState() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(SERVER_ADDRESS))
      ..addJavaScriptChannel("myChannel",
          onMessageReceived: (JavaScriptMessage message) {
        setMessage(message.message);
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            _injectJavascript(_controller);
          },
        ),
      );
    super.initState();

    _messaging = FirebaseMessaging.instance;

    _messaging.getToken().then((token) {
      setState(() {
        deviceToken = token;
      });

      if (token != null && userId != null) {
        setToken(token,  int.parse(userId!));
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {


      if (message.notification != null) {
        showNotificationAndroid(
            message.notification!.title!, message.notification!.body!);
      }
    });
  }

  setMessage(String javascriptMessage) {
    if (mounted) {
      setState(() {
        userId = javascriptMessage;
      });

      _updateToken();
    }
  }

  _injectJavascript(WebViewController controller) async {
    controller.runJavaScript('''
  if(userId){
    myChannel.postMessage(userId);
  }
''');
  }

  @override
  void didUpdateWidget(MyHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateToken();
  }

  void _updateToken() async {
    if (userId != null && deviceToken != null) {
      await setToken(deviceToken!, int.parse(userId!));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _controller != null
          ? WebViewWidget(controller: _controller)
          : Center(child: CircularProgressIndicator()),
    );
  }
}
