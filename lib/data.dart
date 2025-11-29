import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';

class CardList {
  final List<MyCard> cards;

  CardList({required this.cards});

  static Future<CardList> fromAsset() async {
    refreshOwned();
    final String data = await rootBundle.loadString('assets/data.json');
    final List json = jsonDecode(data);
    return CardList(cards: json.map((card) => MyCard.fromMap(card)).toList());
  }

  List<MyCard> getCardsByExpansion(String expansion) {
    return cards
        .where((card) => card.expansion == expansion && card.categories.isEmpty)
        .toList();
  }

  List<MyCard> getPlayset(List<String> selectedExpansions) {
    List<MyCard> cardsInExpansions = [];

    for (String expansion in selectedExpansions) {
      cardsInExpansions.addAll(getCardsByExpansion(expansion));
    }
    cardsInExpansions.shuffle();

    return cardsInExpansions.take(10).toList();
  }

  List<MyCard> getFairPlayset(List<String> selectedExpansions) {
    List<List<MyCard>> cardsInExpansions = [];

    for (String expansion in selectedExpansions) {
      List<MyCard> expCards = getCardsByExpansion(expansion);
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

  List<MyCard> getLandscapeCards(List<String> selectedExpansions, int count) {
    List<MyCard> newCards = [];
    List<String> landscapeTypes = [
      "Event",
      "Landmark",
      "Project",
      "Way",
      "Trait",
    ];
    for (String expansion in selectedExpansions) {
      newCards.addAll(
        cards.where(
          (card) =>
              card.types.any((type) => landscapeTypes.contains(type)) &&
              card.expansion == expansion,
        ),
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
    List<String> selectedExpansions,
    String category,
    int count,
  ) {
    List<MyCard> newCards = [];
    for (String expansion in selectedExpansions) {
      newCards.addAll(
        cards.where(
          (card) =>
              card.categories.contains(category) && card.expansion == expansion,
        ),
      );
    }
    newCards.shuffle();
    return newCards.take(count).toList();
  }

  List<MyCard> getCardsByType(
    List<String> selectedExpansions,
    String type,
    int count,
  ) {
    List<MyCard> newCards = [];
    for (String expansion in selectedExpansions) {
      newCards.addAll(
        cards.where(
          (card) => card.types.contains(type) && card.expansion == expansion,
        ),
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

  static Future refreshOwned() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? preferredExpansions = prefs.getStringList(
      'ownedExpansions',
    );
    if (preferredExpansions != null && preferredExpansions.isNotEmpty) {
      ownedExpansions = preferredExpansions;
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

List<String> ownedExpansions = [
  'Dominion',
  'Intrigue',
  'Dark Ages',
  'Alchemy',
  'Adventures',
  'Empires',
  'Nocturne',
  'Rising Sun',
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
    if (expansionString.contains('Dominion') &&
        expansionString.contains('1E')) {
      return 'Dominion';
    }
    if (expansionString.contains('Intrigue') &&
        expansionString.contains('2E')) {
      return 'Intrigue';
    }
    return expansionString;
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
      subCards = cardList.cards.where((card) => card.name == "Hermit").toList();
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

  Future<String?> getImageUrl() async {
    if (imageUrl != null) {
      return imageUrl;
    }
    final apiUrl = Uri.parse(
      "https://wiki.dominionstrategy.com/api.php?action=query&titles=File:$name.jpg&prop=imageinfo&iiprop=url&format=json",
    );

    final response = await get(apiUrl);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      imageUrl = json['query']['pages'].values.first['imageinfo'].first['url'];
    }
    return imageUrl;
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
