import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'api_service.dart';
import 'opportunity.dart';
import 'detail_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Opportunity> _opportunities = [];
  bool _loading = true;
  String _selectedType = 'all';
  Map<String, dynamic>? _profile;

  final List<Map<String, String>> _categories = [
    {'id': 'all', 'label': 'All'},
    {'id': 'jobs', 'label': 'Jobs'},
    {'id': 'internships', 'label': 'Internships'},
    {'id': 'hackathons', 'label': 'Hackathons'},
    {'id': 'scholarships', 'label': 'Scholarships'},
    {'id': 'govt', 'label': 'Govt'},
    {'id': 'startup', 'label': 'Startup'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final profile = await ApiService.getProfile(uid);
      if (mounted) setState(() => _profile = profile);
    }
    await _loadOpportunities();
  }

  Future<void> _loadOpportunities() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getOpportunities(type: _selectedType);
      if (mounted) {
        setState(() {
          _opportunities = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _firstName {
    final name = _profile?['fullName'] as String? ??
        FirebaseAuth.instance.currentUser?.displayName ??
        'Student';
    return name.split(' ').first;
  }

  String? get _photoUrl =>
      _profile?['photoUrl'] as String? ??
      FirebaseAuth.instance.currentUser?.photoURL;

  Widget _buildCategoryIcon(String type) {
    final map = {
      'jobs': Icons.work_outline,
      'internships': Icons.school_outlined,
      'hackathons': Icons.emoji_events_outlined,
      'scholarships': Icons.card_giftcard_outlined,
      'govt': Icons.account_balance_outlined,
      'startup': Icons.rocket_launch_outlined,
      'all': Icons.grid_view_rounded,
    };
    return Icon(map[type] ?? Icons.work_outline,
        color: const Color(0xFF16213B), size: 18);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Container(
              color: const Color(0xFF16213B),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Namaste, $_firstName 👋',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _profile?['desiredRole'] as String? ??
                              'Find your opportunity in Telangana',
                          style: const TextStyle(
                              color: Color(0xFF8A9BB5), fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Profile avatar button
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProfileScreen(profile: _profile),
                        ),
                      );
                      _loadAll();
                    },
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE2A33B),
                        border: Border.all(
                            color: const Color(0xFFE2A33B), width: 2),
                        image: _photoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_photoUrl!),
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                              )
                            : null,
                      ),
                      child: _photoUrl == null
                          ? Center(
                              child: Text(
                                _firstName.isNotEmpty
                                    ? _firstName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                    color: Color(0xFF16213B),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18),
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),

            // ── Search bar ──
            Container(
              color: const Color(0xFF16213B),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2F4D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 14),
                    Icon(Icons.search, color: Color(0xFF8A9BB5), size: 18),
                    SizedBox(width: 8),
                    Text('Search jobs, internships, hackathons...',
                        style: TextStyle(
                            color: Color(0xFF4A5568), fontSize: 13)),
                  ],
                ),
              ),
            ),

            // ── Category filter ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: _categories.map((cat) {
                    final active = _selectedType == cat['id'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedType = cat['id']!);
                          _loadOpportunities();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(0xFF16213B)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              if (active) ...[
                                Icon(
                                  _categories
                                      .firstWhere((c) =>
                                          c['id'] == _selectedType)
                                      .let((c) => {
                                            'jobs': Icons.work_outline,
                                            'internships':
                                                Icons.school_outlined,
                                            'hackathons':
                                                Icons.emoji_events_outlined,
                                            'scholarships':
                                                Icons.card_giftcard_outlined,
                                            'govt':
                                                Icons.account_balance_outlined,
                                            'startup':
                                                Icons.rocket_launch_outlined,
                                            'all': Icons.grid_view_rounded,
                                          }[c['id']] ??
                                          Icons.work_outline),
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 5),
                              ],
                              Text(
                                cat['label']!,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: active
                                        ? Colors.white
                                        : const Color(0xFF374151)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // ── Count ──
            if (!_loading)
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Row(
                  children: [
                    Text(
                      '${_opportunities.length} opportunities',
                      style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

            // ── List ──
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF16213B)))
                  : _opportunities.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.work_off_outlined,
                                  size: 52,
                                  color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              const Text('No opportunities found',
                                  style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 15)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          itemCount: _opportunities.length,
                          itemBuilder: (context, index) {
                            final opp = _opportunities[index];
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        DetailScreen(opp: opp)),
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: const Color(0xFFE5E7EB)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 46,
                                          height: 46,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEEF2FF),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                              child: _buildCategoryIcon(
                                                  opp.type)),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(opp.title,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 14,
                                                      color:
                                                          Color(0xFF111827))),
                                              const SizedBox(height: 2),
                                              Text(opp.org,
                                                  style: const TextStyle(
                                                      color:
                                                          Color(0xFF6B7280),
                                                      fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        if (opp.urgent)
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3),
                                            decoration: BoxDecoration(
                                              color:
                                                  const Color(0xFFFEF2F2),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Text('Urgent',
                                                style: TextStyle(
                                                    color:
                                                        Color(0xFFEF4444),
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(
                                        height: 1,
                                        color: Color(0xFFF3F4F6)),
                                    const SizedBox(height: 10),
                                    Row(children: [
                                      const Icon(
                                          Icons.location_on_outlined,
                                          size: 14,
                                          color: Color(0xFF9CA3AF)),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(opp.location,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF6B7280)),
                                            overflow:
                                                TextOverflow.ellipsis),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0FDF4),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(opp.money,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF16A34A),
                                                fontWeight:
                                                    FontWeight.w600)),
                                      ),
                                    ]),
                                    const SizedBox(height: 8),
                                    Row(children: [
                                      Icon(Icons.access_time,
                                          size: 13,
                                          color: opp.urgent
                                              ? const Color(0xFFEF4444)
                                              : const Color(0xFF9CA3AF)),
                                      const SizedBox(width: 4),
                                      Text(opp.deadline,
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: opp.urgent
                                                  ? const Color(0xFFEF4444)
                                                  : const Color(0xFF9CA3AF),
                                              fontWeight: opp.urgent
                                                  ? FontWeight.w600
                                                  : FontWeight.w400)),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF2FF),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          opp.type
                                              .substring(0, 1)
                                              .toUpperCase() +
                                              opp.type.substring(1),
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF16213B),
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ]),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) block) => block(this);
}