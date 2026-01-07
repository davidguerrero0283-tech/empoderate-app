import 'package:flutter/material.dart';
import 'info_modal.dart';

class InfoButton extends StatelessWidget {
  final String title;
  final String content;

  const InfoButton({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, right: 16),
      child: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => InfoModal(title: title, content: content),
          );
        },
        backgroundColor: const Color(0xFFD4AF37),
        icon: const Icon(Icons.info_outline, color: Colors.black),
        label: const Text(
          'Información',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
