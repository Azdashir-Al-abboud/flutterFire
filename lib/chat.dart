import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  final String title;
  final String body;
  const Chat({super.key, required this.title, required this.body});
  @override
  State<StatefulWidget> createState() => _Chat();
}

class _Chat extends State<Chat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat Example"),
      ),
      body: Column(
        children: [
          Text(widget.title),
          Text(widget.body),
        ],
      ),
    );
  }
}
