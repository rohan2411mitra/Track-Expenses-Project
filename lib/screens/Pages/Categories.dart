import 'package:flutter/material.dart';
import '../../utils/color_utils.dart';

class Categories extends StatefulWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        elevation: 0,
        title: const Text(
          "Categories",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              hexStringToColor("333333"),
              hexStringToColor("444444"),
              hexStringToColor("555555")
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ListView(
                children: [
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        textColor: Colors.black,
                        trailing: const Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.white,
                        ),
                        title: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 5,horizontal: 2),
                          child: Text("Settings"),
                        )
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        textColor: Colors.black,
                        trailing: const Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.white,
                        ),
                        title: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 5,horizontal: 2),
                          child: Text("Settings"),
                        )
                    ),
                  ),
                ],
              )
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8.0),
              ),
              margin: EdgeInsets.all(10.0),
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Add item',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (String value) {
                        print("hi");
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle),
                    onPressed: () {
                      // Add item to list
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
