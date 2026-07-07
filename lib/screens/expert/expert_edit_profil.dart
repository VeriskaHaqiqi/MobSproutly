import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/image_helper.dart';

const Color kExEditMain = Color(0xFF5DCFCF);
const Color kExEditTeal = Color(0xFF76EAD0);
const Color kExEditBlue = Color(0xFF76D7EA);
const Color kExEditScaffold = Color(0xFFF0F4F3);

class ExpertEditProfilPage extends StatefulWidget {
  const ExpertEditProfilPage({super.key});

  @override
  State<ExpertEditProfilPage> createState() => _ExpertEditProfilPageState();
}

class _ExpertEditProfilPageState extends State<ExpertEditProfilPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _customSpecializationCtrl;

  late final TextEditingController _universityCtrl;
  late final TextEditingController _yearsOfExpCtrl;
  late final TextEditingController _descriptionCtrl;

  late String _gender;
  late String _category;
  late List<String> _selectedSpecializations;
  String? _photoPath;

  final Map<String, List<String>> _specializationOptions = {
    'Ornamental Plants': [
      'Monstera',
      'Aglaonema',
      'Orchid',
      'Anthurium',
      'Rose Specialist',
      'Snake Plant',
      'Peace Lily',
      'Bougainvillea',
      'Elephant Ear',
      'Golden Pothos',
    ],
    'Vegetables': [
      'Chili Pepper',
      'Tomato',
      'Eggplant',
      'Cucumber',
      'Spinach',
      'Water Spinach',
      'Pakcoy',
      'Cabbage',
      'Lettuce',
      'Long Bean',
    ],
    'Food Crops': [
      'Rice',
      'Corn',
      'Cassava',
      'Potato',
      'Sweet Potato',
      'Taro',
      'Soybean',
      'Peanut',
      'Mung Bean',
      'Sorghum',
    ],
    'Fruit Plants': [
      'Mango',
      'Banana',
      'Papaya',
      'Avocado',
      'Orange',
      'Guava',
      'Rambutan',
      'Durian',
      'Dragon Fruit',
      'Pineapple',
    ],
    'Herbs & Culinary Plants': [
      'Ginger',
      'Tumeric',
      'Galangal',
      'Aromatic Ginger',
      'Java Tumeric',
      'Lemongrass',
      'Basil',
      'Mint',
      'Celery',
      'Aromatic Leafy Herbs',
      'Seed & Dried Spices',
    ],
  };

  @override
  void initState() {
    super.initState();

    final user = Provider.of<AuthProvider>(context, listen: false).user;

    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _customSpecializationCtrl = TextEditingController();

    _universityCtrl = TextEditingController(text: user?.expertProfile?.university ?? '');
    _yearsOfExpCtrl = TextEditingController(text: (user?.expertProfile?.yearsOfExperience ?? 0).toString());
    _descriptionCtrl = TextEditingController(text: user?.expertProfile?.description ?? '');

    _gender = _normalizeGender(user?.gender ?? 'Female');
    _category = user?.expertProfile?.description ?? _specializationOptions.keys.first;
    _photoPath = user?.photoUrl;

    if (!_specializationOptions.containsKey(_category)) {
      _category = _specializationOptions.keys.first;
    }

    _selectedSpecializations = user?.specializations
            ?.map((s) => s.name)
            .toList() ??
        [];

    if (_selectedSpecializations.isEmpty) {
      _selectedSpecializations = ['Orchid Specialist'];
    }
  }

  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _customSpecializationCtrl.dispose();
    _universityCtrl.dispose();
    _yearsOfExpCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  String _normalizeGender(String value) {
    final lower = value.toLowerCase().trim();

    if (lower == 'male') return 'Male';
    if (lower == 'female') return 'Female';

    return 'Female';
  }

  bool _isGmail(String value) {
    final email = value.trim();

    final gmailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@gmail\.com$',
    );

    return gmailRegex.hasMatch(email);
  }

  Future<void> _pickPhoto() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    setState(() {
      _photoPath = pickedFile.path;
    });
  }

  void _removePhoto() {
    setState(() {
      _photoPath = null;
    });
  }

  void _uploadDocument(bool isDiploma) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile == null) return;
    
    if (!mounted) return;
    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (_) => const Center(child: CircularProgressIndicator())
    );
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.uploadCertificate(filePath: pickedFile.path, isDiploma: isDiploma);
    
    if (!mounted) return;
    Navigator.pop(context); // close loading dialog
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Document uploaded successfully' : 'Failed to upload document')),
    );
  }

  void _toggleSpecialization(String value) {
    setState(() {
      if (_selectedSpecializations.contains(value)) {
        _selectedSpecializations.remove(value);
      } else {
        _selectedSpecializations.add(value);
      }
    });
  }

  void _addCustomSpecialization() {
    final rawName = _customSpecializationCtrl.text.trim();

    if (rawName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write the specialization name first.'),
        ),
      );
      return;
    }

    final customName = rawName.toLowerCase().contains('specialist')
        ? rawName
        : '$rawName Specialist';

    final allExisting = [
      ..._specializationOptions.values.expand((items) => items),
      ..._selectedSpecializations,
    ];

    final alreadyExists = allExisting.any(
      (item) => item.toLowerCase() == customName.toLowerCase(),
    );

    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This specialization already exists.'),
        ),
      );
      return;
    }

    setState(() {
      _specializationOptions[_category]!.add(customName);
      _selectedSpecializations.add(customName);
      _customSpecializationCtrl.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$customName added to $_category.'),
      ),
    );
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSpecializations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose at least one specialization.'),
        ),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Update basic user profile via API
    final success = await auth.updateProfile(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      gender: _gender,
    );

    // Also update expert category and specializations if possible
    await auth.updateExpertProfile(
      university: _universityCtrl.text.trim(),
      yearsOfExperience: int.tryParse(_yearsOfExpCtrl.text.trim()) ?? 0,
      description: _descriptionCtrl.text.trim().isNotEmpty ? _descriptionCtrl.text.trim() : _category,
    );
    await auth.saveSpecializations(_selectedSpecializations);

    if (success) {
      // Handle photo changes
      if (_photoPath == null) {
        await auth.deletePhoto();
      } else if (!_isNetworkPhoto) {
        await auth.uploadPhoto(_photoPath!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully.'),
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Failed to update profile.'),
          ),
        );
      }
    }
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.outfit(
        fontSize: 13,
        color: Colors.grey.shade400,
      ),
      filled: true,
      fillColor: const Color(0xFFF0F4F3),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kExEditMain, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF0F4F3),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kExEditMain, width: 1.5),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: Colors.black87,
          ),
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  Widget _emptyAccountAvatar() {
    return Container(
      color: const Color(0xFFF0F4F3),
      child: Icon(
        Icons.account_circle_rounded,
        color: Colors.grey.shade400,
        size: 76,
      ),
    );
  }

  bool get _isNetworkPhoto =>
      _photoPath != null &&
      _photoPath!.isNotEmpty &&
      (_photoPath!.startsWith('http://') || _photoPath!.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kExEditScaffold,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildPhotoSection(),
                    const SizedBox(height: 18),
                    _buildBasicInfoCard(),
                    const SizedBox(height: 18),
                    _buildSpecializationCard(),
                    const SizedBox(height: 18),
                    _buildDocumentsCard(),
                    const SizedBox(height: 24),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kExEditBlue, kExEditTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Edit Profile',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kExEditTeal, width: 3),
            ),
            child: ClipOval(
              child: _photoPath != null && _photoPath!.isNotEmpty
                  ? (_isNetworkPhoto
                      ? Image.network(
                          _photoPath!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _emptyAccountAvatar(),
                        )
                      : ImageHelper.fromPath(_photoPath!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _emptyAccountAvatar(),
                        ))
                  : _emptyAccountAvatar(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Profile Photo',
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _photoPath == null
                ? 'No photo selected'
                : 'Your profile photo is active',
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: kExEditMain,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: kExEditMain.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      _photoPath == null ? 'Add Photo' : 'Change Photo',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: _removePhoto,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.2),
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      'Remove Photo',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.redAccent,
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

  Widget _buildBasicInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Basic Information'),
          const SizedBox(height: 14),
          _inputField(
            label: 'Full Name',
            controller: _nameCtrl,
            hint: 'Enter your full name',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Name cannot be empty';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _inputField(
            label: 'Email',
            controller: _emailCtrl,
            hint: 'example@gmail.com',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email cannot be empty';
              }

              if (!_isGmail(value)) {
                return 'Email must use @gmail.com';
              }

              return null;
            },
          ),
          const SizedBox(height: 12),
          _inputField(
            label: 'Phone Number',
            controller: _phoneCtrl,
            hint: 'Enter your phone number',
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Phone number cannot be empty';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _fieldLabel('Gender'),
          const SizedBox(height: 7),
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: _dropdownDecoration(),
            items: const [
              DropdownMenuItem(
                value: 'Male',
                child: Text('Male'),
              ),
              DropdownMenuItem(
                value: 'Female',
                child: Text('Female'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _gender = value;
              });
            },
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: Colors.black87,
            ),
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
          const SizedBox(height: 12),
          _inputField(
            label: 'University',
            controller: _universityCtrl,
            hint: 'Enter your university',
          ),
          const SizedBox(height: 12),
          _inputField(
            label: 'Years of Experience',
            controller: _yearsOfExpCtrl,
            hint: 'e.g. 5',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (int.tryParse(value) == null) {
                  return 'Must be a valid number';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _inputField(
            label: 'Profile Description',
            controller: _descriptionCtrl,
            hint: 'Tell us about your expertise',
          ),
        ],
      ),
    );
  }

  Widget _buildSpecializationCard() {
    final options = _specializationOptions[_category] ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Specialization'),
          const SizedBox(height: 6),
          Text(
            'You can choose more than one specialization. If the option is not available, choose the main category first and add a new specific specialization.',
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: Colors.grey.shade500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          _fieldLabel('Main Category'),
          const SizedBox(height: 7),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: _dropdownDecoration(),
            items: _specializationOptions.keys.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _category = value;
              });
            },
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: Colors.black87,
            ),
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
          const SizedBox(height: 16),
          _fieldLabel('Available Specializations'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((item) {
              final selected = _selectedSpecializations.contains(item);

              return FilterChip(
                label: Text(
                  item,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? kExEditMain : Colors.black54,
                  ),
                ),
                selected: selected,
                onSelected: (_) => _toggleSpecialization(item),
                selectedColor: kExEditTeal.withOpacity(0.22),
                backgroundColor: const Color(0xFFF0F4F3),
                checkmarkColor: kExEditMain,
                side: BorderSide(
                  color: selected ? kExEditMain : Colors.grey.shade200,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          _fieldLabel('Selected Specializations'),
          const SizedBox(height: 10),
          if (_selectedSpecializations.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.withOpacity(0.18),
                ),
              ),
              child: Text(
                'No specialization selected yet.',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: Colors.redAccent,
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedSpecializations.map((item) {
                return Chip(
                  label: Text(
                    item,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: kExEditMain,
                    ),
                  ),
                  deleteIcon: const Icon(
                    Icons.close_rounded,
                    size: 16,
                  ),
                  onDeleted: () {
                    setState(() {
                      _selectedSpecializations.remove(item);
                    });
                  },
                  backgroundColor: kExEditTeal.withOpacity(0.16),
                  side: BorderSide.none,
                );
              }).toList(),
            ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FBFA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel('Add New Specialization'),
                const SizedBox(height: 6),
                Text(
                  'Current category: $_category',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: kExEditMain,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _customSpecializationCtrl,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                  decoration: _inputDecoration(
                    'Example: Calathea, Cactus Care, Mango Disease',
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _addCustomSpecialization,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: kExEditMain,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: kExEditMain.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      'Add Specialization',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Professional Documents'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _uploadDocument(false),
                  icon: const Icon(Icons.file_upload, size: 18),
                  label: const Text('Certificate', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kExEditMain,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _uploadDocument(true),
                  icon: const Icon(Icons.file_upload, size: 18),
                  label: const Text('Diploma', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kExEditMain,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Upload a photo or scanned copy of your professional certificate and diploma. This will be verified by the admin.',
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: Colors.grey.shade500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _saveProfile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kExEditBlue, kExEditMain],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: kExEditMain.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          'Save Changes',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
