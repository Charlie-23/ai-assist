import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:archive/archive.dart';

class ChatHistoryPage extends StatefulWidget {
  final String sessionId;

  ChatHistoryPage({required this.sessionId});

  @override
  _ChatHistoryPageState createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  final List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String sessionKey = 'session_${widget.sessionId}';
      print('Loading chat history for session ${widget.sessionId}.');

      // Retrieve the chat history from SharedPreferences
      final List<String>? chatHistory = prefs.getStringList(sessionKey);

      if (chatHistory != null && chatHistory.isNotEmpty) {
        print('Saved chat history:');

        // Decode each message and print it to the console
        for (String message in chatHistory) {
          Map<String, String> decodedMessage =
              Map<String, String>.from(jsonDecode(message));
          print('${decodedMessage['sender']}: ${decodedMessage['text']}');
        }

        // Update the state with the loaded messages
        setState(() {
          _messages.addAll(chatHistory
              .map((message) => Map<String, String>.from(jsonDecode(message)))
              .toList());
        });

        print('Loaded messages: $_messages');
      } else {
        print('No saved chat history found for session ${widget.sessionId}.');
      }
    } catch (e) {
      print('Error loading chat history: $e');
    }
  }

  String _decompressString(String compressedData) {
    try {
      List<int> compressedBytes = base64Decode(compressedData);
      List<int> decompressedBytes = GZipDecoder().decodeBytes(compressedBytes);
      return utf8.decode(decompressedBytes);
    } catch (e) {
      print('Error decompressing data: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat History'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _messages.isNotEmpty
                ? ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUserMessage = message['sender'] == 'user';

                      return Align(
                        alignment: isUserMessage
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isUserMessage
                                ? Colors.blueAccent
                                : Colors.grey[800],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message['text'] ?? '',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  )
                : Center(child: Text('No chat history available.')),
          ),
        ],
      ),
    );
  }
}
