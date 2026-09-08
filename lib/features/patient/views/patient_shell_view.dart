import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/time_utils.dart';
import '../../../core/widgets/app_widgets.dart';
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

        // Center FAB
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        floatingActionButton: SizedBox(
          width: 66,
          height: 66,
          child: FloatingActionButton(
            elevation: 6,
            backgroundColor: AppColors.primary,
            shape: const CircleBorder(),
            onPressed: () => Get.toNamed(AppRoutes.bookAppointment),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),

        // Custom bottom bar with center cut
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

          // Center spacing for FAB
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
              icon: Icons.chat_bubble_outline_rounded,
              selectedIcon: Icons.chat_bubble_rounded,
              label: 'Chat',
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
        padding: const EdgeInsets.only(top: 9, bottom: 6),
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
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
        children: [
          Obx(() {
            final user = auth.currentUser.value;

            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(.25),
                      width: 2,
                    ),
                  ),
                  child: UserAvatar(
                    user: user,
                    radius: 24,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.greeting(),
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.name ?? 'Patient',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkText,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: IconButton(
                    tooltip: 'Logout',
                    onPressed: auth.logout,
                    icon: const Icon(
                      Icons.logout_rounded,
                      size: 21,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 24),
          _MedicineSummaryCard(),
          const SizedBox(height: 20),
          _HealthBanner(),
          const SizedBox(height: 26),

          const _SectionHeader(
            title: 'Quick actions',
            subtitle: 'Healthcare services at your fingertips',
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
                backgroundColor: const Color(0xFFEAF3FF),
                iconBackground: const Color(0xFFD8E9FF),
                onTap: () => controller.tabIndex.value = 2,
              ),

              _ActionCard(
                icon: Icons.calendar_month_rounded,
                title: 'Appointment',
                subtitle: 'Book your visit',
                backgroundColor: const Color(0xFFE9F9F2),
                iconBackground: const Color(0xFFD4F2E5),
                onTap: () =>
                    Get.toNamed(AppRoutes.bookAppointment),
              ),

              _ActionCard(
                icon: Icons.forum_rounded,
                title: 'Live chat',
                subtitle: 'Get instant support',
                backgroundColor: const Color(0xFFFFF3E5),
                iconBackground: const Color(0xFFFFE6C7),
                onTap: () => controller.tabIndex.value = 3,
              ),

              _ActionCard(
                icon: Icons.chat_rounded,
                title: 'Doctor chat',
                subtitle: 'Message your doctor',
                backgroundColor: const Color(0xFFF3EDFF),
                iconBackground: const Color(0xFFE6D9FF),
                onTap: () => controller.tabIndex.value = 2,
              ),
            ],
          ),

          const SizedBox(height: 26),
          _DoctorsBanner(
            onTap: () {
              controller.tabIndex.value = 2;
            },
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        color: AppColors.secondaryText,
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
            final items = controller.todaysReminders;

            if (items.isEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                child: const EmptyState(
                  icon: Icons.medication_outlined,
                  title: 'No reminders yet',
                  subtitle:
                  'Add a medicine reminder so DoseMate can keep you on track.',
                ),
              );
            }

            return Column(
              children: items.take(5).map((reminder) {
                return _DoseCard(
                  medicineName: reminder.medicineName,
                  dosage: reminder.dosage,
                  times: reminder.times.join(', '),
                  onTaken: () {
                    controller.markTaken(reminder);
                  },
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}
class _MedicineSummaryCard extends GetView<PatientHomeController> {
  const _MedicineSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 188,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.08),
              ),
            ),
          ),

          Positioned(
            right: 35,
            bottom: -65,
            child: Container(
              width: 135,
              height: 135,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.07),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() {
                    final count =
                        controller.todaysReminders.length;

                    return Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Container(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                            Colors.white.withOpacity(.15),
                            borderRadius:
                            BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.medication_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Today’s medicines',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 13),

                        Text(
                          count == 0
                              ? 'No doses\nscheduled'
                              : '$count reminder${count == 1 ? '' : 's'}\ntoday',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                TimeUtils.prettyDate(
                                  DateTime.now(),
                                ),
                                maxLines: 1,
                                overflow:
                                TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
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
                    AppImages.onboardingHealth,
                    fit: BoxFit.contain,
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

class _HealthBanner extends StatelessWidget {
  const _HealthBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 118,
      padding: const EdgeInsets.only(
        left: 18,
        top: 15,
        bottom: 15,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8F5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFD6F1EA),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Text(
                  'Stay healthy,\nstay consistent',
                  style: TextStyle(
                    color: AppColors.darkText,
                    fontSize: 18,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Never miss your daily medicines.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 120,
            height: 110,
            child: Image.asset(
              AppImages.onboardingReminders,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorsBanner extends StatelessWidget {
  const _DoctorsBanner({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 154,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFE8F1FF),
            Color(0xFFF3F7FF),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFDCE8F8),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                18,
                18,
                5,
                18,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  const Text(
                    'Need medical advice?',
                    style: TextStyle(
                      color: AppColors.darkText,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 7),

                  const Text(
                    'Connect with a doctor and get the care you need.',
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppColors.secondaryText,
                    ),
                  ),

                  const SizedBox(height: 11),

                  Material(
                    color: AppColors.primary,
                    borderRadius:
                    BorderRadius.circular(12),
                    child: InkWell(
                      onTap: onTap,
                      borderRadius:
                      BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Consult now',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
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
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                AppImages.onboardingDoctors,
                height: 145,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 19,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}


class _ActionCard extends StatelessWidget {
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
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(.8),
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius:
                  BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 23,
                ),
              ),

              const Spacer(),

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.darkText,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.secondaryText,
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

class _DoseCard extends StatelessWidget {
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
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.025),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.medication_rounded,
              color: AppColors.primary,
              size: 25,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  medicineName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.darkText,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  dosage,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 3),

                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        times,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.secondaryText,
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
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 8,
              ),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(11),
              ),
            ),
            child: const Text(
              'Taken',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}