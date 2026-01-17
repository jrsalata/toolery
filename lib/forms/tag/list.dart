import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/tag/update.dart';
import 'package:toolery/models/tag.dart';

// dedicated Widget to list all of the tags
class TagList extends StatelessWidget {
  const TagList({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Consumer<TagChangeNotifier>(
        builder: (context, tags, child) {
          return tags.tags.isNotEmpty
              ? GridView.count(
                  crossAxisCount: 3,
                  childAspectRatio: 1.0, // square tiles
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  padding: const EdgeInsets.all(8),
                  shrinkWrap: true,
                  children: [
                    for (Tag tag in tags.tags)
                      Material(
                        borderRadius: BorderRadius.circular(12),
                        color: tag.color,
                        child: InkWell(
                          onTap: () async {
                            await Navigator.push<bool>(
                              context,
                              MaterialPageRoute<bool>(
                                builder: (context) => UpdateTag(tag: tag),
                              ),
                            );
                          },
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                tag.name,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              : Text("No tags yet :(");
        },
      ),
    );
  }
}
