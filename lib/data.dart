import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CardList {
  final List<MyCard> cards;

  CardList({required this.cards});

  static Future<CardList> fromAsset() async {
    refreshOwned();
    final String data = await rootBundle.loadString('assets/data.json');
    final List json = jsonDecode(data);
    return CardList(cards: json.map((card) => MyCard.fromMap(card)).toList());
  }

  List<MyCard> getCardsByExpansion(String expansion, {List<int>? editions}) {
    return cards.where((card) {
      if (card.expansion != expansion || card.categories.isNotEmpty) {
        return false;
      }
      if (editions == null || editions.isEmpty || card.editions == null) {
        return true;
      }
      return card.editions!.any((ed) => editions.contains(ed));
    }).toList();
  }

  List<MyCard> getPlayset(List<(String, List<int>?)> selectedExpansions) {
    List<MyCard> cardsInExpansions = [];

    for ((String, List<int>?) exp in selectedExpansions) {
      cardsInExpansions.addAll(getCardsByExpansion(exp.$1, editions: exp.$2));
    }
    cardsInExpansions.shuffle();

    return cardsInExpansions.take(10).toList();
  }

  List<MyCard> getFairPlayset(List<(String, List<int>?)> selectedExpansions) {
    List<List<MyCard>> cardsInExpansions = [];

    for ((String, List<int>?) exp in selectedExpansions) {
      List<MyCard> expCards = getCardsByExpansion(exp.$1, editions: exp.$2);
      expCards.shuffle();
      cardsInExpansions.add(expCards);
    }

    List<MyCard> playset = [];

    for (int i = 0; i < 10; i++) {
      if (cardsInExpansions.isEmpty) {
        break;
      }
      int expansionIndex = Random().nextInt(cardsInExpansions.length);
      if (cardsInExpansions[expansionIndex].isEmpty) {
        cardsInExpansions.removeAt(expansionIndex);
        i--;
        continue;
      }
      playset.add(cardsInExpansions[expansionIndex].removeAt(0));
    }

    return playset;
  }

  List<MyCard> getLandscapeCards(
    List<(String, List<int>?)> selectedExpansions,
    int count,
  ) {
    List<MyCard> newCards = [];
    List<String> landscapeTypes = [
      "Event",
      "Landmark",
      "Project",
      "Way",
      "Trait",
    ];
    for ((String, List<int>?) expansion in selectedExpansions) {
      newCards.addAll(
        cards.where((card) {
          if (!card.types.any((type) => landscapeTypes.contains(type))) {
            return false;
          }
          if (card.expansion != expansion.$1) {
            return false;
          }
          if (expansion.$2 == null ||
              expansion.$2!.isEmpty ||
              card.editions == null) {
            return true;
          }
          return card.editions!.any((ed) => expansion.$2!.contains(ed));
        }),
      );
    }
    newCards.shuffle();
    List<MyCard> result = newCards.take(count).toList();
    if (result.length < 2) {
      return result;
    }
    while (["Way"].contains(result.first.types.first) &&
        result.first.types.first == result.last.types.first) {
      newCards.shuffle();
      result = newCards.take(count).toList();
    }

    return result;
  }

  List<MyCard> getCardsByCategory(
    List<(String, List<int>?)> selectedExpansions,
    String category,
    int count,
  ) {
    List<MyCard> newCards = [];
    for ((String, List<int>?) expansion in selectedExpansions) {
      newCards.addAll(
        cards.where((card) {
          if (!card.categories.contains(category) ||
              card.expansion != expansion.$1) {
            return false;
          }
          if (expansion.$2 == null ||
              expansion.$2!.isEmpty ||
              card.editions == null) {
            return true;
          }
          return card.editions!.any((ed) => expansion.$2!.contains(ed));
        }),
      );
    }
    newCards.shuffle();
    return newCards.take(count).toList();
  }

  List<MyCard> getCardsByType(
    List<(String, List<int>?)> selectedExpansions,
    String type,
    int count,
  ) {
    List<MyCard> newCards = [];
    for ((String, List<int>?) expansion in selectedExpansions) {
      newCards.addAll(
        cards.where((card) {
          if (!card.types.contains(type) || card.expansion != expansion.$1) {
            return false;
          }
          if (expansion.$2 == null ||
              expansion.$2!.isEmpty ||
              card.editions == null) {
            return true;
          }
          return card.editions!.any((ed) => expansion.$2!.contains(ed));
        }),
      );
    }
    newCards.shuffle();
    return newCards.take(count).toList();
  }

  static List<MyCard> sortCards(List<MyCard> cards) {
    cards.sort((a, b) {
      int compare = a.expansionIndex.compareTo(b.expansionIndex);
      if (compare == 0) {
        return a.name.compareTo(b.name);
      }
      return compare;
    });
    return cards;
  }

  static (String, List<int>?) expansionStringParse(String expString) {
    String expansion = expString.substring(0, expString.indexOf(','));
    List<int>? editions = [];
    if (expString.contains('1E')) {
      editions.add(1);
    }
    if (expString.contains('2E')) {
      editions.add(2);
    }
    if (editions.isEmpty) {
      editions = null;
    }
    return (expansion, editions);
  }

  static List<String> reverseExpStringParse(
    List<(String, List<int>?)> expList,
  ) {
    List<String> expansions = [];
    for ((String, List<int>?) exp in expList) {
      String expString = exp.$1;
      if (exp.$2 != null && exp.$2!.isNotEmpty) {
        for (int ed in exp.$2!) {
          expString = "$expString, $ed";
        }
      }
      expansions.add(expString);
    }
    return expansions;
  }

  static Future refreshOwned() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? preferredExpansions = prefs.getStringList(
      'ownedExpansions',
    );
    if (preferredExpansions != null && preferredExpansions.isNotEmpty) {
      ownedExpansions =
          preferredExpansions.map((exp) => expansionStringParse(exp)).toList();
    }
  }
}

