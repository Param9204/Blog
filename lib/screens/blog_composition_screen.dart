import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:blog/services/blog_service.dart';
import 'package:blog/models/blog.dart';
import 'package:blog/services/auth_service.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class BlogCompositionScreen extends StatefulWidget {
  @override
  _BlogCompositionScreenState createState() => _BlogCompositionScreenState();
}

class _BlogCompositionScreenState extends State<BlogCompositionScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _categoriesController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  List<String> _categories = [];
  List<String> _tags = [];
  File? _image;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          _image = File(pickedImage.path);
          _controller.forward(from: 0.0);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image. Please try again.')),
      );
    }
  }

  void _addCategory(String category) {
    if (category.isNotEmpty) {
      setState(() {
        _categories.add(category);
        _categoriesController.clear();
      });
    }
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty) {
      setState(() {
        _tags.add(tag);
        _tagsController.clear();
      });
    }
  }

  void _submitBlog() async {
    if (_formKey.currentState!.validate()) {
      try {
        String imageUrl = '';

        if (_image != null) {
          imageUrl = await _uploadImage(_image!);
        }

        final authService = Provider.of<AuthService>(context, listen: false);
        final authorId = authService.user!.id;
        final authorEmail = authService.user!.email ?? '';

        final blog = Blog(
          id: '',
          title: _titleController.text,
          content: _contentController.text,
          authorId: authorId,
          createdAt: DateTime.now(),
          categories: _categories,
          tags: _tags,
          imageUrl: imageUrl,
          authorEmail: authorEmail,
          likedBy: [],
          dislikedBy: [],
        );

        await Provider.of<BlogService>(context, listen: false).addBlog(blog);

        Navigator.of(context).pushNamed('/explore');
      } catch (e) {
        print('Error submitting blog: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit blog')),
        );
      }
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      String filePath = 'blogs/$fileName.jpg';

      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child(filePath);

      await ref.putFile(imageFile);

      String imageUrl = await ref.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Compose Blog', style: TextStyle(color: Colors.black)),
      //   backgroundColor: Colors.white,
      //   iconTheme: IconThemeData(color: Colors.black),
      //   elevation: 0,
      // ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Compose a New Blog',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                _buildSectionHeader('Title'),
                _buildTitleField(),
                SizedBox(height: 16),
                _buildSectionHeader('Content'),
                _buildContentField(),
                SizedBox(height: 16),
                _buildSectionHeader('Categories'),
                _buildCategoriesField(),
                _buildCategoryChips(),
                SizedBox(height: 16),
                _buildSectionHeader('Tags'),
                _buildTagsField(),
                _buildTagChips(),
                SizedBox(height: 16),
                _buildSectionHeader('Image'),
                _buildImageSelection(),
                SizedBox(height: 16),
                _buildSubmitButton(),
                SizedBox(height: 16), // Additional padding at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueAccent),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Title',
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a title';
        }
        return null;
      },
    );
  }

  Widget _buildContentField() {
    return TextFormField(
      controller: _contentController,
      decoration: InputDecoration(
        labelText: 'Content',
        alignLabelWithHint: true,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      maxLines: null,
      keyboardType: TextInputType.multiline,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter content';
        }
        return null;
      },
    );
  }

  Widget _buildCategoriesField() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _categoriesController,
                decoration: InputDecoration(
                  labelText: 'Categories',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),
            SizedBox(width: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 4),
                  Text('Add', style: TextStyle(color: Colors.white)),
                ],
              ),
              onPressed: () => _addCategory(_categoriesController.text.trim()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsField() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _tagsController,
                decoration: InputDecoration(
                  labelText: 'Tags',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),
            SizedBox(width: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 4),
                  Text('Add', style: TextStyle(color: Colors.white)),
                ],
              ),
              onPressed: () => _addTag(_tagsController.text.trim()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8.0,
      children: _categories.map((category) {
        return Chip(
          label: Text(category),
          onDeleted: () {
            setState(() {
              _categories.remove(category);
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildTagChips() {
    return Wrap(
      spacing: 8.0,
      children: _tags.map((tag) {
        return Chip(
          label: Text(tag),
          onDeleted: () {
            setState(() {
              _tags.remove(tag);
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildImageSelection() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _image == null
                ? ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: Icon(Icons.image, color: Colors.white),
              label: Text('Select Image', style: TextStyle(color: Colors.white)),
              onPressed: _pickImage,
            )
                : Column(
              children: <Widget>[
                FadeTransition(
                  opacity: _controller,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_image!),
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(Icons.edit, color: Colors.white),
                  label: Text('Change Image', style: TextStyle(color: Colors.white)),
                  onPressed: _pickImage,
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(Icons.delete, color: Colors.white),
                  label: Text('Remove Image', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    setState(() {
                      _image = null;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: TextStyle(fontSize: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text('Submit', style: TextStyle(color: Colors.white)),
        onPressed: _submitBlog,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
