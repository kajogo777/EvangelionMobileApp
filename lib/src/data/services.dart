import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import '../models/challenge.dart';
import '../models/user.dart';

// const BASE_URL = "http://192.168.43.24:8000/api/";
// const BASE_URL = "http://192.168.1.145:8000/api/";
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
