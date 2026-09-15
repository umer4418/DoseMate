import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/time_utils.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../models/user_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../chat/views/people_chat_view.dart';
import '../controllers/patient_home_controller.dart';
import '../controllers/reminder_controller.dart';
import 'appointments_view.dart';
import 'consult_doctors_view.dart';
import 'reminders_view.dart';

class PatientShellView extends GetView<PatientHomeController> {
  const PatientShellView({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = const [
      PatientHomeTab(),
      RemindersView(),
      ConsultDoctorsView(),
      PeopleChatView(mode: ChatPeopleMode.mixed),
      AppointmentsView(),
    ];

    return Obx(
          () => Scaffold(
        backgroundColor: const Color(0xFFF5F8FC),

        body: IndexedStack(
          index: controller.tabIndex.value,
          children: pages,
        ),

        floatingActionButtonLocation:
        FloatingActionButtonLocation.centerDocked,

        floatingActionButton: SizedBox(
          width: 66,
          height: 66,
          child: FloatingActionButton(
            elevation: 7,
            backgroundColor: AppColors.primary,
            shape: const CircleBorder(),
            onPressed: () {
              Get.toNamed(AppRoutes.bookAppointment);
            },
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),

        bottomNavigationBar: _PatientBottomBar(
          selectedIndex: controller.tabIndex.value,
          onTap: (index) {
            controller.tabIndex.value = index;
          },
        ),
      ),
    );
  }
}

class _PatientBottomBar extends StatelessWidget {
  const _PatientBottomBar({
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 78,
      elevation: 15,
      shadowColor: Colors.black26,
      color: Colors.white,
      notchMargin: 10,
      shape: const CircularNotchedRectangle(),
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: _BottomBarItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: 'Home',
              selected: selectedIndex == 0,
              onTap: () => onTap(0),
            ),
          ),

          Expanded(
            child: _BottomBarItem(
              icon: Icons.medication_outlined,
              selectedIcon: Icons.medication_rounded,
              label: 'Doses',
              selected: selectedIndex == 1,
              onTap: () => onTap(1),
            ),
          ),

          const SizedBox(width: 72),

          Expanded(
            child: _BottomBarItem(
              icon: Icons.medical_services_outlined,
              selectedIcon: Icons.medical_services_rounded,
              label: 'Consult',
              selected: selectedIndex == 2,
              onTap: () => onTap(2),
            ),
          ),

          Expanded(
            child: _BottomBarItem(
              icon: Icons.message,
              selectedIcon: Icons.message,
              label: 'chats',
              selected: selectedIndex == 3,
              onTap: () => onTap(3),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  const _BottomBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 9,
          bottom: 6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withOpacity(.11)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                selected ? selectedIcon : icon,
                size: 24,
                color: selected
                    ? AppColors.primary
                    : const Color(0xFF87909D),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight:
                selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? AppColors.primary
                    : const Color(0xFF87909D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PatientHomeTab extends GetView<PatientHomeController> {
  const PatientHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return SafeArea(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          20,
          14,
          20,
          120,
        ),
        children: [
          Obx(() {
            final user = auth.currentUser.value;

            return _PatientTopBar(
              user: user,
              userName: user?.name ?? 'Patient',
              notificationCount:
              controller.todaysReminders.length,
              onProfileTap: () {
                _showPatientProfile(
                  context,
                  user,
                );
              },
              onNotificationTap: () {
                _showMedicineNotifications(context);
              },
            );
          }),

          const SizedBox(height: 24),
          const _MedicineSummaryCard(),
          const SizedBox(height: 20),
          const _HealthBanner(),
          const SizedBox(height: 22),

          _HomeAppointmentCard(
            onBook: () {
              Get.toNamed(AppRoutes.bookAppointment);
            },
            onViewAppointments: () {
              controller.tabIndex.value = 4;
            },
          ),

          const SizedBox(height: 28),
          const _SectionHeader(
            title: 'Quick actions',
            subtitle:
            'Healthcare services at your fingertips',
          ),

          const SizedBox(height: 14),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 13,
            crossAxisSpacing: 13,
            childAspectRatio: 1.25,
            children: [
              _ActionCard(
                icon: Icons.medical_services_rounded,
                title: 'Consult doctor',
                subtitle: 'Find a specialist',
                backgroundColor:
                const Color(0xFFEAF3FF),
                iconBackground:
                const Color(0xFFD8E9FF),
                onTap: () {
                  controller.tabIndex.value = 2;
                },
              ),

              _ActionCard(
                icon: Icons.calendar_month_rounded,
                title: 'Appointment',
                subtitle: 'Book your visit',
                backgroundColor:
                const Color(0xFFE9F9F2),
                iconBackground:
                const Color(0xFFD4F2E5),
                onTap: () {
                  Get.toNamed(
                    AppRoutes.bookAppointment,
                  );
                },
              ),

              _ActionCard(
                icon: Icons.forum_rounded,
                title: 'Live chat',
                subtitle: 'Get instant support',
                backgroundColor:
                const Color(0xFFFFF3E5),
                iconBackground:
                const Color(0xFFFFE6C7),
                onTap: () {
                  controller.tabIndex.value = 3;
                },
              ),

              _ActionCard(
                icon: Icons.history_rounded,
                title: 'My visits',
                subtitle: 'View appointments',
                backgroundColor:
                const Color(0xFFF3EDFF),
                iconBackground:
                const Color(0xFFE6D9FF),
                onTap: () {
                  controller.tabIndex.value = 4;
                },
              ),
            ],
          ),

          const SizedBox(height: 28),
          _DoctorsBanner(
            onTap: () {
              controller.tabIndex.value = 2;
            },
          ),

          const SizedBox(height: 30),
          _AppointmentSectionHeader(
            onViewAll: () {
              controller.tabIndex.value = 4;
            },
          ),

          const SizedBox(height: 13),
          _AppointmentPreviewCard(
            onTap: () {
              controller.tabIndex.value = 4;
            },
            onBook: () {
              Get.toNamed(AppRoutes.bookAppointment);
            },
          ),

          const SizedBox(height: 30),

          // ============================================================
          // MEDICINES
          // ============================================================

          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upcoming doses',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 19,
                        color: AppColors.darkText,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Stay consistent with your medicines',
                      style: TextStyle(
                        fontSize: 12.5,
                        color:
                        AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              TextButton(
                onPressed: () {
                  Get.find<ReminderController>();
                  controller.tabIndex.value = 1;
                },
                child: const Text(
                  'See all',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Obx(() {
            final items =
                controller.todaysReminders;

            if (items.isEmpty) {
              return const EmptyState(
                icon:
                Icons.medication_outlined,
                title: 'No reminders yet',
                subtitle:
                'Add a medicine reminder so DoseMate can keep you on track.',
              );
            }

            return Column(
              children: items
                  .take(5)
                  .map(
                    (reminder) => _DoseCard(
                  medicineName:
                  reminder.medicineName,
                  dosage: reminder.dosage,
                  times:
                  reminder.times.join(', '),
                  onTaken: () {
                    controller.markTaken(
                      reminder,
                    );
                  },
                ),
              )
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  // ================================================================
  // PATIENT PROFILE
  // ================================================================

  void _showPatientProfile(
      BuildContext context,
      AppUser? user,
      ) {
    Get.bottomSheet(
      _PatientProfileSheet(
        user: user,
      ),
      isScrollControlled: true,
    );
  }

  // ================================================================
  // MEDICINE NOTIFICATIONS
  // ================================================================

  void _showMedicineNotifications(
      BuildContext context,
      ) {
    final reminders =
        controller.todaysReminders;

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight:
          MediaQuery.of(context).size.height *
              .75,
        ),
        padding:
        const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          25,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFF7FAFE),
          borderRadius:
          BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              margin:
              const EdgeInsets.only(
                bottom: 20,
              ),
              decoration:
              BoxDecoration(
                color:
                const Color(0xFFD6DCE5),
                borderRadius:
                BorderRadius.circular(10),
              ),
            ),

            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration:
                  BoxDecoration(
                    color: AppColors.primary
                        .withOpacity(.10),
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medicine reminders',
                        style: TextStyle(
                          color:
                          AppColors.darkText,
                          fontSize: 19,
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Your medication schedule for today',
                        style: TextStyle(
                          color: AppColors
                              .secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (reminders.isEmpty)
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(
                  vertical: 35,
                  horizontal: 20,
                ),
                decoration:
                BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                  border: Border.all(
                    color:
                    AppColors.border,
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons
                          .notifications_off_outlined,
                      size: 45,
                      color:
                      Color(0xFF9AA4B2),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No medicine reminders',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                        FontWeight.w700,
                        color:
                        AppColors.darkText,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'You have no medicines scheduled for today.',
                      textAlign:
                      TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors
                            .secondaryText,
                      ),
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount:
                  reminders.length,
                  separatorBuilder:
                      (_, __) =>
                  const SizedBox(
                    height: 10,
                  ),
                  itemBuilder:
                      (context, index) {
                    final reminder =
                    reminders[index];

                    return _NotificationMedicineCard(
                      medicineName:
                      reminder.medicineName,
                      dosage:
                      reminder.dosage,
                      times: reminder.times
                          .join(', '),
                      onTaken: () {
                        controller
                            .markTaken(
                          reminder,
                        );

                        Get.back();
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _HomeAppointmentCard extends StatelessWidget {
  const _HomeAppointmentCard({
    required this.onBook,
    required this.onViewAppointments,
  });

  final VoidCallback onBook;
  final VoidCallback onViewAppointments;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary
                      .withOpacity(.10),
                  borderRadius:
                  BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),

              const SizedBox(width: 13),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appointments',
                      style: TextStyle(
                        color: AppColors.darkText,
                        fontSize: 17,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage your doctor visits',
                      style: TextStyle(
                        color:
                        AppColors.secondaryText,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: onViewAppointments,
                tooltip: 'View appointments',
                style: IconButton.styleFrom(
                  backgroundColor:
                  AppColors.primary
                      .withOpacity(.08),
                ),
                icon: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFE),
              borderRadius:
              BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary
                        .withOpacity(.09),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Have an upcoming visit?',
                        style: TextStyle(
                          color:
                          AppColors.darkText,
                          fontSize: 12.5,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Check your appointment records or book a new visit.',
                        style: TextStyle(
                          color:
                          AppColors.secondaryText,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 13),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                  onViewAppointments,
                  icon: const Icon(
                    Icons.history_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'My appointments',
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  style:
                  OutlinedButton.styleFrom(
                    foregroundColor:
                    AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary
                          .withOpacity(.25),
                    ),
                    padding:
                    const EdgeInsets
                        .symmetric(
                      vertical: 13,
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        13,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onBook,
                  icon: const Icon(
                    Icons.add_rounded,
                    size: 19,
                  ),
                  label: const Text(
                    'Book appointment',
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    AppColors.primary,
                    foregroundColor:
                    Colors.white,
                    elevation: 0,
                    padding:
                    const EdgeInsets
                        .symmetric(
                      vertical: 13,
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppointmentSectionHeader
    extends StatelessWidget {
  const _AppointmentSectionHeader({
    required this.onViewAll,
  });

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'My appointments',
                style: TextStyle(
                  color: AppColors.darkText,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Keep track of your doctor visits',
                style: TextStyle(
                  color:
                  AppColors.secondaryText,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),

        TextButton(
          onPressed: onViewAll,
          child: const Text(
            'View all',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _AppointmentPreviewCard
    extends StatelessWidget {
  const _AppointmentPreviewCard({
    required this.onTap,
    required this.onBook,
  });

  final VoidCallback onTap;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(21),
            border: Border.all(
              color: AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color:
                Colors.black.withOpacity(.025),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primary
                      .withOpacity(.09),
                  borderRadius:
                  BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: AppColors.primary,
                  size: 27,
                ),
              ),

              const SizedBox(width: 13),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appointment records',
                      style: TextStyle(
                        color:
                        AppColors.darkText,
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'View your confirmed, pending and completed appointments.',
                      maxLines: 2,
                      style: TextStyle(
                        color:
                        AppColors.secondaryText,
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color:
                AppColors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientTopBar extends StatelessWidget {
  const _PatientTopBar({
    required this.user,
    required this.userName,
    required this.notificationCount,
    required this.onProfileTap,
    required this.onNotificationTap,
  });

  final AppUser? user;
  final String userName;
  final int notificationCount;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onProfileTap,
            borderRadius:
            BorderRadius.circular(18),
            child: Padding(
              padding:
              const EdgeInsets.symmetric(
                vertical: 4,
              ),
              child: Row(
                children: [
                  Container(
                    padding:
                    const EdgeInsets.all(2.5),
                    decoration:
                    BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary
                            .withOpacity(.25),
                        width: 2,
                      ),
                    ),
                    child: UserAvatar(
                      user: user,
                      radius: 24,
                    ),
                  ),

                  const SizedBox(width: 11),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back 👋',
                          style: TextStyle(
                            color: AppColors
                                .secondaryText,
                            fontSize: 12,
                            fontWeight:
                            FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userName,
                          maxLines: 1,
                          overflow:
                          TextOverflow.ellipsis,
                          style:
                          const TextStyle(
                            color:
                            AppColors.darkText,
                            fontSize: 18,
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons
                        .keyboard_arrow_down_rounded,
                    color:
                    AppColors.secondaryText,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        _NotificationButton(
          count: notificationCount,
          onTap: onNotificationTap,
        ),
      ],
    );
  }
}

class _NotificationButton
    extends StatelessWidget {
  const _NotificationButton({
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(15),
          child: InkWell(
            onTap: onTap,
            borderRadius:
            BorderRadius.circular(15),
            child: Container(
              width: 48,
              height: 48,
              decoration:
              BoxDecoration(
                borderRadius:
                BorderRadius.circular(15),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: const Icon(
                Icons
                    .notifications_none_rounded,
                color:
                AppColors.darkText,
                size: 24,
              ),
            ),
          ),
        ),

        if (count > 0)
          Positioned(
            right: -2,
            top: -3,
            child: Container(
              constraints:
              const BoxConstraints(
                minWidth: 19,
                minHeight: 19,
              ),
              padding:
              const EdgeInsets.symmetric(
                horizontal: 5,
              ),
              decoration:
              BoxDecoration(
                color:
                const Color(0xFFFF4D5E),
                borderRadius:
                BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: Text(
                count > 9
                    ? '9+'
                    : '$count',
                textAlign:
                TextAlign.center,
                style:
                const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MedicineSummaryCard
    extends GetView<PatientHomeController> {
  const _MedicineSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 188,
      clipBehavior:
      Clip.antiAlias,
      decoration:
      BoxDecoration(
        gradient:
        const LinearGradient(
          begin:
          Alignment.topLeft,
          end:
          Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius:
        BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary
                .withOpacity(.22),
            blurRadius: 22,
            offset:
            const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -45,
            child: Container(
              width: 155,
              height: 155,
              decoration:
              BoxDecoration(
                shape:
                BoxShape.circle,
                color: Colors.white
                    .withOpacity(.08),
              ),
            ),
          ),

          Positioned(
            right: 35,
            bottom: -65,
            child: Container(
              width: 135,
              height: 135,
              decoration:
              BoxDecoration(
                shape:
                BoxShape.circle,
                color: Colors.white
                    .withOpacity(.07),
              ),
            ),
          ),

          Padding(
            padding:
            const EdgeInsets.all(
              20,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() {
                    final count =
                        controller
                            .todaysReminders
                            .length;

                    return Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                      children: [
                        Container(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration:
                          BoxDecoration(
                            color: Colors.white
                                .withOpacity(
                              .15,
                            ),
                            borderRadius:
                            BorderRadius
                                .circular(
                              20,
                            ),
                          ),
                          child:
                          const Row(
                            mainAxisSize:
                            MainAxisSize
                                .min,
                            children: [
                              Icon(
                                Icons
                                    .medication_rounded,
                                color:
                                Colors.white,
                                size: 16,
                              ),
                              SizedBox(
                                  width: 6),
                              Text(
                                'Today’s medicines',
                                style:
                                TextStyle(
                                  color: Colors
                                      .white,
                                  fontSize: 12,
                                  fontWeight:
                                  FontWeight
                                      .w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                            height: 13),

                        Text(
                          count == 0
                              ? 'No doses\nscheduled'
                              : '$count reminder${count == 1 ? '' : 's'}\ntoday',
                          style:
                          const TextStyle(
                            color:
                            Colors.white,
                            fontSize: 25,
                            height: 1.1,
                            fontWeight:
                            FontWeight
                                .w800,
                          ),
                        ),

                        const SizedBox(
                            height: 10),

                        Row(
                          children: [
                            const Icon(
                              Icons
                                  .calendar_today_outlined,
                              color:
                              Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(
                                width: 6),
                            Flexible(
                              child: Text(
                                TimeUtils
                                    .prettyDate(
                                  DateTime.now(),
                                ),
                                maxLines: 1,
                                overflow:
                                TextOverflow
                                    .ellipsis,
                                style:
                                const TextStyle(
                                  color:
                                  Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                ),

                const SizedBox(width: 5),

                SizedBox(
                  width: 130,
                  height: 150,
                  child: Image.asset(
                    AppImages
                        .onboardingHealth,
                    fit:
                    BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthBanner
    extends StatelessWidget {
  const _HealthBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 118,
      padding:
      const EdgeInsets.only(
        left: 18,
        top: 15,
        bottom: 15,
      ),
      decoration:
      BoxDecoration(
        color:
        const Color(0xFFEAF8F5),
        borderRadius:
        BorderRadius.circular(22),
        border: Border.all(
          color:
          const Color(0xFFD6F1EA),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              mainAxisAlignment:
              MainAxisAlignment
                  .center,
              children: [
                Text(
                  'Stay healthy,\nstay consistent',
                  style:
                  TextStyle(
                    color:
                    AppColors.darkText,
                    fontSize: 18,
                    height: 1.15,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Never miss your daily medicines.',
                  style:
                  TextStyle(
                    fontSize: 11.5,
                    color: AppColors
                        .secondaryText,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            width: 120,
            height: 110,
            child: Image.asset(
              AppImages
                  .onboardingReminders,
              fit:
              BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
class _DoctorsBanner
    extends StatelessWidget {
  const _DoctorsBanner({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 154,
      clipBehavior:
      Clip.antiAlias,
      decoration:
      BoxDecoration(
        borderRadius:
        BorderRadius.circular(24),
        gradient:
        const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFE8F1FF),
            Color(0xFFF3F7FF),
          ],
        ),
        border: Border.all(
          color:
          const Color(0xFFDCE8F8),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Padding(
              padding:
              const EdgeInsets
                  .fromLTRB(
                18,
                18,
                5,
                18,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                mainAxisAlignment:
                MainAxisAlignment
                    .center,
                children: [
                  const Text(
                    'Need medical advice?',
                    style:
                    TextStyle(
                      color:
                      AppColors.darkText,
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                      height: 7),

                  const Text(
                    'Connect with a doctor and get the care you need.',
                    maxLines: 2,
                    style:
                    TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppColors
                          .secondaryText,
                    ),
                  ),

                  const SizedBox(
                      height: 11),

                  Material(
                    color:
                    AppColors.primary,
                    borderRadius:
                    BorderRadius
                        .circular(
                      12,
                    ),
                    child:
                    InkWell(
                      onTap: onTap,
                      borderRadius:
                      BorderRadius
                          .circular(
                        12,
                      ),
                      child:
                      const Padding(
                        padding:
                        EdgeInsets
                            .symmetric(
                          horizontal: 13,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize:
                          MainAxisSize
                              .min,
                          children: [
                            Text(
                              'Consult now',
                              style:
                              TextStyle(
                                color:
                                Colors.white,
                                fontSize: 12,
                                fontWeight:
                                FontWeight
                                    .w700,
                              ),
                            ),
                            SizedBox(
                                width: 5),
                            Icon(
                              Icons
                                  .arrow_forward_rounded,
                              color:
                              Colors.white,
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 4,
            child: Align(
              alignment:
              Alignment
                  .bottomCenter,
              child: Image.asset(
                AppImages
                    .onboardingDoctors,
                height: 145,
                fit:
                BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _SectionHeader
    extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
          const TextStyle(
            fontWeight:
            FontWeight.w800,
            fontSize: 19,
            color:
            AppColors.darkText,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style:
          const TextStyle(
            fontSize: 12.5,
            color:
            AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}

class _ActionCard
    extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.backgroundColor,
    required this.iconBackground,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius:
      BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(22),
        child: Container(
          padding:
          const EdgeInsets.all(15),
          decoration:
          BoxDecoration(
            borderRadius:
            BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white
                  .withOpacity(.8),
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                BoxDecoration(
                  color:
                  iconBackground,
                  borderRadius:
                  BorderRadius.circular(
                    13,
                  ),
                ),
                child: Icon(
                  icon,
                  color:
                  AppColors.primary,
                  size: 23,
                ),
              ),

              const Spacer(),

              Text(
                title,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style:
                const TextStyle(
                  color:
                  AppColors.darkText,
                  fontSize: 14,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style:
                const TextStyle(
                  color: AppColors
                      .secondaryText,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoseCard
    extends StatelessWidget {
  const _DoseCard({
    required this.medicineName,
    required this.dosage,
    required this.times,
    required this.onTaken,
  });

  final String medicineName;
  final String dosage;
  final String times;
  final VoidCallback onTaken;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 11,
      ),
      padding:
      const EdgeInsets.all(13),
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(
              .025,
            ),
            blurRadius: 12,
            offset:
            const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:
            BoxDecoration(
              color: AppColors.primary
                  .withOpacity(.10),
              borderRadius:
              BorderRadius.circular(
                15,
              ),
            ),
            child: const Icon(
              Icons.medication_rounded,
              color:
              AppColors.primary,
              size: 25,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  medicineName,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    color:
                    AppColors.darkText,
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  dosage,
                  style:
                  const TextStyle(
                    color: AppColors
                        .secondaryText,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 3),

                Row(
                  children: [
                    const Icon(
                      Icons
                          .access_time_rounded,
                      size: 13,
                      color:
                      AppColors.primary,
                    ),
                    const SizedBox(
                        width: 4),
                    Expanded(
                      child: Text(
                        times,
                        maxLines: 1,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style:
                        const TextStyle(
                          fontSize: 11.5,
                          color: AppColors
                              .secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          TextButton(
            onPressed: onTaken,
            style:
            TextButton.styleFrom(
              foregroundColor:
              Colors.white,
              backgroundColor:
              AppColors.primary,
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 13,
                vertical: 8,
              ),
              minimumSize:
              Size.zero,
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                  11,
                ),
              ),
            ),
            child:
            const Text(
              'Taken',
              style:
              TextStyle(
                fontSize: 11.5,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationMedicineCard
    extends StatelessWidget {
  const _NotificationMedicineCard({
    required this.medicineName,
    required this.dosage,
    required this.times,
    required this.onTaken,
  });

  final String medicineName;
  final String dosage;
  final String times;
  final VoidCallback onTaken;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.all(15),
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(
              .025,
            ),
            blurRadius: 10,
            offset:
            const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:
            BoxDecoration(
              color: AppColors.primary
                  .withOpacity(.10),
              borderRadius:
              BorderRadius.circular(
                15,
              ),
            ),
            child: const Icon(
              Icons.medication_rounded,
              color:
              AppColors.primary,
              size: 25,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  medicineName,
                  style:
                  const TextStyle(
                    color:
                    AppColors.darkText,
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  dosage,
                  style:
                  const TextStyle(
                    color: AppColors
                        .secondaryText,
                    fontSize: 11.5,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    const Icon(
                      Icons
                          .access_time_rounded,
                      size: 14,
                      color:
                      AppColors.primary,
                    ),
                    const SizedBox(
                        width: 4),
                    Expanded(
                      child: Text(
                        times,
                        style:
                        const TextStyle(
                          color: AppColors
                              .secondaryText,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          IconButton(
            tooltip:
            'Mark as taken',
            onPressed: onTaken,
            style:
            IconButton.styleFrom(
              backgroundColor:
              AppColors.primary
                  .withOpacity(.10),
            ),
            icon: const Icon(
              Icons.check_rounded,
              color:
              AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientProfileSheet
    extends StatelessWidget {
  const _PatientProfileSheet({
    required this.user,
  });

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final auth =
    Get.find<AuthController>();

    return Container(
      constraints: BoxConstraints(
        maxHeight:
        MediaQuery.of(context).size.height *
            .82,
      ),
      padding:
      const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        25,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF7FAFE),
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 42,
              height: 4,
              margin:
              const EdgeInsets.only(
                bottom: 20,
              ),
              decoration:
              BoxDecoration(
                color:
                const Color(0xFFD6DCE5),
                borderRadius:
                BorderRadius.circular(10),
              ),
            ),

            Container(
              padding:
              const EdgeInsets.all(3),
              decoration:
              BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary
                      .withOpacity(.25),
                  width: 2,
                ),
              ),
              child: UserAvatar(
                user: user,
                radius: 43,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              user?.name ?? 'Patient',
              style: const TextStyle(
                color:
                AppColors.darkText,
                fontSize: 21,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              user?.email ?? 'Patient account',
              style: const TextStyle(
                color:
                AppColors.secondaryText,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back();

                  Get.to(
                        () => _EditPatientProfileView(
                      user: user,
                    ),
                  );
                },
                icon: const Icon(
                  Icons.edit_rounded,
                  size: 18,
                ),
                label: const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  AppColors.primary,
                  foregroundColor:
                  Colors.white,
                  elevation: 0,
                  padding:
                  const EdgeInsets
                      .symmetric(
                    vertical: 14,
                  ),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      15,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            _ProfileInfoRow(
              icon:
              Icons.person_outline_rounded,
              title: 'Full name',
              value:
              user?.name ?? 'Not provided',
            ),

            _ProfileInfoRow(
              icon:
              Icons.email_outlined,
              title: 'Email',
              value:
              user?.email ?? 'Not provided',
            ),

            _ProfileInfoRow(
              icon:
              Icons.phone_outlined,
              title: 'Phone',
              value:
              user?.phone ?? 'Not provided',
            ),

            const _ProfileInfoRow(
              icon:
              Icons.medical_information_outlined,
              title: 'Account type',
              value: 'Patient',
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.back();
                  auth.logout();
                },
                icon: const Icon(
                  Icons.logout_rounded,
                  size: 18,
                ),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
                style:
                OutlinedButton.styleFrom(
                  foregroundColor:
                  const Color(
                    0xFFD63B4A,
                  ),
                  side:
                  const BorderSide(
                    color:
                    Color(0xFFF0C8CD),
                  ),
                  padding:
                  const EdgeInsets
                      .symmetric(
                    vertical: 13,
                  ),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditPatientProfileView
    extends StatefulWidget {
  const _EditPatientProfileView({
    required this.user,
  });

  final AppUser? user;

  @override
  State<_EditPatientProfileView>
  createState() =>
      _EditPatientProfileViewState();
}

class _EditPatientProfileViewState
    extends State<_EditPatientProfileView> {
  late final TextEditingController
  nameController;

  late final TextEditingController
  phoneController;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(
          text: widget.user?.name ?? '',
        );

    phoneController =
        TextEditingController(
          text: widget.user?.phone ?? '',
        );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final name =
    nameController.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        'Required',
        'Please enter your name.',
        snackPosition:
        SnackPosition.BOTTOM,
      );
      return;
    }

    Get.back();

    Get.snackbar(
      'Profile',
      'Profile information entered successfully.',
      snackPosition:
      SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF5F8FC),

      appBar: AppBar(
        backgroundColor:
        const Color(0xFFF5F8FC),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
          ),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
      ),

      body: ListView(
        padding:
        const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              padding:
              const EdgeInsets.all(3),
              decoration:
              BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary
                      .withOpacity(.25),
                  width: 2,
                ),
              ),
              child: UserAvatar(
                user: widget.user,
                radius: 48,
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Center(
            child: Text(
              'Update your information',
              style: TextStyle(
                color:
                AppColors.secondaryText,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 30),

          _EditField(
            controller:
            nameController,
            label: 'Full name',
            hint:
            'Enter your full name',
            icon:
            Icons.person_outline_rounded,
          ),

          const SizedBox(height: 16),

          _EditField(
            controller:
            phoneController,
            label: 'Phone number',
            hint:
            'Enter your phone number',
            icon:
            Icons.phone_outlined,
            keyboardType:
            TextInputType.phone,
          ),

          const SizedBox(height: 16),

          Container(
            padding:
            const EdgeInsets.all(15),
            decoration:
            BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(17),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration:
                  BoxDecoration(
                    color: AppColors.primary
                        .withOpacity(.08),
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: const Icon(
                    Icons.email_outlined,
                    color:
                    AppColors.primary,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors
                              .secondaryText,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.user?.email ??
                            'Not available',
                        style:
                        const TextStyle(
                          fontSize: 13,
                          fontWeight:
                          FontWeight.w700,
                          color: AppColors
                              .darkText,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.lock_outline_rounded,
                  size: 18,
                  color:
                  AppColors.secondaryText,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveProfile,
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                AppColors.primary,
                foregroundColor:
                Colors.white,
                elevation: 0,
                padding:
                const EdgeInsets
                    .symmetric(
                  vertical: 16,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    16,
                  ),
                ),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EDIT FIELD
// ============================================================================

class _EditField
    extends StatelessWidget {
  const _EditField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.darkText,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
          decoration:
          InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              size: 21,
              color:
              AppColors.primary,
            ),
            filled: true,
            fillColor: Colors.white,
            border:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(16),
              borderSide:
              BorderSide.none,
            ),
            enabledBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(16),
              borderSide:
              const BorderSide(
                color: AppColors.border,
              ),
            ),
            focusedBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(16),
              borderSide:
              const BorderSide(
                color:
                AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileInfoRow
    extends StatelessWidget {
  const _ProfileInfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
      const EdgeInsets.all(14),
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(17),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration:
            BoxDecoration(
              color: AppColors.primary
                  .withOpacity(.08),
              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),
            child: Icon(
              icon,
              color:
              AppColors.primary,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                  const TextStyle(
                    color: AppColors
                        .secondaryText,
                    fontSize: 10.5,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    color:
                    AppColors.darkText,
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}