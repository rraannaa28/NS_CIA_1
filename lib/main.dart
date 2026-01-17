import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MorseHome(),
    );
  }
}

class MorseHome extends StatefulWidget {
  const MorseHome({super.key});

  @override
  State<MorseHome> createState() => _MorseHomeState();
}

class _MorseHomeState extends State<MorseHome> {
  final TextEditingController _controller = TextEditingController();

  final String serverIP = "192.168.1.9"; // CHANGE THIS
  final int serverPort = 8080;

  String status = "";

  // Morse code map
  final Map<String, String> morseMap = {
    'A': '.-',    'B': '-...',  'C': '-.-.',  'D': '-..',
    'E': '.',     'F': '..-.',  'G': '--.',   'H': '....',
    'I': '..',    'J': '.---',  'K': '-.-',   'L': '.-..',
    'M': '--',    'N': '-.',    'O': '---',   'P': '.--.',
    'Q': '--.-',  'R': '.-.',   'S': '...',   'T': '-',
    'U': '..-',   'V': '...-',  'W': '.--',   'X': '-..-',
    'Y': '-.--',  'Z': '--..',
    '0': '-----', '1': '.----', '2': '..---', '3': '...--',
    '4': '....-', '5': '.....', '6': '-....', '7': '--...',
    '8': '---..', '9': '----.'
  };

  String convertToMorse(String text) {
    return text.toUpperCase().split('').map((char) {
      if (char == ' ') return '/';
      return morseMap[char] ?? '';
    }).join(' ');
  }

  Future<void> sendMorse() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    final morse = convertToMorse(input);

    setState(() {
      status = "Morse Code:\n$morse";
    });

    try {
      final socket = await Socket.connect(
        serverIP,
        serverPort,
        timeout: const Duration(seconds: 5),
      );

      socket.write(morse);

      socket.listen((data) {
        final response = String.fromCharCodes(data);
        setState(() {
          status += "\n\nServer: $response";
        });
        socket.close();
      });
    } catch (e) {
      setState(() {
        status = "❌ Failed to connect to server";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Secret Morse Sender"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Enter Secret Message",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: sendMorse,
              child: const Text("Convert & Send"),
            ),

            const SizedBox(height: 30),

            Text(
              status,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
