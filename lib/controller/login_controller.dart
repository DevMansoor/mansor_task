import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../view/map_screen.dart';

/// LoginController class manages the login process, handles validation,
/// and updates the UI state accordingly.

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passController = TextEditingController();

  /// 'isLoading' used to track whether a login process is in progress,
  RxBool isLoading = false.obs;

  /// 'error' is used to store any error messages related to the login process.
  RxString error = ''.obs;

  /// dispose of the emailController and passController when the controller is closed.
  @override
  void onClose() {
    emailController.dispose();
    passController.dispose();
    super.onClose();
  }

  /// validates the email format
  String? validateEmail(String? email) {
    if (!GetUtils.isEmail(email!)) {
      return 'Invalid email format';
    }
    return null;
  }

  /// called when the user attempts to log in.
  void login() async {
    isLoading.value = true;
    error.value = '';

    /// checks if either the email or password field is empty.
    if (emailController.text.isEmpty || passController.text.isEmpty) {
      error.value = 'Please fill in all fields';
      if (!Get.isSnackbarOpen) {
        Get.snackbar('Error', error.value);
      }
      isLoading.value = false;
      return;
    }
    await Future.delayed(const Duration(seconds: 2));

    if (emailController.text == 'mansoor@watt.com' && passController.text == '123456') {
      Get.to(() => MapPage());
    } else {
      error.value = 'Invalid credentials';
      if (!Get.isSnackbarOpen) {
        Get.snackbar('Error', error.value);
      }
    }

    isLoading.value = false;
  }
}
