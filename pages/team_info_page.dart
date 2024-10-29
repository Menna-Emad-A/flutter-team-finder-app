import 'package:flutter/material.dart';
import '../widgets/wave_clipper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamInfoPage extends StatefulWidget {
  final String teamId;
  final String teamName;
  final List<dynamic> teamMembers;
  final String teamRequirements;

  TeamInfoPage({
    required this.teamId,
    required this.teamName,
    required this.teamMembers,
    required this.teamRequirements,
  });

  @override
  _TeamInfoPageState createState() => _TeamInfoPageState();
}

class _TeamInfoPageState extends State<TeamInfoPage> {
  Map<String, String> memberUsernames = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMemberUsernames();
  }

  Future<void> fetchMemberUsernames() async {
    try {
      List<String> memberIds = widget.teamMembers.cast<String>();

      // Fetch user documents for all member UIDs
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: memberIds)
          .get();

      Map<String, String> usernames = {};

      for (var doc in usersSnapshot.docs) {
        String uid = doc.id;
        String username = doc['username'] ?? 'User';
        usernames[uid] = username;
      }

      setState(() {
        memberUsernames = usernames;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching member usernames: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> memberIds = widget.teamMembers.cast<String>();
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
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
                        'Team Info',
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
            // Team Info Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Team Name: ${widget.teamName}',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Team Members (${memberIds.length}):',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: memberIds.map((memberId) {
                      String username = memberUsernames[memberId] ?? memberId;
                      return Text(
                        '- $username',
                        style: TextStyle(fontSize: 16),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Team Requirements:',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 5),
                  Text(
                    widget.teamRequirements,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'If interested, request to join:',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Handle request submission
                        final User? currentUser = FirebaseAuth.instance.currentUser;
                        if (currentUser != null) {
                          await FirebaseFirestore.instance
                              .collection('teams')
                              .doc(widget.teamId)
                              .update({
                            'requests': FieldValue.arrayUnion([currentUser.uid]),
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Request sent to join the team')),
                          );
                        } else {
                          // User is not logged in
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please log in to send a request')),
                          );
                        }
                      },
                      child: Text('Request'),
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
