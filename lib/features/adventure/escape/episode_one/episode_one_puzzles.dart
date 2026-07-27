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
