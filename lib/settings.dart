import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<String> _selectedExpansions = ownedExpansions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: 
          <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Select expansions to include:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: expansionMap.keys.length,
                itemBuilder: (context, index) {
                  String expansion = expansionMap.keys.elementAt(index);
                  return CheckboxListTile(
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
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_selectedExpansions.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select at least one expansion')),
                  );
                  return;
                }
                ownedExpansions = _selectedExpansions;
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setStringList('ownedExpansions', _selectedExpansions);
                CardList.refreshOwned();
                if (!context.mounted) {
                  return;
                }
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Save Settings'),
            ),
          ],
        ),
    );
  }
}
