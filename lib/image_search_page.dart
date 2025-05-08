// lib/image_search_page.dart

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'osint_service.dart';

class ImageSearchPage extends StatefulWidget {
  const ImageSearchPage({Key? key}) : super(key: key);

  @override
  _ImageSearchPageState createState() => _ImageSearchPageState();
}

class _ImageSearchPageState extends State<ImageSearchPage> {
  Map<String, dynamic>? _result;
  bool _loading = false;
  String? _error;

  Future<void> _pickAndSearch() async {
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    try {
      final pick = await FilePicker.platform.pickFiles(type: FileType.image);
      if (pick == null || pick.files.single.bytes == null) {
        setState(() => _error = 'No image selected.');
      } else {
        final data = await OsintService.searchImage(pick.files.single);
        setState(() => _result = data);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Reverse-Lookup')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : _result == null
          ? Center(
        child: ElevatedButton(
          onPressed: _pickAndSearch,
          child: const Text('Pick Image & Search'),
        ),
      )
          : _buildResults(),
    );
  }

  Widget _buildResults() {
    final google = _result!['google_web'] as Map<String, dynamic>;
    final similar = (google['similar_images'] as List).cast<String>();
    final pages = (google['matching_pages'] as List)
        .cast<Map<String, dynamic>>();
    final sauce = (_result!['saucenao'] as List)
        .cast<Map<String, dynamic>>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🔍 Google Web – Similar Images',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: similar.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Image.network(
                  similar[i],
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                ),
              ),
            ),
          ),
          const Divider(),

          const Text('🔗 Google Web – Matching Pages',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...pages.map((p) => ListTile(
            title: Text(p['title'] ?? p['url']),
            subtitle: Text(p['url']),
            onTap: () => _launchUrl(p['url']),
          )),
          const Divider(),

          const Text('🖼️ SauceNAO Matches',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...sauce.map((s) => Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (s['thumbnail'] != null)
                    Image.network(s['thumbnail'],
                        errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image)),
                  const SizedBox(height: 6),
                  Text('Similarity: ${s['similarity']}%',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (s['title'] != null) Text('Title: ${s['title']}'),
                  if (s['author'] != null) Text('Author: ${s['author']}'),
                  const SizedBox(height: 4),
                  ...((s['urls'] as List).cast<String>()).map(
                        (url) => TextButton(
                      onPressed: () => _launchUrl(url),
                      child: Text(
                        url,
                        style: const TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String raw) async {
    final uri = Uri.parse(raw);
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $raw')),
      );
    }
  }
}
