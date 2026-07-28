from pathlib import Path


def replace_once(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding="utf-8")
    if old not in text:
        raise SystemExit(f"Expected text not found in {path}: {old[:120]!r}")
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


state_path = Path(
    "lib/features/adventure/escape/episode_one_v2/episode_one_redesign_state.dart"
)
replace_once(
    state_path,
    "  bool get supportSuggested => activityErrors >= 2;\n",
    "  bool get supportSuggested => activityErrors >= 2;\n\n"
    "  bool get canUndoCurrentInput =>\n"
    "      selectedNumbers.isNotEmpty ||\n"
    "      selectedTexts.isNotEmpty ||\n"
    "      orderedNumbers.isNotEmpty ||\n"
    "      timelineOrder.isNotEmpty ||\n"
    "      testedGroupSizes.isNotEmpty;\n",
)
replace_once(
    state_path,
    "  void reset() {\n    value = EpisodeOneRedesignSnapshot.initial();\n  }\n",
    "  void reset() {\n"
    "    value = EpisodeOneRedesignSnapshot.initial();\n"
    "  }\n\n"
    "  bool undoCurrentInput() {\n"
    "    final snapshot = value;\n"
    "    if (!snapshot.canUndoCurrentInput) return false;\n\n"
    "    if (snapshot.timelineOrder.isNotEmpty) {\n"
    "      final updated = [...snapshot.timelineOrder]..removeLast();\n"
    "      value = snapshot.copyWith(\n"
    "        timelineOrder: updated,\n"
    "        message: '방금 놓은 증거 카드를 되돌렸어요.',\n"
    "      );\n"
    "      return true;\n"
    "    }\n"
    "    if (snapshot.orderedNumbers.isNotEmpty) {\n"
    "      final updated = [...snapshot.orderedNumbers]..removeLast();\n"
    "      value = snapshot.copyWith(\n"
    "        orderedNumbers: updated,\n"
    "        message: '방금 놓은 숫자를 되돌렸어요.',\n"
    "      );\n"
    "      return true;\n"
    "    }\n"
    "    if (snapshot.selectedTexts.isNotEmpty) {\n"
    "      final updated = {...snapshot.selectedTexts}\n"
    "        ..remove(snapshot.selectedTexts.last);\n"
    "      value = snapshot.copyWith(\n"
    "        selectedTexts: updated,\n"
    "        message: '방금 선택한 기록을 되돌렸어요.',\n"
    "      );\n"
    "      return true;\n"
    "    }\n"
    "    if (snapshot.selectedNumbers.isNotEmpty) {\n"
    "      final updated = {...snapshot.selectedNumbers}\n"
    "        ..remove(snapshot.selectedNumbers.last);\n"
    "      value = snapshot.copyWith(\n"
    "        selectedNumbers: updated,\n"
    "        message: '방금 선택한 숫자를 되돌렸어요.',\n"
    "      );\n"
    "      return true;\n"
    "    }\n"
    "    final updated = {...snapshot.testedGroupSizes}\n"
    "      ..remove(snapshot.testedGroupSizes.last);\n"
    "    value = snapshot.copyWith(\n"
    "      testedGroupSizes: updated,\n"
    "      message: '방금 확인한 묶음 실험을 되돌렸어요.',\n"
    "    );\n"
    "    return true;\n"
    "  }\n",
)

