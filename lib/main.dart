import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Translator App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TranslatorHomePage(cameras: cameras),
    );
  }
}

class TranslatorHomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const TranslatorHomePage({Key? key, required this.cameras}) : super(key: key);

  @override
  _TranslatorHomePageState createState() => _TranslatorHomePageState();
}

class _TranslatorHomePageState extends State<TranslatorHomePage> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HomeTab(),
      VoiceTab(),
      CameraTab(cameras: widget.cameras),
      LanguageTab(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Translator App'),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'Voice'),
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt), label: 'Camera'),
          BottomNavigationBarItem(
              icon: Icon(Icons.language), label: 'Language'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String sourceLanguage = 'en';
  String targetLanguage = 'id';
  String sourceText = '';
  String translatedText = '';
  final FlutterTts flutterTts = FlutterTts();
  bool isTranslating = false;

  Future<void> translateText() async {
    setState(() {
      isTranslating = true;
    });

    // Simulating API call delay
    await Future.delayed(Duration(seconds: 1));

    // Simple string manipulation to simulate translation
    setState(() {
      translatedText = 'Translated: ' + sourceText.split('').reversed.join('');
      isTranslating = false;
    });

    // Uncomment and use this code when you have a real API key
    /*
    final response = await http.post(
      Uri.parse('https://translation.googleapis.com/language/translate/v2'),
      headers: {
        'Content-Type': 'application/json',
        'X-goog-api-key': 'YOUR_GOOGLE_TRANSLATE_API_KEY',
      },
      body: jsonEncode({
        'q': sourceText,
        'source': sourceLanguage,
        'target': targetLanguage,
        'format': 'text',
      }),
    );

    setState(() {
      isTranslating = false;
    });

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      setState(() {
        translatedText = decodedResponse['data']['translations'][0]['translatedText'];
      });
    } else {
      print('Failed to translate text: ${response.statusCode}');
      setState(() {
        translatedText = 'Error: Failed to translate';
      });
    }
    */
  }

  Future<void> speakTranslatedText() async {
    await flutterTts.setLanguage(targetLanguage);
    await flutterTts.speak(translatedText);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<String>(
                value: sourceLanguage,
                onChanged: (String? newValue) {
                  setState(() {
                    sourceLanguage = newValue!;
                  });
                },
                items: <String>['en', 'id', 'ja']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.toUpperCase()),
                  );
                }).toList(),
              ),
              IconButton(
                icon: Icon(Icons.swap_horiz),
                onPressed: () {
                  setState(() {
                    final temp = sourceLanguage;
                    sourceLanguage = targetLanguage;
                    targetLanguage = temp;
                  });
                },
              ),
              DropdownButton<String>(
                value: targetLanguage,
                onChanged: (String? newValue) {
                  setState(() {
                    targetLanguage = newValue!;
                  });
                },
                items: <String>['en', 'id', 'ja']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.toUpperCase()),
                  );
                }).toList(),
              ),
            ],
          ),
          SizedBox(height: 20),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter text to translate',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                sourceText = value;
              });
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: sourceText.isNotEmpty ? translateText : null,
            child: Text('Translate'),
          ),
          SizedBox(height: 20),
          if (isTranslating)
            Center(child: CircularProgressIndicator())
          else if (translatedText.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Translation:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    translatedText,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: speakTranslatedText,
                  icon: Icon(Icons.volume_up),
                  label: Text('Listen'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class VoiceTab extends StatefulWidget {
  @override
  _VoiceTabState createState() => _VoiceTabState();
}

class _VoiceTabState extends State<VoiceTab> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = 'Press the button and start speaking';

  @override
  void initState() {
    super.initState();
    _speech.initialize();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(_text),
          FloatingActionButton(
            onPressed: _listen,
            child: Icon(_isListening ? Icons.mic : Icons.mic_none),
          ),
        ],
      ),
    );
  }
}

class CameraTab extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraTab({Key? key, required this.cameras}) : super(key: key);

  @override
  _CameraTabState createState() => _CameraTabState();
}

class _CameraTabState extends State<CameraTab> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final TextRecognizer _textRecognizer = TextRecognizer();
  String recognizedText = '';

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _processImage() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      setState(() {
        this.recognizedText = recognizedText.text;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
        ElevatedButton(
          onPressed: _processImage,
          child: Text('Capture and Recognize Text'),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(recognizedText),
        ),
      ],
    );
  }
}

class LanguageTab extends StatelessWidget {
  final List<Map<String, String>> languages = [
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'id', 'name': 'Indonesia', 'flag': '🇮🇩'},
    {'code': 'ja', 'name': 'Japanese', 'flag': '🇯🇵'},
    {'code': 'fr', 'name': 'French', 'flag': '🇫🇷'},
    {'code': 'es', 'name': 'Spanish', 'flag': '🇪🇸'},
    {'code': 'de', 'name': 'German', 'flag': '🇩🇪'},
    {'code': 'it', 'name': 'Italian', 'flag': '🇮🇹'},
    {'code': 'pt', 'name': 'Portuguese', 'flag': '🇵🇹'},
    {'code': 'ru', 'name': 'Russian', 'flag': '🇷🇺'},
    {'code': 'zh', 'name': 'Chinese', 'flag': '🇨🇳'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Language',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search language',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text('All Languages',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView.builder(
              itemCount: languages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text(languages[index]['flag']!),
                  title: Text(languages[index]['name']!),
                  trailing: Icon(Icons.cloud_download),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('${languages[index]['name']} selected')),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
