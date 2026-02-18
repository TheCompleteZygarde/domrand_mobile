import 'dart:math';

import 'package:flutter/material.dart';
import 'card_choice.dart';
import 'data.dart';

class ExpansionChoice extends StatefulWidget {
  const ExpansionChoice({super.key, required this.cardList});
  final CardList cardList;

  @override
  State<ExpansionChoice> createState() => _ExpansionChoiceState();
}

class _ExpansionChoiceState extends State<ExpansionChoice> {
  final List<(String, List<int>?)> _selectedExpansions = [];
  final TextEditingController _controller = TextEditingController();

  final List<(String, List<int>?)> expansions = ownedExpansions;

  List<String> editionShown = [];

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
            for ((String, List<int>?) expansion in expansions)
              Container(
                child:
                    (expansion.$2 ?? []).length > 1
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.all(16),
                                minimumSize: Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                alignment: Alignment.centerLeft,
                                textStyle:
                                    Theme.of(context).textTheme.bodyLarge,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (editionShown.contains(expansion.$1)) {
                                    editionShown.remove(expansion.$1);
                                  } else {
                                    editionShown.add(expansion.$1);
                                  }
                                });
                              },
                              child: Text(expansion.$1),
                            ),
                            editionShown.contains(expansion.$1)
                                ? Column(
                                  children: [
                                    Divider(),

                                    for (int ed in expansion.$2!)
                                      CheckboxListTile(
                                        title: Text("Edition $ed"),
                                        value:
                                            _selectedExpansions
                                                    .where(
                                                      (element) =>
                                                          element.$1 ==
                                                          expansion.$1,
                                                    )
                                                    .firstOrNull !=
                                                null &&
                                            _selectedExpansions
                                                .where(
                                                  (element) =>
                                                      element.$1 ==
                                                      expansion.$1,
                                                )
                                                .first
                                                .$2!
                                                .contains(ed),
                                        onChanged: (bool? value) {
                                          setState(() {
                                            (String, List<int>?)? elem =
                                                _selectedExpansions
                                                    .where(
                                                      (element) =>
                                                          element.$1 ==
                                                          expansion.$1,
                                                    )
                                                    .firstOrNull;
                                            if (value == true) {
                                              if (elem == null) {
                                                _selectedExpansions.add((
                                                  expansion.$1,
                                                  [ed],
                                                ));
                                              } else {
                                                _selectedExpansions[_selectedExpansions
                                                        .indexOf(elem)]
                                                    .$2!
                                                    .add(ed);
                                              }
                                            } else {
                                              if (((elem ?? ("", [])).$2 ?? [])
                                                      .length <
                                                  2) {
                                                _selectedExpansions.remove(
                                                  elem,
                                                );
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
                                    Divider(),
                                  ],
                                )
                                : SizedBox.shrink(),
                          ],
                        )
                        : CheckboxListTile(
                          title: Text(expansion.$1),
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
                  _submitExpansions(selected: _selectedExpansions);
                }
              },
              child: Text('Confirm Selection'),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, bottom: 10.0),
              child: Text(
                'Randomize expansions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Enter number of expansions to use',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _controller.clear();
                    setState(() {
                      Random random = Random();
                      int randomNumber = random.nextInt(expansions.length) + 1;
                      _controller.text = randomNumber.toString();
                    });
                  },
                  child: Text('Randomize'),
                ),
              ],
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
        const SnackBar(content: Text('Please select at least one expansion.')),
      );
      return;
    }
    int? numberOfSets = int.tryParse(_controller.text);
    if (numberOfSets == null || numberOfSets <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid number of expansions.'),
        ),
      );
      return;
    }
    if (numberOfSets > _selectedExpansions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Number of expansions exceeds number of selected expansions.',
          ),
        ),
      );
      return;
    }

    List<(String, List<int>?)> randomizedSets =
        _selectedExpansions.toList()..shuffle();
    randomizedSets = randomizedSets.sublist(0, numberOfSets);
    _submitExpansions(selected: randomizedSets);
  }

  void _submitExpansions({required List<(String, List<int>?)> selected}) {
    List<(String, List<int>?)> selectedExpansions = [];
    for (String expansion in expansionMap.keys) {
      (String, List<int>?)? elem =
          selected.where((elem) => elem.$1 == expansion).firstOrNull;
      if (elem != null) {
        selectedExpansions.add(elem);
      }
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CardChoice(
              selectedExpansions: selectedExpansions,
              cardList: widget.cardList,
            ),
      ),
    );
  }
}
