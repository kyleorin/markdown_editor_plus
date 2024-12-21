import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../src/constants.dart';
import '../src/emoji_input_formatter.dart';
import '../src/toolbar.dart';
import 'markdown_toolbar.dart';

class ToggleableMarkdownEditor extends StatefulWidget {
  const ToggleableMarkdownEditor({
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
    this.previewStyle,
    this.preserveLineBreaks = true,
    this.editButtonLabel = 'Edit',
    this.previewButtonLabel = 'Preview',
    this.editIcon,
    this.previewIcon,
    this.toggleButtonStyle,
    this.editButtonTextStyle,
    this.previewButtonTextStyle,
  });

  // Button customization properties
  final String editButtonLabel;
  final String previewButtonLabel;
  final Icon? editIcon;
  final Icon? previewIcon;
  final ButtonStyle? toggleButtonStyle;
  final TextStyle? editButtonTextStyle;
  final TextStyle? previewButtonTextStyle;

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
  final MarkdownStyleSheet? previewStyle;
  final bool preserveLineBreaks;

  @override
  State<ToggleableMarkdownEditor> createState() => _ToggleableMarkdownEditorState();
}

class _ToggleableMarkdownEditorState extends State<ToggleableMarkdownEditor> {
  late TextEditingController _internalController;
  late Toolbar _toolbar;
  final FocusNode _textFieldFocusNode = FocusNode(debugLabel: '_textFieldFocusNode');
  bool _isEditing = true;

  String get _previewText {
    if (_internalController.text.isEmpty) {
      return widget.hintText ?? "_No content yet_";
    }
    
    if (widget.preserveLineBreaks) {
      return _internalController.text
          .split('\n')
          .map((line) => '$line  ')
          .join('\n');
    }
    
    return _internalController.text;
  }

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
    _internalController.addListener(_handleTextChange);
    _toolbar = Toolbar(
      controller: _internalController,
      bringEditorToFocus: () {
        if (!_textFieldFocusNode.hasFocus) {
          _textFieldFocusNode.requestFocus();
        }
      },
    );
  }

  void _handleTextChange() {
    if (widget.onChanged != null) {
      widget.onChanged!(_internalController.text);
    }
  }

  @override
  void dispose() {
    _internalController.removeListener(_handleTextChange);
    if (widget.controller == null) {
      _internalController.dispose();
    }
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _textFieldFocusNode.requestFocus();
      } else {
        _textFieldFocusNode.unfocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String buttonLabel = _isEditing ? widget.previewButtonLabel : widget.editButtonLabel;
    final Icon buttonIcon = _isEditing 
        ? (widget.previewIcon ?? Icon(Icons.preview))
        : (widget.editIcon ?? Icon(Icons.edit));
    final TextStyle? buttonTextStyle = _isEditing 
        ? widget.previewButtonTextStyle 
        : widget.editButtonTextStyle;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: _toggleMode,
                icon: buttonIcon,
                label: Text(
                  buttonLabel,
                  style: buttonTextStyle,
                ),
                style: widget.toggleButtonStyle,
              ),
            ],
          ),
          if (_isEditing) ...[
            TextField(
              controller: _internalController,
              focusNode: _textFieldFocusNode,
              cursorColor: widget.cursorColor,
              inputFormatters: [
                if (widget.emojiConvert) EmojiInputFormatter(),
              ],
              onChanged: (value) {
                _internalController.value = _internalController.value.copyWith(
                  text: value,
                  selection: _internalController.selection,
                  composing: _internalController.value.composing,
                );
                widget.onChanged?.call(value);
              },
              onTap: widget.onTap,
              readOnly: widget.readOnly,
              scrollController: widget.scrollController,
              style: widget.style,
              textCapitalization: widget.textCapitalization,
              maxLines: widget.maxLines ?? null,
              minLines: widget.minLines ?? 3,
              expands: widget.expands,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: widget.decoration.copyWith(
                alignLabelWithHint: true,
                contentPadding: widget.decoration.contentPadding ?? 
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
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
          ] else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: MarkdownBody(
                data: _previewText,
                styleSheet: widget.previewStyle,
                softLineBreak: widget.preserveLineBreaks,
              ),
            ),
        ],
      ),
    );
  }
}