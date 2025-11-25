import 'package:flutter/material.dart';
import 'data.dart';

class AdvancedRandomization extends StatefulWidget {
  const AdvancedRandomization({
    super.key,
    required this.selectedExpansions,
    required this.cardList,
  });
  final List<String> selectedExpansions;
  final CardList cardList;

  @override
  State<AdvancedRandomization> createState() => _AdvancedRandomState();
}

class _AdvancedRandomState extends State<AdvancedRandomization> {
  @override
  void initState() {
    typesSelected = {
      for (var e in widget.cardList.getTypes(widget.selectedExpansions))
        e: true,
    };
    alchemy = widget.selectedExpansions.contains('Alchemy');
    super.initState();
  }

  bool typesShown = false;
  Map<String, bool> typesSelected = {};
  bool typeRangeShown = false;
  Map<String, RangeValues> typeRange = {};
  bool costShown = false;
  RangeValues costRange = RangeValues(0, 10);
  bool alchemy = false;
  bool potionShown = false;
  RangeValues potionRange = RangeValues(0, 10);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Advanced options'),
      ),
      body: ListView(
        children:
            <Widget>[
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    typesShown = !typesShown;
                  });
                },
                child: Text('Specify card types to use'),
              ),
            ] +
            (typesShown
                ? <Widget>[
                  for (String type in typesSelected.keys)
                    CheckboxListTile(
                      value: typesSelected[type],
                      onChanged: (value) {
                        setState(() {
                          typesSelected[type] = value!;
                        });
                      },
                      title: Text(type),
                    ),
                ]
                : [SizedBox.shrink()]) +
            [
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    typeRangeShown = !typeRangeShown;
                  });
                },
                child: Text('Specify amount for specific types'),
              ),
            ] +
            (typeRangeShown
                ? <Widget>[
                  for (String type in typesSelected.keys)
                    Column(
                      children: [
                        SizedBox(height: 20),
                        Text("$type:"),
                        RangeSlider(
                          values: typeRange[type] ?? RangeValues(0, 10),
                          min: 0,
                          max: 10,
                          divisions: 10,
                          labels: RangeLabels(
                            typeRange[type]?.start.round().toString() ?? '0',
                            typeRange[type]?.end.round().toString() ?? '0',
                          ),
                          onChanged: (RangeValues values) {
                            setState(() {
                              typeRange[type] = values;
                            });
                          },
                        ),
                      ],
                    ),
                ]
                : [SizedBox.shrink()]) +
            [
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    costShown = !costShown;
                  });
                },
                child: Text('Specify a range of costs to use'),
              ),
            ] +
            (costShown
                ? [
                  RangeSlider(
                    values: costRange,
                    min: 0,
                    max: 10,
                    divisions: 10,
                    labels: RangeLabels(
                      costRange.start.round().toString(),
                      costRange.end.round().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        costRange = values;
                      });
                    },
                  ),
                ]
                : [SizedBox.shrink()]) +
            (alchemy
                ? [
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        potionShown = !potionShown;
                      });
                    },
                    child: Text(
                      'Specify how many cards with potion cost to use',
                    ),
                  ),
                ]
                : [SizedBox.shrink()]) +
            (potionShown
                ? [
                  RangeSlider(
                    values: potionRange,
                    min: 0,
                    max: 10,
                    divisions: 10,
                    labels: RangeLabels(
                      potionRange.start.round().toString(),
                      potionRange.end.round().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        potionRange = values;
                      });
                    },
                  ),
                ]
                : [SizedBox.shrink()]) +
            [
              SizedBox(height: 10),
              ElevatedButton(onPressed: _submit, child: Text('Submit')),
            ],
      ),
    );
  }

  void _submit() {
    List<String> rejectedTypes =
        typesSelected.entries
            .where((entry) => !entry.value)
            .map((entry) => entry.key)
            .toList();
    debugPrint(rejectedTypes.toString());
    List<MyCard> playset = widget.cardList.getSpecialPlayset(
      widget.selectedExpansions,
      rejectedTypes,
      typeRange,
      costRange,
      potionRange,
    );
    Navigator.pop(context, playset);
  }
}
