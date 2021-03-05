
import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:flutter/material.dart';

import 'components/Body.dart';

class OnboardingScreen extends StatelessWidget {
  static String routeName = "/spllash";
  @override
  Widget build(BuildContext context) {
    // You have to call it on your starting screen
    return ConditionalWillPopScope(
      shouldAddCallbacks: true,
      onWillPop: null,
      child: Scaffold(
        body: Body(),
      ),
    );
  }
}
