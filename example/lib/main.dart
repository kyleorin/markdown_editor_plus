import 'package:flutter/material.dart';
import 'package:markdown_editor_plus/markdown_editor_plus.dart';
import 'package:markdown_editor_plus/widgets/toggle_markdown.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const MarkdownAutoPreview(
            decoration: InputDecoration(
              hintText: 'Markdown Auto Preview',
            ),
            emojiConvert: true,
            // maxLines: 10,
            // minLines: 1,
            // expands: true,
          ),
          ToggleableMarkdownEditor(
  hintText: "Start typing...",
  enableToolBar: true,
  preserveLineBreaks: true,
  maxLines: 5,
  decoration: InputDecoration(
    border: OutlineInputBorder(),
    hintText: 'Enter your markdown text',
  ),
),
          const SplittedMarkdownFormField(
            markdownSyntax: '## Headline',
            decoration: InputDecoration(
              hintText: 'Splitted Markdown FormField',
            ),
            emojiConvert: true,
          ),
        ],
      ),
    );
  }
}
