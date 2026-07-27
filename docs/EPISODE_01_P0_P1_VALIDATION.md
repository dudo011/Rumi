# Episode 1 P0·P1 자동 검증 결과

- 검증 커밋: f2bb2eef5f0c6a56abb42f83513b4d7d7382168c
- flutter pub get: 성공
- flutter analyze: 실패
- flutter test: 실패
- flutter build web: 성공

## Analyze 오류
```text
Resolving dependencies...
Downloading packages...
  hooks 2.0.2 (2.1.0 available)
  matcher 0.12.19 (0.12.20 available)
  meta 1.18.0 (1.19.0 available)
  record_use 0.6.0 (1.0.0 available)
  test_api 0.7.11 (0.7.13 available)
  vector_math 2.2.0 (2.4.1 available)
Got dependencies!
6 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Analyzing Rumi...                                               

   info • The parameter name 'gameSize' doesn't match the name 'size' in the overridden method. Try changing the name to 'size' • lib/features/adventure/escape/episode_one/episode_one_scene.dart:24:29 • avoid_renaming_method_parameters

1 issue found. (ran in 9.4s)
```

## Test 오류
```text
Warning: A call to tap() with finder "Found 1 widget with key [<'star-dust-5'>]: [
  InkWell-[<'star-dust-5'>],
]" derived an Offset (Offset(202.7, 1283.0)) that would not hit test on the specified widget.
Maybe the widget is actually off-screen, or another widget is obscuring it, or the widget cannot receive pointer events.
The finder corresponds to this RenderBox: RenderSemanticsAnnotations#d0039 relayoutBoundary=up18
The hit test result at that offset is: HitTestResult(GameRenderBox#228d1@Offset(200.0, 1283.0), RenderPointerListener#ea2de@Offset(200.0, 1283.0), RenderSemanticsGestureHandler#03a35@Offset(200.0, 1283.0), RenderStack#c785c@Offset(200.0, 1283.0), _RenderLayoutBuilder#976ba@Offset(200.0, 1283.0), RenderDecoratedBox#fe7f5@Offset(200.0, 1283.0), RenderMouseRegion#5031f@Offset(200.0, 1283.0), RenderSemanticsAnnotations#c69f6@Offset(200.0, 1283.0), RenderSemanticsAnnotations#da0a7@Offset(200.0, 1283.0), RenderStack#3879d@Offset(200.0, 1283.0), RenderPadding#d48c4@Offset(200.0, 1283.0), RenderCustomMultiChildLayoutBox#347da@Offset(200.0, 1283.0), _RenderInkFeatures#eb18a@Offset(200.0, 1283.0), RenderPhysicalModel#a685f@Offset(200.0, 1283.0), RenderSemanticsAnnotations#07ac5@Offset(200.0, 1283.0), RenderRepaintBoundary#57a5c@Offset(200.0, 1283.0), RenderIgnorePointer#0e410@Offset(200.0, 1283.0), RenderAnimatedOpacity#3598a@Offset(200.0, 1283.0), RenderAnimatedOpacity#80ff8@Offset(200.0, 1283.0), _RenderColoredBox#b878d@Offset(200.0, 1283.0), RenderAnimatedOpacity#87f23@Offset(200.0, 1283.0), RenderIgnorePointer#2b450@Offset(200.0, 1283.0), RenderAnimatedOpacity#9198b@Offset(202.7, 1283.0), RenderRepaintBoundary#11514@Offset(202.7, 1283.0), RenderSemanticsAnnotations#bd8ae@Offset(202.7, 1283.0), RenderOffstage#19222@Offset(202.7, 1283.0), RenderSemanticsAnnotations#e3973@Offset(202.7, 1283.0), _RenderTheater#08bb9@Offset(202.7, 1283.0), RenderAbsorbPointer#b2d1e@Offset(202.7, 1283.0), RenderPointerListener#fe188@Offset(202.7, 1283.0), RenderSemanticsAnnotations#6ac1c@Offset(202.7, 1283.0), RenderCustomPaint#0c759@Offset(202.7, 1283.0), RenderSemanticsAnnotations#9d22d@Offset(202.7, 1283.0), RenderSemanticsAnnotations#dde72@Offset(202.7, 1283.0), RenderSemanticsAnnotations#77dfb@Offset(202.7, 1283.0), RenderTapRegionSurface#c33e9@Offset(202.7, 1283.0), RenderSemanticsAnnotations#3d174@Offset(202.7, 1283.0), RenderSemanticsAnnotations#f5b81@Offset(202.7, 1283.0), HitTestEntry<HitTestTarget>#dcaf8(_ReusableRenderView#b8145), HitTestEntry<HitTestTarget>#72a2b(<AutomatedTestWidgetsFlutterBinding>))
#0      WidgetController._getElementPoint (package:flutter_test/src/controller.dart:2165:25)
#1      WidgetController.getCenter (package:flutter_test/src/controller.dart:1947:12)
#2      WidgetController.tap (package:flutter_test/src/controller.dart:1080:7)
#3      main.solvePedestal (file:///home/runner/work/Rumi/Rumi/test/garden_exploration_screen_test.dart:32:20)
<asynchronous suspension>
#4      main.reachSolved (file:///home/runner/work/Rumi/Rumi/test/garden_exploration_screen_test.dart:44:5)
<asynchronous suspension>
#5      main.<anonymous closure> (file:///home/runner/work/Rumi/Rumi/test/garden_exploration_screen_test.dart:143:5)
<asynchronous suspension>
#6      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#7      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1952:5)
<asynchronous suspension>
#8      StackZoneSpecification._registerCallback.<anonymous closure> (package:stack_trace/src/stack_zone_specification.dart:114:42)
<asynchronous suspension>
To silence this warning, pass "warnIfMissed: false" to "tap()".
To make this warning fatal, set WidgetController.hitTestWarningShouldBeFatal to true.


Warning: A call to tap() with finder "Found 1 widget with key [<'star-dust-6'>]: [
  InkWell-[<'star-dust-6'>],
]" derived an Offset (Offset(250.3, 1283.0)) that would not hit test on the specified widget.
Maybe the widget is actually off-screen, or another widget is obscuring it, or the widget cannot receive pointer events.
The finder corresponds to this RenderBox: RenderSemanticsAnnotations#66f61 relayoutBoundary=up18
The hit test result at that offset is: HitTestResult(GameRenderBox#228d1@Offset(250.0, 1283.0), RenderPointerListener#ea2de@Offset(250.0, 1283.0), RenderSemanticsGestureHandler#03a35@Offset(250.0, 1283.0), RenderStack#c785c@Offset(250.0, 1283.0), _RenderLayoutBuilder#976ba@Offset(250.0, 1283.0), RenderDecoratedBox#fe7f5@Offset(250.0, 1283.0), RenderMouseRegion#5031f@Offset(250.0, 1283.0), RenderSemanticsAnnotations#c69f6@Offset(250.0, 1283.0), RenderSemanticsAnnotations#da0a7@Offset(250.0, 1283.0), RenderStack#3879d@Offset(250.0, 1283.0), RenderPadding#d48c4@Offset(250.0, 1283.0), RenderCustomMultiChildLayoutBox#347da@Offset(250.0, 1283.0), _RenderInkFeatures#eb18a@Offset(250.0, 1283.0), RenderPhysicalModel#a685f@Offset(250.0, 1283.0), RenderSemanticsAnnotations#07ac5@Offset(250.0, 1283.0), RenderRepaintBoundary#57a5c@Offset(250.0, 1283.0), RenderIgnorePointer#0e410@Offset(250.0, 1283.0), RenderAnimatedOpacity#3598a@Offset(250.0, 1283.0), RenderAnimatedOpacity#80ff8@Offset(250.0, 1283.0), _RenderColoredBox#b878d@Offset(250.0, 1283.0), RenderAnimatedOpacity#87f23@Offset(250.0, 1283.0), RenderIgnorePointer#2b450@Offset(250.0, 1283.0), RenderAnimatedOpacity#9198b@Offset(250.3, 1283.0), RenderRepaintBoundary#11514@Offset(250.3, 1283.0), RenderSemanticsAnnotations#bd8ae@Offset(250.3, 1283.0), RenderOffstage#19222@Offset(250.3, 1283.0), RenderSemanticsAnnotations#e3973@Offset(250.3, 1283.0), _RenderTheater#08bb9@Offset(250.3, 1283.0), RenderAbsorbPointer#b2d1e@Offset(250.3, 1283.0), RenderPointerListener#fe188@Offset(250.3, 1283.0), RenderSemanticsAnnotations#6ac1c@Offset(250.3, 1283.0), RenderCustomPaint#0c759@Offset(250.3, 1283.0), RenderSemanticsAnnotations#9d22d@Offset(250.3, 1283.0), RenderSemanticsAnnotations#dde72@Offset(250.3, 1283.0), RenderSemanticsAnnotations#77dfb@Offset(250.3, 1283.0), RenderTapRegionSurface#c33e9@Offset(250.3, 1283.0), RenderSemanticsAnnotations#3d174@Offset(250.3, 1283.0), RenderSemanticsAnnotations#f5b81@Offset(250.3, 1283.0), HitTestEntry<HitTestTarget>#ea39c(_ReusableRenderView#b8145), HitTestEntry<HitTestTarget>#15ddb(<AutomatedTestWidgetsFlutterBinding>))
#0      WidgetController._getElementPoint (package:flutter_test/src/controller.dart:2165:25)
#1      WidgetController.getCenter (package:flutter_test/src/controller.dart:1947:12)
#2      WidgetController.tap (package:flutter_test/src/controller.dart:1080:7)
#3      main.solvePedestal (file:///home/runner/work/Rumi/Rumi/test/garden_exploration_screen_test.dart:32:20)
<asynchronous suspension>
#4      main.reachSolved (file:///home/runner/work/Rumi/Rumi/test/garden_exploration_screen_test.dart:44:5)
<asynchronous suspension>
#5      main.<anonymous closure> (file:///home/runner/work/Rumi/Rumi/test/garden_exploration_screen_test.dart:143:5)
<asynchronous suspension>
#6      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#7      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1952:5)
<asynchronous suspension>
#8      StackZoneSpecification._registerCallback.<anonymous closure> (package:stack_trace/src/stack_zone_specification.dart:114:42)
<asynchronous suspension>
To silence this warning, pass "warnIfMissed: false" to "tap()".
To make this warning fatal, set WidgetController.hitTestWarningShouldBeFatal to true.

══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following assertion was thrown running a test:
The finder "Found 0 widgets with key [<'star-dust-7'>]: []" (used in a call to "tap()") could not
find any matching widgets.

When the exception was thrown, this was the stack:
#0      WidgetController._getElementPoint (package:flutter_test/src/controller.dart:2095:7)
#1      WidgetController.getCenter (package:flutter_test/src/controller.dart:1947:12)
#2      WidgetController.tap (package:flutter_test/src/controller.dart:1080:7)
#3      main.solvePedestal (file:///home/runner/work/Rumi/Rumi/test/garden_exploration_screen_test.dart:32:20)
<asynchronous suspension>
#4      main.reachSolved (file:///home/runner/work/Rumi/Rumi/test/garden_exploration_screen_test.dart:44:5)
<asynchronous suspension>
#5      main.<anonymous closure> (file:///home/runner/work/Rumi/Rumi/test/garden_exploration_screen_test.dart:143:5)
<asynchronous suspension>
#6      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#7      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1952:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

The test description was:
  세 조사 장면과 추리 보드를 거쳐 사건을 해결한다
════════════════════════════════════════════════════════════════════════════════════════════════════
Test failed. See exception logs above.
The test description was: 세 조사 장면과 추리 보드를 거쳐 사건을 해결한다

::endgroup::
✅ /home/runner/work/Rumi/Rumi/test/garden_exploration_screen_test.dart: 작은 화면에서도 시작 화면과 목표 영역이 넘치지 않는다
✅ /home/runner/work/Rumi/Rumi/test/progress_store_test.dart: 닉네임과 모험 진행 상황을 기기에 저장한다
✅ /home/runner/work/Rumi/Rumi/test/progress_store_test.dart: 경험치가 100을 넘으면 꽃숲 성장 단계가 오른다
✅ /home/runner/work/Rumi/Rumi/test/widget_test.dart: 스플래시 화면에 별정원 소개가 표시된다
✅ /home/runner/work/Rumi/Rumi/test/widget_test.dart: 작은 화면에서도 스플래시 화면이 표시된다
✅ /home/runner/work/Rumi/Rumi/test/widget_test.dart: 스플래시 후 닉네임 입력 화면으로 이동한다
✅ /home/runner/work/Rumi/Rumi/test/widget_test.dart: 올바른 닉네임을 입력하면 꽃루미를 만난다
✅ /home/runner/work/Rumi/Rumi/test/widget_test.dart: 저장된 닉네임이 있으면 메인 화면으로 이동한다
✅ /home/runner/work/Rumi/Rumi/test/adventure_screen_test.dart: 힌트를 보고 문제를 풀면 결과와 경험치를 보여준다
✅ /home/runner/work/Rumi/Rumi/test/question_bank_test.dart: 약수와 배수 문제 은행은 15개의 유효한 문제를 제공한다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: P1은 별가루 12개를 4·4·4로 나눈 경우에만 해결된다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: P0와 P1 완료 전후에 실제 경로 잠금 상태가 달라진다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: 불균형 배치는 유지한 채 별가루를 다시 옮길 수 있다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: Episode 1 HUD가 P0·P1 진행 상태를 반영한다
✅ /home/runner/work/Rumi/Rumi/test/episode_one_escape_foundation_test.dart: 작은 화면에서도 Episode 1 HUD가 넘치지 않는다
✅ /home/runner/work/Rumi/Rumi/test/features/adventure/garden_exploration_screen_test.dart: 별받침대는 문제지보다 조사 지점을 먼저 제공한다
✅ /home/runner/work/Rumi/Rumi/test/features/adventure/garden_exploration_screen_test.dart: 세 지점을 조사하면 별가루 직접 묶기가 열린다
✅ /home/runner/work/Rumi/Rumi/test/features/adventure/flame/escape_feasibility_screen_test.dart: 기술 검증 상태는 초기 인벤토리와 진행 메시지를 보존한다
✅ /home/runner/work/Rumi/Rumi/test/features/adventure/flame/escape_feasibility_screen_test.dart: 기술 검증 화면은 독립 StatefulWidget으로 제공된다
✅ /home/runner/work/Rumi/Rumi/test/features/adventure/garden_exploration_screen_test.dart: 상자와 돌은 발자국 증거 전에는 나타나지 않는다

::error::23 tests passed, 2 failed.
```

