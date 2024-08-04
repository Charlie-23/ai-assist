import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_history_page.dart'; // Make sure to import ChatHistoryPage

class ChatSessionsPage extends StatelessWidget {
  Future<List<String>> _loadChatSessions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('chat_sessions') ?? [];
  }

  Future<void> _clearAllChatSessions(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_sessions');

    // Optionally, remove all individual session data as well
    // You might need to remove each session's data if stored separately
    final allKeys = prefs.getKeys();
    for (String key in allKeys) {
      if (key.startsWith('session_')) {
        await prefs.remove(key);
      }
    }

    // Refresh the UI after clearing the chats
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('All chats cleared successfully')),
    );
    Navigator.pop(
        context); // Go back to the previous page or refresh the current page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat History'),
        backgroundColor: Colors.blueGrey[900],
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () async {
              bool confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Clear All Chats'),
                  content:
                      Text('Are you sure you want to clear all chat sessions?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Clear All'),
                    ),
                  ],
                ),
              );
              if (confirm) {
                await _clearAllChatSessions(context);
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: _loadChatSessions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading chat sessions.'));
          } else if (snapshot.data!.isEmpty) {
            return Center(child: Text('No chat history available.'));
          } else {
            final sessions = snapshot.data!;
            return ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Session ${index + 1}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatHistoryPage(sessionId: sessions[index]),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