Map<String, int> expansionMap = {
  'Dominion': 0,
  'Intrigue': 1,
  'Dark Ages': 2,
  'Alchemy': 3,
  'Adventures': 4,
  'Empires': 5,
  'Nocturne': 6,
  'Rising Sun': 7,
  'Seaside': 8,
  'Prosperity': 9,
  'Cornucopia': 10,
  'Hinterlands': 11,
  'Guilds': 12,
  'Renaissance': 13,
  'Menagerie': 14,
  'Allies': 15,
  'Promo': 17,
  /* The following expansions are not included in data.json
  'Plunder': 16,
  */
};

List<String> multiEdition = [
  'Dominion',
  'Intrigue',
  'Seaside',
  'Prosperity',
  'Cornucopia',
  'Hinterlands',
  'Guilds',
];

List<(String, List<int>?)> ownedExpansions = [
  ('Dominion', [1]),
  ('Intrigue', [2]),
  ('Dark Ages', null),
  ('Alchemy', null),
  ('Adventures', null),
  ('Empires', null),
  ('Nocturne', null),
  ('Rising Sun', null),
];

List<String> colors = [
  'Action',
  'Curse',
  'Duration',
  'Victory',
  'Reaction',
  'Shelter',
  'Reserve',
  'Ruins',
  'Treasure',
  'Night',
  //Landscape cards:
  'Event',
  'Ally',
  'Artifact',
  'Boon',
  'Hex',
  'Landmark',
  'Project',
  'Prophecy',
  'State',
  'Trait',
  'Way',
];

class MyCard {
  final String name;
  final List<String> types;
  final String expansion;
  final int expansionIndex;
  final List<int>? editions;
  final String text;
  final int? cost;
  final int? victoryPoints;
  final int? debt;
  final bool potion;
  final int? maxCards;
  final int? actions;
  final int? buys;
  final int? coinsCoffers;
  final String? setup;
  final List<String> categories;
  String? imageUrl;
  List<MyCard>? subCards;

  MyCard({
    required this.name,
    required this.types,
    required this.expansion,
    this.editions,
    required this.expansionIndex,
    required this.text,
    this.cost,
    this.victoryPoints,
    this.debt,
    required this.potion,
    this.maxCards,
    this.actions,
    this.buys,
    this.coinsCoffers,
    this.categories = const [],
    this.setup,
    this.imageUrl,
  });

  MyCard.fromMap(Map<String, dynamic> map)
    : name = map['name'],
      types = List<String>.from(map['types']),
      expansion = parseExpansion(map['set']),
      editions = parseEditions(map['set']),
      expansionIndex = expansionMap[parseExpansion(map['set'])] ?? 50,
      text = map['text'],
      cost = parseCost(map['cost']),
      potion = parsePotion(map['cost']),
      victoryPoints = parseVictoryPoints(map['victoryPoints']),
      debt = parseDebt(map['cost']),
      maxCards = parseMaxCards(map['cards']),
      actions = parseActions(map['actionsVillagers']),
      buys = parseBuys(map['buys']),
      coinsCoffers = parseCoinsCoffers(map['coinsCoffers']),
      setup = map['setup'],
      categories = List<String>.from(map['categories']),
      imageUrl = null;

  static String parseExpansion(String expansionString) {
    int? end = expansionString.indexOf(",");
    if (end == -1) {
      end = null;
    }
    return expansionString.substring(0, end);
  }

