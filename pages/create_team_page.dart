import 'package:flutter/material.dart';
import '../widgets/wave_clipper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateTeamPage extends StatefulWidget {
  @override
  _CreateTeamPageState createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  final TextEditingController teamNameController = TextEditingController();
  final TextEditingController teamPurposeController = TextEditingController();
  final TextEditingController numberOfMembersController = TextEditingController(text: '1');
  final TextEditingController teamRequirementsController = TextEditingController();

  int numberOfMembers = 1;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void dispose() {
    teamNameController.dispose();
    teamPurposeController.dispose();
    numberOfMembersController.dispose();
    teamRequirementsController.dispose();
    super.dispose();
  }

  // Method to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  // Method to upload team data to Firebase
  Future<void> _uploadTeam() async {
    // Get current user
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to create a team')),
      );
      return;
    }

    String teamName = teamNameController.text.trim();
    String teamPurpose = teamPurposeController.text.trim();
    int numberOfMembers = int.tryParse(numberOfMembersController.text) ?? 1;
    String teamRequirements = teamRequirementsController.text.trim();

    if (teamName.isEmpty || teamPurpose.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    String teamPictureURL = '';

    // Upload image if selected
    if (_imageFile != null) {
      try {
        String fileName = 'team_images/${DateTime.now().millisecondsSinceEpoch}_${currentUser.uid}';
        UploadTask uploadTask = _storage.ref().child(fileName).putFile(_imageFile!);
        TaskSnapshot taskSnapshot = await uploadTask;
        teamPictureURL = await taskSnapshot.ref.getDownloadURL();
      } catch (e) {
        print('Image upload error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image')),
        );
        return;
      }
    }

    // Create team document in Firestore
    try {
      await _firestore.collection('teams').add({
        'teamName': teamName,
        'teamPurpose': teamPurpose,
        'numberOfMembers': numberOfMembers,
        'requirements': teamRequirements,
        'teamPicture': teamPictureURL,
        'members': [currentUser.uid], // Add current user as the first member
        'createdBy': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'requests': [], // Initialize requests list
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Team created successfully')),
      );

      // Navigate back to the home page
      Navigator.pop(context);
    } catch (e) {
      print('Team creation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create team')),
      );
    }
  }

  // Methods to increment and decrement number of members
  void _incrementMembers() {
    setState(() {
      numberOfMembers++;
      numberOfMembersController.text = numberOfMembers.toString();
    });
  }

  void _decrementMembers() {
    setState(() {
      if (numberOfMembers > 1) {
        numberOfMembers--;
        numberOfMembersController.text = numberOfMembers.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Wavy header
            ClipPath(
              clipper: WaveClipper(),
              child: Container(
                color: Colors.blue[800],
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Create a Team',
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Create team form
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: teamNameController,
                    decoration: InputDecoration(
                      labelText: 'Team Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: teamPurposeController,
                    decoration: InputDecoration(
                      labelText: 'Team Purpose',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: numberOfMembersController,
                          decoration: InputDecoration(
                            labelText: 'Number of members',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          readOnly: true,
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: _incrementMembers,
                          ),
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: _decrementMembers,
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: teamRequirementsController,
                    decoration: InputDecoration(
                      labelText: 'Who do you want to join?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: Text('Upload Picture'),
                      ),
                      SizedBox(width: 10),
                      Text(_imageFile != null ? 'Image Selected' : 'No file chosen'),
                    ],
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _uploadTeam,
                      child: Text('Confirm'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
