import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import 'api_service.dart';
import 'home_screen.dart';
import 'data/telangana_data.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});
  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int _step = 0;
  bool _loading = false;
  String? _error;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _dob;
  String? _gender;
  Uint8List? _photoBytes;
  String? _photoUrl;

  String _district = 'Hyderabad';
  final _mandalCtrl = TextEditingController();
  final _villageCtrl = TextEditingController();

  String _college =
      'JNTUH - Jawaharlal Nehru Technological University Hyderabad';
  final _collegeOtherCtrl = TextEditingController();
  String _branch = 'Computer Science Engineering';
  final _branchOtherCtrl = TextEditingController();
  String _yearOfPassing = '2026';
  final _cgpaCtrl = TextEditingController();

  String _currentStatus = 'Student';
  final List<String> _selectedSkills = [];
  String? _resumeUrl;
  String? _resumeName;
  final _linkedinCtrl = TextEditingController();
  final _desiredRoleCtrl = TextEditingController();
  String _expectedSalary = '3-5 LPA';

  final List<String> _stepLabels = [
    'Basic Info',
    'Location',
    'Education',
    'Career'
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _mandalCtrl.dispose();
    _villageCtrl.dispose();
    _collegeOtherCtrl.dispose();
    _branchOtherCtrl.dispose();
    _cgpaCtrl.dispose();
    _linkedinCtrl.dispose();
    _desiredRoleCtrl.dispose();
    super.dispose();
  }

  void _showError(String msg) =>
      setState(() {
        _error = msg;
        _loading = false;
      });

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 85,
    );
    if (img == null) return;
    final bytes = await img.readAsBytes();
    setState(() => _photoBytes = bytes);
  }

  Future<void> _uploadPhoto() async {
    if (_photoBytes == null) return;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final path = 'avatars/$uid.jpg';
    await supabase.storage.from('avatars').uploadBinary(
      path,
      _photoBytes!,
      fileOptions: FileOptions(upsert: true, contentType: 'image/jpeg'),
    );
    _photoUrl = supabase.storage.from('avatars').getPublicUrl(path);
  }

  Future<void> _pickResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final path = 'resumes/$uid.pdf';
      await supabase.storage.from('resumes').uploadBinary(
        path,
        file.bytes!,
        fileOptions:
            FileOptions(upsert: true, contentType: 'application/pdf'),
      );
      _resumeUrl =
          supabase.storage.from('resumes').getPublicUrl(path);
      setState(() {
        _resumeName = file.name;
        _loading = false;
      });
    } catch (e) {
      _showError('Resume upload failed: $e');
    }
  }

  bool _validateStep() {
    setState(() => _error = null);
    if (_step == 0) {
      if (_nameCtrl.text.trim().isEmpty) {
        _showError('Enter your full name');
        return false;
      }
      if (_gender == null) {
        _showError('Select your gender');
        return false;
      }
    }
    if (_step == 1) {
      if (_mandalCtrl.text.trim().isEmpty) {
        _showError('Enter your mandal or town');
        return false;
      }
    }
    if (_step == 2) {
      if (_college == 'Others' &&
          _collegeOtherCtrl.text.trim().isEmpty) {
        _showError('Enter your college name');
        return false;
      }
      if (_branch == 'Others' &&
          _branchOtherCtrl.text.trim().isEmpty) {
        _showError('Enter your branch name');
        return false;
      }
    }
    if (_step == 3) {
      if (_selectedSkills.isEmpty) {
        _showError('Select at least one skill');
        return false;
      }
      if (_desiredRoleCtrl.text.trim().isEmpty) {
        _showError('Enter your desired job role');
        return false;
      }
    }
    return true;
  }

  Future<void> _next() async {
    if (!_validateStep()) return;
    if (_step < 3) {
      setState(() => _step++);
    } else {
      await _submit();
    }
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_photoBytes != null) await _uploadPhoto();
      final user = FirebaseAuth.instance.currentUser!;
      final profile = {
        'firebaseUid': user.uid,
        'email': user.email ?? '',
        'fullName': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'dateOfBirth': _dob,
        'gender': _gender,
        'photoUrl': _photoUrl ?? user.photoURL,
        'district': _district,
        'mandal': _mandalCtrl.text.trim(),
        'village': _villageCtrl.text.trim(),
        'collegeName':
            _college == 'Others' ? _collegeOtherCtrl.text.trim() : _college,
        'branch':
            _branch == 'Others' ? _branchOtherCtrl.text.trim() : _branch,
        'yearOfPassing': _yearOfPassing,
        'cgpa': _cgpaCtrl.text.trim(),
        'currentStatus': _currentStatus,
        'skills': _selectedSkills,
        'resumeUrl': _resumeUrl,
        'linkedinUrl': _linkedinCtrl.text.trim(),
        'desiredRole': _desiredRoleCtrl.text.trim(),
        'expectedSalary': _expectedSalary,
        'profileComplete': true,
      };
      final success = await ApiService.saveProfile(profile);
      if (success && mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        _showError('Could not save profile. Check your connection.');
      }
    } catch (e) {
      _showError('Something went wrong: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Complete Your Profile',
          style: TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w700,
              fontSize: 17),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: (_step + 1) / 4,
            backgroundColor: const Color(0xFFE5E7EB),
            color: const Color(0xFF16213B),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: List.generate(_stepLabels.length, (i) {
                final done = i < _step;
                final active = i == _step;
                return Expanded(
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: done
                                  ? const Color(0xFF16213B)
                                  : active
                                      ? const Color(0xFFE2A33B)
                                      : const Color(0xFFE5E7EB),
                            ),
                            child: Center(
                              child: done
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 15)
                                  : Text(
                                      '${i + 1}',
                                      style: TextStyle(
                                          color: active
                                              ? const Color(0xFF16213B)
                                              : const Color(0xFF9CA3AF),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _stepLabels[i],
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: active
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: active
                                    ? const Color(0xFF16213B)
                                    : const Color(0xFF9CA3AF)),
                          ),
                        ],
                      ),
                      if (i < _stepLabels.length - 1)
                        Expanded(
                          child: Container(
                            height: 1.5,
                            color: done
                                ? const Color(0xFF16213B)
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: _buildStep(),
            ),
          ),
          if (_error != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(children: [
                  const Icon(Icons.error_outline,
                      color: Color(0xFFEF4444), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(_error!,
                          style: const TextStyle(
                              color: Color(0xFFB91C1C), fontSize: 12.5))),
                ]),
              ),
            ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Row(children: [
              if (_step > 0) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() {
                      _step--;
                      _error = null;
                    }),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Back',
                        style: TextStyle(
                            color: Color(0xFF374151),
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _loading ? null : _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16213B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(
                          _step == 3 ? 'Complete Profile' : 'Continue',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15),
                        ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _step1();
      case 1:
        return _step2();
      case 2:
        return _step3();
      case 3:
        return _step4();
      default:
        return const SizedBox();
    }
  }

  Widget _step1() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      Center(
        child: GestureDetector(
          onTap: _pickPhoto,
          child: Stack(children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE5E7EB),
                image: _photoBytes != null
                    ? DecorationImage(
                        image: MemoryImage(_photoBytes!),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      )
                    : null,
              ),
              child: _photoBytes == null
                  ? const Icon(Icons.person,
                      size: 54, color: Color(0xFF9CA3AF))
                  : null,
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                    color: Color(0xFF16213B), shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt,
                    color: Colors.white, size: 16),
              ),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 6),
      const Center(
        child: Text(
          'Upload a clear face photo',
          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
        ),
      ),
      const SizedBox(height: 24),
      _label('Full Name *'),
      _field(_nameCtrl, 'e.g. Praneeth Reddy', icon: Icons.person_outline),
      const SizedBox(height: 16),
      _label('Phone Number'),
      _field(_phoneCtrl, '10-digit mobile number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone),
      const SizedBox(height: 16),
      _label('Date of Birth'),
      GestureDetector(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime(2002),
            firstDate: DateTime(1970),
            lastDate: DateTime(2008),
          );
          if (date != null) {
            setState(
                () => _dob = '${date.day}/${date.month}/${date.year}');
          }
        },
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(children: [
            const Icon(Icons.calendar_today_outlined,
                color: Color(0xFF9CA3AF), size: 18),
            const SizedBox(width: 10),
            Text(
              _dob ?? 'Select date of birth',
              style: TextStyle(
                  color: _dob == null
                      ? const Color(0xFFD1D5DB)
                      : const Color(0xFF111827),
                  fontSize: 14),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      _label('Gender *'),
      _chips(['Male', 'Female', 'Prefer not to say'], _gender,
          (v) => setState(() => _gender = v)),
    ]);
  }

  Widget _step2() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      _label('District *'),
      _dropdown(TelanganaData.districts, _district,
          (v) => setState(() => _district = v!)),
      const SizedBox(height: 16),
      _label('Mandal / Town *'),
      _field(_mandalCtrl, 'e.g. Uppal, Kukatpally, Warangal Urban'),
      const SizedBox(height: 16),
      _label('Village / Area (optional)'),
      _field(_villageCtrl, 'e.g. Nacharam, Moula Ali'),
    ]);
  }

  Widget _step3() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      _label('College / University *'),
      _dropdown(TelanganaData.colleges, _college,
          (v) => setState(() => _college = v!)),
      if (_college == 'Others') ...[
        const SizedBox(height: 10),
        _field(_collegeOtherCtrl, 'Enter your college name'),
      ],
      const SizedBox(height: 16),
      _label('Branch / Stream *'),
      _dropdown(TelanganaData.branches, _branch,
          (v) => setState(() => _branch = v!)),
      if (_branch == 'Others') ...[
        const SizedBox(height: 10),
        _field(_branchOtherCtrl, 'Enter your branch name'),
      ],
      const SizedBox(height: 16),
      _label('Year of Passing *'),
      _dropdown(
          ['2020', '2021', '2022', '2023', '2024', '2025', '2026', '2027', '2028', '2029', '2030'],
          _yearOfPassing,
          (v) => setState(() => _yearOfPassing = v!)),
      const SizedBox(height: 16),
      _label('CGPA / Percentage'),
      _field(_cgpaCtrl, 'e.g. 8.2 or 78%', icon: Icons.school_outlined),
    ]);
  }

  Widget _step4() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      _label('Current Status *'),
      _chips(['Student', 'Fresher', 'Working', 'Internship'],
          _currentStatus, (v) => setState(() => _currentStatus = v)),
      const SizedBox(height: 16),
      _label('Skills * (select all that apply)'),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: TelanganaData.skills.map((s) {
          final selected = _selectedSkills.contains(s);
          return GestureDetector(
            onTap: () => setState(() => selected
                ? _selectedSkills.remove(s)
                : _selectedSkills.add(s)),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF16213B)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: selected
                        ? const Color(0xFF16213B)
                        : const Color(0xFFE5E7EB)),
              ),
              child: Text(s,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: selected
                          ? Colors.white
                          : const Color(0xFF374151))),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 16),
      _label('Desired Job Role *'),
      _field(_desiredRoleCtrl,
          'e.g. Software Engineer, Data Analyst',
          icon: Icons.work_outline),
      const SizedBox(height: 16),
      _label('Expected Salary'),
      _dropdown(
          ['Below 3 LPA', '3-5 LPA', '5-8 LPA', '8-12 LPA', '12-20 LPA', '20+ LPA'],
          _expectedSalary,
          (v) => setState(() => _expectedSalary = v!)),
      const SizedBox(height: 16),
      _label('LinkedIn Profile URL (optional)'),
      _field(_linkedinCtrl, 'https://linkedin.com/in/yourname',
          icon: Icons.link),
      const SizedBox(height: 16),
      _label('Upload Resume (PDF) — optional'),
      GestureDetector(
        onTap: _loading ? null : _pickResume,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: _resumeName != null
                    ? const Color(0xFF16213B)
                    : const Color(0xFFE5E7EB)),
          ),
          child: Row(children: [
            Icon(
                _resumeName != null
                    ? Icons.picture_as_pdf
                    : Icons.upload_file_outlined,
                color: _resumeName != null
                    ? const Color(0xFF16213B)
                    : const Color(0xFF9CA3AF),
                size: 22),
            const SizedBox(width: 12),
            Expanded(
                child: Text(
                    _resumeName ?? 'Tap to upload your resume (PDF)',
                    style: TextStyle(
                        color: _resumeName != null
                            ? const Color(0xFF111827)
                            : const Color(0xFF9CA3AF),
                        fontSize: 13))),
            if (_resumeName != null)
              const Icon(Icons.check_circle,
                  color: Color(0xFF22C55E), size: 18),
          ]),
        ),
      ),
      const SizedBox(height: 12),
    ]);
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      );

  Widget _field(
    TextEditingController ctrl,
    String hint, {
    IconData? icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFF111827), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Color(0xFFD1D5DB), fontSize: 13),
        prefixIcon: icon != null
            ? Icon(icon, color: const Color(0xFF9CA3AF), size: 18)
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF16213B), width: 1.5)),
      ),
    );
  }

  Widget _dropdown(
      List<String> items, String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        style:
            const TextStyle(color: Color(0xFF111827), fontSize: 13),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _chips(
      List<String> options, String? selected, ValueChanged<String> onTap) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((o) {
        final active = o == selected;
        return GestureDetector(
          onTap: () => onTap(o),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: active ? const Color(0xFF16213B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: active
                      ? const Color(0xFF16213B)
                      : const Color(0xFFE5E7EB)),
            ),
            child: Text(o,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: active ? Colors.white : const Color(0xFF374151))),
          ),
        );
      }).toList(),
    );
  }
}