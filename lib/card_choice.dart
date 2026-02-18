import 'package:flutter/material.dart';
import 'response.dart';
import 'data.dart';

class CardChoice extends StatefulWidget {
  const CardChoice({
    super.key,
    required this.selectedExpansions,
    required this.cardList,
  });
  final List<(String, List<int>?)> selectedExpansions;
  final CardList cardList;

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
            for ((String, List<int>?) expansion in widget.selectedExpansions)
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  "${expansion.$1}${expansion.$2 == null ? "" : ", editions: ${expansion.$2}"}",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _randomizeCards();
              },
              child: Text('Randomize cards fairly'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _basicRandom();
              },
              child: Text('Randomize without weight'),
            ),
          ],
        ),
      ),
    );
  }

  void _randomizeCards() {
    List<MyCard> playset = widget.cardList.getFairPlayset(
      widget.selectedExpansions,
    );
    _submitCards(playset);
  }

  void _basicRandom() {
    List<MyCard> playset = widget.cardList.getPlayset(
      widget.selectedExpansions,
    );
    _submitCards(playset);
  }

  void _submitCards(List<MyCard> playset) {
    Set<String> flags = {};
    Set<MyCard> selectedLandscape = {};

    if (playset[0].expansion == "Dark Ages") {
      flags.add("shelters");
    }

    for (MyCard card in playset) {
      if (card.types.contains("Looter")) {
        flags.add("ruins");
      }
      if (card.types.contains("Doom")) {
        flags.add("hexes");
      }
      if (card.types.contains("Reserve") ||
          ["Miser", "Peasant"].contains(card.name)) {
        flags.add("reserve");
      }
      if (card.types.contains("Fate")) {
        flags.add("boons");
        flags.add("spirits");
      } else if ([
        "Devil's Workshop",
        "Tormentor",
        "Cemetery",
        "Exorcist",
      ].contains(card.name)) {
        flags.add("spirits");
      }
      if (card.debt != null ||
          ["Capital", "Gladiator/Fortune"].contains(card.name)) {
        flags.add("debt");
      }
      if (card.types.contains("Gathering") ||
          [
            "Chariot Race",
            "Encampment/Plunder",
            "Groundskeeper",
            "Patrician/Emporium",
            "Sacrifice",
            "Castles",
          ].contains(card.name)) {
        flags.add("VPtokens");
      }
      if (card.text.contains("Spoils")) {
        flags.add("spoils");
      }
      if (["Leprechaun", "Secret Cave"].contains(card.name)) {
        flags.add("wish");
      }
      if (card.potion) {
        flags.add("potion");
      }
      if (card.types.contains("Omen") && !flags.contains("omen")) {
        flags.add("omen");
        selectedLandscape.addAll(
          widget.cardList.getCardsByType(
            widget.selectedExpansions,
            "Prophecy",
            1,
          ),
        );
      }
      if (card.types.contains("Liaison") && !flags.contains("ally")) {
        flags.add("ally");
        selectedLandscape.addAll(
          widget.cardList.getCardsByType(widget.selectedExpansions, "Ally", 1),
        );
      }
    }

    if (selectedLandscape.length < 2) {
      selectedLandscape.addAll(
        widget.cardList.getLandscapeCards(
          widget.selectedExpansions,
          2 - selectedLandscape.length,
        ),
      );
    }

    playset = CardList.sortCards(playset);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ResponseWidget(
              response: playset,
              landscapeCards: selectedLandscape,
              flags: flags,
              cardList: widget.cardList,
            ),
      ),
    );
  }
}
