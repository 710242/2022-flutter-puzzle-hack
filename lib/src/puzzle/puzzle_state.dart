part of 'puzzle_bloc.dart';

@immutable
class PuzzleState {
  const PuzzleState({
    this.puzzle = const Puzzle(tiles: []),
    this.puzzleStatus = PuzzleStatus.incomplete,
  });

  final Puzzle puzzle;

  final PuzzleStatus puzzleStatus;

  PuzzleState copyWith({
    Puzzle? puzzle,
    PuzzleStatus? puzzleStatus,
  }) {
    return PuzzleState(
        puzzle: puzzle ?? this.puzzle,
        puzzleStatus: puzzleStatus ?? this.puzzleStatus
    );
  }
}

class TutorialState extends PuzzleState{
  TutorialState(puzzle) : super(puzzle: puzzle);
}

class IsHomeState extends PuzzleState{
  IsHomeState() : super();
}

class IsGameState extends PuzzleState{
  IsGameState(puzzle) : super(puzzle: puzzle);
}

class PuzzleLoseState extends PuzzleState{
  PuzzleLoseState() : super();
}

class PuzzleWinState extends PuzzleState{
  PuzzleWinState(this.completelevel,this.getstar) : super();

  final int completelevel;
  final int getstar;
}
