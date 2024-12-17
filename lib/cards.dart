import 'package:flutter/material.dart';

// 定义一个 TextCard 类，用于显示文本的卡片
class TextCard extends StatelessWidget {
  final String text; // 要显示的文本
  final double borderRadius; // 圆角半径
  final Color backgroundColor; // 背景颜色
  final Color fontColor; // 字体颜色
  final double width; // 卡片宽度
  final double height; // 卡片高度
  final double fontSizePresent; // 字体大小

  const TextCard({
    super.key,
    required this.text,
    required this.borderRadius,
    required this.backgroundColor,
    required this.fontColor,
    required this.width,
    required this.height,
    required this.fontSizePresent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              style: TextStyle(
                fontSize: height * fontSizePresent, // 调大字体大小
                color: fontColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 定义一个 InputCard 类，用于显示输入框的卡片
class InputCard extends StatelessWidget {
  final TextEditingController controller; // 输入框的控制器
  final String hintText; // 提示文本
  final double borderRadius; // 圆角半径
  final TextAlign textAlign; // 文本对齐方式
  final double width; // 卡片宽度
  final double height; // 卡片高度
  final double fontSizePresent; // 字体大小

  const InputCard({
    super.key,
    required this.controller,
    required this.hintText,
    required this.borderRadius,
    required this.textAlign,
    required this.width,
    required this.height,
    required this.fontSizePresent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: controller,
          textAlign: textAlign,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey.withOpacity(0.5),
              fontSize: height * fontSizePresent,
            ),
            border: InputBorder.none,
          ),
          style: TextStyle(
            fontSize: height * fontSizePresent,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
