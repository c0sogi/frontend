import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web/viewmodel/chat/theme_viewmodel.dart';
import 'package:get/get.dart';

import '../../app/app_config.dart';
import '../../model/chat/chat_model.dart';
import '../../model/message/message_model.dart';

class ChatViewModel extends GetxController {
  // models
  Rx<ChatModel>? _chatModel;
  final TextEditingController messageController = TextEditingController();
  late final FocusNode messageFocusNode = FocusNode(
      debugLabel: "messageFocusNode",
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event.isShiftPressed || !(event.logicalKey.keyLabel == 'Enter')) {
          return KeyEventResult.ignored;
        }
        if (event is RawKeyDownEvent) {
          sendMessage();
        }
        return KeyEventResult.handled;
      });
  final ScrollController _scrollController = ScrollController();
  final RxBool isChatModelInitialized = false.obs;
  final List<MessageModel> messagePlaceholder = <MessageModel>[
    MessageModel(
      message: "좌측 상단 메뉴에서 로그인 후 API키를 선택해야 이용할 수 있습니다.",
      isFinished: true,
      isGptSpeaking: true,
    )
  ];
  bool _autoScroll = true;

  bool get isTalking => _chatModel?.value.isTalking ?? false;
  ScrollController get scrollController => _scrollController;
  bool get isTranslateToggled => _chatModel?.value.isTranslateToggled ?? false;
  int? get length => _chatModel?.value.messages.length;
  List<MessageModel>? get messages => _chatModel?.value.messages;

  @override
  void onInit() {
    super.onInit();
    _scrollController.addListener(
      () => {
        if (_scrollController.hasClients)
          {
            _scrollController.offset + Config.scrollOffset >=
                    _scrollController.position.maxScrollExtent
                ? _autoScroll = true
                : _autoScroll = false
          }
      },
    );
  }

  @override
  void onClose() {
    super.onClose();
    messageController.dispose();
    messageFocusNode.dispose();
    _chatModel?.close();
  }

  void onKeyFocusNode(
      {required RawKeyEvent event, required BuildContext? context}) {
    if (!event.isKeyPressed(LogicalKeyboardKey.enter) || event.isShiftPressed) {
      return;
    }
    // unfocus textfield when mobile device
    if (context != null) {
      GetPlatform.isMobile
          ? FocusScope.of(context).unfocus()
          : FocusScope.of(context).requestFocus(messageFocusNode);
    }
    // send message
    sendMessage();
  }

  void scrollToBottomCallback(Duration duration) {
    if (scrollController.hasClients &&
        _autoScroll &&
        scrollController.position.hasContentDimensions) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    }
  }

  Future<void> scrollToBottomAnimated() async {
    if (scrollController.hasClients &&
        _autoScroll &&
        scrollController.position.hasContentDimensions) {
      await scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> beginChat({
    required String apiKey,
    required int chatRoomId,
  }) async {
    Get.find<ThemeViewModel>().toggleTheme(true);
    // check channel is late initialized or not
    if (isChatModelInitialized.value) {
      await _chatModel?.value.endChat();
      _chatModel?.update((_) => {});
    }
    _chatModel = ChatModel(
        chatRoomId: chatRoomId,
        onMessageCallback: (dynamic raw) => _chatModel?.update((val) {})).obs;
    await _chatModel!.value.beginChat(apiKey);
    _chatModel!.update((_) {});
    isChatModelInitialized(true);
  }

  Future<void> endChat() async {
    Get.find<ThemeViewModel>().toggleTheme(false);
    await _chatModel?.value.endChat();
    _chatModel?.update((_) {});
  }

  void sendMessage() {
    _chatModel?.update((val) {
      if (val!.sendUserMessage(message: messageController.text)) {
        messageController.clear();
      }
    });
  }

  void resendMessage() {
    _chatModel?.update((val) => val!.resendUserMessage());
  }

  void clearChat() {
    _chatModel?.update((val) => val!.clearAllChat());
  }

  void toggleTranslate() {
    _chatModel?.update((val) => val!.toggleTranslate());
  }

  void uploadImage() {
    // TODO: Implement upload image logic
    _chatModel?.update(
      (val) => val!.addChatMessage(
        message: "이미지 업로드 [미지원]",
        isGptSpeaking: false,
        isFinished: true,
      ),
    );
  }

  void uploadAudio() {
    // TODO: Implement upload audio logic
    _chatModel?.update(
      (val) => val!.addChatMessage(
        message: "음원 업로드 [미지원]",
        isGptSpeaking: false,
        isFinished: true,
      ),
    );
  }
}