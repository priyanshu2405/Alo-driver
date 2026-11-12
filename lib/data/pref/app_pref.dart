import 'dart:convert';

import 'package:alo_ride_driver_app/models/model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPref {

  /*
  static final AppPref instance = AppPref.internal();

  AppPref(this._preference,this._in);*/
  //final SharedPreferences _preference;
  Future<bool> clear() {
    var showIntro = this.showIntro;
    var locale = this.locale;
    return _preference.clear().whenComplete(() {
      this.showIntro = showIntro;
      this.locale = locale;
    });
  }

  static late final AppPref _instance;
  final SharedPreferences _preference;

  // Private constructor
  AppPref._(this._preference);

  // Getter for singleton instance
  static AppPref get instance => _instance;

  // Initialize once during app start (e.g., in main())
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _instance = AppPref._(prefs);
  }

  bool get isLogin => _preference.getBool("isLogin") ?? false;

  set isLogin(bool value) => _preference.setBool("isLogin", value);

  String get userToken => _preference.getString("user_token") ?? "";

  set userToken(String value) => _preference.setString("user_token", value);

  Locale? get locale =>
      _preference.getString("locale") != null
          ? Locale(_preference.getString("locale") ?? "en")
          : null;

  set locale(Locale? value) =>
      value == null
          ? _preference.remove("locale")
          : _preference.setString("locale", value.languageCode);

  bool get showIntro => _preference.getBool("show_intro") ?? true;

  set showIntro(bool value) => _preference.setBool("show_intro", value);

  String get fcmToken => _preference.getString("firebaseToken") ?? "";

  set fcmToken(String value) => _preference.setString("firebaseToken", value);

  UserModel? get userProfile =>
      _getData<UserModel>("user_profile", UserModel.fromJson);

  set userProfile(UserModel? userProfile) =>
      _setData("user_profile", userProfile?.toJson());

  /*

  PostAdStoreDataModel? get postAdStoreData =>
      _getData<PostAdStoreDataModel>("post_add", PostAdStoreDataModel.fromJson);

  set postAdStoreData(PostAdStoreDataModel? postAdStoreData) =>
      _setData("post_add", postAdStoreData?.toJson());*/

  int get userId => _preference.getInt("user_id") ?? 0;

  set userId(int value) => _preference.setInt("user_id", value);

  String get themeVariant => _preference.getString("theme_variant") ?? "winter";

  set themeVariant(String value) =>
      _preference.setString("theme_variant", value);

  _setData(String key, Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      _preference.remove(key);
    }
    _preference.setString(key, jsonEncode(json));
  }

  T? _getData<T extends Object>(
    String key,
    T Function(Map<String, dynamic> json) parser,
  ) {
    if (_preference.containsKey(key)) {
      var value = _preference.get(key);
      // If the value is null or empty, return null safely.
      if (value != null && value is String && value.isNotEmpty) {
        return parser(jsonDecode(value));
      }
    }
    // Return null if the data is not found or if parsing failed.
    return null;
  }
}
