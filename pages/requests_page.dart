import 'package:flutter/material.dart';
import '../widgets/wave_clipper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestsPage extends StatefulWidget {
  @override
  _RequestsPageState createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> requestsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    setState(() {
      isLoading = true;
    });
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      // User is not logged in
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      // Get the teams created by the current user
      QuerySnapshot teamsSnapshot = await _firestore
          .collection('teams')
          .where('createdBy', isEqualTo: currentUser.uid)
          .get();

      List<Map<String, dynamic>> tempRequestsList = [];

      for (var teamDoc in teamsSnapshot.docs) {
        String teamId = teamDoc.id;
        String teamName = teamDoc['teamName'] ?? 'Team';
        List<dynamic> requests = teamDoc['requests'] ?? [];

        for (var requestUserId in requests) {
          // Fetch user info
          DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(requestUserId).get();
          String username = userDoc['username'] ?? 'User';
          String profilePicture = userDoc['profilePicture'] ?? '';

          tempRequestsList.add({
            'teamId': teamId,
            'teamName': teamName,
            'requestUserId': requestUserId,
            'username': username,
            'profilePicture': profilePicture,
          });
        }
      }

      setState(() {
        requestsList = tempRequestsList;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching requests: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void acceptRequest(String teamId, String requestUserId) async {
    try {
      await _firestore.collection('teams').doc(teamId).update({
        'members': FieldValue.arrayUnion([requestUserId]),
        'requests': FieldValue.arrayRemove([requestUserId]),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User accepted into the team')),
      );
      fetchRequests(); // Refresh the list
    } catch (e) {
      print('Error accepting request: $e');
    }
  }

  void rejectRequest(String teamId, String requestUserId) async {
    try {
      await _firestore.collection('teams').doc(teamId).update({
        'requests': FieldValue.arrayRemove([requestUserId]),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User request rejected')),
      );
      fetchRequests(); // Refresh the list
    } catch (e) {
      print('Error rejecting request: $e');
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Requests',
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
        SizedBox(height: 16),
        Expanded(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : requestsList.isEmpty
              ? Center(
            child: Text(
              'No requests at the moment.',
              style: TextStyle(fontSize: 18),
            ),
          )
              : ListView.builder(
            itemCount: requestsList.length,
            itemBuilder: (context, index) {
              var request = requestsList[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.blue[800]!),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue[100],
                      backgroundImage: request['profilePicture'] != ''
                          ? NetworkImage(request['profilePicture'])
                          : null,
                      child: request['profilePicture'] == ''
                          ? Icon(Icons.person,
                          color: Colors.blue[800])
                          : null,
                    ),
                    title: Text(
                        '${request['username']} wants to join ${request['teamName']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check_circle,
                              color: Colors.green),
                          onPressed: () {
                            acceptRequest(
                                request['teamId'],
                                request['requestUserId']);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.cancel, color: Colors.red),
                          onPressed: () {
                            rejectRequest(
                                request['teamId'],
                                request['requestUserId']);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
