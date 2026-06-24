import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import 'api_service.dart';
import 'data/telangana_data.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? profile;
  const EditProfileScreen({super.key, this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _loading = false;
  String? _error;
  String? _success;

  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _mandalCtrl;
  late TextEditingController _villageCtrl;
  late TextEditingController _cgpaCtrl;
  late TextEditingController _linkedinCtrl;
  late TextEditingController _desiredRoleCtrl;
  late TextEditingController _collegeOtherCtrl;
  late TextEditingController _branchOtherCtrl;

  late String _district;
  late String _college;
  late String _branch;
  late String _yearOfPassing;
  late String _currentStatus;
  late String _expectedSalary;
  late String _gender;
  late List<String> _selectedSkills;

  Uint8List? _photoBytes;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    final p = widget.profile ?? {};
    _nameCtrl = TextEditingController(text: p['fullName'] ?? '');
    _phoneCtrl = TextEditingController(text: p['phone'] ?? '');
    _mandalCtrl = TextEditingController(text: p['mandal'] ?? '');
    _villageCtrl = TextEditingController(text: p['village'] ?? '');
    _cgpaCtrl = TextEditingController(text: p['cgpa'] ?? '');
    _linkedinCtrl = TextEditingController(text: p['linkedinUrl'] ?? '');
    _desiredRoleCtrl = TextEditingController(text: p['desiredRole'] ?? '');
    _collegeOtherCtrl = TextEditingController();
    _branchOtherCtrl = TextEditingController();
    _district = p['district'] ?? TelanganaData.districts.first;
    _college = TelanganaData.colleges.contains(p['collegeName'])
        ? p['collegeName']
        : TelanganaData.colleges.first;
    _branch = TelanganaData.branches.contains(p['branch'])
        ? p['branch']
        : TelanganaData.branches.first;
    _yearOfPassing = p['yearOfPassing'] ?? '2026';
    _currentStatus = p['currentStatus'] ?? 'Student';
    _expectedSalary = p['expectedSalary'] ?? '3-5 LPA';
    _gender = p['gender'] ?? 'Male';
    _selectedSkills = List<String>.from(p['skills'] ?? []);
    _photoUrl = p['photoUrl'];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _mandalCtrl.dispose();
    _villageCtrl.dispose();
    _cgpaCtrl.dispose();
    _linkedinCtrl.dispose();
    _desiredRoleCtrl.dispose();
    _collegeOtherCtrl.dispose();
    _branchOtherCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
        source: ImageSource.gallery, maxWidth: 400, maxHeight: 400, imageQuality: 85);
    if (img == null) return;
    final bytes = await img.readAsBytes();
    setState(() => _photoBytes = bytes);
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Name cannot be empty');
      return;
    }
    setState(() { _loading = true; _error = null; _success = null; });
    try {
      if (_photoBytes != null) {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        final path = 'avatars/$uid.jpg';
        await supabase.storage.from('avatars').uploadBinary(path, _photoBytes!,
            fileOptions: FileOptions(upsert: true, contentType: 'image/jpeg'));
        _photoUrl = supabase.storage.from('avatars').getPublicUrl(path);
      }
      final user = FirebaseAuth.instance.currentUser!;
      final updated = {
        ...widget.profile ?? {},
        'firebaseUid': user.uid,
        'fullName': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'gender': _gender,
        'photoUrl': _photoUrl,
        'district': _district,
        'mandal': _mandalCtrl.text.trim(),
        'village': _villageCtrl.text.trim(),
        'collegeName': _college == 'Others' ? _collegeOtherCtrl.text.trim() : _college,
        'branch': _branch == 'Others' ? _branchOtherCtrl.text.trim() : _branch,
        'yearOfPassing': _yearOfPassing,
        'cgpa': _cgpaCtrl.text.trim(),
        'currentStatus': _currentStatus,
        'skills': _selectedSkills,
        'linkedinUrl': _linkedinCtrl.text.trim(),
        'desiredRole': _desiredRoleCtrl.text.trim(),
        'expectedSalary': _expectedSalary,
        'profileComplete': true,
      };
      final success = await ApiService.saveProfile(updated);
      if (success && mounted) {
        setState(() { _success = 'Profile updated successfully!'; _loading = false; });
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context);
      } else {
        setState(() { _error = 'Update failed. Try again.'; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = 'Error: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213B),
        foregroundColor: Colors.white,
        title: const Text('Edit Profile',
            style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Save',
                    style: TextStyle(color: Color(0xFFE2A33B),
                        fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) _banner(_error!, isError: true),
            if (_success != null) _banner(_success!, isError: false),
            if (_error != null || _success != null) const SizedBox(height: 12),

            // Photo
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Stack(children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE5E7EB),
                      image: _photoBytes != null
                          ? DecorationImage(image: MemoryImage(_photoBytes!),
                              fit: BoxFit.cover, alignment: Alignment.topCenter)
                          : _photoUrl != null
                              ? DecorationImage(image: NetworkImage(_photoUrl!),
                                  fit: BoxFit.cover, alignment: Alignment.topCenter)
                              : null,
                    ),
                    child: (_photoBytes == null && _photoUrl == null)
                        ? const Icon(Icons.person, size: 50, color: Color(0xFF9CA3AF))
                        : null,
                  ),
                  Positioned(bottom: 2, right: 2,
                    child: Container(
                      width: 30, height: 30,
                      decoration: const BoxDecoration(
                          color: Color(0xFF16213B), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 15),
                    )),
                ]),
              ),
            ),
            const SizedBox(height: 6),
            const Center(child: Text('Tap to change photo',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12))),
            const SizedBox(height: 24),

            _label('Full Name *'),
            _field(_nameCtrl, 'Full name', icon: Icons.person_outline),
            const SizedBox(height: 14),
            _label('Phone Number'),
            _field(_phoneCtrl, '10-digit mobile', icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 14),
            _label('Gender'),
            _chips(['Male', 'Female', 'Prefer not to say'], _gender,
                (v) => setState(() => _gender = v)),
            const SizedBox(height: 14),
            _label('District'),
            _dropdown(TelanganaData.districts, _district,
                (v) => setState(() => _district = v!)),
            const SizedBox(height: 14),
            _label('Mandal / Town'),
            _field(_mandalCtrl, 'e.g. Uppal, Warangal Urban'),
            const SizedBox(height: 14),
            _label('Village / Area'),
            _field(_villageCtrl, 'e.g. Nacharam'),
            const SizedBox(height: 14),
            _label('College'),
            _dropdown(TelanganaData.colleges, _college,
                (v) => setState(() => _college = v!)),
            if (_college == 'Others') ...[
              const SizedBox(height: 10),
              _field(_collegeOtherCtrl, 'Enter college name'),
            ],
            const SizedBox(height: 14),
            _label('Branch'),
            _dropdown(TelanganaData.branches, _branch,
                (v) => setState(() => _branch = v!)),
            if (_branch == 'Others') ...[
              const SizedBox(height: 10),
              _field(_branchOtherCtrl, 'Enter branch name'),
            ],
            const SizedBox(height: 14),
            _label('Year of Passing'),
            _dropdown(
                ['2020','2021','2022','2023','2024','2025','2026','2027','2028','2029','2030'],
                _yearOfPassing, (v) => setState(() => _yearOfPassing = v!)),
            const SizedBox(height: 14),
            _label('CGPA / Percentage'),
            _field(_cgpaCtrl, 'e.g. 8.2 or 78%', icon: Icons.school_outlined),
            const SizedBox(height: 14),
            _label('Current Status'),
            _chips(['Student', 'Fresher', 'Working', 'Internship'],
                _currentStatus, (v) => setState(() => _currentStatus = v)),
            const SizedBox(height: 14),
            _label('Skills'),
            Wrap(spacing: 8, runSpacing: 8,
              children: TelanganaData.skills.map((s) {
                final selected = _selectedSkills.contains(s);
                return GestureDetector(
                  onTap: () => setState(() => selected
                      ? _selectedSkills.remove(s) : _selectedSkills.add(s)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF16213B) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected
                          ? const Color(0xFF16213B) : const Color(0xFFE5E7EB)),
                    ),
                    child: Text(s, style: TextStyle(fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: selected ? Colors.white : const Color(0xFF374151))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            _label('Desired Job Role'),
            _field(_desiredRoleCtrl, 'e.g. Software Engineer', icon: Icons.work_outline),
            const SizedBox(height: 14),
            _label('Expected Salary'),
            _dropdown(['Below 3 LPA','3-5 LPA','5-8 LPA','8-12 LPA','12-20 LPA','20+ LPA'],
                _expectedSalary, (v) => setState(() => _expectedSalary = v!)),
            const SizedBox(height: 14),
            _label('LinkedIn URL'),
            _field(_linkedinCtrl, 'https://linkedin.com/in/yourname', icon: Icons.link),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16213B),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save Changes',
                        style: TextStyle(color: Colors.white,
                            fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _banner(String msg, {required bool isError}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isError ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0)),
      ),
      child: Row(children: [
        Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? const Color(0xFFEF4444) : const Color(0xFF22C55E), size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(msg, style: TextStyle(
            color: isError ? const Color(0xFFB91C1C) : const Color(0xFF15803D), fontSize: 12.5))),
      ]),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(color: Color(0xFF374151),
        fontSize: 13, fontWeight: FontWeight.w600)),
  );

  Widget _field(TextEditingController ctrl, String hint,
      {IconData? icon, TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFF111827), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 13),
        prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF9CA3AF), size: 18) : null,
        filled: true, fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF16213B), width: 1.5)),
      ),
    );
  }

  Widget _dropdown(List<String> items, String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB))),
      child: DropdownButton<String>(
        value: value, isExpanded: true, underline: const SizedBox(),
        style: const TextStyle(color: Color(0xFF111827), fontSize: 13),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _chips(List<String> options, String? selected, ValueChanged<String> onTap) {
    return Wrap(spacing: 8, runSpacing: 8,
      children: options.map((o) {
        final active = o == selected;
        return GestureDetector(
          onTap: () => onTap(o),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: active ? const Color(0xFF16213B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: active ? const Color(0xFF16213B) : const Color(0xFFE5E7EB)),
            ),
            child: Text(o, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                color: active ? Colors.white : const Color(0xFF374151))),
          ),
        );
      }).toList(),
    );
  }
}