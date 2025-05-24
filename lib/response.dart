import 'package:flutter/material.dart';
import 'data.dart';

class ResponseWidget extends StatelessWidget {
  final List<MyCard> response;

  const ResponseWidget({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Response'),
      ),
      body: ListView(
        children: [
          Center(child: Text("Cards to be used:", style: Theme.of(context).textTheme.titleLarge)),
          ...response.map((card) {
            return Card(
              child: Row(
                children: [
                  SizedBox(
                    width: 10
                  ),
                  Expanded(child: Text(card.expansion)), 
                  Expanded(child: Text(card.name))
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}