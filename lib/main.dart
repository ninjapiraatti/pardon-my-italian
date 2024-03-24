import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dart_openai/dart_openai.dart';
import 'learn.dart';

/// Flutter code sample for [BottomNavigationBar].

Future main() async {
  // To load the .env file contents into dotenv.
  // NOTE: fileName defaults to .env and can be omitted in this case.
  // Ensure that the filename corresponds to the path in step 1 and 2.
  await dotenv.load(fileName: ".env");
  String? openAiApiKey = dotenv.env['OPEN_AI_API_KEY'];
  openAiApiKey ??= "lol";
  OpenAI.apiKey = openAiApiKey;
  final openAI = OpenAI.instance;
  runApp(PardonApp(openAI: openAI));
}

class PardonApp extends StatelessWidget {
  final OpenAI openAI;
  PardonApp({super.key, required this.openAI});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PardonMyItalian(openAI: openAI),
    );
  }
}

class PardonMyItalian extends StatefulWidget {
  final OpenAI openAI;
  const PardonMyItalian({super.key, required this.openAI});

  @override
  State<PardonMyItalian> createState() =>
      _PardonMyItalianState();
}

class _PardonMyItalianState
    extends State<PardonMyItalian> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  late List<Widget> _widgetOptions = <Widget>[
    ChatGPTView(openAI: widget.openAI),
    Text(
      'What is this view',
      style: optionStyle,
    ),
    Text(
      'Settings',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BottomNavigationBar Sample'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Home',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grade),
            label: 'Business',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
            backgroundColor: Colors.pink,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}


