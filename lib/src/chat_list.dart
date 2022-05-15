import 'dart:async';
import 'package:flutter/cupertino.dart';

class LoadHistoryResponse<T> {
  /// Determine if there are more historical messages
  ///
  /// 判定是否有更多的历史消息
  bool isHasMore;

  /// List of historical messages, which need to be
  /// in descending chronological order
  ///
  /// 历史消息列表，需要按照时间降序
  List<T> data;
  LoadHistoryResponse({
    required this.isHasMore,
    required this.data,
  });
}

class ChatListController<C> {
  _ChatListBuilderState<C>? _state;

  /// ScrollController allow you to control the scrolling of lists externally
  ///
  /// 滚动控制器，你可以在外部控制列表的滚动
  final ScrollController scrollController = ScrollController();

  void _bindState(_ChatListBuilderState<C> state) {
    _state = state;
  }

  /// Add a new message
  ///
  /// 添加新的消息
  void addNewMessage(C message) {
    _state?._addNewMessage(message);
  }

  /// Adds new messages
  ///
  /// 添加新的复数消息
  void addNewMessages(List<C> messages) {
    _state?._addNewMessages(messages);
  }

  /// Delete the message
  ///
  /// 删除消息
  void deleteMessage(C message) {
    _state?._deleteMessage(message);
  }

  /// Delete messages
  ///
  /// 删除消息
  void deleteMessages(List<C> messages) {
    _state?._deleteMessages(messages);
  }

  void dispose() {
    _state = null;
    scrollController.dispose();
  }
}

/// [ChatListBuilder] is an extremely simple component that is not responsible
/// for any UI generation. It is only responsible for the scrolling
/// behavior of the list
///
/// [ChatListBuilder]是一个极其简单的组件，它并不负责任何UI的生成
/// 它只负责列表的滚动行为
class ChatListBuilder<W> extends StatefulWidget {
  /// When you first enter the page with message content, you need to pay
  /// attention to the sorting of the list in descending chronological order
  ///
  /// 首次进入页面的消息内容，需要注意的时，列表的排序需要是
  /// 按照时间降序
  final List<W> intMeaasge;
  final ChatListController<W> controller;

  final Widget Function(BuildContext, W) itemBuilder;

  /// To load the history, you need to return a [bool] value of
  /// [LoadHistoryResponse.isHasMore] to determine whether the history message
  /// has been loaded. Note that the list needs to be sorted in descending
  /// chronological order
  ///
  /// 加载历史记录，需要返回一个[LoadHistoryResponse.isHasMore]的
  /// [bool]值判定历史消息是否已经加载完成。需要注意的时，列表的排序
  /// 需要是按照时间降序
  final Future<LoadHistoryResponse<W>> Function() loadHistory;

  /// The widget displayed when loading the history message
  ///
  /// 加载历史消息时显示的widget
  final Widget? loadingWidget;

  /// No more history messages are displayed when the widget is displayed
  ///
  /// 没有更多的历史消息时显示的widget
  final Widget? noMoreWidget;

  const ChatListBuilder({
    super.key,
    required this.intMeaasge,
    required this.controller,
    required this.itemBuilder,
    required this.loadHistory,
    this.loadingWidget,
    this.noMoreWidget,
  });

  @override
  State<ChatListBuilder<W>> createState() => _ChatListBuilderState<W>();
}

class _ChatListBuilderState<S> extends State<ChatListBuilder<S>> {
  late Key _centerKsy;

  final List<S> _oldData = [];
  final List<S> _newData = [];

  List<S> _cacheNewData = [];
  final Duration _anmationDuration = const Duration(milliseconds: 100);
  bool _isScollToBottom = false;

  bool _isLoadHistory = false;
  bool _isHasMore = true;

  @override
  void initState() {
    widget.controller._bindState(this);
    _centerKsy = UniqueKey();
    _newData.addAll(widget.intMeaasge.reversed);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.controller.scrollController
          .jumpTo(widget.controller.scrollController.position.maxScrollExtent);
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  void _loadHistory() {
    if (_isLoadHistory) return;
    _isLoadHistory = true;
    widget.loadHistory().then((value) {
      setState(() {
        _isHasMore = value.isHasMore;
        _oldData.addAll(value.data);
        _isLoadHistory = false;
      });
    });
  }

  void _addNewMessage(S message) {
    _cacheNewData.add(message);
    _addCacheMessages();
  }

  void _addNewMessages(List<S> messages) {
    _cacheNewData.addAll(messages);
    _addCacheMessages();
  }

  void _addCacheMessages() {
    if (!_isScollToBottom) {
      final data = _cacheNewData;
      _cacheNewData = [];
      setState(() {
        _newData.addAll(data);
      });
      print(data.length);
      print(widget.controller.scrollController.position.pixels);
      print(widget.controller.scrollController.position.maxScrollExtent);
      _addMessageEffect();
    } else {
      if (_cacheNewData.isNotEmpty) {
        Future.delayed(_anmationDuration, _addCacheMessages);
      }
    }
  }

  void _deleteMessage(S message) {
    if (!_newData.remove(message)) {
      _oldData.remove(message);
    }
    setState(() {});
  }

  void _deleteMessages(List<S> messages) {
    for (var element in messages) {
      if (!_newData.remove(element)) {
        _oldData.remove(element);
      }
    }
    setState(() {});
  }

  void _addMessageEffect() {
    if (widget.controller.scrollController.position.maxScrollExtent -
            widget.controller.scrollController.position.pixels <
        20) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _isScollToBottom = true;
        widget.controller.scrollController
            .animateTo(
          widget.controller.scrollController.position.maxScrollExtent,
          duration: _anmationDuration,
          curve: Curves.linear,
        )
            .then((value) {
          _isScollToBottom = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          cacheExtent: 200,
          controller: widget.controller.scrollController,
          center: _centerKsy,
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  if (index < _oldData.length) {
                    return widget.itemBuilder(context, _oldData[index]);
                  } else {
                    if (_isHasMore) {
                      _loadHistory();
                      return const Center(
                        child: _LoadingHistory(),
                      );
                    } else {
                      return const Center(
                        child: _NoMoreHistory(),
                      );
                    }
                  }
                },
                childCount: _oldData.length + 1,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.zero,
              key: _centerKsy,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return widget.itemBuilder(context, _newData[index]);
                },
                childCount: _newData.length,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LoadingHistory extends StatelessWidget {
  const _LoadingHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(18.0),
      child: CupertinoActivityIndicator(),
    );
  }
}

class _NoMoreHistory extends StatelessWidget {
  const _NoMoreHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Container(),
    );
  }
}
