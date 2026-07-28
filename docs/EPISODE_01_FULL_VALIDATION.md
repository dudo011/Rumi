# Episode 1 전체 자동 검증 결과

- 검증일: 2026-07-28
- 검증 기준 커밋: 13396f804b3ef5fdcd2911eb1cba4e37ca6e0dac
- flutter pub get: 성공
- dart format: 성공
- flutter analyze: 성공
- flutter test: 실패
- flutter build web: 성공

## 최종 판정

실패 항목이 있어 수정과 재검증이 필요하다.

## test 오류
```text
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1952:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///home/runner/work/Rumi/Rumi/test/episode_one_greenhouse_test.dart line 123
The test description was:
  온실 화면에서 문 개방과 P5 전체 조작을 완료할 수 있다
════════════════════════════════════════════════════════════════════════════════════════════════════
Test failed. See exception logs above.
The test description was: 온실 화면에서 문 개방과 P5 전체 조작을 완료할 수 있다

::endgroup::
✅ /home/runner/work/Rumi/Rumi/test/garden_exploration_screen_test.dart: 별받침대는 관찰 후 별가루를 직접 묶어 해결한다
::group::❌ /home/runner/work/Rumi/Rumi/test/episode_one_greenhouse_test.dart: 온실의 마지막 증거를 단서 수첩에서 확인할 수 있다 (failed)

Warning: A call to tap() with finder "Found 1 widget with key [<'episode-one-clue-notebook'>]: [
  IconButton-[<'episode-one-clue-notebook'>](tooltip: 단서 수첩, disabled, disabled, dependencies: [InheritedCupertinoTheme, _InheritedTheme, _LocalizationsScope-[GlobalKey#e5309]]),
]" derived an Offset (Offset(824.0, 30.0)) that would not hit test on the specified widget.
Maybe the widget is actually off-screen, or another widget is obscuring it, or the widget cannot receive pointer events.
The finder corresponds to this RenderBox: RenderSemanticsAnnotations#90769 relayoutBoundary=up4
The hit test result at that offset is: HitTestResult(_RenderInkFeatures#d9193@Offset(824.0, 30.0), RenderPhysicalModel#d7ed3@Offset(824.0, 30.0), RenderStack#9a5e6@Offset(824.0, 30.0), RenderPadding#8e869@Offset(824.0, 30.0), RenderCustomMultiChildLayoutBox#5f8ff@Offset(824.0, 30.0), _RenderInkFeatures#0919b@Offset(824.0, 30.0), RenderPhysicalModel#49f89@Offset(824.0, 30.0), RenderSemanticsAnnotations#4b9f8@Offset(824.0, 30.0), RenderRepaintBoundary#f7ce2@Offset(824.0, 30.0), RenderIgnorePointer#ba338@Offset(824.0, 30.0), RenderAnimatedOpacity#e70aa@Offset(824.0, 30.0), RenderAnimatedOpacity#55fae@Offset(824.0, 30.0), _RenderColoredBox#869e3@Offset(824.0, 30.0), RenderAnimatedOpacity#c83b2@Offset(824.0, 30.0), RenderIgnorePointer#a6469@Offset(824.0, 30.0), RenderAnimatedOpacity#20222@Offset(824.0, 30.0), RenderRepaintBoundary#82384@Offset(824.0, 30.0), RenderSemanticsAnnotations#ae587@Offset(824.0, 30.0), RenderOffstage#d11c0@Offset(824.0, 30.0), RenderSemanticsAnnotations#48258@Offset(824.0, 30.0), _RenderTheater#4a782@Offset(824.0, 30.0), RenderAbsorbPointer#5713b@Offset(824.0, 30.0), RenderPointerListener#c261c@Offset(824.0, 30.0), RenderSemanticsAnnotations#d6723@Offset(824.0, 30.0), RenderCustomPaint#b067e@Offset(824.0, 30.0), RenderSemanticsAnnotations#280c8@Offset(824.0, 30.0), RenderSemanticsAnnotations#19308@Offset(824.0, 30.0), RenderSemanticsAnnotations#ecfc5@Offset(824.0, 30.0), RenderTapRegionSurface#8f7fc@Offset(824.0, 30.0), RenderSemanticsAnnotations#9e388@Offset(824.0, 30.0), RenderSemanticsAnnotations#05c84@Offset(824.0, 30.0), HitTestEntry<HitTestTarget>#8aa1d(_ReusableRenderView#2125f), HitTestEntry<HitTestTarget>#61108(<AutomatedTestWidgetsFlutterBinding>))
#0      WidgetController._getElementPoint (package:flutter_test/src/controller.dart:2165:25)
#1      WidgetController.getCenter (package:flutter_test/src/controller.dart:1947:12)
#2      WidgetController.tap (package:flutter_test/src/controller.dart:1080:7)
#3      main.<anonymous closure> (file:///home/runner/work/Rumi/Rumi/test/episode_one_greenhouse_test.dart:150:18)
<asynchronous suspension>
#4      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#5      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1952:5)
<asynchronous suspension>
#6      StackZoneSpecification._registerCallback.<anonymous closure> (package:stack_trace/src/stack_zone_specification.dart:114:42)
<asynchronous suspension>
To silence this warning, pass "warnIfMissed: false" to "tap()".
To make this warning fatal, set WidgetController.hitTestWarningShouldBeFatal to true.

══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: exactly one matching candidate
  Actual: _KeyWidgetFinder:<Found 0 widgets with key [<'episode-one-clue-warmNest'>]: []>
   Which: means none were found but one was expected

When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///home/runner/work/Rumi/Rumi/test/episode_one_greenhouse_test.dart:154:5)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1952:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///home/runner/work/Rumi/Rumi/test/episode_one_greenhouse_test.dart line 154
The test description was:
  온실의 마지막 증거를 단서 수첩에서 확인할 수 있다
════════════════════════════════════════════════════════════════════════════════════════════════════
Test failed. See exception logs above.
The test description was: 온실의 마지막 증거를 단서 수첩에서 확인할 수 있다

::endgroup::
✅ /home/runner/work/Rumi/Rumi/test/episode_one_greenhouse_test.dart: 작은 화면에서도 온실 장면이 스크롤되고 넘치지 않는다
✅ /home/runner/work/Rumi/Rumi/test/garden_exploration_screen_test.dart: 조사 대상이 증거에 따라 단계적으로 열린다
✅ /home/runner/work/Rumi/Rumi/test/garden_exploration_screen_test.dart: 세 조사 장면과 추리 보드를 거쳐 사건을 해결한다
✅ /home/runner/work/Rumi/Rumi/test/garden_exploration_screen_test.dart: 작은 화면에서도 시작 화면과 목표 영역이 넘치지 않는다
✅ /home/runner/work/Rumi/Rumi/test/starlight_seed_episode_test.dart: 사건을 조사하고 세 장소의 단서를 모아 진실을 밝힌다
✅ /home/runner/work/Rumi/Rumi/test/starlight_seed_episode_test.dart: 온실은 연못과 숲의 단서를 찾기 전에는 잠겨 있다
::group::❌ /home/runner/work/Rumi/Rumi/test/episode_one_finale_test.dart: 최종 추리 오답은 증거 기반 피드백 후 다시 선택할 수 있다 (failed)
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: exactly one matching candidate
  Actual: _KeyWidgetFinder:<Found 0 widgets with key [<'episode-one-deduction-wrong'>]: []>
   Which: means none were found but one was expected

When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///home/runner/work/Rumi/Rumi/test/episode_one_finale_test.dart:48:5)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1952:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///home/runner/work/Rumi/Rumi/test/episode_one_finale_test.dart line 48
The test description was:
  최종 추리 오답은 증거 기반 피드백 후 다시 선택할 수 있다
════════════════════════════════════════════════════════════════════════════════════════════════════
Test failed. See exception logs above.
The test description was: 최종 추리 오답은 증거 기반 피드백 후 다시 선택할 수 있다

::endgroup::
::group::❌ /home/runner/work/Rumi/Rumi/test/episode_one_finale_test.dart: 정답 추리 후 별빛 꽃이 피고 110 XP가 한 번만 기록된다 (failed)
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: exactly one matching candidate
  Actual: _KeyWidgetFinder:<Found 0 widgets with key [<'episode-one-deduction-correct'>]: []>
   Which: means none were found but one was expected

When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///home/runner/work/Rumi/Rumi/test/episode_one_finale_test.dart:84:5)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1952:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///home/runner/work/Rumi/Rumi/test/episode_one_finale_test.dart line 84
The test description was:
  정답 추리 후 별빛 꽃이 피고 110 XP가 한 번만 기록된다
════════════════════════════════════════════════════════════════════════════════════════════════════
Test failed. See exception logs above.
The test description was: 정답 추리 후 별빛 꽃이 피고 110 XP가 한 번만 기록된다

::endgroup::
✅ /home/runner/work/Rumi/Rumi/test/widget_test.dart: 스플래시 화면에 별정원 소개가 표시된다
✅ /home/runner/work/Rumi/Rumi/test/widget_test.dart: 작은 화면에서도 스플래시 화면이 표시된다
::group::❌ /home/runner/work/Rumi/Rumi/test/episode_one_finale_test.dart: 완료 기록 실패 시 재시도해 결말로 이동할 수 있다 (failed)
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: exactly one matching candidate
  Actual: _KeyWidgetFinder:<Found 0 widgets with key [<'episode-one-finale-save-error'>]: []>
   Which: means none were found but one was expected

When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///home/runner/work/Rumi/Rumi/test/episode_one_finale_test.dart:144:5)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1952:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///home/runner/work/Rumi/Rumi/test/episode_one_finale_test.dart line 144
The test description was:
  완료 기록 실패 시 재시도해 결말로 이동할 수 있다
════════════════════════════════════════════════════════════════════════════════════════════════════
Test failed. See exception logs above.
The test description was: 완료 기록 실패 시 재시도해 결말로 이동할 수 있다

::endgroup::
✅ /home/runner/work/Rumi/Rumi/test/episode_one_finale_test.dart: 작은 화면에서도 최종 추리 화면이 스크롤되고 넘치지 않는다
✅ /home/runner/work/Rumi/Rumi/test/widget_test.dart: 스플래시 후 닉네임 입력 화면으로 이동한다
✅ /home/runner/work/Rumi/Rumi/test/widget_test.dart: 올바른 닉네임을 입력하면 꽃루미를 만난다
✅ /home/runner/work/Rumi/Rumi/test/widget_test.dart: 저장된 닉네임이 있으면 메인 화면으로 이동한다
✅ /home/runner/work/Rumi/Rumi/test/progress_store_test.dart: 닉네임과 모험 진행 상황을 기기에 저장한다
✅ /home/runner/work/Rumi/Rumi/test/progress_store_test.dart: 경험치가 100을 넘으면 꽃숲 성장 단계가 오른다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_fountain_test.dart: 분수대 돌 선택은 연못 단서가 있어야 성공할 수 있다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_fountain_test.dart: P4는 바람끈·젖은 발자국·별열쇠를 연결해 달빛 손잡이를 준다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_fountain_test.dart: 잘못된 아이템은 분수대에서 사라지지 않는다
✅ /home/runner/work/Rumi/Rumi/test/adventure_screen_test.dart: 힌트를 보고 문제를 풀면 결과와 경험치를 보여준다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_fountain_test.dart: 분수대 화면에서 P4 전체 연쇄 조작을 완료할 수 있다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_fountain_test.dart: 작은 화면에서도 분수대 연쇄 장면이 스크롤되고 넘치지 않는다
✅ /home/runner/work/Rumi/Rumi/test/question_bank_test.dart: 약수와 배수 문제 은행은 15개의 유효한 문제를 제공한다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: P1은 별가루 12개를 4·4·4로 나눈 경우에만 해결된다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: P2는 4와 6의 첫 공배수인 12번째 칸에서만 해결된다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: P3은 0·2·4·6 순서의 실제 발자국만 허용한다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: P0와 P1 완료 전후에 실제 경로 잠금 상태가 달라진다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: 불균형 배치는 유지한 채 별가루를 다시 옮길 수 있다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: 별무늬 렌즈를 사용해 연못 기억거울과 P3 단서를 해결한다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: 시계꽃 숲은 오답을 유지하지 않고 12번째 칸에서 은빛 바람끈을 준다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: 연못과 시계꽃 숲은 원하는 순서로 해결할 수 있다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: 인벤토리에서 별무늬 렌즈를 선택하고 해제할 수 있다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: 시계꽃 시간고리에서 12번째 칸을 눌러 바람끈을 얻는다
✅ /home/runner/work/Rumi/Rumi/test/features/adventure/garden_exploration_screen_test.dart: 별받침대는 문제지보다 조사 지점을 먼저 제공한다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: 연못 단서를 수첩에서 확인할 수 있다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: 작은 화면에서도 HUD·인벤토리·시계꽃 화면이 넘치지 않는다
✅ /home/runner/work/Rumi/Rumi/test/features/adventure/garden_exploration_screen_test.dart: 세 지점을 조사하면 별가루 직접 묶기가 열린다
✅ /home/runner/work/Rumi/Rumi/test/features/adventure/garden_exploration_screen_test.dart: 상자와 돌은 발자국 증거 전에는 나타나지 않는다
✅ /home/runner/work/Rumi/Rumi/test/features/adventure/flame/escape_feasibility_screen_test.dart: 기술 검증 상태는 초기 인벤토리와 진행 메시지를 보존한다
✅ /home/runner/work/Rumi/Rumi/test/features/adventure/flame/escape_feasibility_screen_test.dart: 기술 검증 화면은 독립 StatefulWidget으로 제공된다

::error::42 tests passed, 5 failed.
```

