// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:gap/gap.dart';

// Project imports:
import 'package:shift/components/style/style.dart';

class SignInHeader extends StatelessWidget {
  const SignInHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('Shifty', style: Styles.defaultStyleWhite20),
        Text('ダウンロードありがとうございます。', style: Styles.defaultStyleWhite20),
        const Gap(10),
        const Divider(
          color: Colors.white,
        ),
        const Gap(10),
      ],
    );
  }
}
