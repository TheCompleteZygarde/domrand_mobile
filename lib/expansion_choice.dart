import 'package:flutter/material.dart';
import 'card_choice.dart';
import 'data.dart';

class ExpansionChoice extends StatefulWidget {
  const ExpansionChoice({super.key});

  @override
  State<ExpansionChoice> createState() => _ExpansionChoiceState();
}

class _ExpansionChoiceState extends State<ExpansionChoice> {
  final List<String> _selectedExpansions = [];
  final TextEditingController _controller = TextEditingController();

  final List<String> expansions = expansionMap.keys.toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Choose Expansions'),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20.0, bottom: 10.0),
              child: Text(
                'Select expansions to include:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Divider(),
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
            Card(
              child: CheckboxListTile(
                title: Text('Select All'),
                value: _selectedExpansions.length == expansions.length,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedExpansions.clear();
                      _selectedExpansions.addAll(expansions);
                    } else {
                      _selectedExpansions.clear();
                    }
                  });
                },
              ),
            ),
            SizedBox(height: 10),
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
            Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, bottom: 10.0),
              child: Text(
                'Randomize sets',
                style: Theme.of(context).textTheme.titleLarge,
                ),
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter number of sets to use',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _randomizeSets,
              child: Text('Randomize expansions based on your selection'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                    _selectedExpansions.clear();
                    _selectedExpansions.addAll(expansions);
                });
                _randomizeSets();
              },
              child: Text('Randomize from all expansions'),
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
    int? numberOfSets = int.tryParse(_controller.text);
    if (numberOfSets == null || numberOfSets <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid number of sets.'),
        ),
      );
      return;
    }
    if (numberOfSets > _selectedExpansions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Number of sets exceeds number of selected expansions.'),
        ),
      );
      return;
    }

    List<String> randomizedSets = _selectedExpansions.toList()..shuffle();
    randomizedSets = randomizedSets.sublist(0, numberOfSets);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardChoice(selectedExpansions: randomizedSets),
      ),
    );
  }
}