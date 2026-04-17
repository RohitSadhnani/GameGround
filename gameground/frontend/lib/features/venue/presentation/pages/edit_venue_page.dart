import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:frontend/features/venue/data/venue_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/features/auth/data/auth_service.dart';

class EditVenuePage extends StatefulWidget {
  final Map<String, dynamic> venue;

  const EditVenuePage({super.key, required this.venue});

  @override
  State<EditVenuePage> createState() => _EditVenuePageState();
}

class _EditVenuePageState extends State<EditVenuePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _locationController;
  late final TextEditingController _timingsController;
  late final TextEditingController _slotsController;
  late final TextEditingController _phoneController;

  List<File> _newImages = [];
  List<String> _existingImageUrls = [];
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  late String _sportType;
  final List<String> _sports = [
    'Football',
    'Basketball',
    'Tennis',
    'Cricket',
    'Badminton',
  ];

  @override
  void initState() {
    super.initState();
    final v = widget.venue;
    _nameController = TextEditingController(text: v['name'] ?? '');
    _descriptionController = TextEditingController(text: v['description'] ?? '');
    _priceController = TextEditingController(text: (v['pricePerHour'] ?? v['price'] ?? '').toString());
    _locationController = TextEditingController(text: v['location'] ?? '');
    _timingsController = TextEditingController(text: v['timings'] ?? '');

    // Reconstruct available slots back into a string
    final slots = v['availableSlots'];
    if (slots is List) {
      _slotsController = TextEditingController(text: slots.join(', '));
    } else {
      _slotsController = TextEditingController(text: slots?.toString() ?? '');
    }

    _phoneController = TextEditingController(text: v['phoneNumber'] ?? '');

    // Set sport type, fallback to Football if not in list
    final sport = v['sportType'] ?? v['sport'] ?? 'Football';
    _sportType = _sports.contains(sport) ? sport : 'Football';

    // Load existing image URLs
    if (v['imageUrls'] != null && v['imageUrls'] is List) {
      _existingImageUrls = List<String>.from(v['imageUrls']);
    } else if (v['imageUrl'] != null && v['imageUrl'].toString().isNotEmpty) {
      _existingImageUrls = [v['imageUrl'].toString()];
    }
  }

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
      appBar: AppBar(title: const Text('Edit Venue'), centerTitle: true),
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
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16),
              _buildImagePickerSection(colorScheme),
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
                value: _sportType,
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
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitEdit,
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
                          'SAVE CHANGES',
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

  Future<void> _submitEdit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      List<String> finalImageUrls = List.from(_existingImageUrls);

      // Upload new images if selected
      if (_newImages.isNotEmpty) {
        final token = AuthService.token;
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${ApiConstants.venues}/upload'),
        );
        request.headers['Authorization'] = 'Bearer $token';

        for (var image in _newImages) {
          request.files.add(
            await http.MultipartFile.fromPath('images', image.path),
          );
        }

        var response = await request.send();
        if (response.statusCode == 200) {
          var responseData = await response.stream.bytesToString();
          var data = jsonDecode(responseData);
          if (data['imageUrls'] != null) {
            finalImageUrls = List<String>.from(data['imageUrls']);
          } else if (data['imageUrl'] != null) {
            finalImageUrls = [data['imageUrl']];
          }
        } else {
          throw Exception('Failed to upload new images');
        }
      }

      final List<String> slots = _slotsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      await VenueService.updateVenue(widget.venue['id'], {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'sportType': _sportType,
        'pricePerHour': double.tryParse(_priceController.text.trim()) ?? 0,
        'location': _locationController.text.trim(),
        'timings': _timingsController.text.trim(),
        'availableSlots': slots,
        'imageUrl': finalImageUrls.isNotEmpty ? finalImageUrls.first : '',
        'imageUrls': finalImageUrls,
        'phoneNumber': _phoneController.text.trim(),
      });

      if (mounted) {
        Navigator.pop(context, true); // return true to signal a refresh
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venue updated successfully!')),
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

  Widget _buildSectionTitle(String title, TextTheme textTheme, ColorScheme colorScheme) {
    return Text(
      title,
      style: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.primary,
      ),
    );
  }

  Widget _buildImagePickerSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Venue Images',
          style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        if (_existingImageUrls.isNotEmpty && _newImages.isEmpty) ...[
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _existingImageUrls.length,
              itemBuilder: (context, index) {
                final url = _existingImageUrls[index];
                final fullUrl = url.startsWith('http') ? url : '${ApiConstants.imageBaseUrl}$url';
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(fullUrl, width: 100, fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (_newImages.isNotEmpty) ...[
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _newImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_newImages[index], width: 100, fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          onPressed: () async {
            final picked = await _picker.pickMultiImage();
            if (picked.isNotEmpty) {
              setState(() {
                _newImages = picked.map((x) => File(x.path)).toList();
              });
            }
          },
          icon: const Icon(Icons.photo_library),
          label: Text(_newImages.isEmpty ? 'Replace Images' : '${_newImages.length} New Image(s) Selected'),
        ),
      ],
    );
  }
}
