import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/responsive.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final email = TextEditingController();
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: ResponsiveScaffoldBody(
        child: Padding(
          padding: EdgeInsets.all(Responsive.pagePadding(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reset your password',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your account email and we will send a Firebase reset link.',
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: email,
                hint: 'Email address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              Obx(
                () => PrimaryButton(
                  label: 'Send reset link',
                  loading: auth.isLoading.value,
                  onPressed: () => auth.forgotPassword(email.text),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
