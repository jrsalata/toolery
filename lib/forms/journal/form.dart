import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:toolery/widgets/editor_app_bar.dart';
import 'package:toolery/widgets/tag_action.dart';

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
      appBar: EditorAppBar(
        title: widget.appBarTitle,
        tagAction: TagAction(tagIDs: _tagIDs, onChanged: _setTagIDs),
        onSave: widget.onSave,
        onDelete: widget.onDelete,
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
