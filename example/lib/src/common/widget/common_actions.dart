import 'dart:collection';

import 'package:example/src/common/widget/history_button.dart';
import 'package:example/src/feature/account/widget/profile_icon_button.dart';
import 'package:example/src/feature/authentication/widget/log_out_button.dart';
import 'package:flutter/widgets.dart';

class CommonActions extends ListBase<Widget> {
  CommonActions([List<Widget>? actions])
      : _actions = <Widget>[
          ...?actions,
          const HistoryButton(),
          const ProfileIconButton(),
          const LogOutButton(),
        ];

  final List<Widget> _actions;

  @override
  int get length => _actions.length;

  @override
  set length(int newLength) => _actions.length = newLength;

  @override
  Widget operator [](int index) => _actions[index];

  @override
  void operator []=(int index, Widget value) => _actions[index] = value;
}
