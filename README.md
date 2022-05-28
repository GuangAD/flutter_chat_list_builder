A flutter package for building a list of chat messages

This package is not responsible for the style of the UI such as bubbles, it is only responsible for the scrolling behavior of the list.

## Features

- Scroll down load history
- When not at the bottom of the list, adding a new message remains unchanged at the current reading position

## Getting started


```dart
import 'package:flutter_chat_list_builder/flutter_chat_list_builder.dart';
```

## Usage


```dart

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
```


