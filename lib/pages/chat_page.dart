import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minimalchat/components/chat_bubble.dart';
import 'package:minimalchat/components/textfield.dart';
import 'package:minimalchat/services/auth/auth_services.dart';
import 'package:minimalchat/services/auth/chatservices/chat_service.dart';

class ChatPage extends StatelessWidget {
  ChatPage(
      {super.key, required this.recieverUsername, required this.receiverId});
  final String recieverUsername;
  final String receiverId;
  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();
  final TextEditingController messageController = TextEditingController();

  //send message
  void sendMessage(context) async {
    if (messageController.text.isNotEmpty) {
      await chatService.sendMessage(receiverId, messageController.text);
      messageController.clear();
    } else {
      showDialog(
          context: context,
          builder: (context) => const AlertDialog(
                title: Text('Empty Message'),
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recieverUsername),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.display_settings))
        ],
      ),
      body: Column(
        children: [
          //displau all chats
          Expanded(child: _buildMessageList()),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderId = authService.getCurrentUser()!.uid;
    print(senderId);
    return StreamBuilder(
        stream: chatService.getMessage(receiverId, senderId),
        builder: (context, snapShot) {
          if (snapShot.hasError) {
            return const Text('Error');
          }
          if (snapShot.connectionState == ConnectionState.waiting) {
            return const Text('Loading');
          }
          // return the listview
          return ListView(
              children: snapShot.data!.docs
                  .map((data) => _buildMessageItem(data))
                  .toList());
        });
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data["senderId"] == authService.getCurrentUser()!.uid;
    print(data["meassage"]);
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    return Container(
        alignment: alignment,
        child: Column(
        //  crossAxisAlignment:isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            ChatBubble(
              message: data["meassage"],
              isCurrentUser: isCurrentUser,
            )
          ],
        ));
  }
  /*Widget _buildMessageItem(DocumentSnapshot doc) {
  Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

  if (data == null || !data.containsKey('senderId')) {
    // Handle the case where data is null or senderId is missing
    return SizedBox(); // or return an appropriate placeholder widget
  }

  bool isCurrentUser =
      data['senderId'] == authService.getCurrentUser()!.uid;
  var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
  
  return Container(
    alignment: alignment,
    child: Column(
      crossAxisAlignment: isCurrentUser
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        ChatBubble(
          message: data['messages'],
          isCurrentUser: isCurrentUser,
        ),
      ],
    ),
  );
}*/

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
                text: 'Type Your Message',
                obsecureText: false,
                controller: messageController),
          ),
          Container(
            decoration: const BoxDecoration(
                color: Colors.green, shape: BoxShape.circle),
            margin: const EdgeInsets.only(right: 10),
            child: IconButton(
                onPressed:(){sendMessage(BuildContext);} , icon: const Icon(Icons.send)),
          )
        ],
      ),
    );
  }
}
