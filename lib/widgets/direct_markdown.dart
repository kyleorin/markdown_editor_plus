import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../src/constants.dart';
import '../src/emoji_input_formatter.dart';
import '../src/toolbar.dart';
import 'markdown_toolbar.dart';

class DirectMarkdownEditor extends StatefulWidget {
  const DirectMarkdownEditor({
    super.key,
    this.controller,
    this.scrollController,
    this.onChanged,
    this.style,
    this.onTap,
    this.cursorColor,
    this.toolbarBackground,
    this.expandableBackground,
    this.maxLines,
    this.minLines,
    this.markdownSyntax,
    this.emojiConvert = false,
    this.enableToolBar = true,
    this.showEmojiSelection = true,
    this.autoCloseAfterSelectEmoji = true,
    this.textCapitalization = TextCapitalization.sentences,
    this.readOnly = false,
    this.expands = false,
    this.decoration = const InputDecoration(isDense: true),
    this.hintText,
  });

  final String? markdownSyntax;
  final String? hintText;
  final bool enableToolBar;
  final bool showEmojiSelection;
  final TextEditingController? controller;
  final ScrollController? scrollController;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final TextStyle? style;
  final bool emojiConvert;
  final VoidCallback? onTap;
  final bool autoCloseAfterSelectEmoji;
  final bool readOnly;
  final Color? cursorColor;
  final Color? toolbarBackground;
  final Color? expandableBackground;
  final InputDecoration decoration;
  final int? maxLines;
  final int? minLines;
  final bool expands;

  @override
  State<DirectMarkdownEditor> createState() => _DirectMarkdownEditorState();
}

class _DirectMarkdownEditorState extends State<DirectMarkdownEditor> {
  late TextEditingController _internalController;
  late Toolbar _toolbar;
  final FocusNode _textFieldFocusNode = FocusNode(debugLabel: '_textFieldFocusNode');

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
    _toolbar = Toolbar(
      controller: _internalController,
      bringEditorToFocus: () {
        if (!_textFieldFocusNode.hasFocus) {
          _textFieldFocusNode.requestFocus();
        }
      },
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyB): BoldTextIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyI): ItalicTextIntent(),
      },
      actions: {
        BoldTextIntent: CallbackAction<BoldTextIntent>(
          onInvoke: (intent) {
            _toolbar.action("**", "**");
            return null;
          },
        ),
        ItalicTextIntent: CallbackAction<ItalicTextIntent>(
          onInvoke: (intent) {
            _toolbar.action("_", "_");
            return null;
          },
        ),
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _internalController,
            focusNode: _textFieldFocusNode,
            cursorColor: widget.cursorColor,
            inputFormatters: [
              if (widget.emojiConvert) EmojiInputFormatter(),
            ],
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            readOnly: widget.readOnly,
            scrollController: widget.scrollController,
            style: widget.style,
            textCapitalization: widget.textCapitalization,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            expands: widget.expands,
            decoration: widget.decoration,
          ),
          if (widget.enableToolBar && !widget.readOnly)
            MarkdownToolbar(
              markdownSyntax: widget.markdownSyntax,
              controller: _internalController,
              autoCloseAfterSelectEmoji: widget.autoCloseAfterSelectEmoji,
              toolbar: _toolbar,
              unfocus: () {
                _textFieldFocusNode.unfocus();
              },
              showEmojiSelection: widget.showEmojiSelection,
              emojiConvert: widget.emojiConvert,
              toolbarBackground: widget.toolbarBackground,
              expandableBackground: widget.expandableBackground,
            ),
        ],
      ),
    );
  }
}