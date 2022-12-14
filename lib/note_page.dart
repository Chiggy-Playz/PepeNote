import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models.dart';

class NotePage extends StatefulWidget {
  Note? note;
  int index;
  NotePage({var key, required this.index, this.note}) : super(key: key);

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final _formKey = GlobalKey<FormState>();
  var _title = "";
  var _content = "";

  void saveAction(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    if (widget.note == null) {
      widget.note = Note(title: _title, content: _content);
    } else {
      widget.note!.title = _title;
      widget.note!.content = _content;
    }

    if (widget.index == -1) {
      Hive.box<Note>("notes").add(widget.note!);
    } else {
      Hive.box<Note>("notes").putAt(widget.index, widget.note!);
    }
    Navigator.of(context).pop();
  }

  void deleteAction(BuildContext context) async {
    bool res = false;
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        res = false;
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Yes"),
      onPressed: () {
        res = true;
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete note?"),
      content: Text("Are you sure you want to delete this note?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    if (res) {
      Hive.box<Note>("notes").deleteAt(widget.index);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.index == -1 ? "New Note" : "Edit Note"),
        actions: [
          IconButton(
              onPressed: () => saveAction(context), icon: Icon(Icons.save)),
          if (widget.index != -1) ...[
            IconButton(
              onPressed: () => deleteAction(context),
              icon: Icon(Icons.delete),
            ),
          ]
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: widget.note?.title ?? "",
                decoration: InputDecoration(
                  hintText: "Title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) => value != null && value.isEmpty
                    ? "Value must not be empty"
                    : null,
                // We always validate first, and then save, so newValue should never be null
                onSaved: (newValue) => _title = newValue ?? "null",
              ),
              SizedBox(height: 16),
              Expanded(
                child: Container(
                  child: TextFormField(
                    initialValue: widget.note?.content ?? "",
                    textAlignVertical: TextAlignVertical.top,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      hintText: "Type here!   (* ^ ω ^)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) => value != null && value.isEmpty
                        ? "Value must not be empty"
                        : null,
                    // We always validate first, and then save, so newValue should never be null
                    onSaved: (newValue) => _content = newValue ?? "null",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
