import 'package:flutter/material.dart';
import 'data.dart';

class ResponseWidget extends StatelessWidget {
  final List<MyCard> response;

  const ResponseWidget({super.key, required this.response});

  void _showCardImage(BuildContext context, MyCard card) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(card.name),
          content: SingleChildScrollView(
            child: FutureBuilder(
              future: precacheImage(NetworkImage(card.imageUrl ?? ''), context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Image.network(card.imageUrl ?? '');
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
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
          ...response.map((card) {
            return Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: ElevatedButton(
                onPressed: () => _showCardImage(context, card),
                child: Row(
                  children: [
                    SizedBox(
                      width: 10
                    ),
                    Expanded(child: Text(card.expansion)), 
                    Expanded(child: Text(card.name))
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}