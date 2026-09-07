import 'package:collection/collection.dart';
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

    return DefaultTabController(
      length: 1 + (showDoctors ? 1 : 0) + (showPatients ? 1 : 0),
      child: Scaffold(
        appBar: AppBar(
          title: Text(mode == ChatPeopleMode.doctors ? 'Doctor chats' : 'Live chat'),
          bottom: TabBar(
            tabs: [
              const Tab(text: 'Inbox'),
              if (showDoctors) const Tab(text: 'Doctors'),
              if (showPatients) const Tab(text: 'People'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _InboxTab(),
            if (showDoctors) const _PeopleTab(role: 'doctor'),
            if (showPatients) const _PeopleTab(role: 'patient'),
          ],
        ),
      ),
    );
  }
}

class _InboxTab extends GetView<ChatListController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final chats = [...controller.chats]
        ..sort((a, b) => (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)));
      if (chats.isEmpty) {
        return const EmptyState(
          icon: Icons.chat_bubble_outline,
          title: 'No conversations',
          subtitle: 'Start a live chat with a patient or doctor.',
        );
      }
      return ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          final otherId = chat.participants.firstWhere(
            (id) => id != controller.me?.uid,
            orElse: () => '',
          );
          final other = controller.users.firstWhereOrNull((u) => u.uid == otherId);
          return ListTile(
            leading: UserAvatar(user: other, name: other?.name ?? 'User'),
            title: Text(other?.name ?? 'DoseMate user', style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(
              chat.lastMessage.isEmpty ? 'No messages yet' : chat.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              chat.type == 'doctor' ? 'Doctor' : 'Peer',
              style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
            ),
            onTap: other == null ? null : () => controller.openChat(other),
          );
        },
      );
    });
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
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: (v) => controller.query.value = v,
            decoration: InputDecoration(
              hintText: 'Search ${role == 'doctor' ? 'doctors' : 'people'}',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            final people = controller.filtered(role: role);
            if (people.isEmpty) {
              return EmptyState(
                icon: Icons.people_outline,
                title: 'Nobody here yet',
                subtitle: 'Other ${role == 'doctor' ? 'doctors' : 'patients'} will show up after they sign up.',
              );
            }
            return ListView.builder(
              itemCount: people.length,
              itemBuilder: (context, index) {
                final user = people[index];
                return ListTile(
                  leading: UserAvatar(user: user),
                  title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    user.isDoctor
                        ? (user.specialization.isEmpty ? 'Doctor' : user.specialization)
                        : user.email,
                  ),
                  trailing: const Icon(Icons.chevron_right),
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
