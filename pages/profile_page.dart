import 'package:flutter/material.dart';
import '../widgets/wave_clipper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_page.dart'; // Import the LoginPage for navigation after logout

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String username = '';
  String email = '';
  String profilePicture = '';
  bool isLoading = true;

  List<Map<String, dynamic>> userTeams = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      // User is not logged in
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      // Fetch user info from Firestore
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(currentUser.uid).get();

      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      setState(() {
        username = userData?['username'] ?? '';
        email = currentUser.email ?? '';
        profilePicture = userData?['profilePicture'] ?? '';
      });

      // Fetch teams where the user is a member
      QuerySnapshot teamsSnapshot = await _firestore
          .collection('teams')
          .where('members', arrayContains: currentUser.uid)
          .get();

      List<Map<String, dynamic>> tempTeams = [];

      for (var teamDoc in teamsSnapshot.docs) {
        tempTeams.add({
          'teamName': teamDoc['teamName'] ?? 'Team',
          'teamPicture': teamDoc['teamPicture'] ?? '',
          'members': teamDoc['members'] ?? [],
        });
      }

      setState(() {
        userTeams = tempTeams;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    // Navigate to the login page and remove all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
      body: Center(child: CircularProgressIndicator()),
    )
        : SingleChildScrollView(
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
                      'Profile',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      backgroundImage: profilePicture != ''
                          ? NetworkImage(profilePicture)
                          : null,
                      child: profilePicture == ''
                          ? Icon(
                        Icons.person,
                        color: Colors.blue[800],
                      )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Profile Details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Username: $username',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'Email: $email',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                // Logout Button
                Center(
                  child: ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                      EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    child: Text(
                      'Logout',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Your teams:',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                // Teams grid
                userTeams.isEmpty
                    ? Center(
                  child: Text(
                    'You are not part of any teams.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: userTeams.length,
                  itemBuilder: (context, index) {
                    var team = userTeams[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.blue[800]!),
                      ),
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.blue[100],
                                backgroundImage:
                                team['teamPicture'] != ''
                                    ? NetworkImage(
                                    team['teamPicture'])
                                    : null,
                                child: team['teamPicture'] == ''
                                    ? Icon(Icons.group,
                                    size: 30,
                                    color: Colors.blue[800])
                                    : null,
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            team['teamName'],
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
