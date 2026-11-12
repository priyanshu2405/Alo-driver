import 'package:alo_ride_driver_app/screen/login/view/login_screen.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';


// Auth Controller using GetX
class AuthController extends GetxController {
  final _box = GetStorage();

  // Observable variables
  var isLoggedIn = false.obs;
  var token = ''.obs;
  var userId = ''.obs;
  var isLoading = false.obs;

  // Keys for storage
  static const String _tokenKey = 'access_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';

  @override
  void onInit() {
    super.onInit();
    _loadStoredData();
  }

  // Load stored data on app start
  void _loadStoredData() {
    token.value = _box.read(_tokenKey) ?? '';
    userId.value = _box.read(_userIdKey) ?? '';
    isLoggedIn.value = token.value.isNotEmpty;
  }

  // Store token and user data
  Future<void> storeUserData({
    required String accessToken,
    required String id,
  }) async {
    await _box.write(_tokenKey, accessToken);
    await _box.write(_userIdKey, id);

    // Update observable variables
    token.value = accessToken;
    userId.value = id;
    isLoggedIn.value = true;
  }

  // Clear all data (logout)
  Future<void> logout() async {
    await _box.remove(_tokenKey);
    await _box.remove(_userIdKey);
    await _box.remove(_userEmailKey);

    // Reset observable variables
    token.value = '';
    userId.value = '';
    isLoggedIn.value = false;

    // Navigate to login
    Get.offAll(() => LoginScreen());
  }

  // Get token for API calls
  String? getToken() {
    return token.value.isEmpty ? null : token.value;
  }

  String? getUserId() {
    return userId.value.isEmpty ? null : userId.value;
  }
  bool get isAuthenticated => isLoggedIn.value;

}