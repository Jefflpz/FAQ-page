import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class InputField extends StatefulWidget {
  final Function(String) onSubmitted;
  final bool isLoading;

  const InputField({
    Key? key,
    required this.onSubmitted,
    required this.isLoading,
  }) : super(key: key);

  @override
  _InputFieldState createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  final TextEditingController _controller = TextEditingController();
  late stt.SpeechToText _speech;
  bool _speechAvailable = false;
  bool _isListening = false;
  String _recognizedText = "";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) => print('onStatus: $status'),
      onError: (error) => print('onError: $error'),
    );
    setState(() {});
  }

  Future<bool> _checkMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }

  void _startListening() async {
    bool granted = await _checkMicrophonePermission();
    if (!granted) {
      print("Permissão de microfone negada");
      return;
    }

    if (_speechAvailable) {
      await _speech.listen(
        listenFor: const Duration(hours: 1), // sem limite prático
        pauseFor: const Duration(seconds: 60),
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
          });
        },
      );
      setState(() {
        _isListening = true;
        _recognizedText = "";
      });
    }
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  void _cancelRecording() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
      _recognizedText = "";
    });
  }

  void _sendMessage() {
    final text = _isListening ? _recognizedText : _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSubmitted(text);
      _controller.clear();
      setState(() {
        _recognizedText = "";
        _isListening = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isListening
        ? _buildRecordingUI()
        : _buildTextInputUI();
  }

  /// Layout padrão com campo de texto + microfone
  Widget _buildTextInputUI() {
    return Center(
      child: Container(
        height: 62, 
        padding: const EdgeInsets.only(left: 16, right: 4), 
        constraints: const BoxConstraints(maxWidth: 340), 
        decoration: BoxDecoration(
          color: Colors.grey[600]!.withOpacity(0.4),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: "Faça uma pergunta",
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(width: 50),
            GestureDetector(
              onTap: widget.isLoading 
                  ? null 
                  : (_controller.text.trim().isEmpty ? _startListening : _sendMessage),
              child: Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _controller.text.trim().isEmpty ? Icons.mic : Icons.send, 
                  color: Colors.white, 
                  size: 26),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Layout quando está gravando (lixeira + texto gravado + botão send)
  Widget _buildRecordingUI() {
    return Center(
      child: Container(
        height: 62, 
        padding: const EdgeInsets.only(left: 14, right: 4), 
        constraints: const BoxConstraints(maxWidth: 340), 
        decoration: BoxDecoration(
          color: Colors.grey[600]!.withOpacity(0.4),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: _cancelRecording,
              child: const Icon(Icons.delete, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _recognizedText.isEmpty ? "Gravando..." : _recognizedText,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: widget.isLoading ? null : _sendMessage,
              child: Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 26),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
