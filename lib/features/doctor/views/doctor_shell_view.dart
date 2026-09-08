import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../chat/views/people_chat_view.dart';
import '../../patient/controllers/appointment_controller.dart';
import '../controllers/doctor_controllers.dart';

class DoctorShellView extends GetView<DoctorHomeController> {
  const DoctorShellView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    const pages = [
      DoctorHomeTab(),
      DoctorBookingsView(),
      AvailabilityView(),
      PeopleChatView(mode: ChatPeopleMode.mixed),
    ];

    return Obx(
          () => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: IndexedStack(
          index: controller.tabIndex.value,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.tabIndex.value,
          onDestinationSelected: (index) {
            controller.tabIndex.value = index;
          },
          backgroundColor: colors.surface,
          indicatorColor: AppColors.primarySoft,
          elevation: 8,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(
                Icons.dashboard_rounded,
                color: AppColors.primary,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: const Icon(Icons.event_note_outlined),
              selectedIcon: Icon(
                Icons.event_note_rounded,
                color: AppColors.primary,
              ),
              label: 'Bookings',
            ),
            NavigationDestination(
              icon: const Icon(Icons.schedule_outlined),
              selectedIcon: Icon(
                Icons.schedule_rounded,
                color: AppColors.primary,
              ),
              label: 'Availability',
            ),
            NavigationDestination(
              icon: const Icon(Icons.chat_outlined),
              selectedIcon: Icon(
                Icons.chat_rounded,
                color: AppColors.primary,
              ),
              label: 'Chats',
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// DOCTOR HOME
// ============================================================================

class DoctorHomeTab extends GetView<DoctorHomeController> {
  const DoctorHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final appointments = Get.find<AppointmentController>();
    final availability = Get.find<AvailabilityController>();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        children: [
          // ------------------------------------------------------------------
          // HEADER
          // ------------------------------------------------------------------

          Obx(
                () {
              final user = auth.currentUser.value;

              return Row(
                children: [
                  // REAL USER PROFILE IMAGE
                  UserAvatar(
                    user: user,
                    radius: 29,
                  ),

                  const SizedBox(width: 13),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style:
                          theme.textTheme.bodySmall?.copyWith(
                            color:
                            colors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          user?.name?.isNotEmpty == true
                              ? user!.name
                              : 'Doctor',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        if (user?.specialization
                            ?.isNotEmpty ==
                            true)
                          Text(
                            user!.specialization,
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style: theme
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                              color:
                              colors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                        colors.outlineVariant,
                      ),
                    ),
                    child: IconButton(
                      onPressed: auth.logout,
                      icon: const Icon(
                        Icons.logout_rounded,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // ------------------------------------------------------------------
          // AVAILABILITY HERO
          // ------------------------------------------------------------------

          Obx(
                () {
              final user = auth.currentUser.value;

              final isAvailable =
                  user?.isAvailable ?? true;

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius:
                  BorderRadius.circular(26),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                            color: colors.onPrimary
                                .withValues(
                              alpha: 0.15,
                            ),
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                          child: Icon(
                            isAvailable
                                ? Icons
                                .event_available_rounded
                                : Icons
                                .event_busy_rounded,
                            color: colors.onPrimary,
                          ),
                        ),

                        const Spacer(),

                        Switch.adaptive(
                          value: isAvailable,
                          activeColor:
                          colors.onPrimary,
                          activeTrackColor:
                          colors.onPrimary
                              .withValues(
                            alpha: 0.3,
                          ),
                          inactiveTrackColor:
                          colors.onPrimary
                              .withValues(
                            alpha: 0.15,
                          ),
                          onChanged: (value) {
                            availability
                                .isAvailable
                                .value = value;

                            availability.save();
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Text(
                      isAvailable
                          ? 'You are available'
                          : 'You are unavailable',
                      style: theme
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                        color: colors.onPrimary,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      isAvailable
                          ? 'Patients can currently request appointments with you.'
                          : 'Patients cannot request new appointments right now.',
                      style: theme
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        color: colors.onPrimary
                            .withValues(
                          alpha: 0.75,
                        ),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // ------------------------------------------------------------------
          // DECORATIVE DOCTOR IMAGE
          // ------------------------------------------------------------------

          Container(
            padding: const EdgeInsets.fromLTRB(
              18,
              18,
              10,
              18,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius:
              BorderRadius.circular(22),
              border: Border.all(
                color: colors.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your practice',
                        style: theme
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          color:
                          colors.onSurface,
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Manage appointments, availability and patient conversations from one place.',
                        style: theme
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color: colors
                              .onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ONLY DECORATIVE IMAGE
                Image.asset(
                  AppImages.doctorAvatar2,
                  height: 105,
                  width: 105,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          // ------------------------------------------------------------------
          // OVERVIEW
          // ------------------------------------------------------------------

          Text(
            'Overview',
            style:
            theme.textTheme.titleLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 13),

          Obx(
                () {
              final list =
                  appointments.doctorAppointments;

              final pending = list
                  .where(
                    (item) =>
                item.status == 'pending',
              )
                  .length;

              final confirmed = list
                  .where(
                    (item) =>
                item.status == 'confirmed',
              )
                  .length;

              final completed = list
                  .where(
                    (item) =>
                item.status == 'completed',
              )
                  .length;

              return Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon:
                      Icons.pending_actions_rounded,
                      title: 'Pending',
                      value: pending.toString(),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _StatCard(
                      icon:
                      Icons.event_available_rounded,
                      title: 'Confirmed',
                      value:
                      confirmed.toString(),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _StatCard(
                      icon: Icons.task_alt_rounded,
                      title: 'Completed',
                      value:
                      completed.toString(),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          // ------------------------------------------------------------------
          // UPCOMING REQUESTS
          // ------------------------------------------------------------------

          Row(
            children: [
              Expanded(
                child: Text(
                  'Upcoming requests',
                  style: theme
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    color: colors.onSurface,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),

              TextButton(
                onPressed: () {
                  controller.tabIndex.value = 1;
                },
                child: Text(
                  'View all',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Obx(
                () {
              final items = controller.upcoming;

              if (items.isEmpty) {
                return const _ModernEmptyState(
                  icon:
                  Icons.event_available_outlined,
                  title:
                  'No upcoming bookings',
                  subtitle:
                  'New patient requests will appear here.',
                );
              }

              return Column(
                children: items
                    .take(5)
                    .map(
                      (item) =>
                      _UpcomingBookingCard(
                        patientName:
                        item.patientName,
                        date: item.date,
                        time: item.time,
                        status: item.status,
                      ),
                )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning';
    }

    if (hour < 17) {
      return 'Good afternoon';
    }

    return 'Good evening';
  }
}

// ============================================================================
// BOOKINGS
// ============================================================================

class DoctorBookingsView
    extends GetView<AppointmentController> {
  const DoctorBookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor:
      theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text(
          'Appointment Requests',
        ),
        backgroundColor:
        theme.scaffoldBackgroundColor,
        surfaceTintColor:
        Colors.transparent,
        elevation: 0,
      ),

      body: Obx(
            () {
          final items =
          [...controller.doctorAppointments]
            ..sort(
                  (a, b) =>
                  '${b.date}${b.time}'
                      .compareTo(
                    '${a.date}${a.time}',
                  ),
            );

          if (items.isEmpty) {
            return const _ModernEmptyState(
              icon: Icons.inbox_outlined,
              title: 'No appointments',
              subtitle:
              'Patients will appear here when they book your available slots.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              30,
            ),
            itemCount: items.length,
            itemBuilder:
                (context, index) {
              final item = items[index];

              return _AppointmentCard(
                patientName:
                item.patientName,
                date: item.date,
                time: item.time,
                notes: item.notes,
                status: item.status,

                onDecline:
                item.status == 'pending'
                    ? () =>
                    controller.updateStatus(
                      item.id,
                      'rejected',
                    )
                    : null,

                onConfirm:
                item.status == 'pending'
                    ? () =>
                    controller.updateStatus(
                      item.id,
                      'confirmed',
                    )
                    : null,

                onComplete:
                item.status == 'confirmed'
                    ? () =>
                    controller.updateStatus(
                      item.id,
                      'completed',
                    )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================================================
// AVAILABILITY
// ============================================================================

class AvailabilityView
    extends GetView<AvailabilityController> {
  const AvailabilityView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor:
      theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text('Availability'),
        backgroundColor:
        theme.scaffoldBackgroundColor,
        surfaceTintColor:
        Colors.transparent,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          8,
          20,
          30,
        ),
        children: [
          // ----------------------------------------------------------------
          // HEADER
          // ----------------------------------------------------------------

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius:
              BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius:
                    BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: colors.onPrimary,
                    size: 25,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your schedule',
                        style: theme
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          color:
                          colors.onSurface,
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Set when patients can book appointments with you.',
                        style: theme
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color: colors
                              .onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // ----------------------------------------------------------------
          // ACCEPT BOOKINGS
          // ----------------------------------------------------------------

          _AvailabilitySectionCard(
            child: Obx(
                  () => SwitchListTile.adaptive(
                contentPadding:
                EdgeInsets.zero,
                value:
                controller.isAvailable.value,
                activeColor:
                AppColors.primary,
                title: Text(
                  'Accept new bookings',
                  style: theme
                      .textTheme
                      .titleSmall
                      ?.copyWith(
                    fontWeight:
                    FontWeight.w700,
                    color:
                    colors.onSurface,
                  ),
                ),
                subtitle: Text(
                  controller.isAvailable.value
                      ? 'Patients can book appointments.'
                      : 'New appointment requests are disabled.',
                  style: theme
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color: colors
                        .onSurfaceVariant,
                  ),
                ),
                onChanged: (value) {
                  controller
                      .isAvailable
                      .value = value;
                },
              ),
            ),
          ),

          const SizedBox(height: 18),

          // ----------------------------------------------------------------
          // WORKING DAYS
          // ----------------------------------------------------------------

          _AvailabilitySectionCard(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Working days',
                  style: theme
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    color:
                    colors.onSurface,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Select the days you are available.',
                  style: theme
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color:
                    colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 16),

                Obx(
                      () => Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: controller.days
                        .map(
                          (day) {
                        final selected =
                        controller
                            .selectedDays
                            .contains(
                          day,
                        );

                        return ChoiceChip(
                          label: Text(
                            day.substring(
                              0,
                              3,
                            ),
                          ),
                          selected:
                          selected,
                          selectedColor:
                          AppColors
                              .primary,
                          backgroundColor:
                          colors.surface,
                          side: BorderSide(
                            color: selected
                                ? AppColors
                                .primary
                                : colors
                                .outlineVariant,
                          ),
                          labelStyle:
                          theme
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                            color: selected
                                ? colors
                                .onPrimary
                                : colors
                                .onSurface,
                            fontWeight:
                            FontWeight
                                .w700,
                          ),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              12,
                            ),
                          ),
                          onSelected: (_) {
                            controller
                                .toggleDay(
                              day,
                            );
                          },
                        );
                      },
                    )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ----------------------------------------------------------------
          // WORKING HOURS
          // ----------------------------------------------------------------

          _AvailabilitySectionCard(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Working hours',
                  style: theme
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    color:
                    colors.onSurface,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Choose the time range for appointments.',
                  style: theme
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color:
                    colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Obx(
                            () => _TimeCard(
                          title: 'Start time',
                          value: controller
                              .startTime
                              .value
                              .isEmpty
                              ? 'Select'
                              : controller
                              .startTime
                              .value,
                          icon: Icons
                              .play_circle_outline_rounded,
                          onTap: () =>
                              controller
                                  .pickStart(
                                context,
                              ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Obx(
                            () => _TimeCard(
                          title: 'End time',
                          value: controller
                              .endTime
                              .value
                              .isEmpty
                              ? 'Select'
                              : controller
                              .endTime
                              .value,
                          icon: Icons
                              .stop_circle_outlined,
                          onTap: () =>
                              controller
                                  .pickEnd(
                                context,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Obx(
                () => PrimaryButton(
              label: 'Save availability',
              loading:
              controller.saving.value,
              onPressed: controller.save,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// STAT CARD
// ============================================================================

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: colors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 19,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style: theme
                .textTheme
                .headlineSmall
                ?.copyWith(
              color: colors.onSurface,
              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,
            style: theme
                .textTheme
                .bodySmall
                ?.copyWith(
              color:
              colors.onSurfaceVariant,
              fontWeight:
              FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// UPCOMING BOOKING
// ============================================================================

class _UpcomingBookingCard
    extends StatelessWidget {
  const _UpcomingBookingCard({
    required this.patientName,
    required this.date,
    required this.time,
    required this.status,
  });

  final String patientName;
  final String date;
  final String time;
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin:
      const EdgeInsets.only(bottom: 11),
      padding:
      const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color:
          colors.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          // Decorative image, NOT doctor profile
          Container(
            height: 50,
            width: 50,
            padding:
            const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color:
              AppColors.primarySoft,
              borderRadius:
              BorderRadius.circular(15),
            ),
            child: Image.asset(
              AppImages.doctorAvatar2,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: theme
                      .textTheme
                      .titleSmall
                      ?.copyWith(
                    color:
                    colors.onSurface,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    Icon(
                      Icons
                          .calendar_today_outlined,
                      size: 14,
                      color: colors
                          .onSurfaceVariant,
                    ),

                    const SizedBox(width: 5),

                    Flexible(
                      child: Text(
                        date,
                        style: theme
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color: colors
                              .onSurfaceVariant,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Icon(
                      Icons
                          .access_time_rounded,
                      size: 14,
                      color: colors
                          .onSurfaceVariant,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      time,
                      style: theme
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color: colors
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          StatusChip(
            status: status,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// APPOINTMENT CARD
// ============================================================================

class _AppointmentCard
    extends StatelessWidget {
  const _AppointmentCard({
    required this.patientName,
    required this.date,
    required this.time,
    required this.notes,
    required this.status,
    this.onDecline,
    this.onConfirm,
    this.onComplete,
  });

  final String patientName;
  final String date;
  final String time;
  final String notes;
  final String status;

  final VoidCallback? onDecline;
  final VoidCallback? onConfirm;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin:
      const EdgeInsets.only(bottom: 14),
      padding:
      const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius:
        BorderRadius.circular(21),
        border: Border.all(
          color:
          colors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 50,
                width: 50,
                padding:
                const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color:
                  AppColors.primarySoft,
                  borderRadius:
                  BorderRadius.circular(
                    15,
                  ),
                ),
                child: Image.asset(
                  AppImages.doctorAvatar2,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: theme
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        color:
                        colors.onSurface,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Patient appointment',
                      style: theme
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color: colors
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              StatusChip(
                status: status,
              ),
            ],
          ),

          const SizedBox(height: 17),

          Container(
            padding:
            const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: colors
                  .surfaceContainerHighest
                  .withValues(
                alpha: 0.45,
              ),
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _AppointmentInfo(
                    icon: Icons
                        .calendar_today_outlined,
                    value: date,
                  ),
                ),

                Container(
                  height: 28,
                  width: 1,
                  color:
                  colors.outlineVariant,
                ),

                Expanded(
                  child: _AppointmentInfo(
                    icon: Icons
                        .access_time_rounded,
                    value: time,
                  ),
                ),
              ],
            ),
          ),

          if (notes.isNotEmpty) ...[
            const SizedBox(height: 14),

            Text(
              'Patient notes',
              style: theme
                  .textTheme
                  .labelLarge
                  ?.copyWith(
                color:
                colors.onSurface,
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              notes,
              style: theme
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                color:
                colors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],

          if (status == 'pending') ...[
            const SizedBox(height: 17),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                    onDecline,
                    style: OutlinedButton
                        .styleFrom(
                      minimumSize:
                      const Size
                          .fromHeight(
                        46,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                          13,
                        ),
                      ),
                    ),
                    child:
                    const Text(
                      'Decline',
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed:
                    onConfirm,
                    style: ElevatedButton
                        .styleFrom(
                      backgroundColor:
                      AppColors.primary,
                      foregroundColor:
                      colors.onPrimary,
                      minimumSize:
                      const Size
                          .fromHeight(
                        46,
                      ),
                      elevation: 0,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                          13,
                        ),
                      ),
                    ),
                    child:
                    const Text(
                      'Confirm',
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (status == 'confirmed')
            Align(
              alignment:
              Alignment.centerRight,
              child: TextButton.icon(
                onPressed:
                onComplete,
                icon: const Icon(
                  Icons
                      .task_alt_rounded,
                  size: 18,
                ),
                label: const Text(
                  'Mark completed',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// APPOINTMENT INFO
// ============================================================================

class _AppointmentInfo
    extends StatelessWidget {
  const _AppointmentInfo({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 17,
        ),

        const SizedBox(width: 7),

        Flexible(
          child: Text(
            value,
            overflow:
            TextOverflow.ellipsis,
            style: theme
                .textTheme
                .bodySmall
                ?.copyWith(
              color:
              colors.onSurface,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// AVAILABILITY SECTION
// ============================================================================

class _AvailabilitySectionCard
    extends StatelessWidget {
  const _AvailabilitySectionCard({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    return Container(
      padding:
      const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color:
          colors.outlineVariant,
        ),
      ),
      child: child,
    );
  }
}

// ============================================================================
// TIME CARD
// ============================================================================

class _TimeCard
    extends StatelessWidget {
  const _TimeCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surface,
      borderRadius:
      BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(16),
        child: Container(
          padding:
          const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(16),
            border: Border.all(
              color:
              colors.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color:
                    AppColors.primary,
                    size: 20,
                  ),

                  const SizedBox(width: 7),

                  Expanded(
                    child: Text(
                      title,
                      style: theme
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color: colors
                            .onSurfaceVariant,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                value,
                style: theme
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                  color:
                  colors.onSurface,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// EMPTY STATE
// ============================================================================

class _ModernEmptyState
    extends StatelessWidget {
  const _ModernEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Container(
        margin:
        const EdgeInsets.all(20),
        padding:
        const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 40,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius:
          BorderRadius.circular(22),
          border: Border.all(
            color:
            colors.outlineVariant,
          ),
        ),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color:
                AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color:
                AppColors.primary,
                size: 30,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              title,
              textAlign:
              TextAlign.center,
              style: theme
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                color:
                colors.onSurface,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              subtitle,
              textAlign:
              TextAlign.center,
              style: theme
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                color:
                colors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}