  static List<int>? parseEditions(String expansionString) {
    List<int> editions = [];
    if (expansionString.contains('1E')) {
      editions.add(1);
    }
    if (expansionString.contains('2E')) {
      editions.add(2);
    }
    if (editions.isEmpty) {
      return null;
    }
    return editions;
  }

  static int? parseCost(String costString) {
    if (!costString.contains('\$')) {
      return null;
    }
    final String costValue =
        costString.split('\$')[1].replaceAll("*", "").split(',')[0];
    return int.tryParse(costValue);
  }

  static int? parseVictoryPoints(String vpString) {
    if (vpString.isEmpty) {
      return null;
    }
    int positiveVpValue = 0;
    int negativeVpValue = 0;
    if (vpString.contains('+')) {
      positiveVpValue =
          int.tryParse(vpString.split('+')[1].split('VP')[0]) ?? 0;
    }
    if (vpString.contains('-')) {
      negativeVpValue =
          int.tryParse(vpString.split('-')[1].split('VP')[0]) ?? 0;
    }
    return positiveVpValue - negativeVpValue;
  }

  static int? parseDebt(String debtString) {
    if (!debtString.contains('DBT')) {
      return null;
    }
    final String debtValue = debtString.split('DBT')[0];
    if (debtValue.contains('\$')) {
      return int.tryParse(debtValue.split(' ')[1]);
    }
    return int.tryParse(debtValue);
  }

  static bool parsePotion(String costString) {
    return costString.contains("P");
  }

  static int? parseMaxCards(String maxCardsString) {
    if (maxCardsString.isEmpty) {
      return null;
    }
    int positiveMaxCardsValue = 0;
    int negativeMaxCardsValue = 0;
    if (maxCardsString.contains('+')) {
      positiveMaxCardsValue =
          int.tryParse(maxCardsString.split('+')[1].split(',')[0]) ?? 0;
    }
    if (maxCardsString.contains('-')) {
      negativeMaxCardsValue =
          int.tryParse(maxCardsString.split('-')[1].split(',')[0]) ?? 0;
    }
    return positiveMaxCardsValue - negativeMaxCardsValue;
  }

  static int? parseActions(String actionsString) {
    if (actionsString.isEmpty) {
      return null;
    }
    int actionsValue = 0;
    if (actionsString.contains('+')) {
      actionsValue =
          int.tryParse(actionsString.split('+')[1].split(',')[0]) ?? 0;
    }
    if (actionsString.contains('-')) {
      actionsValue -=
          int.tryParse(actionsString.split('-')[1].split(',')[0]) ?? 0;
    }
    if (actionsString.contains('P')) {
      actionsValue +=
          int.tryParse(actionsString.split('P')[1].split(',')[0]) ?? 0;
    }
    return actionsValue;
  }

  static int? parseBuys(String buysString) {
    if (buysString.isEmpty) {
      return null;
    }
    int buysValue = 0;
    if (buysString.contains('+')) {
      buysValue = int.tryParse(buysString.split('+')[1].split(',')[0]) ?? 0;
    }
    return buysValue;
  }

  static int? parseCoinsCoffers(String coinsCoffersString) {
    if (coinsCoffersString.isEmpty) {
      return null;
    }
    int coinsCoffersValue = 0;
    if (coinsCoffersString.contains('\$')) {
      coinsCoffersValue =
          int.tryParse(coinsCoffersString.split('\$')[1].split(',')[0]) ?? 0;
    }
    if (coinsCoffersString.contains('CFR')) {
      coinsCoffersValue +=
          int.tryParse(coinsCoffersString.split('+')[1].split('CFR')[0]) ?? 0;
    }
    if (coinsCoffersString.contains('R')) {
      coinsCoffersValue -=
          int.tryParse(coinsCoffersString.split('R')[1].split(',')[0]) ?? 0;
    }
    return coinsCoffersValue;
  }

