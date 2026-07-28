from pathlib import Path


def replace_once(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding="utf-8")
    if old not in text:
        raise SystemExit(f"Expected text not found in {path}: {old[:120]!r}")
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


state_path = Path(
    "lib/features/adventure/escape/episode_one_v3/episode_one_v3_state.dart"
)

metadata_anchor = """    EpisodeOneV3Stage.completed => '연못 아래의 잠긴 수문이 다음 조사를 기다리고 있어요.',
  };
}

@immutable
"""

metadata_replacement = """    EpisodeOneV3Stage.completed => '연못 아래의 잠긴 수문이 다음 조사를 기다리고 있어요.',
  };

  String get problemPrompt => switch (this) {
    EpisodeOneV3Stage.identifyFragment => '받침대 오른쪽 홈에 맞는 물체는 무엇일까요?',
    EpisodeOneV3Stage.testTwelveGroups =>
      '별가루 12개를 2개씩, 3개씩, 4개씩, 5개씩 묶으면 각각 남는 것이 있는지 확인하세요.',
    EpisodeOneV3Stage.revealTwelveDivisors =>
      '12개를 남김없이 똑같이 나눌 수 있는 수를 모두 고르세요.',
    EpisodeOneV3Stage.pairTwelveFactors => '곱해서 12가 되는 식을 모두 고르세요.',
    EpisodeOneV3Stage.orderTwelveDivisors =>
      '찾은 12의 약수를 작은 수부터 차례로 누르세요.',
    EpisodeOneV3Stage.identifyFlowerpot =>
      '받침대가 보여 준 오른쪽 여섯 잎 문양과 같은 화분은 어느 것일까요?',
    EpisodeOneV3Stage.assembleScratches =>
      '같은 사건에서 생긴 긁힘 조각만 골라 총 18개의 흔적을 복원하세요.',
    EpisodeOneV3Stage.arrangeEighteen =>
      '18개를 남김없이 같은 줄로 배열할 수 있는 줄 수를 모두 고르세요.',
    EpisodeOneV3Stage.removeDuplicateEighteen =>
      '앞에서 찾은 배열과 같은 곱셈 짝을 뒤집어 쓴 기록을 모두 고르세요.',
    EpisodeOneV3Stage.findMissingEighteen =>
      '1×18, 2×9, 3×□에서 빈칸에 들어갈 수를 고르세요.',
    EpisodeOneV3Stage.rejectNonDivisorEighteen =>
      '2·3·4·6·9 중 18개를 똑같이 나눌 수 없는 수 하나를 고르세요.',
    EpisodeOneV3Stage.arrangeTwentyFour =>
      '곱해서 24가 되고 씨앗이 빈칸 없이 들어가는 배열을 모두 고르세요.',
    EpisodeOneV3Stage.mapTwentyFourPins =>
      '네 배열에 사용된 모든 변의 길이를 중복 없이 고르세요.',
    EpisodeOneV3Stage.orderStorageGlyphs =>
      '짧은 변이 작은 건조판부터 오른쪽으로 문양을 누르세요.',
    EpisodeOneV3Stage.rejectFalseRecord =>
      'A·B·C 중 틀린 기록 하나를 고르고 5칸 시험판으로 확인하세요.',
    EpisodeOneV3Stage.useTraceFilters =>
      '세 도구를 모두 사용해 씨앗선·젖은 발자국·장화 자국을 따로 보이게 하세요.',
    EpisodeOneV3Stage.chooseTrackStart =>
      '작은 둥근 발자국이 처음 나타난 지점을 고르세요.',
    EpisodeOneV3Stage.testTrackIntervals =>
      '4칸·5칸·6칸 간격을 모두 시험해 24번째 돌까지 정확히 이어지는지 확인하세요.',
    EpisodeOneV3Stage.connectFootprints =>
      '앞 단계에서 남긴 조건을 만족하는 젖은 발자국을 시작점부터 순서대로 연결하세요.',
    EpisodeOneV3Stage.orderEvidence =>
      '다섯 사건 카드를 가장 먼저 일어난 일부터 차례로 놓으세요.',
    EpisodeOneV3Stage.chooseConclusion =>
      '지금까지 확인한 사실만으로 확실히 말할 수 있는 문장을 하나 고르세요.',
    EpisodeOneV3Stage.completed => '연못 아래에서 드러난 다음 사건의 입구를 확인하세요.',
  };

  String get decisionRule => switch (this) {
    EpisodeOneV3Stage.identifyFragment =>
      '모양뿐 아니라 홈의 위치와 긁힌 방향까지 모두 맞아야 합니다.',
    EpisodeOneV3Stage.testTwelveGroups =>
      '12개를 같은 수씩 묶었을 때 남는 것이 있는지 직접 시험합니다.',
    EpisodeOneV3Stage.revealTwelveDivisors =>
      '12를 나누어 나머지가 0이 되게 하는 수를 12의 약수라고 합니다.',
    EpisodeOneV3Stage.pairTwelveFactors =>
      '두 수의 곱이 12이면 두 수는 12의 약수 한 쌍입니다.',
    EpisodeOneV3Stage.orderTwelveDivisors =>
      '1과 12도 약수에 포함하며, 곱셈 짝을 이용하면 빠뜨리지 않을 수 있습니다.',
    EpisodeOneV3Stage.identifyFlowerpot =>
      '앞에서 얻은 문양은 오른쪽 방향과 잎 6개를 나타냅니다.',
    EpisodeOneV3Stage.assembleScratches =>
      '방향이 다른 바람종 자국은 사건 흔적이 아닙니다. 선택한 조각 수의 합도 확인하세요.',
    EpisodeOneV3Stage.arrangeEighteen =>
      '18을 나누어 나머지가 0이 되는 수가 18의 약수입니다.',
    EpisodeOneV3Stage.removeDuplicateEighteen =>
      '1×18과 18×1처럼 순서만 바뀐 식은 같은 약수 쌍입니다.',
    EpisodeOneV3Stage.findMissingEighteen =>
      '3과 어떤 수를 곱해야 18이 되는지 생각하세요.',
    EpisodeOneV3Stage.rejectNonDivisorEighteen =>
      '18을 그 수로 나누었을 때 나머지가 생기면 18의 약수가 아닙니다.',
    EpisodeOneV3Stage.arrangeTwentyFour =>
      '두 수의 곱이 24가 되고 빈칸이나 남는 씨앗이 없어야 합니다.',
    EpisodeOneV3Stage.mapTwentyFourPins =>
      '올바른 곱셈 짝에 등장한 수를 모으면 24의 약수를 빠짐없이 찾을 수 있습니다.',
    EpisodeOneV3Stage.orderStorageGlyphs =>
      '앞 단서의 작은 것부터 읽기와 오른쪽 진행 규칙을 함께 사용합니다.',
    EpisodeOneV3Stage.rejectFalseRecord =>
      '작은 수라고 모두 약수는 아닙니다. 24를 나누어 나머지가 0인지 실험해야 합니다.',
    EpisodeOneV3Stage.useTraceFilters =>
      '렌즈는 젖은 흔적, 흔적틀은 크기, 조명은 오래된 씨앗 이동선을 보여 줍니다.',
    EpisodeOneV3Stage.chooseTrackStart =>
      '발자국은 씨앗이 떨어지기 전이 아니라 떨어진 뒤에 시작해야 합니다.',
    EpisodeOneV3Stage.testTrackIntervals =>
      '24를 간격 수로 나누어 나머지가 없으면 24번째 돌까지 정확히 이어집니다.',
    EpisodeOneV3Stage.connectFootprints =>
      '일정한 간격뿐 아니라 오른쪽 방향, 젖은 돌, 시작 시점을 모두 만족해야 합니다.',
    EpisodeOneV3Stage.orderEvidence =>
      '원인이 먼저, 그 결과가 나중에 오도록 배열합니다.',
    EpisodeOneV3Stage.chooseConclusion =>
      '단서로 확인하지 못한 내용은 사실이 아니라 추측입니다.',
    EpisodeOneV3Stage.completed => 'Episode 1에서 확인한 사실과 아직 남은 의문을 구분합니다.',
  };

  String get interactionGuide => switch (this) {
    EpisodeOneV3Stage.identifyFragment ||
    EpisodeOneV3Stage.identifyFlowerpot ||
    EpisodeOneV3Stage.findMissingEighteen ||
    EpisodeOneV3Stage.rejectNonDivisorEighteen ||
    EpisodeOneV3Stage.chooseTrackStart ||
    EpisodeOneV3Stage.chooseConclusion => '정답이라고 판단한 항목 하나를 선택하세요.',
    EpisodeOneV3Stage.testTwelveGroups || EpisodeOneV3Stage.testTrackIntervals =>
      '모든 시험 버튼을 한 번씩 눌러 결과를 본 뒤 확인하세요.',
    EpisodeOneV3Stage.orderTwelveDivisors ||
    EpisodeOneV3Stage.orderStorageGlyphs ||
    EpisodeOneV3Stage.connectFootprints ||
    EpisodeOneV3Stage.orderEvidence => '정답 순서대로 하나씩 누르세요. 잘못 누르면 되돌릴 수 있습니다.',
    EpisodeOneV3Stage.rejectFalseRecord =>
      '기록 하나를 고른 뒤 반드시 5칸 시험판 버튼도 눌러 검증하세요.',
    EpisodeOneV3Stage.useTraceFilters => '도구 세 개를 모두 켠 뒤 흔적이 분리되는지 확인하세요.',
    EpisodeOneV3Stage.completed => '결말을 확인한 뒤 정원으로 돌아갈 수 있습니다.',
    _ => '정답이라고 판단한 항목을 모두 선택한 뒤 결과를 확인하세요.',
  };

  String get submitLabel => switch (this) {
    EpisodeOneV3Stage.testTwelveGroups || EpisodeOneV3Stage.testTrackIntervals =>
      '실험 결과 확인하기',
    EpisodeOneV3Stage.orderTwelveDivisors ||
    EpisodeOneV3Stage.orderStorageGlyphs ||
    EpisodeOneV3Stage.connectFootprints ||
    EpisodeOneV3Stage.orderEvidence => '순서 확인하기',
    EpisodeOneV3Stage.useTraceFilters => '도구 결과 확인하기',
    EpisodeOneV3Stage.rejectFalseRecord => '기록 검증하기',
    EpisodeOneV3Stage.identifyFragment ||
    EpisodeOneV3Stage.identifyFlowerpot ||
    EpisodeOneV3Stage.findMissingEighteen ||
    EpisodeOneV3Stage.rejectNonDivisorEighteen ||
    EpisodeOneV3Stage.chooseTrackStart ||
    EpisodeOneV3Stage.chooseConclusion => '선택 확인하기',
    EpisodeOneV3Stage.completed => '확인하기',
    _ => '선택 결과 확인하기',
  };
}

@immutable
"""
replace_once(state_path, metadata_anchor, metadata_replacement)

