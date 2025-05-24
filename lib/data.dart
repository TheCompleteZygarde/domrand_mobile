import 'dart:convert';
import 'package:flutter/services.dart';

class CardList {
  final List<MyCard> cards;

  CardList({required this.cards});

  static Future<CardList> fromAsset() async {
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
}

Map<String, int> expansionMap = {
  'Dominion': 0,
  'Intrigue': 1,
  'Dark Ages': 2,
  'Alchemy': 3,
  'Adventures': 4,
  'Empires': 5,
  'Nocturne': 6,
};

class MyCard {
  final String name;
  final List<String> types;
  final String expansion;
  final int expansionIndex;
  final String text;
  final int? cost;
  final int? victoryPoints;
  final int? debt;
  final int? maxCards;
  final int? actions;
  final int? buys;
  final int? coinsCoffers;
  final List<String> categories;

  MyCard({
    required this.name,
    required this.types,
    required this.expansion,
    required this.expansionIndex,
    required this.text,
    this.cost,
    this.victoryPoints,
    this.debt,
    this.maxCards,
    this.actions,
    this.buys,
    this.coinsCoffers,
    this.categories = const [],
  });

  MyCard.fromMap(Map<String, dynamic> map)
      : name = map['name'],
        types = List<String>.from(map['types']),
        expansion = map['set'],
        expansionIndex = expansionMap[map['set']] ?? 0,
        text = map['text'],
        cost = parseCost(map['cost']),
        victoryPoints = parseVictoryPoints(map['victoryPoints']),
        debt = parseDebt(map['cost']),
        maxCards = parseMaxCards(map['cards']),
        actions = parseActions(map['actionsVillagers']),
        buys = parseBuys(map['buys']),
        coinsCoffers = parseCoinsCoffers(map['coinsCoffers']),
        categories = List<String>.from(map['categories']);

  static String parseExpansion(String expansionString) {
    if (expansionString == 'Dominon, 1E') {
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
}