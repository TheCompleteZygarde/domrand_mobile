import 'package:domrand_mobile/data.dart';
import 'package:flutter/material.dart';
import 'package:domrand_mobile/expansion_choice.dart';
import 'package:domrand_mobile/settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dominion Randomizer',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const MyHomePage(title: 'Dominion Randomizer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {

    Future<CardList> cardListFuture = getCardList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {

            final CardList cardList = await cardListFuture;

            if (!context.mounted) {
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExpansionChoice(cardList: cardList)
              ),
            );
          },
          child: const Text('Generate Dominion set'),
        ),
      ),
    );
  }

  Future<CardList> getCardList() async {
    return await CardList.fromAsset();
  }
}