message_replacements = {
    "2·3·4개씩은 남지 않았고 5개씩은 2개가 남았어요. 벽화의 숨은 배치도 확인할 수 있어요.":
        "나누어 남는 것이 없는 수를 약수라고 해요. 실험 결과를 이용해 12의 약수를 모두 찾아보세요.",
    "남김없이 빛나는 여섯 별자리 조각을 모두 찾았어요.":
        "1·2·3·4·6·12는 12를 나누어 남지 않게 하므로 모두 12의 약수예요.",
    "18개의 흔적이 남김없이 들어가는 배열을 모두 확인했어요.":
        "1·2·3·6·9·18은 18을 나누어 남지 않게 하므로 모두 18의 약수예요.",
    "네 건조판이 모두 빈칸 없이 채워지고 가장자리 문양을 드러냈어요.":
        "곱해서 24가 되는 네 쌍을 찾았어요. 이 곱셈 짝으로 24의 약수를 빠짐없이 찾을 수 있어요.",
    "네 배열의 두 변을 모아 여덟 잠금핀을 모두 밝혔어요.":
        "1·2·3·4·6·8·12·24는 24의 약수예요. 여덟 잠금핀이 모두 빛났어요.",
}
for old, new in message_replacements.items():
    replace_once(state_path, old, new)

