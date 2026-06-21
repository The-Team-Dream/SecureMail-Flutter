import 'package:flutter/material.dart';
import 'package:securemail/features/mailboxes/screens/add_mailbox_shared_widgets.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';

/// Base scaffold for all "Add Mailbox" step screens.
///
/// Extracts the repeated layout (AppBar, StepProgress, body, StepButtons,
/// SecureFooter) so each step screen only needs to provide its unique [body].
class StepScaffold extends StatelessWidget {
  const StepScaffold({
    super.key,
    required this.currentStep,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.onBack,
    required this.onNext,
    this.totalSteps = 4,
    this.nextEnabled = true,
    this.nextLoading = false,
  });

  /// Which step number is currently active.
  final int currentStep;

  /// Total number of steps in the flow (default: 4).
  final int totalSteps;

  /// Title shown below the step progress indicator.
  final String title;

  /// Subtitle / description shown below the title.
  final String subtitle;

  /// The unique content widget for this step.
  final Widget body;

  /// Called when the user presses the Back button.
  final VoidCallback onBack;

  /// Called when the user presses the Next button.
  final VoidCallback onNext;

  /// Whether the Next button is enabled.
  final bool nextEnabled;

  /// Whether the Next button should show a loading indicator.
  final bool nextLoading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: context.text1, size: AppIconSize.md),
          onPressed: onBack,
        ),
        title: Text(title,
            style: AppTextStyles.headingL.copyWith(color: context.text1)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.screenVertical),
                      StepProgress(current: currentStep, total: totalSteps),
                      const SizedBox(height: AppSpacing.sectionGap),
                      Text(title,
                          style: AppTextStyles.displayS.copyWith(
                            color: context.text1,
                          )),
                      const SizedBox(height: AppSpacing.x2),
                      Text(subtitle,
                          style: AppTextStyles.bodyM
                              .copyWith(color: context.text3)),
                      const SizedBox(height: AppSpacing.sectionGap),
                      body,
                      const Spacer(),
                      Column(
                        children: [
                          StepButtons(
                            onBack: onBack,
                            onNext: nextEnabled ? onNext : null,
                            isLoading: nextLoading,
                            nextLabel: currentStep == totalSteps
                                ? 'Save & Finish'
                                : 'Next Step',
                          ),
                          const SizedBox(height: AppSpacing.screenVertical),
                          const SecureFooter(),
                          const SizedBox(height: AppSpacing.screenVertical),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
