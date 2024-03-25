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
  List<OpenAIChatCompletionChoiceMessageModel> _messageHistory = [];

  @override
  void initState() {
    super.initState();
    // Initialize the chat with a system message
    _initChatWithSystemMessage();
  }

  void _initChatWithSystemMessage() {
    final OpenAIChatCompletionChoiceMessageModel systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          "You are a helpful AI assistant, ready to help the user in their request. At the end of each answer, you will teach the user a word in Italian and use it in a sentence. Try to make it on the same subject as the user's request."
        ),
      ],
      role: OpenAIChatMessageRole.assistant,
    );
    _messageHistory.add(systemMessage);
  }

  void _sendPrompt() async {
    if (_promptController.text.isEmpty) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    // User's message
    final OpenAIChatCompletionChoiceMessageModel userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(_promptController.text),
      ],
      role: OpenAIChatMessageRole.user,
    );

    List<OpenAIChatCompletionChoiceMessageModel> tempHistory = List.from(_messageHistory)..add(userMessage);

    // Trim based on character count
    int totalLength = tempHistory.fold(0, (int length, message) => length + (message.content?.first.text ?? '').length);
    const int maxLength = 1024; // Adjust as needed
    while (totalLength > maxLength && tempHistory.isNotEmpty) {
      totalLength -= (tempHistory.first.content?.first.text ?? '').length;
      tempHistory.removeAt(1);
    }

    final chatCompletion = await widget.openAI.chat.create(
      model: "gpt-4-turbo-preview",
      messages: tempHistory,
      temperature: 0.7,
      maxTokens: 1500,
    );

    final latestResponse = chatCompletion.choices.last.message;
    tempHistory.add(latestResponse); // Update tempHistory with the latest response for accurate character counting

    setState(() {
      _isLoading = false;
      _response += '\n${latestResponse.content?.first.text ?? 'No response'}';
      _messageHistory = List.from(tempHistory); // Update the actual history with the trimmed version
      _promptController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with GPT'),
      ),
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
          Padding(
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
        ],
      ),
    );
  }
}
