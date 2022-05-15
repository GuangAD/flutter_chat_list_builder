import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chat_list_builder/flutter_chat_list_builder.dart';
import 'package:english_words/english_words.dart';

class Message {
  final String text = generateWordPairs().take(1).first.asCamelCase;
  final bool isMeSend = Random().nextBool();
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
        intMeaasge: List.generate(20, (index) => Message()),
        loadHistory: () async {
          return Future.delayed(const Duration(seconds: 5), () {
            return LoadHistoryResponse(
              isHasMore: true,
              data: List.generate(20, (index) => Message()),
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
            controller.addNewMessage(Message());
            // controller.addNewMessages(List.generate(100, (index) => Message()));
          },
          child: const Text('New Message'),
        ),
      ],
    );
  }
}
