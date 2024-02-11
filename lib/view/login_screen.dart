import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mansoor_task/widget/custom_textField.dart';

import '../controller/login_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final LoginController _controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Login"), centerTitle: true),
        body: Obx(() {
          return Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: _controller.validateEmail,
                          hintText: 'Enter Email',
                        ),
                        const SizedBox(height: 15),
                        CustomTextField(
                          controller: _controller.passController,
                          obscureText: true,
                          keyboardType: TextInputType.text,
                          hintText: 'Enter Password',
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(onPressed: _controller.login, child: const Text('Login'))
                      ],
                    ),
                  ),
                ),
              ),
              if (_controller.isLoading.value)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
