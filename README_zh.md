一个用于构建聊天信息列表的flutter package

这个包不负责气泡等UI的样式，它只负责列表的滚动行为。

## Features

- 向下滚动加载历史记录
- 当不处于列表最下面时，添加新消息保持当前阅读位置不变

![chat_list_load](https://github.com/GuangAD/flutter_chat_list_builder/blob/main/screen/chat_list.gif?raw=true)
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

