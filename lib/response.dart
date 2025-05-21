import 'package:flutter/material.dart';

class ResponseWidget extends StatelessWidget {
  final Map<String, String> response;

  const ResponseWidget({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Response'),
      ),
      body: ListView(
        children: [
          Text("Cards to be used:", style: Theme.of(context).textTheme.titleLarge),
          ...response.entries.map((entry) {
            return ListTile(
              title: Text("${entry.key}: ${entry.value}"),
            );
          }).toList(),
        ],
      ),
    );
  }
}