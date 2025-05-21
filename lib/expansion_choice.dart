import 'package:flutter/material.dart';
import 'card_choice.dart';

const List<String> expansions = [
  'Dominion',
  'Intrigue',
  'Alchemy',
  'Dark Ages',
  'Adventures',
  'Empires',
  'Nocturne',
];

class ExpansionChoice extends StatefulWidget {
  const ExpansionChoice({super.key});

  @override
  State<ExpansionChoice> createState() => _ExpansionChoiceState();
}

class _ExpansionChoiceState extends State<ExpansionChoice> {
  final List<String> _selectedExpansions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Expansions'),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            const Text('Select the expansions to include:'),
            for (String expansion in expansions)
              CheckboxListTile(
                title: Text(expansion),
                value: _selectedExpansions.contains(expansion),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedExpansions.add(expansion);
                    } else {
                      _selectedExpansions.remove(expansion);
                    }
                  });
                },
              ),
            ElevatedButton(
              onPressed: () {
                if (_selectedExpansions.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select at least one expansion.'),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CardChoice(selectedExpansions: _selectedExpansions),
                    ),
                  );
                }
              },
              child: Text('Confirm Selection'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _randomizeSets,
              child: Text('Randomize expansions based on your selection'),
            ),
          ],
        ),
      ),
    );
  }

  void _randomizeSets() {
    if (_selectedExpansions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one expansion.'),
        ),
      );
      return;
    }

    // Randomize the sets based on the selected expansions
    final randomizedSets = _selectedExpansions.toList()..shuffle();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardChoice(selectedExpansions: randomizedSets),
      ),
    );
  }
}