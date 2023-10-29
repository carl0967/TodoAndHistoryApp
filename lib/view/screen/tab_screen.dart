import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:src/view/screen/all_task_screen.dart';
import 'package:src/view/screen/history_screen.dart';
import 'package:src/view/screen/home_screen.dart';

import '../../provider/task_provider.dart';

class TabScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                title: Text('Import'),
                onTap: () {
                  ref.read(taskListProvider.notifier).importJson();
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
