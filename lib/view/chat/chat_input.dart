import 'package:flutter/material.dart';
import 'package:flutter_web/viewmodel/chat/theme_viewmodel.dart';
import 'package:get/get.dart';
import '../../viewmodel/chat/chat_viewmodel.dart';

class ChatInput extends StatelessWidget {
  const ChatInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                RepaintBoundary(
                  child: TextFormField(
                    autofocus: true,
                    focusNode: Get.find<ChatViewModel>().messageFocusNode,
                    maxLines: 20,
                    minLines: 1,
                    textAlignVertical: TextAlignVertical.center,
                    controller: Get.find<ChatViewModel>().messageController,
                    decoration: InputDecoration(
                      hintText: 'Send a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const BottomToolbar(),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const MessageButtons(),
        ],
      ),
    );
  }
}

class BottomToolbar extends StatelessWidget {
  const BottomToolbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: const [
          // Upload file button
          UploadFileBox(),
          // if (Localizations.localeOf(context) == const Locale('ko', 'KR'))
          TranslateBox(),
          QueryBox(),
          Expanded(child: SizedBox()),
          TokenShowBox(),
        ],
      ),
    );
  }
}

class TranslateBox extends StatelessWidget {
  const TranslateBox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final RxBool isTranslateToggled =
        Get.find<ChatViewModel>().isTranslateToggled!;
    return Column(children: [
      Obx(
        () => Get.find<ChatViewModel>().isChatModelInitialized.value
            ? SizedBox(
                height: 20,
                child: Switch(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  activeColor: ThemeViewModel.idleColor,
                  value: isTranslateToggled.value,
                  onChanged: (value) => isTranslateToggled(value),
                ),
              )
            : Container(),
      ),
      Row(
        children: const [Icon(Icons.translate), Text("Traslate")],
      ),
    ]);
  }
}

// const Text.rich(
//   TextSpan(children: [
//     TextSpan(
//       text: '영어로\n',
//       style: TextStyle(fontSize: 10),
//     ),
//     TextSpan(
//       text: '번역',
//       style: TextStyle(fontSize: 15),
//     ),
//   ]),
//   textAlign: TextAlign.left,
// ),

class QueryBox extends StatelessWidget {
  const QueryBox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final RxBool isQueryToggled = Get.find<ChatViewModel>().isQueryToggled!;
    return Column(children: [
      Obx(
        () => Get.find<ChatViewModel>().isChatModelInitialized.value
            ? SizedBox(
                height: 20,
                child: Switch(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  activeColor: ThemeViewModel.idleColor,
                  value: isQueryToggled.value,
                  onChanged: (value) => isQueryToggled(value),
                ),
              )
            : Container(),
      ),
      Row(
        children: const [Icon(Icons.search), Text("Query")],
      ),
    ]);
  }
}

class UploadFileBox extends StatelessWidget {
  const UploadFileBox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "Upload PDF, TXT, or other text-included file to embed",
      waitDuration: const Duration(milliseconds: 500),
      showDuration: const Duration(milliseconds: 0),
      child: FilledButton(
        style: ElevatedButton.styleFrom(
          surfaceTintColor: ThemeViewModel.idleColor,
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () => Get.find<ChatViewModel>().uploadFile(),
        child: Row(children: const [
          Icon(Icons.document_scanner),
          SizedBox(width: 8),
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: 'Embed\n',
                style: TextStyle(fontSize: 14),
              ),
              TextSpan(
                text: 'Document',
                style: TextStyle(fontSize: 10),
              ),
            ]),
            textAlign: TextAlign.left,
          ),
        ]),
      ),
    );
  }
}

class TokenShowBox extends StatefulWidget {
  const TokenShowBox({Key? key}) : super(key: key);

  @override
  State<TokenShowBox> createState() => _TokenShowBoxState();
}

class _TokenShowBoxState extends State<TokenShowBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<Color?> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    animation = ColorTween(
      begin: ThemeViewModel.idleColor,
      end: Colors.white,
    ).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ChatViewModel chatViewModel = Get.find<ChatViewModel>();

    return Obx(() {
      final tokens = chatViewModel.tokens.value.toString();
      controller
        ..reset()
        ..forward();

      return Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "You used",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
              maxLines: 1,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: controller,
                  builder: (BuildContext context, Widget? child) {
                    return Text(
                      tokens,
                      style: TextStyle(
                        fontSize: 16,
                        color: animation.value,
                      ),
                      maxLines: 1,
                    );
                  },
                ),
                const Text(
                  " Tokens",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class MessageButtons extends StatelessWidget {
  const MessageButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ChatViewModel chatViewModel = Get.find<ChatViewModel>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Tooltip(
          message: "Clear chat",
          showDuration: const Duration(milliseconds: 0),
          waitDuration: const Duration(milliseconds: 500),
          child: IconButton(
            onPressed: () => chatViewModel.clearChat!(clearViewOnly: false),
            icon: const Icon(Icons.clear_all),
          ),
        ),
        Tooltip(
          message: "Resend message",
          showDuration: const Duration(milliseconds: 0),
          waitDuration: const Duration(milliseconds: 500),
          child: IconButton(
            onPressed: () => chatViewModel.resendUserMessage!(),
            icon: const Icon(Icons.refresh),
          ),
        ),
        Obx(
          () => chatViewModel.isQuerying?.value ?? false
              ? Tooltip(
                  message: "Stop query",
                  showDuration: const Duration(milliseconds: 0),
                  child: IconButton(
                    onPressed: () => chatViewModel.sendText!("stop"),
                    icon: const Icon(Icons.stop),
                  ),
                )
              : Tooltip(
                  message: "Send message",
                  showDuration: const Duration(milliseconds: 0),
                  waitDuration: const Duration(milliseconds: 500),
                  child: IconButton(
                    onPressed: chatViewModel.sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ),
        ),
      ],
    );
  }
}
