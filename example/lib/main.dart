import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_chat_list_builder/flutter_chat_list_builder.dart';
import 'package:english_words/english_words.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home Page'),
        ),
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                    return const ChatPage();
                  }));
                },
                child: const Text('TO CHAT'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                    return const ChatPage2();
                  }));
                },
                child: const Text('TO CHAT2'),
              ),
            ],
          ),
        ));
  }
}

class Message {
  final int ind;
  Message(this.ind);
  final String _text = generateWordPairs().take(1).first.asCamelCase;
  final bool isMeSend = Random().nextBool();

  String get text => ind.toString() + _text;
}

class ChatPage extends StatelessWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ChatListController<Message> controller = ChatListController<Message>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Page"),
      ),
      body: ChatListBuilder<Message>(
        loadHistory: () async {
          return Future.delayed(const Duration(seconds: 2), () {
            return LoadHistoryResponse(
              isHasMore: true,
              data: List.generate(30, (index) => Message(index)),
            );
          });
        },
        loadingBackgroundColor: Colors.white,
        itemBuilder: (_, element) {
          if (element.isMeSend) {
            return Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green[400],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(element.text),
                )
              ],
            );
          } else {
            return Row(
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.yellow[400],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(element.text),
                )
              ],
            );
          }
        },
        controller: controller,
      ),
      persistentFooterButtons: [
        ElevatedButton(
          onPressed: () {
            // List.generate(10, (index) => Message()).forEach((element) {
            //   controller.addNewMessage(element);
            // });
            controller.addNewMessage(Message(999));
            // controller.addNewMessages(List.generate(100, (index) => Message()));
          },
          child: const Text('New Message'),
        ),
      ],
    );
  }
}

class ChatPage2 extends StatelessWidget {
  const ChatPage2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ChatListController<Message> controller = ChatListController<Message>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Page2"),
      ),
      body: ChatListBuilder<Message>.initMsg(
        intMeaasge: List.generate(20, (index) => Message(index)),
        loadHistory: () async {
          return Future.delayed(const Duration(seconds: 2), () {
            return LoadHistoryResponse(
              isHasMore: true,
              data: List.generate(30, (index) => Message(index)),
            );
          });
        },
        itemBuilder: (_, element) {
          if (element.isMeSend) {
            return Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green[400],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(element.text),
                )
              ],
            );
          } else {
            return Row(
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.yellow[400],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(element.text),
                )
              ],
            );
          }
        },
        controller: controller,
      ),
      persistentFooterButtons: [
        ElevatedButton(
          onPressed: () {
            // List.generate(10, (index) => Message()).forEach((element) {
            //   controller.addNewMessage(element);
            // });
            controller.addNewMessage(Message(999));
            // controller.addNewMessages(List.generate(100, (index) => Message()));
          },
          child: const Text('New Message'),
        ),
      ],
    );
  }
}
