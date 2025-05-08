import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../services/osint_service.dart';

/// Your brand color
const Color brandColor = Color(0xFF00897B);

/// A chat “message,” either text or an image
class Message {
  final String? text;
  final Uint8List? imageBytes;
  final bool fromUser;

  Message({
    this.text,
    this.imageBytes,
    required this.fromUser,
  }) : assert(text != null || imageBytes != null);
}

/// The main screen: a chat-style UI with text + image upload
class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  bool _loading = false;

  /// Pick an image file, then immediately _send() it
  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    if (file.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not read image bytes.')),
      );
      return;
    }
    // auto-submit
    await _send(imageFile: file);
  }

  /// Send either text or an image to your Flask API
  Future<void> _send({PlatformFile? imageFile}) async {
    if (_loading) return;
    final text = _controller.text.trim();
    final hasImage = imageFile != null;
    if (!hasImage && text.isEmpty) return;

    setState(() {
      _loading = true;
      _messages.add(Message(
        text: hasImage ? null : text,
        imageBytes: hasImage ? imageFile!.bytes : null,
        fromUser: true,
      ));
      _controller.clear();
    });

    try {
      if (hasImage) {
        // call /api/search_image
        final resultMap = await OsintService.searchImage(imageFile!);
        final safeResult = resultMap.isNotEmpty
            ? resultMap
            : {'info': 'No results found.'};
        final pretty = const JsonEncoder.withIndent('  ').convert(safeResult);
        _messages.add(Message(text: pretty, fromUser: false));
      } else {
        // call /api/orchestrate
        final reply = await OsintService.fetchResponse(text);
        _messages.add(Message(text: reply, fromUser: false));
      }
    } catch (e) {
      _messages.add(Message(text: 'Error: $e', fromUser: false));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: brandColor,
        centerTitle: true,
        title: Image.asset(
          'assets/infosleuth_logo.png',
          height: 36,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Instruction banner
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: Text(
                'InfoSleuth – lookup phones, emails, names, social handles, or reverse-search images.',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: brandColor, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),

            // Chat history
            Expanded(
              child: ListView.builder(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _messages.length,
                itemBuilder: (_, i) {
                  final m = _messages[i];
                  final radius = const Radius.circular(16);
                  final borderRadius = m.fromUser
                      ? BorderRadius.only(
                    topLeft: radius,
                    topRight: radius,
                    bottomLeft: radius,
                  )
                      : BorderRadius.only(
                    topLeft: radius,
                    topRight: radius,
                    bottomRight: radius,
                  );
                  return Container(
                    margin: const EdgeInsets.only(top: 8),
                    alignment:
                    m.fromUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: m.fromUser ? brandColor : Colors.white,
                        borderRadius: borderRadius,
                      ),
                      padding: const EdgeInsets.all(12),
                      child: m.imageBytes != null
                          ? ClipRRect(
                        borderRadius: borderRadius,
                        child: Image.memory(m.imageBytes!),
                      )
                          : Text(
                        m.text!,
                        style: TextStyle(
                          color: m.fromUser
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (_loading) LinearProgressIndicator(color: brandColor),
            const Divider(height: 1),

            // Input row: camera + text + send
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8)
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    color: brandColor,
                    onPressed: _loading ? null : _pickImage,
                    tooltip: 'Upload photo',
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type phone/email/name—or tap 📷',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: brandColor,
                    onPressed: _loading ? null : _send,
                    tooltip: 'Send',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
