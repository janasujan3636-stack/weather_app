import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/glass_container.dart';

class AddReportScreen extends StatefulWidget {
  final String currentCity;

  const AddReportScreen({super.key, this.currentCity = 'Mumbai'});

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _cityController;
  final _tempController = TextEditingController(text: '28.0');
  final _notesController = TextEditingController();
  final _authorController = TextEditingController(text: 'Student Observer');

  String _selectedCondition = 'Sunny';
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> _conditions = [
    'Sunny',
    'Clear',
    'Cloudy',
    'Rainy',
    'Thunderstorm',
    'Foggy',
    'Snowy',
  ];

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController(text: widget.currentCity);
  }

  @override
  void dispose() {
    _cityController.dispose();
    _tempController.dispose();
    _notesController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not access image: $e')),
        );
      }
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF152238),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Sky / Climate Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF00D2FF)),
                title: const Text('Capture with Camera', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: Colors.tealAccent),
                title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final prov = Provider.of<WeatherProvider>(context, listen: false);

    final success = await prov.submitWeatherReport(
      city: _cityController.text.trim(),
      temperature: double.tryParse(_tempController.text.trim()) ?? 25.0,
      condition: _selectedCondition,
      notes: _notesController.text.trim().isEmpty
          ? 'Live sky observation report.'
          : _notesController.text.trim(),
      author: _authorController.text.trim(),
      pickedImage: _selectedImage,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Observation uploaded to Firebase Storage & saved via REST POST!',
            ),
            backgroundColor: Colors.teal.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit report. Please try again.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<WeatherProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Post Weather Observation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Photo Upload Section (Firebase Storage Requirement)
                  GestureDetector(
                    onTap: _showImagePickerModal,
                    child: GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (_selectedImage != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: kIsWeb
                                  ? Image.network(
                                      _selectedImage!.path,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(_selectedImage!.path),
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                            )
                          else
                            Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 48,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to select/capture Sky photo',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Will be uploaded to Firebase Storage',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_rounded,
                                size: 18,
                                color: const Color(0xFF00D2FF),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _selectedImage == null ? 'Select Photo' : 'Change Selected Photo',
                                style: const TextStyle(
                                  color: Color(0xFF00D2FF),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Observation Details Card
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // City Name
                        TextFormField(
                          controller: _cityController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Location / City',
                            prefixIcon: Icon(Icons.location_city, color: Colors.white70),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Please enter city' : null,
                        ),
                        const SizedBox(height: 16),

                        // Temperature & Condition Row
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: _tempController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'Temp (°C)',
                                  prefixIcon: Icon(Icons.thermostat, color: Colors.amberAccent),
                                ),
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Enter temp' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                value: _selectedCondition,
                                dropdownColor: const Color(0xFF152238),
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'Condition',
                                  prefixIcon: Icon(Icons.wb_sunny_outlined, color: Colors.white70),
                                ),
                                items: _conditions.map((cond) {
                                  return DropdownMenuItem(
                                    value: cond,
                                    child: Text(cond),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedCondition = val);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Author
                        TextFormField(
                          controller: _authorController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Observer Name',
                            prefixIcon: Icon(Icons.person_outline, color: Colors.white70),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Observation Notes
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Climate Notes / Atmospheric Observations',
                            alignLabelWithHint: true,
                            hintText: 'e.g. Dark storm clouds approaching from the west...',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: prov.isUploading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D2FF),
                      foregroundColor: const Color(0xFF0F2027),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    child: prov.isUploading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Uploading Image & Saving (POST)...',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        : const Text(
                            'Submit Observation (REST POST + Firebase)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
