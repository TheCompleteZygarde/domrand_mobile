import 'package:flutter/material.dart';
import 'response.dart';
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Choose Cards'),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
              child: Text(
                'Selected expansions:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            for (String expansion in widget.selectedExpansions)
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  expansion,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _randomizeCards();
              },
              child: Text('Randomize cards'),
            ),
          ],
        ),
      ),
    );
  }

  void _randomizeCards() async {
    CardList cardList = await CardList.fromAsset();
    List<MyCard> playset = cardList.getPlayset(widget.selectedExpansions);

    playset = CardList.sortCards(playset);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResponseWidget(response: playset),
      ),
    );
  }
}