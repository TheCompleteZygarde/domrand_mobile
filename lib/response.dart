import 'package:flutter/material.dart';
import 'data.dart';
import 'dart:math';

class ResponseWidget extends StatefulWidget {
  final List<MyCard> response;
  final Set<MyCard> landscapeCards;
  final Set<String> flags;
  final CardList cardList;

  const ResponseWidget({super.key, required this.response, required this.landscapeCards, required this.flags, required this.cardList});

  @override
  State<ResponseWidget> createState() => _ResponseWidgetState();
}

class _ResponseWidgetState extends State<ResponseWidget> {
  final TextEditingController _controller = TextEditingController();
  final CarouselController _carouselController = CarouselController();
  int _startingPlayer = 0;

  void _showCardImage(BuildContext context, MyCard card) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        card.parseSubCards(widget.cardList);
        return AlertDialog(
          title: Text(card.name),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: CarouselView.weighted(
              controller: _carouselController,
              itemSnapping: true,
              flexWeights: const <int>[1, 7, 1],
              children: [
                FutureBuilder(
                  future: card.getImageUrl(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error loading image, could not fetch from the wiki');
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return Text('No image available');
                    }
                    final String imageUrl = snapshot.data!;
                    return FutureBuilder(
                      future: precacheImage(NetworkImage(imageUrl), context),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Image.network(imageUrl);
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    );
                  }
                ),
                for (MyCard subCard in card.subCards!)
                  FutureBuilder(
                    future: subCard.getImageUrl(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error loading image, could not fetch from the wiki');
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return Text('No image available');
                      }
                      final String imageUrl = snapshot.data!;
                      return FutureBuilder(
                        future: precacheImage(NetworkImage(imageUrl), context),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            return Image.network(imageUrl);
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      );
                    }
                  ),
                ]
              ),
            ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Response'),
      ),
      body: ListView(
        children: [
          Center(child: Text("Cards to be used:", style: Theme.of(context).textTheme.titleLarge)),
          Divider(),
          ...widget.response.map((card) {
            return Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: ElevatedButton(
                onPressed: () => _showCardImage(context, card),
                child: Row(
                  children: [
                    Image(
                      image: AssetImage('assets/images/${card.expansion.replaceAll(" ", "_")}_icon.png'),
                      width: 24,
                      height: 24,
                    ),
                    SizedBox(
                      width: 5
                    ),
                    Expanded(child: Text(card.expansion)),
                    for (AssetImage image in card.getCostImages(widget.cardList))
                      Image(image: image, width: 24, height: 24),
                    SizedBox(
                      width: 5
                    ),
                    Expanded(child: Text(card.name))
                  ],
                ),
              ),
            );
          }),
          Divider(),
          if (widget.landscapeCards.isNotEmpty)
            Center(child: Text("Landscape cards to use:", style: Theme.of(context).textTheme.titleLarge)),
          ...widget.landscapeCards.map((card) {
            return Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: ElevatedButton(
                onPressed: () => _showCardImage(context, card),
                child: Row(
                  children: [
                    Image(
                      image: AssetImage('assets/images/${card.expansion.replaceAll(" ", "_")}_icon.png'),
                      width: 24,
                      height: 24,
                    ),
                    SizedBox(
                      width: 5
                    ),
                    Expanded(child: Text(card.expansion)),
                    for (AssetImage image in card.getCostImages(widget.cardList))
                      Image(image: image, width: 24, height: 24),
                    SizedBox(
                      width: 5
                    ),
                    Expanded(child: Text(card.name))
                  ],
                ),
              ),
            );
          }),
          Divider(),
          Center(child: Text("Setup to do:", style: Theme.of(context).textTheme.titleLarge)),
          for (MyCard card in widget.response.where((MyCard card) => card.setup != null && card.setup!.isNotEmpty)) 
            Card(
              child: Column(
                children: [
                  Text(card.name, style: Theme.of(context).textTheme.titleMedium,),
                  Text(card.setup!),
                ],
              ),
            ),
          Center(child: Text("You will need:", style: Theme.of(context).textTheme.titleMedium)),
          Padding(
            padding: const EdgeInsets.only(left:20.0), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.flags.contains("reserve"))
                  Text("Tavern Mat"),
                if (widget.flags.contains("debt"))
                  Text("Debt counters"),
                if (widget.flags.contains("VPtokens"))
                  Text("Victory Point tokens"),
                if (widget.flags.contains("ruins"))
                  Text("Ruins cards"),
                if (widget.flags.contains("boons"))
                  Text("Boons"),
                if (widget.flags.contains("hexes"))
                  Text("Hexes"),
                if (widget.flags.contains("spirits"))
                  Text("Spirit cards"),
                if (widget.flags.contains("spoils"))
                  Text("Spoils cards"),
                if (widget.flags.contains("wish"))
                  Text("Wish cards"),
                if (widget.flags.contains("potion"))
                  Text("Potion cards"),
                if (widget.flags.contains("omen"))
                  Text("Use a Prophecy card. Put an amount of Sun tokens on it dependent on the number of players: 5 for 2 players, 8 for 3 players, 10 for 4 players, 12 for 5 players and 13 for 6 players."),
                if (widget.flags.contains("shelters"))
                  Text("You should play with Shelters.", style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
          Divider(),
          Center(
            child: Text(
              "Randomize who goes first",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          SizedBox(height: 10),
          Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Enter number of players',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      int? inputNumber = int.tryParse(_controller.text);
                      if (inputNumber == null || inputNumber < 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please enter a valid number of players')),
                        );
                        return;
                      }
                      Random random = Random();
                      int randomNumber = random.nextInt(inputNumber) + 1;
                      _startingPlayer = randomNumber;
                    });
                  }, 
                  child: Text('Randomize'))
              ],
          ),
          if (_startingPlayer > 0)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Starting player is player $_startingPlayer",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          SizedBox(height: 60.0),
        ],
      ),
    );
  }
}