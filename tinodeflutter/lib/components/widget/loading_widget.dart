
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../../Constants/ColorConstants.dart';

class LoadingWidget extends StatelessWidget {
  LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement buildLoadingWidget()
    return Center(
      child: SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
            color: ColorConstants.colorMain),
      ),
    );
  }
}