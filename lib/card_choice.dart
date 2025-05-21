import 'package:flutter/material.dart';
import 'data.dart';

class CardChoice extends StatefulWidget {
  const CardChoice({super.key, required this.selectedExpansions});
  final List<String> selectedExpansions;

  @override
  State<CardChoice> createState() => _CardChoiceState();
}

class _CardChoiceState extends State<CardChoice> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Cards'),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // TODO: Handle confirm selection
              },
              child: Text('Confirm Selection'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _randomizeCards,
              child: Text('Randomize sets from selection'),
            ),
          ],
        ),
      ),
    );
  }

  void _randomizeCards() {
    // TODO: Implement randomization logic
  }
}