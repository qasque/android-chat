import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/src/theme.dart';

class PremiumNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const PremiumNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  State<PremiumNavBar> createState() => _PremiumNavBarState();
}

class _PremiumNavBarState extends State<PremiumNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slideCtrl;
  late Animation<double> _slideAnim;
  int _prevIndex = 0;

  static const _items = <_NavItemData>[
    _NavItemData(Icons.forum_outlined, Icons.forum_rounded, "Диалоги"),
    _NavItemData(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, "Чат"),
    _NavItemData(Icons.person_outline_rounded, Icons.person_rounded, "Профиль"),
  ];

  @override
  void initState() {
    super.initState();
    _prevIndex = widget.selectedIndex;
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnim = AlwaysStoppedAnimation(widget.selectedIndex.toDouble());
  }

  @override
  void didUpdateWidget(PremiumNavBar old) {
    super.didUpdateWidget(old);
    if (old.selectedIndex != widget.selectedIndex) {
      _slideAnim = Tween(
        begin: _prevIndex.toDouble(),
        end: widget.selectedIndex.toDouble(),
      ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
      _slideCtrl.forward(from: 0);
      _prevIndex = widget.selectedIndex;
    }
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 56,
            child: AnimatedBuilder(
              animation: _slideCtrl,
              builder: (context, _) => _buildBar(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBar(BuildContext context) {
    final w = MediaQuery.of(context).size.width / _items.length;
    const pillW = 28.0;
    final left = _slideAnim.value * w + (w - pillW) / 2;

    return Stack(
      children: [
        Positioned(
          left: left,
          top: 0,
          child: Container(
            width: pillW,
            height: 3,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(2)),
              color: AppColors.accentLight,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.45),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
        ),
        Row(
          children: List.generate(_items.length, (i) {
            return Expanded(
              child: _NavItem(
                data: _items[i],
                active: i == widget.selectedIndex,
                onTap: () {
                  if (i != widget.selectedIndex) {
                    HapticFeedback.lightImpact();
                    widget.onTap(i);
                  }
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItemData(this.icon, this.activeIcon, this.label);
}

class _NavItem extends StatefulWidget {
  final _NavItemData data;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.data,
    required this.active,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.08), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 30),
    ]).animate(_ctrl);
  }

  @override
  void didUpdateWidget(_NavItem old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) _ctrl.forward(from: 0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: _scale.value,
                  child: Icon(
                    widget.active ? widget.data.activeIcon : widget.data.icon,
                    size: 22,
                    color: widget.active ? AppColors.accentLight : AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.data.label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: widget.active ? FontWeight.w600 : FontWeight.w400,
                    color: widget.active ? AppColors.accentLight : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
