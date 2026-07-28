from pathlib import Path


def replace_once(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding="utf-8")
    if old not in text:
        raise SystemExit(f"Expected text not found in {path}: {old!r}")
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


state_path = Path(
    "lib/features/adventure/escape/episode_one_v2/episode_one_redesign_state.dart"
)
replace_once(
    state_path,
    """    if (value.activity != EpisodeOneRedesignActivity.orderTwelveDivisors)
      return;
""",
    """    if (value.activity != EpisodeOneRedesignActivity.orderTwelveDivisors) {
      return;
    }
""",
)

screen_path = Path(
    "lib/features/adventure/escape/episode_one_v2/episode_one_redesign_screen.dart"
)
replace_once(
    screen_path,
    """        SizedBox.square(
          dimension: 44,
          child: IconButton.filledTonal(
            key: const Key('episode-one-v2-back'),
            tooltip: '모험 나가기',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
""",
    """        KeyedSubtree(
          key: const Key('episode-one-foundation-back'),
          child: SizedBox.square(
            dimension: 44,
            child: IconButton.filledTonal(
              key: const Key('episode-one-v2-back'),
              tooltip: '모험 나가기',
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
        ),
""",
)
replace_once(
    screen_path,
    """  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      key: Key('episode-one-v2-conclusion-$code'),
      value: code,
      groupValue: selected ? code : null,
      onChanged: (_) => onTap(code),
      title: Text('$code. $text'),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
""",
    """  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        key: Key('episode-one-v2-conclusion-$code'),
        onTap: () => onTap(code),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFE8DDF5)
                : const Color(0xFFF4F0F6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFF79559D)
                  : const Color(0xFFD8CEDF),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: const Color(0xFF7255A0),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  '$code. $text',
                  style: const TextStyle(
                    color: Color(0xFF4D4058),
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
""",
)

home_path = Path("lib/features/home/home_screen.dart")
replace_once(
    home_path,
    "'Chapter 1 · Episode 1',",
    "'사라진 별빛 씨앗',",
)
