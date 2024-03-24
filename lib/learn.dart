import 'package:flutter/material.dart';
import 'package:dart_openai/dart_openai.dart';

class ChatGPTView extends StatefulWidget {
  final OpenAI openAI;

  ChatGPTView({required this.openAI});

  @override
  _ChatGPTViewState createState() => _ChatGPTViewState();
}

class _ChatGPTViewState extends State<ChatGPTView> {
  final TextEditingController _promptController = TextEditingController();
  bool _isLoading = false;
  String _response = '';

  void _sendPrompt() async {
    if (_promptController.text.isEmpty) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    
    // Define the initial system message
    final OpenAIChatCompletionChoiceMessageModel systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          "You are a helpful AI assistant, ready to help the user in their request. At the end of each answer, you will teach the user a word in Italian and use it in a sentence. Try to make it on the same subject as the user's request."
        ),
      ],
      role: OpenAIChatMessageRole.assistant,
    );

    // Define the user's message
    final OpenAIChatCompletionChoiceMessageModel userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(_promptController.text),
      ],
      role: OpenAIChatMessageRole.user,
    );

    // Combine system and user messages for the API call
    final chatCompletion = await widget.openAI.chat.create(
      model: "gpt-4-turbo-preview",
      messages: [systemMessage, userMessage], // Send both messages
      temperature: 0.7,
      maxTokens: 1500,
    );

    setState(() {
      _isLoading = false;
      _response = chatCompletion.choices.last.message.content?.first.text ?? 'No response'; // Use the last response
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with GPT'),
      ),
      /*
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _promptController,
              decoration: InputDecoration(
                labelText: 'Enter your prompt',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _sendPrompt(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendPrompt,
              child: Text('Send'),
            ),
            SizedBox(height: 20),
            Expanded( // Wrap the response area in an Expanded widget
              child: SingleChildScrollView( // Make the response scrollable
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Text(_response, style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
      */
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (_response.isNotEmpty)
                  Text(_response, style: TextStyle(fontSize: 16)),
                if (_isLoading)
                  Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _promptController,
                    decoration: InputDecoration(
                      labelText: 'Enter your prompt',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: _promptController.clear,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _sendPrompt,
                    child: Text('Send'),
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

