import 'package:flutter/material.dart';
import '../pallete.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final double horizontalPadding;
  final VoidCallback onPressed;

  const SocialButton({
    Key? key,
    required this.iconPath,
    required this.label,
    required this.onPressed, // Dodano wymaganą funkcję onPressed
    this.horizontalPadding = 16.0, // Zmniejszony padding dla pełnej szerokości
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: onPressed, // Wywołanie przekazanej funkcji onPressed
        icon: SvgPicture.asset(
          iconPath,
          width: 25,
          color: Pallete.whiteColor,
        ),
        label: Text(
          label,
          style: const TextStyle(
            color: Pallete.whiteColor,
            fontSize: 17,
          ),
        ),
        style: TextButton.styleFrom(
          padding:
              EdgeInsets.symmetric(vertical: 20, horizontal: horizontalPadding),
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              color: Pallete.borderColor,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
