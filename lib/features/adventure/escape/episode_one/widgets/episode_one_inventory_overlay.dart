import 'package:flutter/material.dart';

import '../episode_one_state.dart';

class EpisodeOneInventoryOverlay extends StatelessWidget {
  const EpisodeOneInventoryOverlay({required this.controller, super.key});

  final EpisodeOneStateController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<EpisodeOneSnapshot>(
      valueListenable: controller,
      builder: (context, snapshot, _) {
        final items = snapshot.inventory.toList()
          ..sort((first, second) => first.index.compareTo(second.index));

        return Container(
          key: const Key('episode-one-inventory'),
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xE6222E38),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x5578DFC3)),
            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 12)],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.backpack_rounded,
                color: Color(0xFFFFE39A),
                size: 20,
              ),
              const SizedBox(width: 8),
              for (var index = 0; index < 4; index++) ...[
                Expanded(
                  child: _InventorySlot(
                    item: index < items.length ? items[index] : null,
                    selected:
                        index < items.length &&
                        snapshot.selectedItem == items[index],
                    enabled: !snapshot.inputLocked,
                    onTap: index < items.length
                        ? () => controller.selectItem(items[index])
                        : null,
                  ),
                ),
                if (index != 3) const SizedBox(width: 6),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _InventorySlot extends StatelessWidget {
  const _InventorySlot({
    required this.item,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final EpisodeOneItem? item;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final currentItem = item;
    return Semantics(
      button: currentItem != null,
      selected: selected,
      label: currentItem?.label ?? '빈 인벤토리 칸',
      child: InkWell(
        key: currentItem == null
            ? null
            : Key('episode-one-item-${currentItem.name}'),
        borderRadius: BorderRadius.circular(14),
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          decoration: BoxDecoration(
            color: selected ? const Color(0x665FE3C0) : const Color(0x44384B55),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFFFFE39A)
                  : const Color(0x336ED4BA),
              width: selected ? 2.5 : 1,
            ),
          ),
          child: currentItem == null
              ? const Icon(
                  Icons.add_rounded,
                  size: 18,
                  color: Color(0x556E817E),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _iconFor(currentItem),
                      size: 22,
                      color: selected
                          ? const Color(0xFFFFE39A)
                          : const Color(0xFFD9F3EC),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentItem.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  IconData _iconFor(EpisodeOneItem item) {
    return switch (item) {
      EpisodeOneItem.starLens => Icons.filter_vintage_rounded,
      EpisodeOneItem.silverRibbon => Icons.air_rounded,
      EpisodeOneItem.starKey => Icons.key_rounded,
      EpisodeOneItem.moonHandle => Icons.nights_stay_rounded,
    };
  }
}
