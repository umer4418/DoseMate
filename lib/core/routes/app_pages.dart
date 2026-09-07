import 'package:get/get.dart';

import '../../features/auth/views/doctor_signup_view.dart';
import '../../features/auth/views/forgot_password_view.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/patient_signup_view.dart';
import '../../features/auth/views/signup_role_view.dart';

import '../../features/chat/controllers/chat_list_controller.dart';
import '../../features/chat/controllers/chat_room_controller.dart';
import '../../features/chat/views/chat_room_view.dart';

import '../../features/doctor/controllers/doctor_controllers.dart';
import '../../features/doctor/views/doctor_shell_view.dart';

import '../../features/onboarding/controllers/onboarding_controller.dart';
import '../../features/onboarding/views/onboarding_view.dart';

import '../../features/patient/controllers/appointment_controller.dart';
import '../../features/patient/controllers/patient_home_controller.dart';
import '../../features/patient/controllers/reminder_controller.dart';
import '../../features/patient/views/book_appointment_view.dart';
import '../../features/patient/views/patient_shell_view.dart';

import '../../features/splash/controllers/splash_controller.dart';
import '../../features/splash/views/splash_view.dart';

import '../../models/user_model.dart';

import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: BindingsBuilder(() {
        Get.put(OnboardingController());
      }),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupRoleView(),
    ),
    GetPage(
      name: AppRoutes.patientSignup,
      page: () => const PatientSignupView(),
    ),
    GetPage(
      name: AppRoutes.doctorSignup,
      page: () => const DoctorSignupView(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
    ),

    // ============================================================
    // GOOGLE AUTH
    // ============================================================

    GetPage(
      name: AppRoutes.googleRole,
      page: () => const GoogleRoleView(),
    ),

    GetPage(
      name: AppRoutes.googlePatient,
      page: () => const GooglePatientView(),
    ),

    GetPage(
      name: AppRoutes.googleDoctor,
      page: () => const DoctorSignupView(
        googleFlow: true,
      ),
    ),

    // ============================================================
    // PATIENT
    // ============================================================

    GetPage(
      name: AppRoutes.patientShell,
      page: () => const PatientShellView(),
      binding: BindingsBuilder(() {
        Get.put(
          PatientHomeController(
            dataService: Get.find(),
          ),
        );

        Get.put(
          ReminderController(
            dataService: Get.find(),
          ),
        );

        Get.put(
          AppointmentController(
            dataService: Get.find(),
          ),
        );

        Get.put(
          ChatListController(
            dataService: Get.find(),
          ),
        );
      }),
    ),

    // ============================================================
    // DOCTOR
    // ============================================================

    GetPage(
      name: AppRoutes.doctorShell,
      page: () => const DoctorShellView(),
      binding: BindingsBuilder(() {
        Get.put(
          AppointmentController(
            dataService: Get.find(),
          ),
        );

        Get.put(
          DoctorHomeController(),
        );

        Get.put(
          AvailabilityController(),
        );

        Get.put(
          ChatListController(
            dataService: Get.find(),
          ),
        );
      }),
    ),

    // ============================================================
    // BOOK APPOINTMENT
    // ============================================================

    GetPage(
      name: AppRoutes.bookAppointment,
      page: () => const BookAppointmentView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AppointmentController>()) {
          Get.put(
            AppointmentController(
              dataService: Get.find(),
            ),
          );
        }
      }),
    ),

    // ============================================================
    // CHAT ROOM
    // ============================================================

    GetPage(
      name: AppRoutes.chatRoom,
      page: () => const ChatRoomView(),
      binding: BindingsBuilder(() {
        final args = Get.arguments as Map;

        Get.put(
          ChatRoomController(
            dataService: Get.find(),
            chatId: args['chatId'] as String,
            other: args['other'] as AppUser,
          ),
        );
      }),
    ),
  ];
}