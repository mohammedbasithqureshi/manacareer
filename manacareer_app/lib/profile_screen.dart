import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic>? profile;
  const ProfileScreen({super.key, this.profile});

  @override
  Widget build(BuildContext context) {
    final photoUrl = profile?['photoUrl'] as String? ??
        FirebaseAuth.instance.currentUser?.photoURL;
    final name = profile?['fullName'] as String? ??
        FirebaseAuth.instance.currentUser?.displayName ??
        'Student';
    final email = profile?['email'] as String? ??
        FirebaseAuth.instance.currentUser?.email ??
        '';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213B),
        foregroundColor: Colors.white,
        title: const Text('My Profile',
            style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditProfileScreen(profile: profile),
              ),
            ),
            icon: const Icon(Icons.edit_outlined,
                color: Color(0xFFE2A33B), size: 18),
            label: const Text('Edit',
                style: TextStyle(
                    color: Color(0xFFE2A33B),
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Hero header ──
            Container(
              width: double.infinity,
              color: const Color(0xFF16213B),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Column(
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE2A33B),
                      border: Border.all(
                          color: const Color(0xFFE2A33B), width: 3),
                      image: photoUrl != null
                          ? DecorationImage(
                              image: NetworkImage(photoUrl),
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            )
                          : null,
                    ),
                    child: photoUrl == null
                        ? Center(
                            child: Text(
                              name.isNotEmpty
                                  ? name[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                  color: Color(0xFF16213B),
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(email,
                      style: const TextStyle(
                          color: Color(0xFF8A9BB5), fontSize: 13)),
                  if (profile?['desiredRole'] != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2A33B).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFE2A33B).withOpacity(0.4)),
                      ),
                      child: Text(profile!['desiredRole'],
                          style: const TextStyle(
                              color: Color(0xFFE2A33B),
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                  const SizedBox(height: 10),
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _stat(profile?['district'] ?? 'Telangana',
                          Icons.location_on_outlined),
                      const SizedBox(width: 20),
                      _stat(profile?['currentStatus'] ?? 'Student',
                          Icons.badge_outlined),
                      const SizedBox(width: 20),
                      _stat(profile?['yearOfPassing'] ?? '2026',
                          Icons.school_outlined),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _section('Personal Details', [
                    _row(Icons.phone_outlined, 'Phone',
                        profile?['phone'] ?? 'Not added'),
                    _row(Icons.cake_outlined, 'Date of Birth',
                        profile?['dateOfBirth'] ?? 'Not added'),
                    _row(Icons.person_outline, 'Gender',
                        profile?['gender'] ?? 'Not added'),
                  ]),
                  const SizedBox(height: 12),
                  _section('Location', [
                    _row(Icons.location_city_outlined, 'District',
                        profile?['district'] ?? 'Not added'),
                    _row(Icons.map_outlined, 'Mandal',
                        profile?['mandal'] ?? 'Not added'),
                    _row(Icons.place_outlined, 'Village/Area',
                        profile?['village']?.isNotEmpty == true
                            ? profile!['village']
                            : 'Not added'),
                  ]),
                  const SizedBox(height: 12),
                  _section('Education', [
                    _row(Icons.school_outlined, 'College',
                        profile?['collegeName'] ?? 'Not added'),
                    _row(Icons.book_outlined, 'Branch',
                        profile?['branch'] ?? 'Not added'),
                    _row(Icons.calendar_today_outlined, 'Year of Passing',
                        profile?['yearOfPassing'] ?? 'Not added'),
                    _row(Icons.grade_outlined, 'CGPA / %',
                        profile?['cgpa']?.isNotEmpty == true
                            ? profile!['cgpa']
                            : 'Not added'),
                  ]),
                  const SizedBox(height: 12),
                  _section('Career', [
                    _row(Icons.badge_outlined, 'Current Status',
                        profile?['currentStatus'] ?? 'Not added'),
                    _row(Icons.work_outline, 'Desired Role',
                        profile?['desiredRole'] ?? 'Not added'),
                    _row(Icons.currency_rupee, 'Expected Salary',
                        profile?['expectedSalary'] ?? 'Not added'),
                    _row(Icons.link, 'LinkedIn',
                        profile?['linkedinUrl']?.isNotEmpty == true
                            ? profile!['linkedinUrl']
                            : 'Not added'),
                    _row(Icons.picture_as_pdf_outlined, 'Resume',
                        profile?['resumeUrl'] != null ? 'Uploaded' : 'Not uploaded'),
                  ]),
                  if (profile?['skills'] != null &&
                      (profile!['skills'] as List).isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Skills',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Color(0xFF111827))),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                (profile!['skills'] as List).map((s) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(s.toString(),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF16213B),
                                        fontWeight: FontWeight.w500)),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  // Edit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit_outlined,
                          color: Colors.white, size: 18),
                      label: const Text('Update Profile',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditProfileScreen(profile: profile),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16213B),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Sign out
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout,
                          color: Color(0xFFEF4444), size: 18),
                      label: const Text('Sign Out',
                          style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.w600)),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(
                            color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, IconData icon) {
    return Row(children: [
      Icon(icon, color: const Color(0xFF8A9BB5), size: 14),
      const SizedBox(width: 4),
      Text(label,
          style: const TextStyle(color: Color(0xFF8A9BB5), fontSize: 12)),
    ]);
  }

  Widget _section(String title, List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF111827))),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    color: Color(0xFF6B7280), fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}