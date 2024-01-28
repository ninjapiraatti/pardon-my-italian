import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dart_openai/dart_openai.dart';
import 'dart:convert';

class LearnView extends StatefulWidget {
  final OpenAI openAI;

  LearnView({required this.openAI});

  @override
  _LearnViewState createState() => _LearnViewState(openAI: openAI);
}


class _LearnViewState extends State<LearnView> {
  final OpenAI openAI;
  String _wordEnglish = '';
  String _wordTranslated = '';
  String _exampleSentence = '';
  List<OpenAIChatCompletionChoiceMessageContentItemModel>? _apiResponse;

  _LearnViewState({required this.openAI});
  late String _selectedValue;
  List<String> options = ['Italian', 'Swedish', 'Ukranian']; // Example options

  @override
  void initState() {
    super.initState();
    _selectedValue = options.first;
  }

  void _onDropdownChanged(String? newValue) {
    if (newValue == null) {
      return;
    }
    setState(() {
      _selectedValue = newValue;
    });
    _makeApiCall(openAI, newValue);
  }

  void _makeApiCall(OpenAI openAI, String value) async {
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          "You are given a topic and a language. Teach the user a random word on the topic. Return your answer in JSON as follows: {'word_english': 'the chosen random word in English', 'word_language': 'the translation of the chosen random word to the language the user chose' 'in_sentence': 'use the word ina a sentence in the user chosen language'}",
        ),
      ],
      role: OpenAIChatMessageRole.assistant,
    );
    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          "Hello, teach me a word in $value on the topic of 'agriculture'",
        ),

        //! image url contents are allowed only for models with image support such gpt-4.
        // OpenAIChatCompletionChoiceMessageContentItemModel.imageUrl(
        //   "https://placehold.co/600x400",
        // ),
      ],
      role: OpenAIChatMessageRole.user,
    );
    final requestMessages = [
      systemMessage,
      userMessage,
    ];
    OpenAIChatCompletionModel chatCompletion = await openAI.chat.create(
      model: "gpt-3.5-turbo-1106",
      responseFormat: {"type": "json_object"},
      seed: 6,
      messages: requestMessages,
      temperature: 0.2,
      maxTokens: 500,
    );
    print("Making API call");
    print(chatCompletion.choices.first.message); // ...
    print(chatCompletion.systemFingerprint); // ...
    print(chatCompletion.usage.promptTokens); // ...
    print(chatCompletion.id); // ...
    setState(() {
      String _response = chatCompletion.choices.first.message.content?.first.text as String;
      final responseJson = json.decode(_response);
      _wordEnglish = responseJson['word_english'];
      _wordTranslated = responseJson['word_language'];
      _exampleSentence = responseJson['in_sentence'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: Center( // Center the content
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          DropdownButton<String>(
            value: _selectedValue,
            onChanged: _onDropdownChanged,
            items: options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          if (_wordEnglish.isNotEmpty) ...[
            Text(
              'English Word: $_wordEnglish',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Translated: $_wordTranslated',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Example Sentence: $_exampleSentence',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ],
      ),
    ),
  );
  }
}
