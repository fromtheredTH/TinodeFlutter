import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'CallController.dart';

class CallScreen extends StatelessWidget {
  final CallController controller = Get.put(CallController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('In Call'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'John Doe',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Mobile • 00:00',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CallButton(
                    icon: Icons.mic,
                    text: 'Mute',
                    onPressed: controller.toggleMute,
                  ),
                  CallButton(
                    icon: Icons.dialpad,
                    text: 'Keypad',
                    onPressed: controller.showKeypad,
                  ),
                  CallButton(
                    icon: Icons.volume_up,
                    text: 'Speaker',
                    onPressed: controller.toggleSpeaker,
                  ),
                  CallButton(
                    icon: Icons.call_end,
                    text: 'End',
                    color: Colors.red,
                    onPressed: () {
                      controller.endCall();
                      Get.back();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class CallButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const CallButton({
    Key? key,
    required this.icon,
    required this.text,
    required this.onPressed,
    this.color = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: onPressed,
          child: Icon(icon),
          backgroundColor: color,
        ),
        SizedBox(height: 8),
        Text(text),
      ],
    );
  }
}