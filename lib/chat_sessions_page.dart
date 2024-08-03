import 'package:flutter/material.dart';
import 'chat_history_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatSessionsPage extends StatefulWidget {
  @override
  _ChatSessionsPageState createState() => _ChatSessionsPageState();
}

class _ChatSessionsPageState extends State<ChatSessionsPage> {
  List<String> _chatSessions = [];

  @override
  void initState() {
    super.initState();
    _loadChatSessions();
  }

  Future<void> _loadChatSessions() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> sessions = prefs.getStringList('chat_sessions') ?? [];

    // Keep only the most recent 5 sessions
    if (sessions.length > 5) {
      sessions = sessions.sublist(sessions.length - 5);
      await prefs.setStringList(
          'chat_sessions', sessions); // Save the trimmed list back
    }

    setState(() {
      _chatSessions = sessions;
    });
  }

  void _viewChatSession(String sessionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatHistoryPage(sessionId: sessionId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Up to 5 Recent Sessions'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: _chatSessions.isEmpty
          ? Center(
              child: Text(
                'No previous chat sessions found.',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: _chatSessions.length,
              itemBuilder: (context, index) {
                final sessionId = _chatSessions[index];
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        'Session ${index + 1}',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () => _viewChatSession(sessionId),
                      trailing: Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                      tileColor: Colors.blueGrey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    SizedBox(height: 12), // Add space between sessions
                  ],
                );
              },
            ),
      backgroundColor: Colors.black87,
    );
  }
}
