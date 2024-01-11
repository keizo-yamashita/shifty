import 'package:flutter/material.dart';
import 'package:shift/src/components/style/style.dart';

class InputShiftName extends StatelessWidget {
  final FocusNode focusNode;
  final TextEditingController textController;
  final Function(String) onTextChanged;

  const InputShiftName({
    super.key,
    required this.focusNode,
    required this.textController,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: FittedBox(
            fit: BoxFit.fill,
            child: Text(
              "① 作成するシフト表名を入力して下さい。（最大10文字）",
              style: Styles.defaultStyle15,
            ),
          ),
        ),
        SizedBox(height: screenSize.height * 0.02),
        SizedBox(
          height: 80,
          child: TextField(
            controller: textController,
            cursorColor: Styles.primaryColor,
            style: Styles.headlineStyleGreen15,
            focusNode: focusNode,
            autofocus: false,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 20.0,
              ),
              prefixIconColor: Styles.primaryColor,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(
                  color: Styles.hiddenColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(
                  color: Styles.primaryColor,
                ),
              ),
              prefixIcon: const Icon(Icons.input),
              hintText: 'シフト表名 (例) 〇〇店シフト',
              hintStyle: Styles.defaultStyle15,
            ),
            maxLength: 10,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.go,
            onTap: () {
              FocusScope.of(context).requestFocus(focusNode);
            },
            onChanged: (value) {
              onTextChanged(value);
            },
          ),
        ),
      ],
    );
  }
}
