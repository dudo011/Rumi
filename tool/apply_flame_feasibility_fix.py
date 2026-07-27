from pathlib import Path


def replace_once(source: str, old: str, new: str, label: str) -> str:
    if old not in source:
        raise RuntimeError(f"Missing marker: {label}")
    return source.replace(old, new, 1)


def update_flame_screen() -> None:
    path = Path("lib/features/adventure/flame/escape_feasibility_screen.dart")
    source = path.read_text(encoding="utf-8")

    if not source.startswith("// ignore_for_file: sort_child_properties_last"):
        source = replace_once(
            source,
            "import 'dart:async';",
            "// ignore_for_file: sort_child_properties_last\n\nimport 'dart:async';",
            "file ignore",
        )

    source = source.replace("Rect get key =>", "Rect get keyRect =>")
    source = source.replace("key.inflate(20)", "keyRect.inflate(20)")
    source = source.replace("key.center", "keyRect.center")
    source = source.replace("key.left", "keyRect.left")
    source = source.replace("key.bottom", "keyRect.bottom")
    source = source.replace("key.width", "keyRect.width")

    drag_start = "void onDragStart(DragStartEvent event) {\n"
    drag_start_with_super = (
        "void onDragStart(DragStartEvent event) {\n"
        "    super.onDragStart(event);\n"
    )
    if drag_start_with_super not in source:
        source = replace_once(
            source,
            drag_start,
            drag_start_with_super,
            "drag start super call",
        )

    drag_end = "void onDragEnd(DragEndEvent event) {\n"
    drag_end_with_super = (
        "void onDragEnd(DragEndEvent event) {\n"
        "    super.onDragEnd(event);\n"
    )
    if drag_end_with_super not in source:
        source = replace_once(
            source,
            drag_end,
            drag_end_with_super,
            "drag end super call",
        )

    source = source.replace(
        "builder: (_, state, __) =>",
        "builder: (_, state, _) =>",
    )
    path.write_text(source, encoding="utf-8")


def update_entry_point() -> None:
    path = Path("lib/features/adventure/garden_exploration_screen.dart")
    source = path.read_text(encoding="utf-8")

    old = """        Positioned(
          left: 16,
          bottom: 86,
          child: SafeArea(
            child: FilledButton.icon(
              key: const Key('open-flame-feasibility-lab'),
"""
    new = """        Positioned(
          right: 16,
          top: 18,
          child: SafeArea(
            child: FilledButton.icon(
              key: const Key('open-flame-feasibility-lab'),
"""

    if old in source:
        source = source.replace(old, new, 1)
    elif new not in source:
        raise RuntimeError("Missing feasibility button position marker")

    path.write_text(source, encoding="utf-8")


def main() -> None:
    update_flame_screen()
    update_entry_point()


if __name__ == "__main__":
    main()
