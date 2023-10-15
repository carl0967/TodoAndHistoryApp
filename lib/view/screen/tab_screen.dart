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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight + 18), //AppBarのtitleを無理やり非表示にする
          child: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home), text: "Home"),
                Tab(icon: Icon(Icons.history), text: "History"),
                Tab(icon: Icon(Icons.align_horizontal_left_outlined), text: "All"),
              ],
            ),
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
