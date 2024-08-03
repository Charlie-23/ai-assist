import 'package:flutter/material.dart';
import 'chat_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tokens = 5;

  Future<void> _startChat() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(tokens: _tokens),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text('Techy Home Page'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to the Techy App!',
              style: Theme.of(context).textTheme.headline4,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _startChat,
              child: Text('Start Chat'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _getMoreTokens,
              child: Text('Get More Tokens'),
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
    );
  }
}
