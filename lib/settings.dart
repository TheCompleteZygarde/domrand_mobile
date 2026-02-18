import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<(String, List<int>?)> _selectedExpansions = ownedExpansions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: <Widget>[
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
                (String, List<int>?)? elem =
                    _selectedExpansions
                        .where((element) => element.$1 == expansion)
                        .firstOrNull;
                if (multiEdition.contains(expansion)) {
                  return Column(
                    children: [
                      Text(expansion),
                      for (int ed in [1, 2])
                        CheckboxListTile(
                          title: Text("Edition $ed"),
                          value: elem != null && elem.$2!.contains(ed),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                if (elem == null) {
                                  _selectedExpansions.add((expansion, [ed]));
                                } else {
                                  _selectedExpansions[_selectedExpansions
                                          .indexOf(elem)]
                                      .$2!
                                      .add(ed);
                                }
                              } else {
                                if ((((elem ?? ("", [])).$2) ?? []).length <
                                    2) {
                                  _selectedExpansions.remove(elem);
                                } else {
                                  _selectedExpansions[_selectedExpansions
                                          .indexOf(elem!)]
                                      .$2!
                                      .remove(ed);
                                }
                              }
                            });
                          },
                        ),
                    ],
                  );
                }
                return CheckboxListTile(
                  title: Text(expansion),
                  value: _selectedExpansions.contains(elem),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedExpansions.add((expansion, []));
                      } else {
                        _selectedExpansions.remove(elem);
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
                  const SnackBar(
                    content: Text('Please select at least one expansion'),
                  ),
                );
                return;
              }
              ownedExpansions = _selectedExpansions;
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              await prefs.setStringList(
                'ownedExpansions',
                CardList.reverseExpStringParse(_selectedExpansions),
              );
              if (!context.mounted) {
                return;
              }
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Save Settings'),
          ),
          SizedBox(height: 60),
        ],
      ),
    );
  }
}
