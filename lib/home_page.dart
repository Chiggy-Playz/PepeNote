import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models.dart';
import 'note_page.dart';

class HomePage extends StatefulWidget {
  HomePage({key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget getListTile(Note note, int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: Colors.lightGreen[200],
        title: Text(note.title),
        subtitle: Text(
          note.content,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        onTap: () => pushNotePage(note, index),
        isThreeLine: true,
      ),
    );
  }

  void pushNotePage(Note? note, int index) {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (_, __, ___) => NotePage(note: note, index: index),
        transitionDuration: Duration(milliseconds: 300),
        transitionsBuilder: (_, a, __, c) {
          // https://stackoverflow.com/questions/56792479/flutter-animate-transition-to-named-route
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: a.drive(tween),
            child: c,
          );
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Note>("notes").listenable(),
        builder: (context, Box<Note> box, child) {
          if (box.isEmpty) {
            return Center(
              child: Text(
                  "You have no notes yet. Get started by clicking that button!"),
            );
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              // Show in descending order
              var note = box.getAt(box.length - 1 - index);
              // This shouldn't ever happen, this is only to satify the type checker
              if (note == null) {
                return Text(
                    "Whoopsie Daisy! Something went super wrong  ☆⌒(> _ <)");
              }
              return getListTile(note, box.length - 1 - index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => pushNotePage(null, -1),
        tooltip: 'Create a note',
        child: Icon(Icons.add),
      ),
    );
  }
}
