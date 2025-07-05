import 'dart:convert';
import 'dart:math';
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
    return CardList(
      cards: json.map((card) => MyCard.fromMap(card)).toList(),
    );
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
    
    List<MyCard> playset = [];
    
    for (int i = 0; i < 10; i++) {
      if (cardsInExpansions.isEmpty) {
        break;
      }
      playset.add(cardsInExpansions.removeAt(0));
    }
    return playset;
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
    final List<String>? preferredExpansions = prefs.getStringList('ownedExpansions');
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
  'Promo': 17,
  /* The following expansions are not included in data.json
  'Allies': 15,
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
    if (expansionString.contains('Dominion') && expansionString.contains('1E')) {
      return 'Dominion';
    }
    if (expansionString.contains('Intrigue') && expansionString.contains('2E')) {
      return 'Intrigue';
    }
    return expansionString;
  }

  static int? parseCost(String costString) {
    if (!costString.contains('\$')) {
      return null;
    }
    final String costValue = costString.split('\$')[1];
    return int.tryParse(costValue);
  }

  static int? parseVictoryPoints(String vpString) {
    if (vpString.isEmpty) {
      return null;
    }
    int positiveVpValue = 0;
    int negativeVpValue = 0;
    if (vpString.contains('+')) {
      positiveVpValue = int.tryParse(vpString.split('+')[1].split('VP')[0]) ?? 0;
    }
    if (vpString.contains('-')) {
      negativeVpValue = int.tryParse(vpString.split('-')[1].split('VP')[0]) ?? 0;
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
      positiveMaxCardsValue = int.tryParse(maxCardsString.split('+')[1].split(',')[0]) ?? 0;
    }
    if (maxCardsString.contains('-')) {
      negativeMaxCardsValue = int.tryParse(maxCardsString.split('-')[1].split(',')[0]) ?? 0;
    }
    return positiveMaxCardsValue - negativeMaxCardsValue;
  }

  static int? parseActions(String actionsString) {
    if (actionsString.isEmpty) {
      return null;
    }
    int actionsValue = 0;
    if (actionsString.contains('+')) {
      actionsValue = int.tryParse(actionsString.split('+')[1].split(',')[0]) ?? 0;
    }
    if (actionsString.contains('-')) {
      actionsValue -= int.tryParse(actionsString.split('-')[1].split(',')[0]) ?? 0;
    }
    if (actionsString.contains('P')) {
        actionsValue += int.tryParse(actionsString.split('P')[1].split(',')[0]) ?? 0;
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
        coinsCoffersValue = int.tryParse(coinsCoffersString.split('\$')[1].split(',')[0]) ?? 0;
    }
    if (coinsCoffersString.contains('CFR')) {
        coinsCoffersValue += int.tryParse(coinsCoffersString.split('+')[1].split('CFR')[0]) ?? 0;
    }
    if (coinsCoffersString.contains('R')) {
        coinsCoffersValue -= int.tryParse(coinsCoffersString.split('R')[1].split(',')[0]) ?? 0;
    }
    return coinsCoffersValue;
  }

  Future<String?> getImageUrl() async {
    if (imageUrl != null) {
      return imageUrl;
    }
    final apiUrl = Uri.parse("https://wiki.dominionstrategy.com/api.php?action=query&titles=File:$name.jpg&prop=imageinfo&iiprop=url&format=json");

    final response = await get(apiUrl);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      imageUrl = json['query']['pages'].values.first['imageinfo'].first['url'];
    }
    return imageUrl;
  }
}