screen_path = Path(
    "lib/features/adventure/escape/episode_one_v3/episode_one_v3_screen.dart"
)

replace_once(
    screen_path,
    """        children: [
          _StageContent(
""",
    """        children: [
          _StageInstructionCard(stage: snapshot.stage, compact: compact),
          const SizedBox(height: 12),
          _StageContent(
""",
)

replace_once(
    screen_path,
    """                  label: const Text('장치 확인하기'),
""",
    """                  label: Text(snapshot.stage.submitLabel),
""",
)

instruction_widget = r'''
class _StageInstructionCard extends StatelessWidget {
  const _StageInstructionCard({required this.stage, required this.compact});

  final EpisodeOneV3Stage stage;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('episode-one-v3-instruction-${stage.name}'),
      padding: EdgeInsets.all(compact ? 13 : 15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8DF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2C878), width: 1.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.assignment_rounded,
                color: Color(0xFF76591A),
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '지금 풀 문제',
                      style: TextStyle(
                        color: Color(0xFF76591A),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      stage.problemPrompt,
                      key: const Key('episode-one-v3-problem-prompt'),
                      style: TextStyle(
                        color: const Color(0xFF342D22),
                        fontSize: compact ? 14 : 15,
                        height: 1.4,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0x44A9853A)),
          const SizedBox(height: 9),
          _InstructionLine(
            icon: Icons.rule_rounded,
            label: '판단 기준',
            text: stage.decisionRule,
            compact: compact,
          ),
          const SizedBox(height: 7),
          _InstructionLine(
            icon: Icons.touch_app_rounded,
            label: '조작 방법',
            text: stage.interactionGuide,
            compact: compact,
          ),
        ],
      ),
    );
  }
}

class _InstructionLine extends StatelessWidget {
  const _InstructionLine({
    required this.icon,
    required this.label,
    required this.text,
    required this.compact,
  });

  final IconData icon;
  final String label;
  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF80652D), size: 18),
        const SizedBox(width: 7),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label  ',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                TextSpan(text: text),
              ],
            ),
            key: Key('episode-one-v3-${label == '판단 기준' ? 'decision-rule' : 'interaction-guide'}'),
            style: TextStyle(
              color: const Color(0xFF514633),
              fontSize: compact ? 11.5 : 12.5,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

'''
replace_once(
    screen_path,
    "class _StageContent extends StatelessWidget {\n",
    instruction_widget + "class _StageContent extends StatelessWidget {\n",
)

