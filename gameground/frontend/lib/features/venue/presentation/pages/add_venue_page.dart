import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:frontend/features/venue/data/venue_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/features/auth/data/auth_service.dart';

class AddVenuePage extends StatefulWidget {
  const AddVenuePage({super.key});

  @override
  State<AddVenuePage> createState() => _AddVenuePageState();
}

class _AddVenuePageState extends State<AddVenuePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _timingsController = TextEditingController();
  final _slotsController = TextEditingController();
  final _phoneController = TextEditingController();

  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  String _sportType = 'Football';
  final List<String> _sports = [
    'Football',
    'Basketball',
    'Tennis',
    'Cricket',
    'Badminton',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _timingsController.dispose();
    _slotsController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('List New Venue'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Venue Details', textTheme, colorScheme),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Venue Name',
                  hintText: 'e.g., Riverside Sports Complex',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe your venue, facilities, etc.',
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16),
              _buildImagePickerRow(colorScheme),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Sport & Pricing', textTheme, colorScheme),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _sportType,
                decoration: const InputDecoration(
                  labelText: 'Sport Category',
                  prefixIcon: Icon(Icons.sports),
                ),
                items: _sports.map((sport) {
                  return DropdownMenuItem(value: sport, child: Text(sport));
                }).toList(),
                onChanged: (val) => setState(() => _sportType = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price per Hour (₹)',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter a price' : null,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Location', textTheme, colorScheme),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Address Location',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (val) => val == null || val.isEmpty
                    ? 'Please enter an address'
                    : null,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Availability', textTheme, colorScheme),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timingsController,
                decoration: const InputDecoration(
                  labelText: 'Operating Timings',
                  hintText: 'e.g., 06:00 AM - 10:00 PM',
                  prefixIcon: Icon(Icons.access_time),
                ),
                validator: (val) => val == null || val.isEmpty
                    ? 'Please enter operating timings'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _slotsController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Available Slots (Comma separated)',
                  hintText: 'e.g., 06:00-07:00, 07:00-08:00',
                  prefixIcon: Icon(Icons.view_agenda),
                ),
                validator: (val) => val == null || val.isEmpty
                    ? 'Please enter available slots'
                    : null,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);
                            try {
                              List<String> finalImageUrls = [];

                              // 1. Upload images if selected
                              if (_selectedImages.isNotEmpty) {
                                final token = AuthService.token;
                                var request = http.MultipartRequest(
                                  'POST',
                                  Uri.parse('${ApiConstants.venues}/upload'),
                                );
                                request.headers['Authorization'] =
                                    'Bearer $token';
                                
                                for (var image in _selectedImages) {
                                  request.files.add(
                                    await http.MultipartFile.fromPath(
                                      'images', // Note the 'images' field name to match backend
                                      image.path,
                                    ),
                                  );
                                }

                                var response = await request.send();
                                if (response.statusCode == 200) {
                                  var responseData = await response.stream
                                      .bytesToString();
                                  var data = jsonDecode(responseData);
                                  // Store only the relative paths returned by the upload API
                                  if (data['imageUrls'] != null) {
                                      finalImageUrls = List<String>.from(data['imageUrls']);
                                  } else if (data['imageUrl'] != null) {
                                      finalImageUrls = [data['imageUrl']];
                                  }
                                } else {
                                  throw Exception(
                                    'Failed to upload images securely',
                                  );
                                }
                              }

                              // 2. Submit formal venue object
                              final List<String> slots = _slotsController.text
                                  .split(',')
                                  .map((s) => s.trim())
                                  .where((s) => s.isNotEmpty)
                                  .toList();

                              await VenueService.createVenue({
                                'name': _nameController.text.trim(),
                                'description': _descriptionController.text
                                    .trim(),
                                'sportType': _sportType,
                                'pricePerHour': double.parse(
                                  _priceController.text.trim(),
                                ),
                                'location': _locationController.text.trim(),
                                'timings': _timingsController.text.trim(),
                                'availableSlots': slots,
                                'imageUrl': finalImageUrls.isNotEmpty ? finalImageUrls.first : '',
                                'imageUrls': finalImageUrls,
                                'phoneNumber': _phoneController.text.trim(),
                              });

                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Venue listed successfully!'),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          }
                        },
                  child: _isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: colorScheme.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'ADD VENUE',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
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

  Widget _buildSectionTitle(String title, TextTheme textTheme, ColorScheme colorScheme) {
    return Text(
      title,
      style: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.primary,
      ),
    );
  }

  Widget _buildImagePickerRow(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Venue Images (Multiple Allowed)',
          style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  border: Border.all(color: colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _selectedImages.isNotEmpty
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_selectedImages[index], fit: BoxFit.cover, width: 120),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          'No images selected',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: () async {
                final pickedFiles = await _picker.pickMultiImage();
                if (pickedFiles.isNotEmpty) {
                  setState(() {
                    _selectedImages = pickedFiles.map((xFile) => File(xFile.path)).toList();
                  });
                }
              },
              icon: const Icon(Icons.photo_library),
              label: const Text('Pick Image'),
            ),
          ],
        ),
      ],
    );
  }
}
