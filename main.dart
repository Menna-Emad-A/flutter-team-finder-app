import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mainn/pages/create_team_page.dart';
import 'package:mainn/pages/home_page.dart';
import 'package:mainn/pages/login_page.dart';
import 'package:mainn/pages/profile_page.dart';
import 'package:mainn/pages/requests_page.dart';
import 'package:mainn/pages/signup_page.dart';
import 'package:mainn/pages/team_info_page.dart';
import 'firebase_options.dart'; // Import the generated file


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(TeamApp());
}

class TeamApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeamNY',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
      routes: {
        '/home': (context) => HomePage(),
        '/create-team': (context) => CreateTeamPage(),
        '/profile': (context) => ProfilePage(),
        '/requests': (context) => RequestsPage(),
        '/signup': (context) => SignUpPage(),
        //'/team-info': (context) => TeamInfoPage(teamName: '', teamMembers: '', teamRequirements: '', teamId: '',),
      },
    );
  }
}
