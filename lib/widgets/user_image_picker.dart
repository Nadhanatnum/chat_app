import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickImage});
  final void Function(XFile pickedImage) onPickImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  XFile? _pickedXFile;
  Uint8List? _webImageBytes;

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: kIsWeb ? ImageSource.gallery : ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );

    if (pickedImage == null) return;
    final bytes = await pickedImage.readAsBytes();

    setState(() {
      _pickedXFile = pickedImage;
      _webImageBytes = bytes;
    });

    widget.onPickImage(pickedImage);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFA855F7).withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C2EB9).withOpacity(0.3),
                blurRadius: 12,
              ),
            ],
          ),
          child: ClipOval(
            child: _webImageBytes != null
                ? Image.memory(
                    _webImageBytes!,
                    fit: BoxFit.cover,
                    width: 88,
                    height: 88,
                  )
                : Container(
                    color: const Color(0xFF2D1154),
                    child: const Icon(
                      Icons.person,
                      color: Color(0x8FF5F0FF),
                      size: 44,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.photo_library_outlined,
              color: Color(0xFFA855F7), size: 18),
          label: Text(
            _pickedXFile == null ? 'Add Image' : 'Change Image',
            style: const TextStyle(
              color: Color(0xFFC084FC),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