screen_path = Path(
    "lib/features/adventure/escape/episode_one_v2/episode_one_redesign_screen.dart"
)
replace_once(
    screen_path,
    "  void _showClues(EpisodeOneRedesignSnapshot snapshot) {\n",
    "  void _handleBackAttempt() {\n"
    "    if (_controller.undoCurrentInput()) return;\n"
    "    final message = _controller.value.completed\n"
    "        ? '조사가 끝났어요. 결말 화면의 정원으로 돌아가기 버튼을 이용하세요.'\n"
    "        : '단서 6개를 모두 찾기 전에는 메인 화면으로 나갈 수 없어요.';\n"
    "    ScaffoldMessenger.of(context)\n"
    "      ..hideCurrentSnackBar()\n"
    "      ..showSnackBar(SnackBar(content: Text(message)));\n"
    "  }\n\n"
    "  void _showClues(EpisodeOneRedesignSnapshot snapshot) {\n",
)
replace_once(
    screen_path,
    "    return Scaffold(\n      key: const Key('episode-one-v2-screen'),",
    "    return PopScope<Object?>(\n"
    "      canPop: false,\n"
    "      onPopInvokedWithResult: (didPop, result) {\n"
    "        if (!didPop) _handleBackAttempt();\n"
    "      },\n"
    "      child: Scaffold(\n"
    "        key: const Key('episode-one-v2-screen'),",
)
replace_once(
    screen_path,
    "                          onBack: () => Navigator.of(context).maybePop(),\n",
    "                          onUndo: _controller.undoCurrentInput,\n",
)
marker = "      ),\n    );\n  }\n}\n\nclass _FullScreenBackground"
replace_once(
    screen_path,
    marker,
    "      ),\n      ),\n    );\n  }\n}\n\nclass _FullScreenBackground",
)
replace_once(
    screen_path,
    "    required this.onBack,\n",
    "    required this.onUndo,\n",
)
replace_once(
    screen_path,
    "  final VoidCallback onBack;\n",
    "  final VoidCallback onUndo;\n",
)
old_back = """        KeyedSubtree(
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
"""
new_undo = """        SizedBox.square(
          dimension: 44,
          child: IconButton.filledTonal(
            key: const Key('episode-one-v2-undo'),
            tooltip: '현재 선택 하나 되돌리기',
            onPressed: snapshot.canUndoCurrentInput ? onUndo : null,
            icon: const Icon(Icons.undo_rounded),
          ),
        ),
"""
replace_once(screen_path, old_back, new_undo)

home_test = Path("test/home_episode_one_navigation_test.dart")
replace_once(
    home_test,
    """    expect(
      find.byKey(const Key('episode-one-foundation-back')),
      findsOneWidget,
    );
""",
    """    expect(find.byKey(const Key('episode-one-v2-screen')), findsOneWidget);
    expect(find.byKey(const Key('episode-one-v2-undo')), findsOneWidget);
    expect(find.byKey(const Key('episode-one-v2-back')), findsNothing);
    expect(find.byKey(const Key('episode-one-foundation-back')), findsNothing);
""",
)

redesign_test = Path("test/episode_one_redesign_test.dart")
replace_once(
    redesign_test,
    """    final backButton = find.byKey(const Key('episode-one-v2-back'));
    final messageBar = find.byKey(const Key('episode-one-v2-message-bar'));

    expect(backButton, findsOneWidget);
    expect(messageBar, findsOneWidget);
    expect(tester.getTopLeft(backButton).dy, greaterThanOrEqualTo(28));
""",
    """    final undoButton = find.byKey(const Key('episode-one-v2-undo'));
    final messageBar = find.byKey(const Key('episode-one-v2-message-bar'));

    expect(undoButton, findsOneWidget);
    expect(find.byKey(const Key('episode-one-v2-back')), findsNothing);
    expect(messageBar, findsOneWidget);
    expect(tester.getTopLeft(undoButton).dy, greaterThanOrEqualTo(28));
""",
)
replace_once(
    redesign_test,
    """  testWidgets('첫 별조각을 누르면 두 번째 학습 활동으로 이어진다', (tester) async {
""",
    """  test('현재 활동의 마지막 입력만 되돌릴 수 있다', () {
    final controller = EpisodeOneRedesignController();
    addTearDown(controller.dispose);

    controller.fitFallenPiece();
    controller.testGroupSize(2);
    controller.testGroupSize(3);

    expect(controller.value.testedGroupSizes, containsAll({2, 3}));
    expect(controller.undoCurrentInput(), isTrue);
    expect(controller.value.testedGroupSizes.length, 1);
    expect(controller.value.message, contains('되돌렸어요'));
  });

  testWidgets('시스템 뒤로가기는 메인으로 나가지 않고 현재 입력을 되돌린다', (tester) async {
    final controller = EpisodeOneRedesignController();
    addTearDown(controller.dispose);
    controller.fitFallenPiece();
    controller.testGroupSize(2);

    await tester.pumpWidget(
      MaterialApp(home: EpisodeOneRedesignScreen(controller: controller)),
    );
    await tester.pump();

    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(find.byKey(const Key('episode-one-v2-screen')), findsOneWidget);
    expect(controller.value.testedGroupSizes, isEmpty);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('첫 별조각을 누르면 두 번째 학습 활동으로 이어진다', (tester) async {
""",
)
# The new test does not need HomeScreen; avoid adding a cross-feature import.
redesign_text = redesign_test.read_text(encoding="utf-8")
redesign_text = redesign_text.replace(
    "    expect(find.byType(HomeScreen), findsNothing);\n",
    "    expect(find.byKey(const Key('episode-one-v2-screen')), findsOneWidget);\n",
)
redesign_test.write_text(redesign_text, encoding="utf-8")
