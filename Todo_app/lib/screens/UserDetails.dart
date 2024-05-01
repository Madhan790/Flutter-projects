import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class UserDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
        backgroundColor: Color(0xFF679CEF),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3E2AB),
              Color(0xFFA9D0E3),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              _buildProfileImageWidget(context),
              SizedBox(height: 20),
              Text(
                'Name: ${user?.displayName ?? "N/A"}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                'Email: ${user?.email ?? "N/A"}',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageWidget(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return GestureDetector(
        onTap: () {
          _showImageSelectionDialog(context);
        },
        child: Row(
          children: [
            // Display profile photo if available
            if (user.photoURL != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  user.photoURL!,
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                ),
              ),
            // Display user name and email
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName ?? 'User',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    user.email ?? '',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // If user is not signed in, display a placeholder or default image
      return Placeholder(
        color: Colors.grey, // Placeholder color
      );
    }
  }

  void _showImageSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Profile Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Take a Photo'),
                onTap: () {
                  _getImage(ImageSource.camera);
                  Navigator.pop(context); // Close the dialog
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  _getImage(ImageSource.gallery);
                  Navigator.pop(context); // Close the dialog
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    // Create an instance of ImagePicker
    final picker = ImagePicker();
    // Call getImage method to pick an image from the specified source
    final pickedFile = await picker.pickImage(source: source);
    // Check if an image was picked
    if (pickedFile != null) {
      // If an image was picked, set the selected image file to _profileImage
      // Handle image selection as needed
    }
  }
}
