import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'dart:convert';
import 'package:ch_app/src/models/challenge.dart';
import 'package:ch_app/src/models/user.dart';

// const BASE_URL = "http://192.168.99.100/api/";
const BASE_URL = "https://evangelion.stmary-rehab.com/api/";

class SecureStorageService {
  static final _storage = new FlutterSecureStorage();

  static accessCodeExists() async {
    final code = await getAccessCode();
    return code != null;
  }

  static getAccessCode() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('first_run') ?? true) {
      await SecureStorageService.clear();
      prefs.setBool('first_run', false);
    }
    return await _storage.read(key: "evangelionAccessCode");
  }

  static setAccessCode(String accessCode) async {
    await _storage.write(key: "evangelionAccessCode", value: accessCode);
  }

  static clear() async {
    await _storage.deleteAll();
  }
}

class NetworkService {
  static dynamic getResource(String path) async {
    final accessCode = await SecureStorageService.getAccessCode();

    final response = await http.get(BASE_URL + path + "/",
        headers: {HttpHeaders.authorizationHeader: "Bearer " + accessCode});

    if (response.statusCode != 200)
      throw Exception(
          "Network GET request returned a non 200 status code: ${response.statusCode}");
    String body = utf8.decode(response.bodyBytes);
    return json.decode(body);
  }

  static dynamic postResource(String path, Map<String, dynamic> data) async {
    final accessCode = await SecureStorageService.getAccessCode();

    final response = await http.post(BASE_URL + path + "/",
        headers: {
          HttpHeaders.authorizationHeader: "Bearer " + accessCode,
          HttpHeaders.contentTypeHeader: "application/json"
        },
        body: json.encode(data));

    if (response.statusCode != 201)
      throw Exception(
          "Network POST request returned a non 201 status code: ${response.statusCode}");
    String body = utf8.decode(response.bodyBytes);
    return json.decode(body);
  }
}

class UserNetworkService {
  static Future<bool> isValidCode(String accessCode) async {
    final response = await http.get(BASE_URL + 'users',
        headers: {HttpHeaders.authorizationHeader: "Bearer " + accessCode});
    return response.statusCode == 200;
  }

  static Future<User> fetchUser() async {
    final data = await NetworkService.getResource("users");
    return User.fromJson(data[0]);
  }
}

class ChallengeNetworkService {
  static Future<List<Challenge>> fetchChallenges() async {
    final data = await NetworkService.getResource("challenges");
    final List<Challenge> challengeList = (data['results'] as List)
        .map((challenge) => Challenge.fromJson(challenge))
        .toList();
    return challengeList;
  }
}

class ResponseNetworkService {
  static Future<Response> submitResponse(int challengeId, int answerId) async {
    final data = await NetworkService.postResource("responses",
        new Response(challengeId: challengeId, answerId: answerId).toJson());
    final Response response = Response.fromJson(data, challengeId);
    return response;
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final int default_hour = 18;
  static final int default_minute = 0;

  static Future<void> initializeReminders() async {
    // Future onSelectNotification(String payload) async {
    //   if (payload != null) {
    //     debugPrint('notification payload: ' + payload);
    //   }
    //   await Navigator.push(
    //     context,
    //     new MaterialPageRoute(builder: (context) => new SecondScreen(payload)),
    //   );
    // }

    // Future onDidReceiveLocalNotification(
    //     int id, String title, String body, String payload) {}

    WidgetsFlutterBinding.ensureInitialized();

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS =
        new IOSInitializationSettings(); //onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(
        initializationSettings); //,onSelectNotification: onSelectNotification);

    await schedulePeriodicNotification();
  }

  static Future<void> setReminderTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setInt('notification_hour', hour);
    prefs.setInt('notification_minute', minute);
  }

  static Future<Time> getReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('notification_hour') ||
        !prefs.containsKey('notification_minute')) {
      await setReminderTime(default_hour, default_minute);
    }

    return Time(prefs.getInt('notification_hour'),
        prefs.getInt('notification_minute'), 0);
  }

  static Future<void> updatePeriodicNotification() async {
    DateTime now = new DateTime.now();
    DateTime fewMinsAgo = now.subtract(new Duration(minutes: 10));
    await setReminderTime(fewMinsAgo.hour, fewMinsAgo.minute);

    // set new schedule
    await schedulePeriodicNotification();
  }

  static Future<void> schedulePeriodicNotification() async {
    final reminderTime = await getReminderTime();

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'repeating channel id',
        'repeating channel name',
        'repeating description');
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    // cancel old schedule
    await flutterLocalNotificationsPlugin.cancelAll();
    // setup new schedule
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        0,
        'Remember to read the bible today!',
        'it will only take a few minutes',
        reminderTime,
        platformChannelSpecifics);
  }
}
