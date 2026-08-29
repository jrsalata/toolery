import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:toolery/models/tag.dart';
import 'package:toolery/notifiers/tag.dart';

/// Shared layout for creating and editing a journal entry.
///
/// The title scrolls away with the rest of the page so the editor can reach
/// the top of the screen, tags live behind an AppBar icon + bottom sheet
/// instead of taking up permanent space, and the Quill toolbar is trimmed to
/// a handful of buttons docked at the bottom, collapsible via a chevron.
class JournalForm extends StatefulWidget {
  const JournalForm({
    super.key,
    required this.formKey,
    required this.appBarTitle,
    required this.titleController,
    required this.titleAutofocus,
    required this.quillController,
    required this.initialTagIDs,
    required this.onTagIDsChanged,
    required this.onSave,
    this.onDelete,
  });

  final GlobalKey<FormState> formKey;
  final String appBarTitle;
  final TextEditingController titleController;
  final bool titleAutofocus;
  final QuillController quillController;
  final List<int> initialTagIDs;
  final ValueChanged<List<int>> onTagIDsChanged;
  final VoidCallback onSave;
  final VoidCallback? onDelete;

  @override
  State<JournalForm> createState() => _JournalFormState();
}

class _JournalFormState extends State<JournalForm> {
  late List<int> _tagIDs;
  bool _toolbarExpanded = true;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  static const _toolbarConfig = QuillSimpleToolbarConfig(
    multiRowsDisplay: false,
    showDividers: false,
    showFontFamily: false,
    showFontSize: true,
    showBoldButton: true,
    showItalicButton: true,
    showSmallButton: false,
    showUnderLineButton: true,
    showLineHeightButton: false,
    showStrikeThrough: false,
    showInlineCode: false,
    showColorButton: false,
    showBackgroundColorButton: false,
    showClearFormat: false,
    showAlignmentButtons: false,
    showLeftAlignment: false,
    showCenterAlignment: false,
    showRightAlignment: false,
    showJustifyAlignment: false,
    showHeaderStyle: false,
    showListNumbers: true,
    showListBullets: true,
    showListCheck: true,
    showCodeBlock: false,
    showQuote: false,
    showIndent: false,
    showLink: true,
    showUndo: true,
    showRedo: true,
    showDirection: false,
    showSearchButton: false,
    showSubscript: false,
    showSuperscript: false,
  );

  @override
  void initState() {
    super.initState();
    _tagIDs = List<int>.from(widget.initialTagIDs);
  }

  @override
  void dispose() {
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  void _setTagIDs(List<int> tagIDs) {
    setState(() => _tagIDs = tagIDs);
    widget.onTagIDsChanged(List<int>.from(_tagIDs));
  }

  Future<void> _showTagSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tags',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Consumer<TagNotifier>(
                      builder: (context, tagNotifier, _) {
                        return Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (Tag tag in tagNotifier.tags)
                              FilterChip(
                                selected: _tagIDs.contains(tag.id),
                                backgroundColor: tag.color,
                                selectedColor: tag.color,
                                label: Text(tag.name),
                                labelStyle: TextStyle(
                                  color: tag.color.computeLuminance() > 0.5
                                      ? Colors.black
                                      : Colors.white,
                                ),
                                showCheckmark: true,
                                checkmarkColor:
                                    tag.color.computeLuminance() > 0.5
                                    ? Colors.black
                                    : Colors.white,
                                onSelected: (bool selected) {
                                  final updated = List<int>.from(_tagIDs);
                                  if (selected) {
                                    if (!updated.contains(tag.id)) {
                                      updated.add(tag.id);
                                    }
                                  } else {
                                    updated.remove(tag.id);
                                  }
                                  setSheetState(() {});
                                  _setTagIDs(updated);
                                },
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildToolbar() {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 150),
                  child: _toolbarExpanded
                      ? QuillSimpleToolbar(
                          controller: widget.quillController,
                          config: _toolbarConfig,
                        )
                      : const SizedBox(height: 0, width: double.infinity),
                ),
              ),
              IconButton(
                icon: Icon(
                  _toolbarExpanded ? Icons.expand_more : Icons.text_format,
                ),
                tooltip: _toolbarExpanded
                    ? 'Hide formatting'
                    : 'Show formatting',
                onPressed: () {
                  setState(() => _toolbarExpanded = !_toolbarExpanded);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appBarTitle),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _tagIDs.isNotEmpty,
              label: Text('${_tagIDs.length}'),
              child: const Icon(Icons.label_outline),
            ),
            tooltip: 'Tags',
            onPressed: _showTagSheet,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save',
            onPressed: widget.onSave,
          ),
          if (widget.onDelete != null)
            PopupMenuButton<void>(
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: widget.onDelete,
                  child: const Text('Delete'),
                ),
              ],
            ),
        ],
      ),
      body: Form(
        key: widget.formKey,
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    sliver: SliverToBoxAdapter(
                      child: TextFormField(
                        autofocus: widget.titleAutofocus,
                        controller: widget.titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          hintText: 'Give this entry a title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverFillRemaining(
                      hasScrollBody: true,
                      child: QuillEditor.basic(
                        controller: widget.quillController,
                        focusNode: _editorFocusNode,
                        scrollController: _editorScrollController,
                        config: const QuillEditorConfig(
                          expands: true,
                          placeholder: 'Write your journal entry here...',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildToolbar(),
          ],
        ),
      ),
    );
  }
}