  void parseSubCards(CardList cardList) {
    if (subCards != null) {
      return;
    }
    if (name == "Castles" ||
        name == "Knights" ||
        name == "Augurs" ||
        name == "Forts" ||
        name == "Odysseys" ||
        name == "Wizards") {
      subCards =
          cardList.cards
              .where(
                (card) =>
                    card.types.contains(name.substring(0, name.length - 1)) &&
                    !card.types.contains("Split pile"),
              )
              .toList();
      return;
    }
    if (name == "Townsfolk") {
      subCards =
          cardList.cards
              .where(
                (card) =>
                    card.types.contains("Townsfolk") &&
                    !card.types.contains("Split pile"),
              )
              .toList();
      return;
    }
    if (name == "Clashes") {
      subCards =
          cardList.cards
              .where(
                (card) =>
                    card.types.contains("Clash") &&
                    !card.types.contains("Split pile"),
              )
              .toList();
      return;
    }
    if (name == "Page") {
      subCards = cardList.cards.sublist(
        cardList.cards.indexWhere((card) => card.name == "Treasure Hunter"),
        cardList.cards.indexWhere((card) => card.name == "Champion") + 1,
      );
      return;
    }
    if (name == "Peasant") {
      subCards = cardList.cards.sublist(
        cardList.cards.indexWhere((card) => card.name == "Soldier"),
        cardList.cards.indexWhere((card) => card.name == "Teacher") + 1,
      );
      return;
    }
    if (name == "Vampire") {
      subCards = cardList.cards.where((card) => card.name == "Bat").toList();
      return;
    }
    if (name == "Hermit") {
      subCards = cardList.cards.where((card) => card.name == "Madman").toList();
      return;
    }
    if (name.contains("/")) {
      List<String> subCardNames = name.split("/");
      subCards = [];
      for (String subCardName in subCardNames) {
        MyCard subCard = cardList.cards.firstWhere(
          (card) => card.name == subCardName.trim(),
        );
        subCards!.add(subCard);
      }
      return;
    }
    if (text.contains('Heirloom')) {
      subCards = subCards ?? [];
      MyCard subCard = cardList.cards.firstWhere(
        (card) => card.name == text.substring(text.indexOf("Heirloom:") + 10),
      );
      subCards!.add(subCard);
    }
    if (subCards != null) {
      return;
    }
    subCards = [];
  }

  List<AssetImage> getCostImages(CardList cardList) {
    parseSubCards(cardList);
    List<AssetImage> images = [];
    if (types.contains("Split pile") && subCards!.length < 4) {
      for (MyCard subCard in subCards!) {
        images.addAll(subCard.getCostImages(cardList));
        images.add(AssetImage('assets/images/divider.png'));
      }
      return images.sublist(0, images.length - 1);
    }
    if (cost != null) {
      images.add(AssetImage('assets/images/cost/Coin$cost.png'));
    }
    if (debt != null) {
      images.add(AssetImage('assets/images/cost/Debt$debt.png'));
    }
    if (potion) {
      images.add(AssetImage('assets/images/cost/Potion.png'));
    }
    return images;
  }

  Color getColor() {
    if (types.contains("Victory")) {
      return Colors.green;
    }
    if (types.contains("Treasure")) {
      return Colors.yellow;
    }
    return Colors.grey;
  }

  String getColorImage() {
    List<String> colorTypes = [];
    String path = "assets/images/colors/";
    for (String type in types) {
      if (colors.contains(type)) {
        colorTypes.add(type);
      }
    }
    if (colorTypes.length == 1) {
      return '$path${colorTypes[0].toLowerCase()}.png';
    }
    if (colorTypes.contains('Victory')) {
      if (colorTypes.contains('Action')) {
        return '${path}action_victory.png';
      }
      if (colorTypes.contains('Reserve')) {
        return '${path}reserve_victory.png';
      }
      if (colorTypes.contains('Treasure')) {
        return '${path}treasure_victory.png';
      }
      if (colorTypes.contains('Duration')) {
        return '${path}victory_duration.png';
      }
      if (colorTypes.contains('Reaction')) {
        return '${path}victory_reaction.png';
      }
      if (colorTypes.contains('Shelter')) {
        return '${path}victory_shelter.png';
      }
      return '${path}victory.png';
    }
    if (colorTypes.contains('Treasure')) {
      if (colorTypes.contains('Duration')) {
        return '${path}treasure_duration.png';
      }
      if (colorTypes.contains('Reaction')) {
        return '${path}treasure_reaction.png';
      }
      if (colorTypes.contains('Reserve')) {
        return '${path}treasure_reserve.png';
      }
      if (colorTypes.contains('Action')) {
        return '${path}action_treasure.png';
      }
      return '${path}treasure.png';
    }
    if (colorTypes.contains('Duration')) {
      if (colorTypes.contains('Reaction')) {
        return '${path}duration_reaction.png';
      }
      return '${path}duration.png';
    }
    if (colorTypes.contains('Reaction')) {
      return '${path}reaction.png';
    }
    if (colorTypes.contains('Ruins')) {
      return '${path}ruins.png';
    }
    if (colorTypes.contains('Action')) {
      if (colorTypes.contains('Shelter')) {
        return '${path}action_shelter.png';
      }
      return "${path}action.png";
    }
    debugPrint("Type not parsed to color correctly");
    return "${path}action.png";
  }

  @override
  String toString() {
    return """
    Name: $name
    Types: $types
    Expansion: $expansion
    Text: $text
    Categories: $categories
    Subcards: $subCards
    """;
  }
}
