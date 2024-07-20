import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:blog/models/blog.dart';
import 'package:blog/services/blog_service.dart';

class EditBlogScreen extends StatefulWidget {
  final Blog blog;

  const EditBlogScreen({Key? key, required this.blog}) : super(key: key);

  @override
  _EditBlogScreenState createState() => _EditBlogScreenState();
}

class _EditBlogScreenState extends State<EditBlogScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _categoriesController;
  late TextEditingController _tagsController;
  List<String> _categories = [];
  List<String> _tags = [];
  File? _image;
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.blog.title);
    _contentController = TextEditingController(text: widget.blog.content);
    _categoriesController = TextEditingController();
    _tagsController = TextEditingController();
    _categories = List.from(widget.blog.categories);
    _tags = List.from(widget.blog.tags);
    _imageUrl = widget.blog.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _categoriesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedImage =
      await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          _image = File(pickedImage.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image. Please try again.')),
      );
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      // Simulate upload to Firebase Storage or any other service
      await Future.delayed(Duration(seconds: 2));
      String imageUrl = 'https://via.placeholder.com/150'; // Replace with actual URL
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return ''; // Return empty string or null in case of error
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

  void _saveChanges() async {
    String imageUrl = _imageUrl;

    if (_image != null) {
      imageUrl = await _uploadImage(_image!);
      if (imageUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image')),
        );
        return;
      }
    }

    final updatedBlog = Blog(
      id: widget.blog.id,
      title: _titleController.text,
      content: _contentController.text,
      authorId: widget.blog.authorId,
      createdAt: widget.blog.createdAt,
      categories: _categories,
      tags: _tags,
      imageUrl: imageUrl,
      authorEmail: '',
      likedBy: [],
      dislikedBy: [],
    );

    try {
      await Provider.of<BlogService>(context, listen: false)
          .updateBlog(updatedBlog);
      Navigator.pop(context); // Return to previous screen after saving
    } catch (e) {
      print('Error updating blog: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update blog')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Blog'),
        centerTitle: true,
        // actions: [
        //   // IconButton(
        //   //   icon: Icon(Icons.save),
        //   //   onPressed: _saveChanges,
        //   // ),
        // ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
                labelStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
                labelStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _categoriesController,
                    decoration: InputDecoration(
                      labelText: 'Categories',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      labelStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Text('Add Category'),
                  onPressed: () => _addCategory(_categoriesController.text.trim()),
                ),
              ],
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: _categories
                  .map((category) => Chip(
                label: Text(category),
                onDeleted: () {
                  setState(() {
                    _categories.remove(category);
                  });
                },
              ))
                  .toList(),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _tagsController,
                    decoration: InputDecoration(
                      labelText: 'Tags',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      labelStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Text('Add Tag'),
                  onPressed: () => _addTag(_tagsController.text.trim()),
                ),
              ],
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: _tags
                  .map((tag) => Chip(
                label: Text(tag),
                onDeleted: () {
                  setState(() {
                    _tags.remove(tag);
                  });
                },
              ))
                  .toList(),
            ),
            SizedBox(height: 16),
            _image == null && _imageUrl.isEmpty
                ? ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              icon: Icon(Icons.image),
              label: Text('Select Image'),
              onPressed: _pickImage,
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: AlignmentDirectional.bottomEnd,
                  children: [
                    _image != null
                        ? Image.file(
                      _image!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                        : Image.network(
                      _imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: _pickImage,
                      color: Colors.white,
                    ),
                  ],
                ),
                if (_image != null) SizedBox(height: 8),
                if (_image != null)
                  Text(
                    'Tap image to change',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: _saveChanges,
              child: Text('Save Changes'),
            ),
            SizedBox(height: 16), // Additional space at the bottom
          ],
        ),
      ),
    );
  }
}
