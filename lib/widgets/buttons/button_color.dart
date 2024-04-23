import 'package:flutter/material.dart';
import 'package:parkfinder_customer/assets/colors/constant.dart';
// Ensure you have the AppColor class defined somewhere in your project.

class GaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color; // The color property is already added

  // The constructor takes a color parameter and defaults to AppColor.appPrimaryColor if not provided
  const GaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColor.appGrey,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 309, // Set the width of the button
      height: 54, // Set the height of the button
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(color), // Use the color property here
          foregroundColor: MaterialStateProperty.all(Colors.white),
          padding: MaterialStateProperty.all(
              const EdgeInsets.all(15)), // Adjusted padding
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10)), // Adjusted borderRadius
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
