import 'package:flutter/material.dart';
import  'socialmedia_detector.dart'; // Replace with actual package name or use relative import

void main() {
  runApp(SocialMediaApp());
}

class SocialMediaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Media Detector',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: SocialMediaHomePage(),
    );
  }
}

class SocialMediaHomePage extends StatefulWidget {
  @override
  _SocialMediaHomePageState createState() => _SocialMediaHomePageState();
}

class _SocialMediaHomePageState extends State<SocialMediaHomePage> {
  final TextEditingController _controller = TextEditingController();
  String result = '';
  bool isButtonEnabled = false;

  late SocialMediaDetector detector;

  @override
  void initState() {
    super.initState();
    detector = SocialMediaDetector();
    detector.loadModel('assets/platform_nb_model.json');
    _controller.addListener(() {
      setState(() {
        isButtonEnabled = _controller.text.trim().isNotEmpty;
      });
    });
  }

  void _predictPlatform() async {
    final inputText = _controller.text;
    final platform = await detector.predict(inputText);
    setState(() {
      result = "Predicted Platform: ${platform.toUpperCase()}";
    });
  }

  void _clearText() async {
    final inputText = _controller.text;
    final platform = await detector.predict(inputText);
    setState(() {
      result = "Please Enter Something to Predict☝️";
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Social Media Detector',
          style: TextStyle(
            color: Colors.black45,
            fontWeight: FontWeight.bold,
            fontSize: 26.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter a message',
                labelStyle: TextStyle(
                  color: Colors.indigo,
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0,
                ),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isButtonEnabled ? _predictPlatform : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade100,
                    ),
                    child: Text(
                      'Predict Platform',
                      style: TextStyle(
                        color: Colors.green.shade500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _clearText,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                    ),
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              result,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
