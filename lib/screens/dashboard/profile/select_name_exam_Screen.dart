import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/api_service.dart';
import '../judiciary_exam_constants.dart';

class SelectExamScreen extends StatefulWidget {
  const SelectExamScreen({super.key});

  @override
  State<SelectExamScreen> createState() => _SelectExamScreenState();
}

class _SelectExamScreenState extends State<SelectExamScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController nameController = TextEditingController();

  String? selectedExam;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    final name = nameController.text.trim();
    final exam = selectedExam;

    // -------- VALIDATION --------
    if (name.isEmpty) {
      Get.snackbar(
        'Required',
        'Please enter your name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.black87,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return;
    }

    if (exam == null) {
      Get.snackbar(
        'Required',
        'Please select your exam',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.black87,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // -------- API CALL --------
      await _apiService.updateProfile(
        name: name,
        preparingForExam: exam,
      );

      // -------- SUCCESS MESSAGE --------
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

      // Wapas ProfileScreen pe bhej — refresh trigger karne ke liye
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 600));
        Navigator.pop(context, true);
      }
    } catch (e) {
      // -------- ERROR MESSAGE --------
      final rawMsg = e.toString().replaceFirst('Exception: ', '');
      Get.snackbar(
        'Failed',
        rawMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Complete your profile',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tell us what exam you are preparing for.',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              const Text(
                'Name',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              const Text(
                'Preparing For Exam',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: selectedExam,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: 'Select your exam',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    enabled: false,
                    child: Text('State Judicial Services',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ...STATE_JUDICIAL_SERVICES.map(
                        (exam) => DropdownMenuItem<String>(
                      value: exam['value'],
                      child: Text(exam['label']!),
                    ),
                  ),
                  const DropdownMenuItem<String>(
                    enabled: false,
                    child: Text('Union Territories',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ...UNION_TERRITORY_JUDICIAL_SERVICES.map(
                        (exam) => DropdownMenuItem<String>(
                      value: exam['value'],
                      child: Text(exam['label']!),
                    ),
                  ),
                  const DropdownMenuItem<String>(
                    enabled: false,
                    child: Text('Other',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ...OTHER_JUDICIARY_OPTIONS.map(
                        (exam) => DropdownMenuItem<String>(
                      value: exam['value'],
                      child: Text(exam['label']!),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => selectedExam = value);
                },
              ),
              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _updateProfile,
                  child: isLoading
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                      : const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}