import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: new MyHomePage(title: 'Indian Food'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<FoodItemCard> foodList = List<FoodItemCard>();
  bool isInBasket = false;

  Widget foodCard({name, description, photo, price, weight}){
    return Card(
      color: Colors.white70,
      margin: EdgeInsets.all(4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 100.0,
            alignment: Alignment.topCenter,
            padding: EdgeInsets.all(5.0),
            child: Image.network(
              photo,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            margin: EdgeInsets.all(5.0),
            alignment: Alignment.topLeft,
            padding: EdgeInsets.all(6.0),
            child: Text(
              name,
              style: TextStyle(
                  color: Colors.black45,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: EdgeInsets.all(5.0),
            child: Text(
              description,
              style: TextStyle(fontSize: 13.0),
            ),
          ),
          IconButton(
              icon: Icon(Icons.shopping_basket),
              onPressed: () {
                setState(() {
                  this.isInBasket = true;
                  foodList.add(FoodItemCard(
                      name: name,
                      description: description,
                      photo: photo,
                      price: price,
                      weight: weight));
                  print(foodList);
                });
              }),
        ],
      ),
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final Iterable<ListTile> tiles = foodList.map(
                (FoodItemCard foodItem) {
              return new ListTile(
                title: new Text(
                  foodItem.name,
                  style: TextStyle(fontSize: 22.0),
                ),
              );
            },
          );
          final List<Widget> divided = ListTile
              .divideTiles(
            context: context,
            tiles: tiles,
          )
              .toList();
          return new Scaffold(
            appBar: new AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: new ListView(children: divided),
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.shopping_basket),
            onPressed: _pushSaved
          ),
        ],
        title: new Text(widget.title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('food_cards').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return new Center(child: CircularProgressIndicator());
          return new GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            scrollDirection: Axis.vertical,
            children: snapshot.data.documents.map((DocumentSnapshot document) {
              return new Column(
                children: <Widget>[
                  foodCard(
                    name: document['name'],
                    description: document['description'],
                    photo: document['photo'],
                    price: document['price'],
                    weight: document['weight'],
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class FoodItemCard {
  final String name;
  final String description;
  final String photo;
  final price;
  final weight;

  const FoodItemCard({
    this.name,
    this.description,
    this.photo,
    this.price,
    this.weight,
  });
}
