import 'package:flutter/material.dart';

class StockSelection extends StatefulWidget {
  @override
  State<StockSelection> createState() => _StockSelectionState();
}

class _StockSelectionState extends State<StockSelection> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Symbol'),
      ),
      body: Form(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: TextFormField(
                  controller: _textController,
                  textInputAction: TextInputAction.go,
                  autofocus: true,
                  onFieldSubmitted: (value) {
                    Navigator.pop(context, value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Symbol',
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.pop(context, _textController.text);
              },
            )
          ],
        ),
      ),
    );
  }
}
