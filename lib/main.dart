import 'package:avatar_glow/avatar_glow.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String text = '';
  String textbn = '';
  bool isListening = false;
  final translator = GoogleTranslator();

  _transalateLang() async {
    await translator.translate(text, to: 'bn', from: 'en').then((value) {
      setState(() {
        textbn = value.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
          floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
          floatingActionButton: AvatarGlow(
            endRadius: 75,
            animate: isListening,
            glowColor: Theme.of(context).primaryColor,
            child: FloatingActionButton(
              child: Icon(
                isListening ? Icons.mic : Icons.mic_none,
                size: 35,
              ),
              onPressed: toggleRecording,
            ),
          ),
          appBar: AppBar(
            title: Text('Press the button and start speaking',
                style: TextStyle(fontSize: 15)),
            actions: [
              Builder(
                builder: (context) => IconButton(
                    onPressed: () async {
                      if (textbn.isNotEmpty) {
                        await FlutterClipboard.copy(textbn);
                        Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text('Copied to Clipbord')),
                        );
                      } else {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text('Not Copied')),
                        );
                      }
                    },
                    icon: Icon(Icons.content_copy)),
              )
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  width: width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Color.fromARGB(255, 234, 228, 206)),
                  child: SingleChildScrollView(
                    reverse: true,
                    padding: const EdgeInsets.all(10).copyWith(bottom: 100),
                    child: Text(
                      text,
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Text("Translate English to Bangla"),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  width: width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Color.fromARGB(255, 234, 230, 215)),
                  child: SingleChildScrollView(
                    reverse: true,
                    padding: const EdgeInsets.all(10).copyWith(bottom: 100),
                    child: Text(
                      textbn,
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: _transalateLang, child: Text('Translate now')),
                ],
              )
            ],
          )),
    );
  }

  Future toggleRecording() => Voice.toggleRecording(
      onResult: (text) => setState(() => this.text = text),
      onListening: (isListening) {
        setState(() => this.isListening = isListening);
      });
}

class Voice {
  static final _speech = SpeechToText();

  static Future toggleRecording({
    required Function(String text) onResult,
    required ValueChanged onListening,
  }) async {
    if (_speech.isListening) {
      _speech.stop();
      return true;
    }
    final isAvailable = await _speech.initialize(
      onStatus: (status) => onListening(_speech.isListening),
      onError: (e) => print('Error: $e'),
    );
    if (isAvailable == true) {
      _speech.listen(
        onResult: (result) => onResult(result.recognizedWords),
      );
    }
    return isAvailable;
  }
}
