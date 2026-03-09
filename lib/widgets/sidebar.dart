import 'package:flutter/material.dart';

class SidebarController extends ChangeNotifier {
  bool isOpen = true;

  void toggle() {
    isOpen = !isOpen;
    notifyListeners();
  }

  void open() {
    isOpen = true;
    notifyListeners();
  }

  void close() {
    isOpen = false;
    notifyListeners();
  }
}

class SidebarProvider extends InheritedNotifier<SidebarController> {
  const SidebarProvider({
    super.key,
    required SidebarController controller,
    required Widget child,
  }) : super(notifier: controller, child: child);

  static SidebarController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SidebarProvider>()!
        .notifier!;
  }
}

class Sidebar extends StatelessWidget {
  final Widget child;
  final double width;
  final double collapsedWidth;

  const Sidebar({
    super.key,
    required this.child,
    this.width = 250,
    this.collapsedWidth = 70,
  });

  @override
  Widget build(BuildContext context) {
    final controller = SidebarProvider.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: controller.isOpen ? width : collapsedWidth,
          color: Colors.grey.shade900,
          child: child,
        );
      },
    );
  }
}

class SidebarTrigger extends StatelessWidget {
  const SidebarTrigger({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SidebarProvider.of(context);

    return IconButton(
      icon: const Icon(Icons.menu),
      color: Colors.white,
      onPressed: controller.toggle,
    );
  }
}

class SidebarHeader extends StatelessWidget {
  final Widget child;

  const SidebarHeader({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }
}

class SidebarContent extends StatelessWidget {
  final List<Widget> children;

  const SidebarContent({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(children: children),
    );
  }
}

class SidebarMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const SidebarMenuItem({
    super.key,
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = SidebarProvider.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return ListTile(
          leading: Icon(icon, color: Colors.white),
          title: controller.isOpen
              ? Text(
            label,
            style: TextStyle(
              color: active ? Colors.blue : Colors.white,
              fontWeight:
              active ? FontWeight.bold : FontWeight.normal,
            ),
          )
              : null,
          onTap: onTap,
        );
      },
    );
  }
}

class SidebarFooter extends StatelessWidget {
  final Widget child;

  const SidebarFooter({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }
}
