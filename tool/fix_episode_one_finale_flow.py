from pathlib import Path


def replace_once(text: str, old: str, new: str, label: str) -> str:
    if old not in text:
        raise SystemExit(f"Expected block not found: {label}")
    return text.replace(old, new, 1)


overlay_path = Path(
    "lib/features/adventure/escape/episode_one/widgets/episode_one_finale_overlay.dart"
)
overlay = overlay_path.read_text(encoding="utf-8")

overlay = replace_once(
    overlay,
    "  _FinaleStage _stage = _FinaleStage.deduction;\n"
    "  int? _selectedHypothesis;",
    "  _FinaleStage _stage = _FinaleStage.deduction;\n"
    "  bool _finaleStarted = false;\n"
    "  int? _selectedHypothesis;",
    "finale started state",
)

overlay = replace_once(
    overlay,
    "        if (!snapshot.seedFound) return const SizedBox.shrink();\n\n"
    "        return Material(",
    "        if (!snapshot.seedFound) return const SizedBox.shrink();\n"
    "        if (!_finaleStarted) {\n"
    "          return _FinaleStartPrompt(\n"
    "            onPressed: () => setState(() => _finaleStarted = true),\n"
    "          );\n"
    "        }\n\n"
    "        return Material(",
    "finale start gate",
)

prompt_widget = r'''
class _FinaleStartPrompt extends StatelessWidget {
  const _FinaleStartPrompt({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 12,
          right: 12,
          bottom: 148,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xF04F3D6C), Color(0xF023594B)],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFFFE39A), width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 16),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.psychology_alt_rounded,
                    color: Color(0xFFFFE39A),
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '핵심 증거 3개를 모두 찾았어요',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          '씨앗과 포포를 확인한 뒤 준비되면 사건의 진실을 추리하세요.',
                          style: TextStyle(
                            color: Color(0xFFDCE9E5),
                            fontSize: 11,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    key: Key('episode-one-start-final-deduction'),
                    onPressed: onPressed,
                    child: const Text(
                      '사건 해결하기',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

'''

overlay = replace_once(
    overlay,
    "class _FinalePage extends StatelessWidget {",
    prompt_widget + "class _FinalePage extends StatelessWidget {",
    "finale start prompt widget",
)

overlay_path.write_text(overlay, encoding="utf-8")


test_path = Path("test/episode_one_finale_test.dart")
test_text = test_path.read_text(encoding="utf-8")

pump_line = "    await tester.pump(const Duration(milliseconds: 300));\n"
start_block = (
    pump_line
    + "    await tester.tap(\n"
    + "      find.byKey(const Key('episode-one-start-final-deduction')),\n"
    + "    );\n"
    + "    await tester.pump();\n"
)
pump_count = test_text.count(pump_line)
if pump_count != 4:
    raise SystemExit(f"Expected 4 initial pumps, found {pump_count}")
test_text = test_text.replace(pump_line, start_block)

for key in ["episode-one-hypothesis-0", "episode-one-hypothesis-1"]:
    tap = f"    await tester.tap(find.byKey(const Key('{key}')));\n"
    replacement = (
        f"    await tester.ensureVisible(find.byKey(const Key('{key}')));\n"
        + tap
    )
    if tap not in test_text:
        raise SystemExit(f"Expected tap not found: {key}")
    test_text = test_text.replace(tap, replacement)

action_tap = (
    "    await tester.tap(find.byKey(const Key('episode-one-deduction-action')));\n"
)
action_replacement = (
    "    await tester.ensureVisible(\n"
    "      find.byKey(const Key('episode-one-deduction-action')),\n"
    "    );\n"
    + action_tap
)
action_count = test_text.count(action_tap)
if action_count < 6:
    raise SystemExit(f"Expected at least 6 deduction action taps, found {action_count}")
test_text = test_text.replace(action_tap, action_replacement)

test_path.write_text(test_text, encoding="utf-8")
