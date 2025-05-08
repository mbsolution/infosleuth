import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ResultsScreen extends StatefulWidget {
  final String query, type;
  const ResultsScreen({
    Key? key,
    required this.query,
    required this.type,
  }) : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  Map<String, dynamic>? _res;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _lookup();
  }

  Future<void> _lookup() async {
    try {
      final result = await ApiService.lookupByPhone(widget.query);
      setState(() {
        _res = result;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Results')),
        body: Center(child: Text('Error: $_error')),
      );
    }
    if (_res == null || _res!['valid'] != true) {
      return Scaffold(
        appBar: AppBar(title: const Text('Results')),
        body: Center(child: Text('No record found for "${widget.query}"')),
      );
    }
    // Successful result
    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text("Name: ${_res!['caller_name']}"),
            Text("Carrier: ${_res!['carrier']}"),
            Text("Location: ${_res!['location']}"),
            Text("Spam Score: ${_res!['spam_score']}"),
          ],
        ),
      ),
    );
  }
}