test_path = Path("test/episode_one_v3_test.dart")
unit_test_anchor = """  test('발자국 퍼즐은 필터·시작점·간격·방향 경로를 모두 요구한다', () {
"""
unit_test = """  test('약수 단계는 선수 지식 없이 문제와 판단 기준을 설명한다', () {
    expect(
      EpisodeOneV3Stage.revealTwelveDivisors.problemPrompt,
      contains('12개를 남김없이'),
    );
    expect(
      EpisodeOneV3Stage.revealTwelveDivisors.decisionRule,
      contains('12의 약수'),
    );
    expect(
      EpisodeOneV3Stage.revealTwelveDivisors.interactionGuide,
      contains('모두 선택'),
    );
    expect(
      EpisodeOneV3Stage.testTwelveGroups.submitLabel,
      '실험 결과 확인하기',
    );
  });

"""
replace_once(test_path, unit_test_anchor, unit_test + unit_test_anchor)

widget_test_anchor = """  testWidgets('시스템 뒤로가기는 Episode를 종료하지 않는다', (tester) async {
"""
widget_test = """  testWidgets('선택지 위에 문제·판단 기준·조작 방법을 표시한다', (tester) async {
    final controller = EpisodeOneV3Controller();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(home: EpisodeOneV3Screen(controller: controller)),
    );
    await tester.pump();

    expect(
      find.byKey(
        const Key('episode-one-v3-instruction-identifyFragment'),
      ),
      findsOneWidget,
    );
    expect(find.text('지금 풀 문제'), findsOneWidget);
    expect(
      find.byKey(const Key('episode-one-v3-problem-prompt')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('episode-one-v3-decision-rule')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('episode-one-v3-interaction-guide')),
      findsOneWidget,
    );
    expect(find.text('선택 확인하기'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

"""
replace_once(test_path, widget_test_anchor, widget_test + widget_test_anchor)
