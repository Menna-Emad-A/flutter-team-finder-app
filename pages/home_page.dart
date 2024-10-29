import 'package:flutter/material.dart';
import '../widgets/wave_clipper.dart';
import 'create_team_page.dart';
import 'team_info_page.dart';
import 'requests_page.dart';
import 'profile_page.dart'; // Import ProfilePage
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeContentPage(), // The main content of the home page
    RequestsPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _getUsername();
  }

  // Fetch the current user's username from Firestore
  void _getUsername() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        username = userDoc['username'] ?? 'User';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_page),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Separate widget for the Home page content
class HomeContentPage extends StatefulWidget {
  @override
  _HomeContentPageState createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  String username = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _getUsername();
  }

  // Fetch the current user's username from Firestore
  void _getUsername() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        username = userDoc['username'] ?? 'User';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Wavy header
        ClipPath(
          clipper: WaveClipper(),
          child: Container(
            color: Colors.blue[800],
            height: 200,
            child: Center(
              child: Text(
                'Welcome, $username',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ),
        ),
        // "Need a team? Create one" Text
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateTeamPage()),
              );
            },
            child: Text(
              'Need a team? Create one',
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
          ),
        ),
        // Teams List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('teams').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                // Show a loading indicator while waiting for data
                return Center(child: CircularProgressIndicator());
              }
              final teams = snapshot.data!.docs;
              if (teams.isEmpty) {
                // Show a message if there are no teams
                return Center(
                  child: Text(
                    'No teams currently.',
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }
              return ListView.builder(
                itemCount: teams.length,
                itemBuilder: (context, index) {
                  var team = teams[index];
                  List<dynamic> members = team['members'] ?? [];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: team['teamPicture'] != null &&
                          team['teamPicture'] != ''
                          ? NetworkImage(team['teamPicture'])
                          : AssetImage('assets/default_team.png')
                      as ImageProvider,
                    ),
                    title: Text(team['teamName'] ?? 'Team'),
                    subtitle: Text('Members: ${members.length}'),
                    onTap: () {
                      // Navigate to Team Info Page with required parameters
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeamInfoPage(
                            teamId: team.id,
                            teamName: team['teamName'] ?? 'Team',
                            teamMembers: members,
                            teamRequirements:
                            team['requirements'] ?? 'No requirements specified.',
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
