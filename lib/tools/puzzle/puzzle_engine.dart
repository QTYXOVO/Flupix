import 'dart:math' as math;

/// 返回与 [index] 相邻（上下左右）的格子下标。
List<int> puzzleNeighbors(int index, int grid) {
  final row = index ~/ grid;
  final col = index % grid;
  return <int>[
    if (row > 0) index - grid,
    if (row < grid - 1) index + grid,
    if (col > 0) index - 1,
    if (col < grid - 1) index + 1,
  ];
}

/// 判断棋盘是否已经排好：前 n-1 格依次归位，最后一格为空。
bool isSolvedBoard(List<int> board, int blankValue) {
  for (var i = 0; i < board.length - 1; i++) {
    if (board[i] != i) return false;
  }
  return board.isNotEmpty && board.last == blankValue;
}

/// 生成一个可解的初始局面。
List<int> generateShuffledBoard(int grid, math.Random random) {
  final total = grid * grid;
  final blankValue = total - 1;
  final board = List<int>.generate(total, (index) => index);

  // 从已完成状态出发随机滑动，保证生成的局面一定有解。
  var blank = blankValue;
  var previous = -1;
  for (var i = 0; i < total * 40; i++) {
    final candidates = puzzleNeighbors(blank, grid);
    if (previous >= 0) candidates.remove(previous);
    if (candidates.isEmpty) {
      previous = -1;
      continue;
    }
    final next = candidates[random.nextInt(candidates.length)];
    board[blank] = board[next];
    board[next] = blankValue;
    previous = blank;
    blank = next;
  }
  if (isSolvedBoard(board, blankValue)) {
    final next = puzzleNeighbors(blank, grid).first;
    board[blank] = board[next];
    board[next] = blankValue;
  }
  return board;
}
