import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:archive/archive.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final int tokens;
  final String sessionId;

  ChatPage({required this.tokens, required this.sessionId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  Timer? _timer;
  int _remainingTime = 0; // in seconds
  int _tokens = 0;

  @override
  void initState() {
    super.initState();
    _tokens = widget.tokens;
    _remainingTime = _tokens *
        60; // Set total chat time based on tokens (1 token = 60 seconds)
    _loadChatHistory();
    _startTimer();
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

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(_messages);
    final compressedData = _compressString(jsonData);
    await prefs.setString(widget.sessionId, compressedData);
  }

  String _compressString(String data) {
    List<int> stringBytes = utf8.encode(data);
    List<int> compressedBytes = GZipEncoder().encode(stringBytes) ?? [];
    return base64Encode(compressedBytes);
  }

  String _decompressString(String compressedData) {
    List<int> compressedBytes = base64Decode(compressedData);
    List<int> decompressedBytes = GZipDecoder().decodeBytes(compressedBytes);
    return utf8.decode(decompressedBytes);
  }

  void _startTimer() {
    if (_tokens > 0) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_remainingTime <= 0) {
          timer.cancel();
          _showTokenExpiredDialog();
        } else {
          if (_remainingTime % 60 == 0) {
            _reduceToken();
          }
          setState(() {
            _remainingTime--;
          });
        }
      });
    }
  }

  void _reduceToken() {
    if (_tokens > 0) {
      setState(() {
        _tokens--; // Reduce one token each minute
      });
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _controller.clear();
    });

    _saveChatHistory(); // Save chat history after sending message

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _messages.add({'sender': 'ai', 'text': 'AI response to: $text'});
      });
      _saveChatHistory(); // Save chat history after AI response
    });
  }

  void _showTokenExpiredDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tokens Expired'),
          content: Text(
              'Your chat time has expired. Please add more tokens to continue or exit the chat.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context,
                    _tokens); // Return to home page with updated tokens
              },
              child: Text('Exit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _addMoreTokens();
              },
              child: Text('Add Tokens'),
            ),
          ],
        );
      },
    );
  }

  void _addMoreTokens() {
    setState(() {
      _tokens += 5;
      _remainingTime += 5 * 60; // Add more time based on added tokens
      if (_timer == null || !_timer!.isActive) {
        _startTimer(); // Restart the timer if it was stopped
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    Navigator.pop(context, _tokens); // Pass back the updated tokens
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chat'),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isUserMessage
                            ? Colors.blueAccent
                            : Colors.grey[800],
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Time Remaining: ${(_remainingTime ~/ 60).toString().padLeft(2, '0')}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Available Tokens: $_tokens',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
