import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/responsive.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = Get.find<AuthController>();
  Worker? _rememberWorker;

  @override
  void initState() {
    super.initState();
    _applyRemembered();
    _rememberWorker = ever(auth.rememberedEmail, (_) => _applyRemembered());
  }

  void _applyRemembered() {
    emailController.text = auth.rememberedEmail.value;
    passwordController.text = auth.rememberedPassword.value;
  }

  @override
  void dispose() {
    _rememberWorker?.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsiveScaffoldBody(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.pagePadding(context),
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Image.asset(AppImages.splashLogo, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'Welcome to DoseMate',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Login to manage medicines, chat with doctors\nand never miss a dose.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Email Address',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  controller: emailController,
                  hint: 'Enter your email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Password',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => AppTextField(
                    controller: passwordController,
                    hint: 'Enter your password',
                    icon: Icons.lock_outline_rounded,
                    obscureText: auth.obscurePassword.value,
                    suffix: IconButton(
                      onPressed: () =>
                          auth.obscurePassword.toggle(),
                      icon: Icon(
                        auth.obscurePassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Obx(
                      () => Checkbox(
                        value: auth.rememberMe.value,
                        activeColor: AppColors.primary,
                        onChanged: (v) => auth.rememberMe.value = v ?? false,
                      ),
                    ),
                    const Text(
                      'Remember password',
                      style: TextStyle(color: AppColors.secondaryText),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Obx(
                  () => PrimaryButton(
                    label: 'Login',
                    loading: auth.isLoading.value,
                    onPressed: () => auth.login(
                      emailController.text.trim(),
                      passwordController.text,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('OR', style: TextStyle(color: Color(0xFF9AA6B8))),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: auth.googleLogin,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(AppImages.googleLogo, width: 22, height: 22),
                        const SizedBox(width: 10),
                        const Text(
                          'Continue with Google',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Wrap(
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: AppColors.secondaryText),
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.signup),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
