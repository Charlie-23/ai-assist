import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
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
    final prefs = await SharedPreferences.getInstance();
    final compressedData = prefs.getString(widget.sessionId);
    if (compressedData != null) {
      final decompressedData = _decompressString(compressedData);
      final List<dynamic> jsonData = jsonDecode(decompressedData);
      setState(() {
        _messages.addAll(jsonData
            .map((message) => Map<String, String>.from(message))
            .toList());
      });
    }
  }

  String _decompressString(String compressedData) {
    List<int> compressedBytes = base64Decode(compressedData);
    List<int> decompressedBytes = GZipDecoder().decodeBytes(compressedBytes);
    return utf8.decode(decompressedBytes);
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
            child: ListView.builder(
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
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          isUserMessage ? Colors.blueAccent : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message['text']!,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
