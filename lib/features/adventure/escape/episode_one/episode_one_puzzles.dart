class PedestalBalancePuzzle {
  const PedestalBalancePuzzle._();

  static const int totalDust = 12;
  static const int cupCount = 3;
  static const int targetPerCup = totalDust ~/ cupCount;

  static int usedDust(List<int> cups) {
    return cups.fold(0, (total, count) => total + count);
  }

  static int remainingDust(List<int> cups) {
    return totalDust - usedDust(cups);
  }

  static bool isSolved(List<int> cups) {
    if (cups.length != cupCount || usedDust(cups) != totalDust) {
      return false;
    }
    return cups.every((count) => count == targetPerCup);
  }

  static String feedback(List<int> cups) {
    final remaining = remainingDust(cups);
    if (remaining > 0) {
      return '별가루 $remaining개가 남아 있어요. 세 컵의 높이를 같게 맞춰 보세요.';
    }
    if (isSolved(cups)) {
      return '세 컵의 무게가 같아졌어요. 받침대 안쪽 장치가 움직이기 시작해요!';
    }
    return '세 컵의 무게가 아직 달라요. 아래쪽 빼기 버튼으로 다시 옮길 수 있어요.';
  }
}

class PondTrackPuzzle {
  const PondTrackPuzzle._();

  static const List<int> correctOrder = [0, 2, 4, 6];
  static const Set<int> windMarks = {1, 3, 5};

  static bool isExpectedTrack({
    required int selectedIndex,
    required int progress,
  }) {
    if (progress < 0 || progress >= correctOrder.length) return false;
    return correctOrder[progress] == selectedIndex;
  }

  static bool isRealFootprint(int index) {
    return correctOrder.contains(index);
  }

  static bool isCompleted(int progress) {
    return progress >= correctOrder.length;
  }

  static String incorrectFeedback({
    required int selectedIndex,
    required int progress,
  }) {
    if (windMarks.contains(selectedIndex)) {
      return '이 자국에는 작은 발가락 모양이 없어요. 바람이 물 위를 스친 흔적 같아요.';
    }
    if (isRealFootprint(selectedIndex)) {
      return progress == 0
          ? '물가에서 가장 가까운 둥근 발자국부터 찾아보세요.'
          : '빛으로 이어진 마지막 발자국 다음의 흔적을 찾아보세요.';
    }
    return '둥근 발바닥과 작은 발가락이 있는 흔적을 찾아보세요.';
  }
}

class ClockflowerPuzzle {
  const ClockflowerPuzzle._();

  static const int ringSize = 12;
  static const int blueInterval = 4;
  static const int yellowInterval = 6;
  static const int firstCommonStep = 12;

  static bool isValidStep(int step) {
    return step >= 1 && step <= ringSize;
  }

  static bool blueOpensAt(int step) {
    return isValidStep(step) && step % blueInterval == 0;
  }

  static bool yellowOpensAt(int step) {
    return isValidStep(step) && step % yellowInterval == 0;
  }

  static bool isSolved(int step) {
    return step == firstCommonStep;
  }

  static String feedback(int step) {
    if (!isValidStep(step)) {
      return '시간고리의 1번부터 12번 사이 칸을 선택하세요.';
    }
    final blueOpen = blueOpensAt(step);
    final yellowOpen = yellowOpensAt(step);
    if (blueOpen && yellowOpen) {
      return '두 시계꽃이 함께 열렸어요. 은빛 바람끈이 내려오기 시작해요!';
    }
    if (blueOpen) return '파란 시계꽃만 반응했어요.';
    if (yellowOpen) return '노란 시계꽃만 반응했어요.';
    return '아직 두 꽃의 시간이 아니에요.';
  }
}
