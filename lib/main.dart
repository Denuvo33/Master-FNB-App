import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:master_foodapp/model/food_model.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseReference? dbref;
  DatabaseReference? dbUpdate;
  Map<String, List<FoodItem>> userFoodItems = {};
  bool dataLoad = false;
  String orderStatus = 'Cooked';

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() {
    dbref = FirebaseDatabase.instance.ref().child('inOrder');
    dbref!.onValue.listen((event) {
      final data = event.snapshot.value;

      if (data != null && data is Map) {
        userFoodItems = {};

        data.entries.forEach((userEntry) {
          final userItemsData = userEntry.value as Map<dynamic, dynamic>;
          final userItems = userItemsData.entries.map((itemEntry) {
            final itemData = itemEntry.value as Map<dynamic, dynamic>;
            final name = itemData['name'];
            final image = itemData['image'];
            final uid = itemData['uid'];
            final total = itemData['total'];
            final address = itemData['address'];
            final userName = itemData['userName'];
            setState(() {
              orderStatus = itemData['status'];
            });
            return FoodItem(
                name: name,
                image: image,
                status: orderStatus,
                total: total,
                userName: userName,
                uid: uid,
                address: address);
          }).toList();

          final uid = userItemsData.values.first['uid'];

          userFoodItems[uid] = userItems;
        });

        setState(() {
          dataLoad = true;
        });
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(10),
          child: Visibility(
            visible: dataLoad,
            replacement: Center(
              child: Text('No order'),
            ),
            child: RefreshIndicator(
              onRefresh: () async {
                await getData();
              },
              child: ListView.builder(
                itemCount: userFoodItems.length,
                itemBuilder: (BuildContext context, int index) {
                  final userItems = userFoodItems.values.toList()[index];
                  final userName = userItems.first.userName;

                  return Card(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Order From: $userName',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        Text('Address: ${userItems[index].address}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: userItems.length,
                          itemBuilder: (BuildContext context, int itemIndex) {
                            final foodItem = userItems[itemIndex];

                            return ListTile(
                              title: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(foodItem.name),
                                      ElevatedButton(
                                        onPressed: () {
                                          debugPrint('Click it');
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text(
                                                      'Change Order Status'),
                                                  content: SizedBox(
                                                    height: 120,
                                                    child: Column(
                                                      children: [
                                                        TextButton(
                                                            onPressed:
                                                                () async {
                                                              dbUpdate = FirebaseDatabase
                                                                  .instance
                                                                  .ref()
                                                                  .child(
                                                                      'inOrder')
                                                                  .child(foodItem
                                                                      .uid
                                                                      .toString())
                                                                  .child(
                                                                      '${foodItem.name + foodItem.uid.toString()}');
                                                              await dbUpdate!
                                                                  .update({
                                                                'status':
                                                                    'Cooked'
                                                              });
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child:
                                                                Text('Cooked')),
                                                        Divider(),
                                                        TextButton(
                                                            onPressed:
                                                                () async {
                                                              dbUpdate = FirebaseDatabase
                                                                  .instance
                                                                  .ref()
                                                                  .child(
                                                                      'inOrder')
                                                                  .child(foodItem
                                                                      .uid
                                                                      .toString())
                                                                  .child(
                                                                      '${foodItem.name + foodItem.uid.toString()}');
                                                              await dbUpdate!
                                                                  .update({
                                                                'status':
                                                                    'Delivery'
                                                              });
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text(
                                                                'Delivery')),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              });
                                        },
                                        child: Text('Change Status'),
                                      )
                                    ],
                                  ),
                                  Divider(
                                    color: Colors.black,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Total Order: ${foodItem.total}'),
                                      Text(
                                        'Status:${foodItem.status!}',
                                        style: TextStyle(color: Colors.green),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              leading: Image.network(foodItem.image),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
