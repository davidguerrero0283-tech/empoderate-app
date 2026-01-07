import 'package:flutter/material.dart';
import '../../ui/theme/color_palette.dart';
import '../../ui/components/header/universal_header.dart';
import '../../ui/components/drawer/premium_drawer.dart';
import '../../src/services/menu_persistent_state.dart';

class PremiumScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final String? subtitle;
  final bool showBackButton;
  final bool showProfileActions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool useScroll; 
  final bool usePadding;
  final VoidCallback? onBack;
  final Widget? endDrawer;
  final bool showBranding;

  final bool isNeonTitle;
  final List<Widget>? actions;

  const PremiumScaffold({
    Key? key,
    required this.body,
    this.title,
    this.subtitle,
    this.showBackButton = true,
    this.showProfileActions = true,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.useScroll = true, 
    this.usePadding = true, 
    this.onBack,
    this.endDrawer,
    this.showBranding = false, 

    this.isNeonTitle = false,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: isDark ? const Color(0xFF0F1520) : const Color(0xFFF5F5F5),
      appBar: buildUniversalHeader(
        context,
        title: title ?? "",
        subtitle: subtitle,
        showBackButton: showBackButton,
        showProfileButton: showProfileActions,
        showBranding: showBranding,
        isNeonTitle: isNeonTitle,
        actions: actions,
        onOpenDrawer: () => MenuStateService().toggleMenu(),
      ),
      endDrawer: endDrawer,
      body: useScroll
          ? SingleChildScrollView(
              padding: usePadding ? const EdgeInsets.all(20) : EdgeInsets.zero,
              child: body,
            )
          : SizedBox.expand(
              child: Padding(
                padding: usePadding ? const EdgeInsets.all(20) : EdgeInsets.zero,
                child: body,
              ),
            ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
