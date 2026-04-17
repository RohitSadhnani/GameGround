import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:frontend/features/coaching/data/coaching_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/features/auth/data/auth_service.dart';

class AddCoachingPage extends StatefulWidget {
  const AddCoachingPage({super.key});

  @override
  State<AddCoachingPage> createState() => _AddCoachingPageState();
}

class _AddCoachingPageState extends State<AddCoachingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _durationController = TextEditingController();
  final _priceController = TextEditingController();
  
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Coaching Session', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Coaching Details'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.black),
                  labelText: 'Coaching Session Name',
                  hintText: 'e.g., Summer Football Camp',
                  prefixIcon: Icon(Icons.sports, color: Colors.black),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              _buildImagePickerRow(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.black),
                  labelText: 'Mobile Number',
                  prefixIcon: Icon(Icons.phone, color: Colors.black),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter a mobile number' : null,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Duration & Pricing'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.black),
                  labelText: 'Duration (Months)',
                  hintText: 'e.g., 3',
                  prefixIcon: Icon(Icons.calendar_today, color: Colors.black),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter duration in months' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.black),
                  labelText: 'Price per Month (₹)',
                  prefixIcon: Icon(Icons.currency_rupee, color: Colors.black),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter a price' : null,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading 
                    ? const SizedBox(
                        height: 24, 
                        width: 24, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text('Add Coaching Session', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        String? finalImageUrl;

        if (_selectedImage != null) {
          final token = AuthService.token;
          var request = http.MultipartRequest('POST', Uri.parse('${ApiConstants.coaching}/upload'));
          request.headers['Authorization'] = 'Bearer $token';
          request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));

          var response = await request.send();
          if (response.statusCode == 200) {
            var responseData = await response.stream.bytesToString();
            var data = jsonDecode(responseData);
            finalImageUrl = data['pic']; // Server returns relative path e.g., /uploads/coaching-...jpg
          } else {
            throw Exception('Failed to upload image');
          }
        }

        await CoachingService.createCoaching({
          'name': _nameController.text.trim(),
          'pic': finalImageUrl,
          'mobileNo': _mobileController.text.trim(),
          'durationMonths': int.parse(_durationController.text.trim()),
          'pricePerMonth': double.parse(_priceController.text.trim()),
        });
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Coaching session added successfully!')),
          );
        }
      } catch (e) {
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
         }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget _buildImagePickerRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Coaching Image (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : const Center(child: Text('No image selected', style: TextStyle(color: Colors.grey))),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _selectedImage = File(pickedFile.path);
                  });
                }
              },
              icon: const Icon(Icons.photo_library, color: Colors.black),
              label: const Text('Pick Image', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.black),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
