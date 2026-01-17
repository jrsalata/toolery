import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/tag/update.dart';
import 'package:toolery/models/tag.dart';

// single-page to show all of the info on one tag
class TagInfo extends StatelessWidget {
  const TagInfo({super.key, required this.tagID});

  // single tag to view
  final int tagID;

  @override
  Widget build(BuildContext context) {
    final tagNotifier = context.watch<TagChangeNotifier>();
    return FutureBuilder<Tag>(
      future: tagNotifier.getTag(tagID),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        final Tag? tag = snapshot.data;
        return Scaffold(
          appBar: AppBar(title: Text(tag!.name)),
          body: Column(
            children: [
              CircleAvatar(backgroundColor: tag.color,)
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push<bool>(
                context,
                MaterialPageRoute<bool>(
                  builder: (context) => UpdateTag(tag: tag),
                ),
              );
            },
            child: const Icon(Icons.edit),
          ),
        );
      },
    );
  }
}
