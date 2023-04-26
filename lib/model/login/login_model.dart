import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../app/app_config.dart';
import '../../model/login/login_storage_model.dart';
import '../../utils/fetch_utils.dart';

class SnackBarModel {
  final String title;
  final String message;
  final Color backgroundColor;
  final Duration duration;
  final SnackPosition snackPosition;

  SnackBarModel({
    required this.title,
    required this.message,
    required this.backgroundColor,
    this.duration = const Duration(seconds: 1),
    this.snackPosition = SnackPosition.TOP,
  });
}

class LoginModel {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final AuthService _authService = AuthService();

  final List<dynamic> _apiKeys = <dynamic>[];
  final List<int> _chatrooms = <int>[];
  String _jwtToken = '';
  String _selectedApiKey = '';
  final int _selectedChatroom = 0;
  bool isRemembered = false;
  String _username = "";

  GlobalKey<FormBuilderState> get formKey => _formKey;
  List<dynamic> get apiKeys => _apiKeys;
  List<int> get chatRooms => _chatrooms;
  String get jwtToken => _jwtToken;
  String get selectedApiKey => _selectedApiKey;
  int get selectedChatroom => _selectedChatroom;
  String get username => _username;

  Future<SnackBarModel?> init() async {
    return await loadJwtTokenFromLocalStorage();
  }

  void close() {
    _formKey.currentState?.reset();
  }

  void onClickApiKey({required String accessKey, required String userMemo}) {
    // Save the selected API key for later use and show a Snackbar for visual confirmation
    _selectedApiKey = accessKey;
  }

  Future<String?> onGetToken(String token) async {
    _jwtToken = token;
    if (isRemembered) {
      await _authService.saveToken(token);
    }
    final List<String?> result = await Future.wait([
      FetchUtils.fetch(
        authorization: token,
        url: Config.fetchApiKeysUrl,
        successCode: 200,
        messageOnFail: "API 키를 불러오는데 실패하였습니다.",
        onSuccess: (dynamic body) async {
          _apiKeys.assignAll(body);
        },
      ),
      FetchUtils.fetch(
          authorization: token,
          url: Config.fetchUserInfoUrl,
          successCode: 200,
          messageOnFail: "사용자 정보를 불러오는데 실패하였습니다.",
          onSuccess: (dynamic body) async {
            _username = body['email'];
          }),
      // FetchUtils.fetch(
      //     authorization: token,
      //     url: Config.fetchUserChatrooms,
      //     successCode: 200,
      //     messageOnFail: "채팅방 정보를 불러오는데 실패하였습니다.",
      //     onSuccess: (dynamic body) async {
      //       _chatrooms.assignAll(body);
      //     }),
    ]);
    // If all the results are null, return null. Otherwise, return the joined string.
    // This is because the result of Future.wait is a List of Future<T> and we want to
    // return a Error Message String (or null for success)
    // join result without null if there is any null, instead of result.join("\n")
    final Iterable<String?> errorMessages =
        result.where((String? element) => element != null);
    if (errorMessages.isEmpty) {
      return null;
    } else {
      return errorMessages.join("\n");
    }
  }

  Future<SnackBarModel> register(String email, String password) async {
    final response = await http.post(
      Uri.parse(Config.registerUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );
    final String? fetchResult = await FetchUtils.getFetchResult<String?>(
      body: response.body,
      statusCode: response.statusCode,
      successCode: 201,
      messageOnSuccess: null,
      messageOnFail: "회원가입에 실패하였습니다.",
      messageOnTokenExpired: "토큰이 만료되었습니다. 다시 로그인해주세요.",
      onSuccess: (dynamic body) async {
        final String? errorMessages = await onGetToken(
          jsonDecode(response.body)['Authorization'],
        );
        if (errorMessages != null) {
          throw errorMessages;
        }
      },
    );
    return SnackBarModel(
      title: fetchResult == null ? "Success" : "Error",
      message: fetchResult ?? "회원가입에 성공하였습니다.",
      backgroundColor: fetchResult == null ? Colors.green : Colors.red,
    );
  }

  Future<SnackBarModel> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(Config.loginUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );
    final String? fetchResult = await FetchUtils.getFetchResult<String?>(
      body: response.body,
      statusCode: response.statusCode,
      successCode: 200,
      messageOnSuccess: null,
      messageOnFail: "로그인에 실패하였습니다.",
      messageOnTokenExpired: "토큰이 만료되었습니다. 다시 로그인해주세요.",
      onSuccess: (dynamic body) async {
        final String? errorMessages = await onGetToken(
          jsonDecode(response.body)['Authorization'],
        );
        if (errorMessages != null) {
          throw errorMessages;
        }
      },
    );
    return SnackBarModel(
      title: fetchResult == null ? "Success" : "Error",
      message: fetchResult ?? "로그인에 성공하였습니다.",
      backgroundColor: fetchResult == null ? Colors.green : Colors.red,
    );
  }

  Future<void> logout() async {
    _selectedApiKey = "";
    _apiKeys.clear();
    await deleteToken();
  }

  Future<void> deleteToken() async {
    _jwtToken = "";
    await _authService.deleteToken();
  }

  Future<SnackBarModel?> loadJwtTokenFromLocalStorage() async {
    final storedToken = await _authService.getToken();
    if (storedToken != null) {
      _jwtToken = storedToken;
      final String? errorMessages = await onGetToken(storedToken);
      return SnackBarModel(
        title: errorMessages == null ? "Success" : "Error",
        message: errorMessages ?? "자동로그인에 성공하였습니다.",
        backgroundColor: errorMessages == null ? Colors.green : Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    return null;
  }
}