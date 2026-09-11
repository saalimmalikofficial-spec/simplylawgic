import 'package:flutter/material.dart';
import 'package:simplylawgic/utils/app_colors.dart';
import 'package:simplylawgic/models/student_model.dart';
import 'package:simplylawgic/services/storage_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final StorageService _storage = StorageService();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _examController = TextEditingController();
  final TextEditingController _examLabelController = TextEditingController();

  bool _isLoading = false;
  Student? _currentStudent;
  String? _selectedExam;
  String? _selectedAvatar;

  // Exam options for dropdown
  final List<String> _examOptions = [
    'CLAT',
    'Judiciary',
    'AILET',
    'LSAT',
    'Other',
  ];

  // Static Avatar Options with emojis
  final List<Map<String, dynamic>> _avatarOptions = [
    {'emoji': '👨‍🎓', 'label': 'Student', 'color': Colors.blue},
    {'emoji': '👩‍🎓', 'label': 'Graduate', 'color': Colors.purple},
    {'emoji': '👨‍🏫', 'label': 'Teacher', 'color': Colors.green},
    {'emoji': '👩‍⚖️', 'label': 'Lawyer', 'color': Colors.indigo},
    {'emoji': '📚', 'label': 'Bookworm', 'color': Colors.orange},
    {'emoji': '⚖️', 'label': 'Justice', 'color': Colors.red},
    {'emoji': '🧑‍💻', 'label': 'Tech', 'color': Colors.cyan},
    {'emoji': '🌟', 'label': 'Star', 'color': Colors.amber},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final student = await _storage.getStudent();
      setState(() {
        _currentStudent = student;
        if (student != null) {
          _nameController.text = student.name;
          _emailController.text = student.email;
          _phoneController.text = student.phone;
          _examController.text = student.preparingForExam;
          _examLabelController.text = student.preparingForExamLabel;

          // Set selected exam if it exists in options
          if (_examOptions.contains(student.preparingForExam)) {
            _selectedExam = student.preparingForExam;
          } else if (student.preparingForExam.isNotEmpty) {
            _selectedExam = 'Other';
            _examLabelController.text = student.preparingForExam;
          } else {
            _selectedExam = null;
          }

          // Load saved avatar
          _selectedAvatar = student.avatarUrl ?? '👨‍🎓';
        }
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final updatedStudent = Student(
          id: _currentStudent?.id ?? '',
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          preparingForExam: _selectedExam == 'Other'
              ? _examLabelController.text.trim()
              : (_selectedExam ?? ''),
          preparingForExamLabel: _selectedExam == 'Other'
              ? _examLabelController.text.trim()
              : (_selectedExam ?? ''),
          authProvider: _currentStudent?.authProvider ?? 'email',
          avatarUrl: _selectedAvatar ?? '👨‍🎓',
        );

        await _storage.saveStudent(updatedStudent);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Profile updated successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _examController.dispose();
    _examLabelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0F) : AppColors.background,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF12121A) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: Text(
              'Save',
              style: TextStyle(
                color: _isLoading ? Colors.grey : AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture with Avatar
              _buildProfilePicture(isDark),
              const SizedBox(height: 12),

              // Change Avatar Button
              TextButton.icon(
                onPressed: () => _showAvatarPicker(context, isDark),
                icon: Icon(
                  Icons.emoji_emotions_outlined,
                  color: AppColors.primary,
                  size: 18,
                ),
                label: Text(
                  'Change Avatar',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Full Name
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                isDark: isDark,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                isDark: isDark,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                isDark: isDark,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (value.length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Preparing For Exam (Dropdown)
              _buildDropdownField(
                label: 'Preparing For Exam',
                icon: Icons.school_outlined,
                value: _selectedExam,
                items: _examOptions,
                isDark: isDark,
                onChanged: (value) {
                  setState(() {
                    _selectedExam = value;
                    if (value == 'Other') {
                      _examLabelController.text = '';
                    } else if (value != null && value != 'Other') {
                      _examLabelController.text = value;
                    }
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an exam';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Exam Label (shown when 'Other' is selected or has custom value)
              if (_selectedExam == 'Other' ||
                  (_selectedExam != null && !_examOptions.contains(_selectedExam)))
                _buildTextField(
                  controller: _examLabelController,
                  label: 'Specify Exam',
                  icon: Icons.label_outline,
                  isDark: isDark,
                  hintText: 'Enter your exam name',
                  validator: (value) {
                    if (_selectedExam == 'Other' && (value == null || value.isEmpty)) {
                      return 'Please specify your exam';
                    }
                    return null;
                  },
                ),

              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture(bool isDark) {
    final avatarEmoji = _selectedAvatar ?? '👨‍🎓';

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Avatar Container with Gradient Border
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: CircleAvatar(
                radius: 57,
                backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.grey[100],
                child: Text(
                  avatarEmoji,
                  style: const TextStyle(
                    fontSize: 50,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Edit Button
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? const Color(0xFF0A0A0F) : Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.edit_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ],
    );
  }

  void _showAvatarPicker(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    'Choose Your Avatar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select an emoji that represents you',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Current Avatar Preview
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0A0A0F) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white24 : Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Current: ',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white60 : Colors.grey[600],
                          ),
                        ),
                        Text(
                          _selectedAvatar ?? '👨‍🎓',
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Selected',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Avatar Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: _avatarOptions.length,
                    itemBuilder: (context, index) {
                      final avatar = _avatarOptions[index];
                      final isSelected = _selectedAvatar == avatar['emoji'];

                      return GestureDetector(
                        onTap: () {
                          // Update local state
                          setStateModal(() {
                            _selectedAvatar = avatar['emoji'];
                          });
                          // Update main state
                          setState(() {
                            _selectedAvatar = avatar['emoji'];
                          });
                          // Show feedback
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('✅ ${avatar['label']} avatar selected!'),
                              backgroundColor: avatar['color'] as Color,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(milliseconds: 800),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                          // Close the bottom sheet after selection
                          Navigator.pop(context);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (avatar['color'] as Color).withOpacity(0.2)
                                : (isDark ? const Color(0xFF0A0A0F) : Colors.grey[50]),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? avatar['color'] as Color
                                  : (isDark ? Colors.white24 : Colors.grey[300]!),
                              width: isSelected ? 2.5 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                              BoxShadow(
                                color: (avatar['color'] as Color).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                avatar['emoji'],
                                style: TextStyle(
                                  fontSize: isSelected ? 36 : 32,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                avatar['label'],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                  color: isSelected
                                      ? avatar['color'] as Color
                                      : (isDark ? Colors.white70 : Colors.grey[600]),
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: avatar['color'] as Color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: isDark ? Colors.white60 : Colors.grey[600],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(
        color: isDark ? Colors.white : AppColors.textPrimary,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white60 : Colors.grey[600],
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDark ? Colors.white.withOpacity(0.4) : Colors.grey[400],
        ),
        prefixIcon: Icon(
          icon,
          color: isDark ? Colors.white60 : Colors.grey[600],
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.24) : Colors.grey[300]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.24) : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required bool isDark,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white60 : Colors.grey[600],
        ),
        prefixIcon: Icon(
          icon,
          color: isDark ? Colors.white60 : Colors.grey[600],
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.24) : Colors.grey[300]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.24) : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      ),
      style: TextStyle(
        color: isDark ? Colors.white : AppColors.textPrimary,
        fontSize: 15,
      ),
      dropdownColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      icon: Icon(
        Icons.arrow_drop_down,
        color: isDark ? Colors.white60 : Colors.grey[600],
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}