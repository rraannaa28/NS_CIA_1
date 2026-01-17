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
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/spy_bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Dark Overlay
          Container(
            color: Colors.black.withOpacity(0.7),
          ),

          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const Spacer(flex: 1), // Push everything down
                  _buildInputField(),
                  const SizedBox(height: 20),
                  _buildSendButton(),
                  const SizedBox(height: 30),
                  _buildStatusCard(),
                  const Spacer(flex: 1), // Optional extra space at bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return TextField(
      controller: _controller,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: "Enter Secret Message",
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return ElevatedButton(
      onPressed: sendMorse,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        "SEND",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(15),
        
        child: SingleChildScrollView(
          child: Text(
            status.isEmpty ? "Awaiting transmission..." : status,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
