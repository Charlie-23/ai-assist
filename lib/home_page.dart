import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart'; // Import Uuid package
import 'chat_page.dart'; // Import ChatPage
import 'chat_sessions_page.dart'; // Import ChatSessionsPage

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tokens = 5;

  @override
  void initState() {
    super.initState();
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tokens = prefs.getInt('tokens') ??
          5; // Load tokens, defaulting to 5 if not found
    });
    print("Loaded tokens: $_tokens");
  }

  Future<void> _startChat() async {
    final sessionId = Uuid().v4();
    final prefs = await SharedPreferences.getInstance();
    List<String> sessions = prefs.getStringList('chat_sessions') ?? [];

    // Add the new session
    sessions.add(sessionId);
    await prefs.setStringList('chat_sessions', sessions);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(tokens: _tokens, sessionId: sessionId),
      ),
    );

    // Update tokens after returning from the chat
    if (result != null && result is int) {
      setState(() {
        _tokens = result;
        _saveTokens(_tokens); // Save the updated token count
      });
    }
  }

  Future<void> _saveTokens(int tokens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tokens', tokens);
    print("Saved tokens: $tokens");
  }

  Future<void> _getMoreTokens() async {
    // Simulate watching an ad by showing a dialog with a timer
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent the dialog from being closed prematurely
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Watch Ad to Earn Token'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Watching an ad...'),
              SizedBox(height: 20),
              CircularProgressIndicator(),
            ],
          ),
        );
      },
    );

    // Simulate a 5-second ad watching time
    await Future.delayed(Duration(seconds: 5));

    // Close the dialog
    Navigator.of(context).pop();

    // Increment the token count
    setState(() {
      _tokens += 1;
    });

    // Save the updated token count
    await _saveTokens(_tokens);

    // Notify the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You have earned 1 token!')),
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
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color:
                Colors.black.withOpacity(0.5), // Add a semi-transparent overlay
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Welcome to the AI Assist!',
                    style: Theme.of(context).textTheme.headline4?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  _buildCustomButton('Start New Chat', _startChat),
                  SizedBox(height: 10),
                  _buildCustomButton('Get More Tokens', _getMoreTokens),
                  SizedBox(height: 10),
                  _buildCustomButton('View Chat Sessions', _viewChatSessions),
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

  Widget _buildCustomButton(String text, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blueAccent.withOpacity(0.7),
            Colors.blueGrey.withOpacity(0.7)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            offset: Offset(2, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
