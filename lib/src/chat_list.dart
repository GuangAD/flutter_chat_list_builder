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
///
/// [ChatListBuilder]是一个极其简单的组件，它并不负责任何UI的生成
/// 它只负责列表的滚动行为
class ChatListBuilder<W> extends StatefulWidget {
  final ChatListController<W> controller;

  /// When you first enter the page with message content, you need to pay
  /// attention to the sorting of the list in descending chronological order
  ///
  /// 首次进入页面的消息内容，需要注意的时，列表的排序需要是
  /// 按照时间降序
  final List<W>? intMeaasge;

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

  /// Loading widget when you first enter the page
  ///
  /// 首次进入页面时的loading widget
  final Widget? initloadingWidget;

  /// The widget displayed when loading the history message
  ///
  /// 加载历史消息时显示的widget
  final Widget? loadingWidget;

  /// No more history messages are displayed when the widget is displayed
  ///
  /// 没有更多的历史消息时显示的widget
  final Widget? noMoreWidget;

  /// The background color of loading when entering the page for the first time,
  ///  it is recommended that it should be the same as the background color of
  ///  the page
  ///
  /// 首次进入页面时的loading的背景颜色，建议应与页面的背景颜色相同
  final Color? loadingBackgroundColor;

  const ChatListBuilder({
    super.key,
    required this.controller,
    required this.itemBuilder,
    required this.loadHistory,
    this.loadingWidget,
    this.initloadingWidget,
    this.noMoreWidget,
    required Color this.loadingBackgroundColor,
  }) : intMeaasge = null;

  const ChatListBuilder.initMsg({
    super.key,
    required this.controller,
    required this.itemBuilder,
    required this.loadHistory,
    this.loadingWidget,
    this.noMoreWidget,
    required List<W> this.intMeaasge,
  })  : initloadingWidget = null,
        loadingBackgroundColor = null;

  @override
  State<ChatListBuilder<W>> createState() => _ChatListBuilderState<W>();
}

class _ChatListBuilderState<S> extends State<ChatListBuilder<S>> {
  late Key _centerKey;

  final List<S> _oldData = [];
  final List<S> _newData = [];

  List<S> _cacheNewData = [];
  final Duration _anmationDuration = const Duration(milliseconds: 100);
  bool _isScollToBottom = false;
  bool _isFrameCallbackAdd = false;

  bool _isLoadHistory = false;
  bool _isHasMore = true;
  bool _isHasMessage = false;

  @override
  void initState() {
    widget.controller._bindState(this);
    _centerKey = UniqueKey();
    if (widget.intMeaasge != null) {
      _newData.addAll(widget.intMeaasge!.reversed);
      _isHasMessage = true;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        widget.controller.scrollController.jumpTo(
            widget.controller.scrollController.position.maxScrollExtent);
      });
    } else {
      _isLoadHistory = true;
      widget.loadHistory().then((value) {
        if (mounted) {
          setState(() {
            _isHasMore = value.isHasMore;
            _newData.addAll(value.data.reversed);
            _isLoadHistory = false;
          });
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            widget.controller.scrollController.jumpTo(
                widget.controller.scrollController.position.maxScrollExtent);
            setState(() {
              _isHasMessage = true;
            });
          });
        }
      });
    }
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
      if (mounted) {
        setState(() {
          _isHasMore = value.isHasMore;
          _oldData.addAll(value.data);
          _isLoadHistory = false;
        });
      }
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
    if (!_isScollToBottom && _cacheNewData.isNotEmpty) {
      final data = _cacheNewData;
      _cacheNewData = [];
      setState(() {
        _newData.addAll(data);
      });
      _runFrameCallback();
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

  void _scrollToEnd() {
    _isScollToBottom = true;
    _isFrameCallbackAdd = false;
    widget.controller.scrollController
        .animateTo(
      widget.controller.scrollController.position.maxScrollExtent,
      duration: _anmationDuration,
      curve: Curves.linear,
    )
        .then((value) {
      _isScollToBottom = false;
    });
  }

  void _runFrameCallback() {
    if (widget.controller.scrollController.position.maxScrollExtent ==
        widget.controller.scrollController.position.pixels) {
      if (!_isFrameCallbackAdd) {
        _isFrameCallbackAdd = true;
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          _scrollToEnd();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          controller: widget.controller.scrollController,
          center: _centerKey,
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  if (index < _oldData.length) {
                    return widget.itemBuilder(context, _oldData[index]);
                  } else {
                    if (!_isHasMessage) return Container();
                    if (_isHasMore) {
                      _loadHistory();
                      return Center(
                        child: widget.loadingWidget ?? const _LoadingHistory(),
                      );
                    } else {
                      return Center(
                        child: widget.noMoreWidget ?? const _NoMoreHistory(),
                      );
                    }
                  }
                },
                childCount: _oldData.length + 1,
              ),
            ),
            SliverList(
              key: _centerKey,
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return widget.itemBuilder(context, _newData[index]);
                },
                childCount: _newData.length,
              ),
            ),
          ],
        ),
        if (!_isHasMessage)
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: widget.loadingBackgroundColor,
              child: Center(
                child: widget.initloadingWidget ?? const _LoadingHistory(),
              ),
            ),
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
