import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:src/model/status_change.dart';

class StatusChangeEditScreen extends StatefulWidget {
  final StatusChange statusChange;

  StatusChangeEditScreen({required this.statusChange});

  @override
  _StatusChangeEditScreenState createState() => _StatusChangeEditScreenState();
}

class _StatusChangeEditScreenState extends State<StatusChangeEditScreen> {
  late DateTime changeTime;
  final TextEditingController _changeTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    changeTime = widget.statusChange.changeTime;
    _changeTimeController.text = DateFormat('y/MM/dd HH:mm').format(changeTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("状態遷移の編集"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _save(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            SizedBox(
              width: 150,
              child: TextField(
                controller: _changeTimeController,
                decoration: InputDecoration(
                  labelText: "変更した時刻",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save(BuildContext context) {
    final content = _changeTimeController.text;
    try {
      widget.statusChange.changeTime = DateFormat('y/MM/dd HH:mm').parse(content);
    } catch (e) {
      print("Invalid start time format");
    }
  }
}
