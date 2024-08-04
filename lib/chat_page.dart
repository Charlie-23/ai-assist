import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  String _prevState = ""; // To store the state returned by the API
  bool _isUserInputEnabled = false; // Control whether user can send a message
  bool _isTimerPaused = false; // To keep track if the timer is paused
  bool _isTimerExpired = false; // To track if the timer has expired
  @override
  void initState() {
    super.initState();
    _tokens = widget.tokens;
    _remainingTime = _tokens *
        60; // Set total chat time based on tokens (1 token = 60 seconds)
    _startTimer();
    _sendInitialAIMessage(); // Send the first AI message
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_tokens > 0) {
      _isTimerExpired = false; // Reset the expired flag
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_remainingTime <= 0) {
          timer.cancel();
          _isTimerExpired = true; // Reset the expired flag
          _showTokenExpiredDialog();
        } else {
          if (!_isTimerPaused) {
            // Only decrement time if timer is not paused
            if (_remainingTime % 60 == 0) {
              _reduceToken();
            }
            setState(() {
              _remainingTime--;
            });
          }
        }
      });
    }
  }

  void _reduceToken() {
    if (_tokens > 0) {
      setState(() {
        _tokens--; // Reduce one token each minute
        _saveTokens(); // Save updated token count
      });
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _controller.clear();
      _isUserInputEnabled = false; // Disable user input after sending a message
    });

    _saveChatHistory(); // Save chat history after sending message

    // Make API request to get bot response
    await _getBotResponse();
  }

  Future<void> _getBotResponse() async {
    // Start a timer that will send the fallback message if the API doesn't respond within 4 seconds
    bool apiResponded = false;
    Future.delayed(Duration(seconds: 4)).then((_) {
      if (!apiResponded) {
        _handleError(); // Send the fallback message
      }
    });

    // Convert messages to the required API format
    // final List<Map<String, String>> apiData = _messages.map((message) {
    //   if (message['sender'] == 'user') {
    //     return {'user_message': message['text']!, 'bot_message': ''};
    //   } else {
    //     return {'user_message': '', 'bot_message': message['text']!};
    //   }
    // }).toList();
// Convert messages to the required API format
// Convert messages to the required API format
    final List<Map<String, String>> apiData = [];
    String? lastBotMessage;

    for (var message in _messages) {
      if (message['sender'] == 'ai') {
        // Store the bot's message to be paired with the next user message
        lastBotMessage = message['text']!;
      } else if (message['sender'] == 'user' && lastBotMessage != null) {
        // Pair the bot's message with the user response
        apiData.add({
          'bot_message': lastBotMessage,
          'user_message': message['text']!,
        });
        lastBotMessage = null; // Reset for the next pair
      }
    }

    // Print the apiData for debugging
    print('API Data: $apiData');

    final response = await http.post(
      Uri.parse('http://fellow-nicolea-counselor-ee37a316.koyeb.app/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "data": apiData,
        "prev_state": _prevState,
      }),
    );

    // If the API responds in time, process the response
    if (response.statusCode == 200) {
      apiResponded = true; // Mark that the API has responded
      final responseData = jsonDecode(response.body);
      final botMessage = responseData['output'];
      _prevState =
          responseData['state']; // Update prev_state with the new state

      setState(() {
        _messages.add({'sender': 'ai', 'text': botMessage});
        _isUserInputEnabled =
            true; // Enable user input after receiving AI response
      });

      _saveChatHistory(); // Save chat history after receiving AI response
    }
  }

  void _handleError() {
    setState(() {
      _messages.add({
        'sender': 'ai',
        'text': 'Oops!! Sorry, backend is down. We will be back soon!!'
      });
      _isUserInputEnabled = true; // Enable user input even on error
    });

    _saveChatHistory(); // Save chat history after receiving the fallback message
  }

  void _sendInitialAIMessage() async {
    // Send an initial empty API request to get the first AI message

    final botMessage =
        'Namaste, Welcome to your personal counselor. Aapki Samasya bataye.';

    setState(() {
      _messages.add({'sender': 'ai', 'text': botMessage});
      _isUserInputEnabled =
          true; // Enable user input after receiving AI response
    });

    _saveChatHistory(); // Save chat history after receiving the initial AI message
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

  void _showTokensPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tokens Available'),
          content: Text(
              'You have $_tokens tokens available. Would you like to add more?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _addMoreTokens();
              },
              child: Text('Add Tokens'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _addMoreTokens() {
    _showMockAd(); // Show a mock ad before adding more tokens
  }

  Future<void> _showMockAd() async {
    // Pause the timer
    setState(() {
      _isTimerPaused = true;
    });

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
      _remainingTime += 60; // Add 60 seconds for each token
      _saveTokens(); // Save the updated token count
      _isTimerPaused = false; // Resume the timer
    });
    // Restart the timer if it was expired
    if (_isTimerExpired) {
      _startTimer();
    }
    // Notify the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You have earned 1 token!')),
    );
  }

  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String sessionKey = 'session_${widget.sessionId}';
      final List<String> chatHistory = _messages.map((message) {
        return jsonEncode(message);
      }).toList();
      await prefs.setStringList(sessionKey, chatHistory);
      print('Chat history saved successfully.');
    } catch (e) {
      print('Failed to save chat history: $e');
    }
  }

  Future<void> _saveTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('tokens', _tokens);
      print('Tokens saved successfully.');
    } catch (e) {
      print('Failed to save tokens: $e');
    }
  }

  Future<bool> _onWillPop() async {
    bool exit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text(
                'Do you want to exit the chat? Any unsaved progress will be lost.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;

    if (exit) {
      await _saveChatHistory(); // Save chat history before exiting
      await _saveTokens(); // Save tokens before exiting
      Navigator.pop(
          context, _tokens); // Return the token count to the previous screen
    }

    return exit;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chat'),
          backgroundColor: Colors.blueGrey[900],
          actions: [
            IconButton(
              icon: Icon(Icons.token),
              onPressed: _showTokensPopup, // Show tokens and option to add more
            ),
          ],
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
                      enabled:
                          _isUserInputEnabled, // Enable/Disable based on AI response
                      decoration: InputDecoration(
                        hintText: _isUserInputEnabled
                            ? 'Type a message...'
                            : 'Waiting for AI response...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _isUserInputEnabled
                        ? _sendMessage
                        : null, // Enable/Disable based on AI response
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
