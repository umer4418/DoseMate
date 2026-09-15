import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../controllers/chat_list_controller.dart';

enum ChatPeopleMode { mixed, doctors, patients }

class PeopleChatView extends GetView<ChatListController> {
  const PeopleChatView({super.key, this.mode = ChatPeopleMode.mixed});

  final ChatPeopleMode mode;

  @override
  Widget build(BuildContext context) {
    final showDoctors = mode != ChatPeopleMode.patients;
    final showPatients = mode != ChatPeopleMode.doctors;

    final tabLength = 1 + (showDoctors ? 1 : 0) + (showPatients ? 1 : 0);

    return DefaultTabController(
      length: tabLength,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F8FC),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(.10),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.forum_rounded,
                            color: AppColors.primary,
                            size: 25,
                          ),
                        ),

                        const SizedBox(width: 13),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mode == ChatPeopleMode.doctors
                                    ? 'Doctor chats'
                                    : 'Live chat',
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkText,
                                ),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                mode == ChatPeopleMode.doctors
                                    ? 'Connect with healthcare professionals'
                                    : 'Connect with doctors and people',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F6FA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: AppColors.secondaryText,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        dividerColor: Colors.transparent,
                        tabs: [
                          const Tab(
                            icon: Icon(Icons.chat_bubble_outline, size: 17),
                            text: 'Inbox',
                          ),

                          if (showDoctors)
                            const Tab(
                              icon: Icon(
                                Icons.medical_services_outlined,
                                size: 17,
                              ),
                              text: 'Doctors',
                            ),

                          if (showPatients)
                            const Tab(
                              icon: Icon(Icons.people_outline, size: 17),
                              text: 'People',
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    const _InboxTab(),

                    if (showDoctors) const _PeopleTab(role: 'doctor'),

                    if (showPatients) const _PeopleTab(role: 'patient'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InboxTab extends GetView<ChatListController> {
  const _InboxTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final chats = [...controller.chats]
        ..sort(
          (a, b) => (b.updatedAt ?? DateTime(0)).compareTo(
            a.updatedAt ?? DateTime(0),
          ),
        );

      if (chats.isEmpty) {
        return const _EmptyChatState();
      }

      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];

          final otherId = chat.participants.firstWhere(
            (id) => id != controller.me?.uid,
            orElse: () => '',
          );

          final other = controller.users.firstWhereOrNull(
            (u) => u.uid == otherId,
          );

          return _ChatCard(
            name: other?.name ?? 'DoseMate user',
            user: other,
            message: chat.lastMessage.isEmpty
                ? 'No messages yet'
                : chat.lastMessage,
            type: chat.type == 'doctor' ? 'Doctor' : 'Peer',
            isDoctor: chat.type == 'doctor',
            onTap: other == null ? null : () => controller.openChat(other),
          );
        },
      );
    });
  }
}

class _ChatCard extends StatelessWidget {
  const _ChatCard({
    required this.name,
    required this.user,
    required this.message,
    required this.type,
    required this.isDoctor,
    required this.onTap,
  });

  final String name;
  final dynamic user;
  final String message;
  final String type;
  final bool isDoctor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.02),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDoctor
                            ? AppColors.primary.withOpacity(.35)
                            : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: UserAvatar(user: user, name: name),
                  ),

                  if (isDoctor)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 19,
                        height: 19,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 11,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkText,
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDoctor
                                ? AppColors.primary.withOpacity(.09)
                                : const Color(0xFFF1F3F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              color: isDoctor
                                  ? AppColors.primary
                                  : AppColors.secondaryText,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 7),

              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeopleTab extends GetView<ChatListController> {
  const _PeopleTab({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.02),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) => controller.query.value = value,
              decoration: InputDecoration(
                hintText: 'Search ${role == 'doctor' ? 'doctors' : 'people'}',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(17),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(17),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(17),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            final people = controller.filtered(role: role);

            if (people.isEmpty) {
              return _EmptyPeopleState(role: role);
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
              itemCount: people.length,
              itemBuilder: (context, index) {
                final user = people[index];

                return _PersonCard(
                  user: user,
                  role: role,
                  onTap: () => controller.openChat(user),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.user,
    required this.role,
    required this.onTap,
  });

  final dynamic user;
  final String role;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDoctor = role == 'doctor';

    final subtitle = user.isDoctor
        ? (user.specialization.isEmpty ? 'Doctor' : user.specialization)
        : user.email;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.only(bottom: 11),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDoctor
                        ? AppColors.primary.withOpacity(.30)
                        : AppColors.border,
                    width: 2,
                  ),
                ),
                child: UserAvatar(user: user),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkText,
                            ),
                          ),
                        ),

                        if (isDoctor)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(.09),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Doctor',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.primary,
                  size: 19,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(.09),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.forum_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No conversations yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Start a conversation with a doctor or another DoseMate user.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryText, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPeopleState extends StatelessWidget {
  const _EmptyPeopleState({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final isDoctor = role == 'doctor';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 95,
              height: 95,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDoctor
                    ? Icons.medical_services_outlined
                    : Icons.people_outline_rounded,
                size: 45,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              isDoctor ? 'No doctors available' : 'Nobody here yet',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              isDoctor
                  ? 'Doctors will appear here once they join DoseMate.'
                  : 'Other patients will appear here once they sign up.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.secondaryText,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
