import 'dart:convert';

import 'package:pushy/constants.dart';
import 'package:http/http.dart' as http;

Future<http.Response> setToken(String token, int userId) {
  return http.post(
    Uri.parse("$SERVER_ADDRESS/api/notifications/set_token"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'token': token,
      'user_id': userId
    }),
  );
}