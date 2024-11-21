import 'dart:async';
import 'dart:io';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:story_app/generated/l10n.dart';
import 'package:story_app/services/preferences_service.dart';

import '../providers/story_provider.dart';

class AddStoryScreen extends StatefulWidget {
  final String isPaid;

  const AddStoryScreen({super.key, required this.isPaid});

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  late final TextEditingController _latController = TextEditingController();
  late final TextEditingController _lonController = TextEditingController();
  File? _imageFile;
  String tokenIn = '';
  bool isLatLonVisible = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _descriptionController.dispose();
    _latController.dispose();
    _lonController.dispose();
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    debugPrint("BACK BUTTON!"); // Do some stuff.
    context.go('/stories');
    return true;
  }

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    _fetchStories();
    if (widget.isPaid == 'Free') {
      isLatLonVisible = false;
    } else {
      isLatLonVisible = true;
      Timer.periodic(const Duration(seconds: 30), (timer) {
        //getCurrentLocation();
      });
    }
  }


  Future<void> _fetchStories() async {
    final token = await PreferencesService.getToken();
    tokenIn = token.toString();
    // debugPrint("Token uploading story: ${token.toString()}");
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadStory(BuildContext context) async {
    if (_imageFile != null && _descriptionController.text.isNotEmpty) {
      final storyProvider = Provider.of<StoryProvider>(context, listen: false);
      double? lat = _latController.text.isNotEmpty
          ? double.tryParse(_latController.text)
          : null;
      double? lon = _lonController.text.isNotEmpty
          ? double.tryParse(_lonController.text)
          : null;

      final success = await storyProvider.addStory(
        _imageFile!,
        _descriptionController.text,
        tokenIn,
        lat!,
        lon!,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Story uploaded successfully')),
        );
        context.go('/stories');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload story')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please provide an image and description')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
   // final locationProvider = Provider.of<MapZoomProvider>(context);
    //_latController.text = locationProvider.haslatitude.toString();
   // _lonController.text = locationProvider.haslongitude.toString();
    // Ambil parameter lat dan lon dari URL

    final queryParams = GoRouterState.of(context).uri.queryParameters;;

    debugPrint(queryParams.toString());
    final lat = queryParams['lat'];
    final lon = queryParams['lon'];

    if (lat != null && lon != null) {
      _latController.text = lat;
      _lonController.text = lon;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).add_storie),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/stories'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _showImageSourceDialog(context),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _imageFile == null
                      ? Center(
                          child: Text(
                            S.of(context).image,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: S.of(context).description,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              Visibility(
                visible: isLatLonVisible,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _latController,
                        decoration: InputDecoration(
                          labelText: 'Lat',
                          labelStyle: const TextStyle(color: Colors.black54),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _lonController,
                        decoration: InputDecoration(
                          labelText: 'Lon',
                          labelStyle: const TextStyle(color: Colors.black54),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_location_alt_outlined),
                      onPressed: ()=> context.go('/mapSearch'),
                      tooltip: 'Lokasi',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _uploadStory(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(S.of(context).upload),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  GoRouter.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  GoRouter.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
