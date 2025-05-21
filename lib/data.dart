import 'dart:convert';
import 'package:flutter/services.dart';

class CardList {
  final List<Card> cards;

  CardList({required this.cards});

  static Future<CardList> fromAsset() async {
    final String data = await rootBundle.loadString('assets/data.json');
    final List<Map<String, dynamic>> json = jsonDecode(data);
    return CardList(
      cards: json.map((card) => Card.fromMap(card)).toList(),
    );
  }

  List<Card> getCardsByExpansion(String expansion) {
    return cards
        .where((card) => card.expansion == expansion && card.categories.isEmpty)
        .toList();
  }

  List<Card> getPlayset(List<String> selectedExpansions) {
    List<Card> cardsInExpansions = [];

    for (String expansion in selectedExpansions) {
      cardsInExpansions.addAll(getCardsByExpansion(expansion));
    }
    cardsInExpansions.shuffle();
    
    List<Card> playset = [];
    
    for (int i = 0; i < 10; i++) {
      if (cardsInExpansions.isEmpty) {
        break;
      }
      playset.add(cardsInExpansions.removeAt(0));
    }
    return playset;
  }
}

class Card {
  final String name;
  final List<String> types;
  final String expansion;
  final String text;
  final int? cost;
  final int? victoryPoints;
  final int? debt;
  final int? maxCards;
  final int? actions;
  final int? buys;
  final int? coinsCoffers;
  final List<String> categories;

  Card({
    required this.name,
    required this.types,
    required this.expansion,
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

  Card.fromMap(Map<String, dynamic> map)
      : name = map['name'],
        types = List<String>.from(map['types']),
        expansion = map['set'],
        text = map['text'],
        cost = parseCost(map['cost']),
        victoryPoints = parseVictoryPoints(map['victoryPoints']),
        debt = parseDebt(map['debt']),
        maxCards = parseMaxCards(map['cards']),
        actions = parseActions(map['actions']),
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
    final int positiveVpValue = int.parse(vpString.split('+')[1].split('VP')[0]);
    final int negativeVpValue = int.parse(vpString.split('-')[1].split('VP')[0]);
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
    final int positiveMaxCardsValue = int.tryParse(maxCardsString.split('+')[1].split(',')[0]) ?? 0;
    final int negativeMaxCardsValue = int.tryParse(maxCardsString.split('-')[1].split(',')[0]) ?? 0;
    return positiveMaxCardsValue - negativeMaxCardsValue;
  }

  static int? parseActions(String actionsString) {
    if (actionsString.isEmpty) {
      return null;
    }
    final int actionsValue = int.tryParse(actionsString.split('+')[1].split(',')[0]) ?? 0;
    return actionsValue;
  }

  static int? parseBuys(String buysString) {
    if (buysString.isEmpty) {
      return null;
    }
    final int buysValue = int.tryParse(buysString.split('+')[1].split(',')[0]) ?? 0;
    return buysValue;
  }

  static int? parseCoinsCoffers(String coinsCoffersString) {
    if (coinsCoffersString.isEmpty) {
      return null;
    }
    final int coinsValue = int.tryParse(coinsCoffersString.split('\$')[1].split(',')[0]) ?? 0;
    final int coffersValue = int.tryParse(coinsCoffersString.split('+')[1].split('CFR')[0]) ?? 0;
    final int coinsCoffersValue = coinsValue + coffersValue;
    return coinsCoffersValue;
  }
}