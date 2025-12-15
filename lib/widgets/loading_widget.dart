import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class LoadingWidget extends StatelessWidget {
  final String? text;

  const LoadingWidget({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: AppTheme.primary,
            strokeWidth: 3,
          ),
          if (text != null) ...[
            const SizedBox(height: 18),
            Text(
              text!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.darkText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
