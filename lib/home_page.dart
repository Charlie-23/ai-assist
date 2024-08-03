import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'chat_sessions_page.dart'; // Import the new ChatSessionsPage
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tokens = 5;

  Future<void> _startChat() async {
    final sessionId = Uuid().v4();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(tokens: _tokens, sessionId: sessionId),
      ),
    );

    // Update the tokens if a result is returned from the ChatPage
    if (result != null && result is int) {
      setState(() {
        _tokens = result;
      });
    }
  }

  void _getMoreTokens() {
    setState(() {
      _tokens += 5;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added More Tokens')),
    );
  }

  void _viewChatSessions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatSessionsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text('Techy Home Page'),
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/background.jpg'), // Add a background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black87
                .withOpacity(0.7), // Overlay with semi-transparent color
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Welcome to the Techy App!',
                    style: Theme.of(context).textTheme.headline4?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _startChat,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: TextStyle(fontSize: 18),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text('Start New Chat'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _getMoreTokens,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: TextStyle(fontSize: 18),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text('Get More Tokens'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _viewChatSessions,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: TextStyle(fontSize: 18),
                      backgroundColor: Color(0xff3c26e1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text('View Chat Sessions'),
                  ),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.token,
                        color: Colors.yellow,
                        size: 40,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Available Tokens: $_tokens',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
