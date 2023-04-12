import 'package:flutter/material.dart';
import 'package:flutter_web/viewmodel/login/login_viewmodel.dart';
import 'package:get/get.dart';
import './widgets/conversation_list.dart';
import 'chat/chat_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Get.find<LoginViewModel>().scaffoldKey,
      appBar: AppBar(
        title: const Text('ChatGPT'),
      ),
      drawer: const Drawer(
        child: ConversationList(),
      ),
      body: Row(
        children: const [
          Expanded(
            flex: 3,
            child: ChatView(),
          ),
        ],
      ),
    );
  }
}
