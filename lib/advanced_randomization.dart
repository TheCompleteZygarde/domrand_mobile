import 'package:flutter/material.dart';
import 'data.dart';

class AdvancedRandomization extends StatefulWidget {
  const AdvancedRandomization({super.key, required this.selectedExpansions, required this.cardList});
  final List<String> selectedExpansions;
  final CardList cardList;

  @override
  State<AdvancedRandomization> createState() => _AdvancedRandomState();
}

class _AdvancedRandomState extends State<AdvancedRandomization> {

  @override
  void initState() {
    typesSelected = { for (var e in widget.cardList.getTypes(widget.selectedExpansions)) e : true };
    super.initState();
  }

  bool typesShown = false;
  Map<String, bool> typesSelected = {};
  bool typeMinShown = false;
  Map<String, int> typeMin = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: const Text('Advanced options'),
      ),
      body: ListView(
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              setState(() {
                typesShown = !typesShown;
              });
            }, 
            child: Text('Specify card types to use')
          )
        ] + 
        ( typesShown 
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
                ) 
            ]
          : [SizedBox.shrink()] ) +
        [
          SizedBox(height: 10,),
          ElevatedButton(
            onPressed: () {
              setState(() {
                typeMinShown = !typeMinShown;
              });
            }, 
            child: Text('Specify minimum for specific types')
          )
        ] +
        ( typeMinShown
          ? <Widget>[
            for (String type in typesSelected.keys)
              TextField(
                keyboardType: TextInputType.number,
              )
            ]
          : [SizedBox.shrink()] ) +
        [
          SizedBox(height: 10,),
          ElevatedButton(
            onPressed: _submit, 
            child: Text('Submit')
          )
        ],
      ),
    );
  }

  void _submit() {
    List<MyCard> playset = [];
    Navigator.pop(context, playset);
  }
}