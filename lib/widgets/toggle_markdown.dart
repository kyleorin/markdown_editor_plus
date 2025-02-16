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
  TextDirection _textDirection = TextDirection.ltr;
  
  void _updateTextDirection(String text) {
    if (text.isEmpty) return;
    final RegExp rtlScript = RegExp(r'[֑-߿יִ-﷽ﹰ-ﻼ]');
    final firstChar = text.characters.firstWhere(
      (char) => char.trim().isNotEmpty,
      orElse: () => '',
    );
    setState(() {
      _textDirection = rtlScript.hasMatch(firstChar) 
          ? TextDirection.rtl 
          : TextDirection.ltr;
    });
  }
  
  String get _previewText {
    final text = _internalController.text;
    return text.isEmpty ? (widget.hintText ?? '') : text;
  }


  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
    _internalController.addListener(() {
      _handleTextChange();
      _updateTextDirection(_internalController.text);
    });
    _textFieldFocusNode.addListener(_handleFocusChange);
    _toolbar = Toolbar(
      controller: _internalController,
      bringEditorToFocus: () {
        if (!_textFieldFocusNode.hasFocus && _isEditing) {
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

  void _handleFocusChange() {
    if (!_isEditing && _textFieldFocusNode.hasFocus) {
      _textFieldFocusNode.unfocus();
    } else if (_isEditing && !_textFieldFocusNode.hasFocus) {
      _textFieldFocusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _internalController.removeListener(_handleTextChange);
    _textFieldFocusNode.removeListener(_handleFocusChange);
    if (widget.controller == null) {
      _internalController.dispose();
    }
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ToggleableMarkdownEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null && widget.controller != oldWidget.controller) {
      _internalController.removeListener(_handleTextChange);
      _internalController = widget.controller!;
      _internalController.addListener(_handleTextChange);
    }
  }

  void _toggleMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
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
            Directionality(
              textDirection: _textDirection,
              child: TextField(
                controller: _internalController,
                focusNode: _textFieldFocusNode,
                cursorColor: widget.cursorColor,
                inputFormatters: [
                  if (widget.emojiConvert) EmojiInputFormatter(),
                ],
                onChanged: (value) {
                  widget.onChanged?.call(value);
                  _updateTextDirection(value);
                },
                onTap: () {
                  if (!_isEditing) {
                    _textFieldFocusNode.unfocus();
                    return;
                  }
                  if (widget.onTap != null) {
                    widget.onTap!();
                  }
                },
                readOnly: widget.readOnly,
                scrollController: widget.scrollController,
                style: widget.style,
                textCapitalization: widget.textCapitalization,
                maxLines: widget.maxLines ?? null,
                minLines: widget.minLines ?? 3,
                expands: widget.expands,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                textAlign: _textDirection == TextDirection.rtl ? TextAlign.right : TextAlign.left,
                autofocus: false,
                decoration: widget.decoration.copyWith(
                  alignLabelWithHint: true,
                  contentPadding: widget.decoration.contentPadding ?? 
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
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
              child: Directionality(
                textDirection: _textDirection,
                child: MarkdownBody(
                  data: _previewText,
                  styleSheet: widget.previewStyle,
                  softLineBreak: widget.preserveLineBreaks,
                ),
              ),
            ),
        ],
      ),
    );
  }
}