import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DefaultSvg extends StatelessWidget {
  const DefaultSvg({
    Key? key,
    required this.assetName,
  }) : super(key: key);

  final String assetName;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(assetName, width: MediaQuery.of(context).size.width / 2);
  }
}
