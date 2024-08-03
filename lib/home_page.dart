import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'chat_sessions_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

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
  }

  Future<void> _saveTokens(int tokens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tokens', tokens); // Save tokens to shared_preferences
  }

  Future<void> _showMockAd() async {
    // Simulate an ad experience with a simple dialog
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Watch this ad to earn 1 token'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Simulate an ad with a progress indicator
              Container(
                height: 150,
                color: Colors.grey[300],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Ad Placeholder'),
                      SizedBox(height: 20),
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('Please wait...'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _tokens += 1; // Reward the user with one token
                  _saveTokens(_tokens);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('You earned 1 token!')),
                );
              },
              child: Text('Close Ad'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startChat() async {
    final sessionId = Uuid().v4();
    final prefs = await SharedPreferences.getInstance();
    List<String> sessions = prefs.getStringList('chat_sessions') ?? [];

    // Add the new session and keep only the most recent 5
    sessions.add(sessionId);
    if (sessions.length > 5) {
      sessions = sessions.sublist(sessions.length - 5);
    }
    await prefs.setStringList('chat_sessions', sessions);

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
        _saveTokens(_tokens); // Save the updated token count
      });
    }
  }

  void _getMoreTokens() {
    _showMockAd(); // Show the mock ad dialog
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
                    'Welcome to the Techy App!',
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
