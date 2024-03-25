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

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFFFFC300),
  primaryColorLight: const Color(0xFFFFD60A),
  primaryColorDark: const Color(0xFF003566),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFFFC300),
    surfaceVariant: Color(0xFF001D3D),
    background: Color(0xFF000814),
  ),
  useMaterial3: true,
);

class PardonApp extends StatelessWidget {
  final OpenAI openAI;
  PardonApp({super.key, required this.openAI});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PardonMyItalian(openAI: openAI),
      title: 'Pardon My Italian',
      themeMode: ThemeMode.dark,
      darkTheme: darkTheme,
      theme: darkTheme,
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


