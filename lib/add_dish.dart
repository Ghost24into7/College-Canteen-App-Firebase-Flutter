import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddDishPage extends StatefulWidget {
  const AddDishPage({super.key});

  @override
  _AddDishPageState createState() => _AddDishPageState();
}

class _AddDishPageState extends State<AddDishPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dishNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  File? _image;
  String? _imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Dish'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _dishNameController,
                decoration: const InputDecoration(labelText: 'Dish Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter dish name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price (INR)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _image != null
                  ? Image.file(
                _image!,
                height: 200,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              )
                  : Container(),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Select Image'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addDish,
                child: const Text('Add Dish'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> _addDish() async {
    if (_formKey.currentState!.validate() && _image != null) {
      try {
        // Upload image to Firebase Storage
        Reference ref = _storage.ref().child(
            'dishes/${DateTime.now().millisecondsSinceEpoch}${_image!.path.split('/').last}');
        UploadTask uploadTask = ref.putFile(_image!);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
        _imageUrl = await taskSnapshot.ref.getDownloadURL();

        // Add dish details to Firestore
        await _firestore.collection('dishes').add({
          'dishName': _dishNameController.text,
          'description': _descriptionController.text,
          'price': _priceController.text,
          'imageUrl': _imageUrl,
          'timestamp': FieldValue.serverTimestamp(), // Store timestamp
        });

        // Reset form after successful submission
        _formKey.currentState!.reset();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dish added successfully.'),
          ),
        );

        // Navigate to menu page
        // You can use Navigator to navigate to the menu page
      } catch (e) {
        // Handle error
        print('Error adding dish: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding dish: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form validation failed or image not selected.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
