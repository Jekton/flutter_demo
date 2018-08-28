import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final buildings = [
      Building(BuildingType.theater, 'CineArts at the Empire', '85 W Portal Ave'),
      Building(BuildingType.theater, 'The Castro Theater', '429 Castro St'),
      Building(BuildingType.theater, 'Alamo Drafthouse Cinema', '2550 Mission St'),
      Building(BuildingType.theater, 'Roxie Theater', '3117 16th St'),
      Building(BuildingType.theater, 'United Artists Stonestown Twin', '501 Buckingham Way'),
      Building(BuildingType.theater, 'AMC Metreon 16', '135 4th St #3000'),
      Building(BuildingType.restaurant, 'K\'s Kitchen', '1923 Ocean Ave'),
      Building(BuildingType.restaurant, 'Chaiya Thai Restaurant', '72 Claremont Blvd'),
      Building(BuildingType.restaurant, 'La Ciccia', '291 30th St'),

      // double 一下
      Building(BuildingType.theater, 'CineArts at the Empire', '85 W Portal Ave'),
      Building(BuildingType.theater, 'The Castro Theater', '429 Castro St'),
      Building(BuildingType.theater, 'Alamo Drafthouse Cinema', '2550 Mission St'),
      Building(BuildingType.theater, 'Roxie Theater', '3117 16th St'),
      Building(BuildingType.theater, 'United Artists Stonestown Twin', '501 Buckingham Way'),
      Building(BuildingType.theater, 'AMC Metreon 16', '135 4th St #3000'),
      Building(BuildingType.restaurant, 'K\'s Kitchen', '1923 Ocean Ave'),
      Building(BuildingType.restaurant, 'Chaiya Thai Restaurant', '72 Claremont Blvd'),
      Building(BuildingType.restaurant, 'La Ciccia', '291 30th St'),
    ];
    return MaterialApp(
      title: 'ListView demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Buildings'),
        ),
        body: BuildingListView(buildings, (index) => debugPrint('item $index clicked'))
      ),
    );
  }
}



enum BuildingType { theater, restaurant }

class Building {
  final BuildingType type;
  final String title;
  final String address;

  Building(this.type, this.title, this.address);
}

typedef OnItemClickListener = void Function(int position);

class ItemView extends StatelessWidget {
  final int position;
  final Building building;
  final OnItemClickListener listener;

  ItemView(this.position, this.building, this.listener);

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
        building.type == BuildingType.restaurant
            ? Icons.restaurant
            : Icons.theaters,
        color: Colors.blue[500]);

    final widget = Row(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(16.0),
          child: icon,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(building.title,
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                  )),
              Text(building.address)
            ],
          ),
        )
      ],
    );

    return InkWell(
      onTap: () => listener(position),
      child: widget
    );
  }
}

class BuildingListView extends StatelessWidget {
  final List<Building> buildings;
  final OnItemClickListener listener;

  BuildingListView(this.buildings, this.listener);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: buildings.length,
      itemBuilder: (context, index) {
        return new ItemView(index, buildings[index], listener);
      }
    );
  }
}
