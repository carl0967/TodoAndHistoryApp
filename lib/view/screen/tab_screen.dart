import 'package:flutter/material.dart';
import 'package:src/view/screen/all_task_screen.dart';
import 'package:src/view/screen/history_screen.dart';
import 'package:src/view/screen/home_screen.dart';

class TabScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: TabBar(
            tabs: [
              Container(
                  width: MediaQuery.of(context).size.width / 4,
                  child: Tab(icon: Icon(Icons.home), text: "Home")),
              Container(
                  width: MediaQuery.of(context).size.width / 4,
                  child: Tab(icon: Icon(Icons.history), text: "History")),
              Container(
                  width: MediaQuery.of(context).size.width / 4,
                  child: Tab(icon: Icon(Icons.align_horizontal_left_outlined), text: "All")),
            ],
            isScrollable: true,
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('Drawer Header'),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: Text('Item 1'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              ListTile(
                title: Text('Item 2'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            HomeScreen(),
            HistoryScreen(),
            AllTaskScreen(),
          ],
        ),
      ),
    );
  }
}
