import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/tag/update.dart';
import 'package:toolery/models/tag.dart';

// dedicated Widget to list all of the tags
class TagList extends StatelessWidget {
  const TagList({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Consumer<TagChangeNotifier>(
        builder: (context, tags, child) {
          return tags.tags.isNotEmpty
              ? ListView(
                  children: [
                    for (Tag tag in tags.tags)
                      ListTile(
                        title: Text(tag.name),
                        tileColor: tag.color,
                        onTap: () async {
                          await Navigator.push<bool>(
                            context,
                            MaterialPageRoute<bool>(
                              builder: (context) => UpdateTag(tag: tag),
                            ),
                          );
                        },
                      ),
                  ],
                )
              : Text("No tags yet :(");
        },
      ),
    );
  }
}
