import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _authService = AuthService();

  String _formatCreatedAt(dynamic value) {
    try {
      DateTime? dt;
      if (value is Timestamp) {
        dt = value.toDate();
      } else if (value is DateTime) {
        dt = value;
      } else if (value is String) {
        dt = DateTime.tryParse(value);
      }
      if (dt == null) return '-';
      return DateFormat('d MMM y HH:mm', 'th').format(dt.toLocal());
    } catch (_) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6D83F2), Color(0xFF8E54E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('หน้าหลัก'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () async {
                await _authService.signOut();
              },
              icon: const Icon(Icons.logout),
              tooltip: 'Sign out',
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: colorScheme.primary.withOpacity(
                              0.15,
                            ),
                            child: Text(
                              (user?.displayName?.isNotEmpty == true
                                      ? user!.displayName!.characters.first
                                      : (user?.email?.characters.first ?? '?'))
                                  .toUpperCase(),
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.displayName ?? 'ผู้ใช้งาน',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.email ?? '-',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          if (user?.emailVerified == true)
                            Chip(
                              label: const Text('Verified'),
                              avatar: const Icon(
                                Icons.verified,
                                color: Colors.white,
                                size: 18,
                              ),
                              backgroundColor: Colors.green,
                              labelStyle: const TextStyle(color: Colors.white),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            )
                          else
                            Chip(
                              label: const Text('Unverified'),
                              avatar: const Icon(
                                Icons.mark_email_unread,
                                color: Colors.white,
                                size: 18,
                              ),
                              backgroundColor: Colors.orange,
                              labelStyle: const TextStyle(color: Colors.white),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      if (user != null)
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: _firestore
                              .collection('users')
                              .doc(user.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return _InfoSection(
                                title: 'โปรไฟล์',
                                children: const [
                                  _InfoRow(label: 'Display name', value: '-'),
                                  _InfoRow(label: 'Created at', value: '-'),
                                ],
                              );
                            }
                            final data = snapshot.data!.data() ?? {};
                            final createdAt = _formatCreatedAt(
                              data['createdAt'],
                            );
                            return _InfoSection(
                              title: 'โปรไฟล์',
                              children: [
                                _InfoRow(
                                  label: 'Display name',
                                  value: (data['displayName'] ?? '-') as String,
                                ),
                                _InfoRow(label: 'Created at', value: createdAt),
                              ],
                            );
                          },
                        )
                      else
                        const Text('Not signed in'),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 46,
                        child: FilledButton.icon(
                          onPressed: () async {
                            await _authService.signOut();
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('ออกจากระบบ'),
                          style: ButtonStyle(
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(value),
            ),
          ),
        ],
      ),
    );
  }
}
