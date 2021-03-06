import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:slide_puzzle/src/model/models.dart';

part 'puzzle_event.dart';
part 'puzzle_state.dart';

class PuzzleBloc extends Bloc<PuzzleEvent, PuzzleState> {
  PuzzleBloc(this.level,this.tileMovementStatus,) : super(const PuzzleState()) {
    on<IsHome>(_onIsHome);
    on<PuzzleInitialized>(_onPuzzleInitialized);
    on<Tutorial>(_onTutorial);
    on<PressedTile>(_onPressedTile);
    on<TileTapped>(_onTileTapped);
    on<TileUnTapped>(_onTileUnTapped);
    on<SwapTiles>(_onSwapTiles);
    on<SwapKingTiles>(_onSwapKinigTiles);
    on<PuzzleLose>(_onPuzzleLose);
  }

  int level;

  late int getStars;

  /// first screen is feild leftmovestep is not initialized
  late int leftmovesteps = _generateMoveTimes();

  bool isBlack = true;

  List<bool> boardtheme = [true,false,false];

  ThemeData theme = ThemeData(
      primaryColorLight: Color.fromRGBO(255,255,255, 1.0),
      primaryColorDark:  Color.fromRGBO(110,110,110, 1.0),
      selectedRowColor: Colors.green
  );

  TileMovementStatus tileMovementStatus;

  Tile? tiletapped;

  int _calculateStar(){
    bool eatEnemy = true;
    int tempcnt = 0;
    for(List<Tile> l in this.state.puzzle.tiles){
      for(Tile t in l){
        if(t.value == ChessPieces.EnemyKing){
          eatEnemy = false;
        }
      }
    }
    if(eatEnemy == true) tempcnt += 1;

    switch(this.level){
      case 0:
        return 3;
      case 1:
        if(leftmovesteps >= 3) tempcnt = 3;
        break;
      case 2:
        if(leftmovesteps >= 3) tempcnt += 2;
        else tempcnt += 1;
        break;
      case 3:
        if(leftmovesteps >= 5) tempcnt += 2;
        else tempcnt += 1;
        break;
      case 4:
        if(leftmovesteps >= 5) tempcnt += 2;
        else tempcnt += 1;
        break;
      case 5:
        if(leftmovesteps >= 3) tempcnt += 2;
        else tempcnt += 1;
        break;
      case 6:
        if(leftmovesteps >= 3) tempcnt += 2;
        else tempcnt += 1;
        break;
      case 7:
        if(leftmovesteps >= 3) tempcnt += 2;
        else tempcnt += 1;
        break;
      case 8:
        if(leftmovesteps >= 5) tempcnt += 2;
        else tempcnt += 1;
        break;
      case 9:
        if(leftmovesteps >= 5) tempcnt += 2;
        else tempcnt += 1;
        break;
      case 10:
        if(leftmovesteps >= 2) tempcnt += 2;
        else tempcnt += 1;
        break;
    }
    return tempcnt;
  }

  Puzzle _generatePuzzle(){
    Puzzle puzzle = Puzzle(tiles: []);
    puzzle.initializeTiles(level);
    return puzzle;
  }

  int _generateMoveTimes(){
    switch(level){
      case 0:
        return 100;
      case 1:
        return 10;
      case 2:
        return 10;
      case 3:
        return 15;
      case 4:
        return 20;
      case 5:
        return 15;
      case 6:
        return 15;
      case 7:
        return 10;
      case 8:
        return 15;
      case 9:
        return 20;
      case 10:
        return 10;
    }
    return 10;
  }

  void _onIsHome(IsHome event, Emitter<PuzzleState> emit){
    emit(
      IsHomeState()
    );
  }

  void _onPuzzleInitialized(PuzzleInitialized event, Emitter<PuzzleState> emit,) {
    this.level = event.level;
    final puzzle = _generatePuzzle();
    this.leftmovesteps = _generateMoveTimes();
    emit(
      IsGameState(
        puzzle
      ),
    );
  }

  void _onTutorial(Tutorial event, Emitter<PuzzleState> emit){
    this.level = 0;
    final puzzle = _generatePuzzle();
    this.leftmovesteps = _generateMoveTimes();
    emit(
      TutorialState(
          puzzle
      ),
    );
  }

  void _onPressedTile(PressedTile event, Emitter<PuzzleState> emit,){
    if(this.tileMovementStatus == TileMovementStatus.tapped){

      if(event.tile == this.tiletapped && !this.tiletapped!.isKing()){
        /// cur and pre are not king, cur is pre
        this.add(TileUnTapped(event.tile));
        this.tileMovementStatus = TileMovementStatus.nothingTapped;
        this.tiletapped = null;
      }else if( event.tile.isKing() && this.tiletapped!.isKing() ){
        /// cur and pre are king, cur is pre
        this.add(TileUnTapped(event.tile));
        this.tileMovementStatus = TileMovementStatus.nothingTapped;
        this.tiletapped = null;
      }else if(event.tile.tapped == false){
        /// not matter what will tapped on this
        this
          ..add(TileUnTapped(this.tiletapped!))
          ..add(TileTapped(event.tile))
          ..tileMovementStatus = TileMovementStatus.tapped
          ..tiletapped = event.tile;
      }else if(event.tile.tapped == true && !event.tile.isKing() && !this.tiletapped!.isKing()){
        this
          ..add(TileUnTapped(this.tiletapped!))
          ..add(SwapTiles(this.tiletapped!, event.tile))
          ..tileMovementStatus = TileMovementStatus.nothingTapped
          ..tiletapped = null;
      }else if(event.tile.tapped == true && !event.tile.isKing() && this.tiletapped!.isKing()){
        List<Tile> king = [];
        if(this.tiletapped!.value == ChessPieces.KingTopLeft){
          king
            ..add(this.tiletapped!)
            ..add(this.state.puzzle.tiles[this.tiletapped!.currentPosition.y][this.tiletapped!.currentPosition.x+1])
            ..add(this.state.puzzle.tiles[this.tiletapped!.currentPosition.y+1][this.tiletapped!.currentPosition.x])
            ..add(this.state.puzzle.tiles[this.tiletapped!.currentPosition.y+1][this.tiletapped!.currentPosition.x+1]);
        }else if(this.tiletapped!.value == ChessPieces.KingTopRight){
          king
            ..add(this.state.puzzle.tiles[this.tiletapped!.currentPosition.y][this.tiletapped!.currentPosition.x-1])
            ..add(this.tiletapped!)
            ..add(this.state.puzzle.tiles[this.tiletapped!.currentPosition.y+1][this.tiletapped!.currentPosition.x-1])
            ..add(this.state.puzzle.tiles[this.tiletapped!.currentPosition.y+1][this.tiletapped!.currentPosition.x]);
        }else if(this.tiletapped!.value == ChessPieces.KingButtomLeft){
          king
            ..add(this.state.puzzle.tiles[this.tiletapped!.currentPosition.y-1][this.tiletapped!.currentPosition.x])
            ..add(this.state.puzzle.tiles[this.tiletapped!.currentPosition.y-1][this.tiletapped!.currentPosition.x+1])
            ..add(this.tiletapped!)
            ..add(this.state.puzzle.tiles[this.tiletapped!.currentPosition.y][this.tiletapped!.currentPosition.x+1]);
        }else if(this.tiletapped!.value == ChessPieces.KingButtomRight){
          king
            ..add(this.state.puzzle.tiles[this.tiletapped!.currentPosition.y-1][this.tiletapped!.currentPosition.x-1])
            ..add(this.state.puzzle.tiles[this.tiletapped!.currentPosition.y-1][this.tiletapped!.currentPosition.x])
            ..add(this.state.puzzle.tiles[this.tiletapped!.currentPosition.y][this.tiletapped!.currentPosition.x-1])
            ..add(this.tiletapped!);
        }
        this
          ..add(TileUnTapped(this.tiletapped!))
          ..add(SwapKingTiles(king, event.tile))
          ..tileMovementStatus = TileMovementStatus.nothingTapped
          ..tiletapped = null;
      }
    }else {
      this
        ..add(TileTapped(event.tile))
        ..tileMovementStatus = TileMovementStatus.tapped
        ..tiletapped = event.tile;
    }
  }

  void _onTileTapped(TileTapped event, Emitter<PuzzleState> emit,){
    /// this event is the tile we put into TileTapped class
    final tappedTile = event.tile;
    tappedTile.tapped = true;
    print(tappedTile.currentPosition.x);
    print(tappedTile.currentPosition.y);
    print(this.state.puzzle.tiles[tappedTile.currentPosition.y][tappedTile.currentPosition.x]);

    int maxX = this.state.puzzle.tiles[0].length;
    int maxY = this.state.puzzle.tiles.length;

    if(tappedTile.value == ChessPieces.Pawn){
      Position p = tappedTile.currentPosition;
      if(p.x+1 < maxX){
        if(this.state.puzzle.tiles[p.y][p.x+1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][p.x+1].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y][p.x+1].tapped = true;
        }
      }
      if(p.x-1 >= 0){
        if(this.state.puzzle.tiles[p.y][p.x-1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][p.x-1].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y][p.x-1].tapped = true;
        }
      }
      if(p.y+1 < maxY){
        if(this.state.puzzle.tiles[p.y+1][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+1][p.x].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y+1][p.x].tapped = true;
        }
      }
      if(p.y-1 >= 0){
        if(this.state.puzzle.tiles[p.y-1][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-1][p.x].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y-1][p.x].tapped = true;
        }
      }
    }

    if(tappedTile.value == ChessPieces.Knight){
      Position p = tappedTile.currentPosition;
      if(p.y - 2 >= 0 && p.x - 1 >= 0){
        if(this.state.puzzle.tiles[p.y-2][p.x-1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-2][p.x-1].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y-2][p.x-1].tapped = true;
        }
      }
      if(p.y - 1 >= 0 && p.x - 2 >= 0){
        if(this.state.puzzle.tiles[p.y-1][p.x-2].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-1][p.x-2].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y-1][p.x-2].tapped = true;
        }
      }
      if(p.y + 1 < maxY && p.x - 2 >= 0){
        if(this.state.puzzle.tiles[p.y+1][p.x-2].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+1][p.x-2].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y+1][p.x-2].tapped = true;
        }
      }
      if(p.y + 2 < maxY && p.x - 1 >= 0){
        if(this.state.puzzle.tiles[p.y+2][p.x-1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+2][p.x-1].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y+2][p.x-1].tapped = true;
        }
      }
      if(p.y + 2 < maxY && p.x + 1 < maxX){
        if(this.state.puzzle.tiles[p.y+2][p.x+1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+2][p.x+1].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y+2][p.x+1].tapped = true;
        }
      }
      if(p.y + 1 < maxY && p.x + 2 < maxX){
        if(this.state.puzzle.tiles[p.y+1][p.x+2].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+1][p.x+2].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y+1][p.x+2].tapped = true;
        }
      }
      if(p.y - 1 >= 0 && p.x + 2 < maxX){
        if(this.state.puzzle.tiles[p.y-1][p.x+2].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-1][p.x+2].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y-1][p.x+2].tapped = true;
        }
      }
      if(p.y - 2 >= 0 && p.x + 1 < maxX){
        if(this.state.puzzle.tiles[p.y-2][p.x+1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-2][p.x+1].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y-2][p.x+1].tapped = true;
        }
      }
    }

    if(tappedTile.value == ChessPieces.Rook){
      Position p = tappedTile.currentPosition;
      int tempX = p.x;
      int tempY = p.y;

      while(tempX - 1 >= 0){
        if(this.state.puzzle.tiles[p.y][tempX-1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][tempX-1].value == ChessPieces.EnemyKing) {
          this.state.puzzle.tiles[p.y][tempX-1].tapped = true;
        }else{
          break;
        }
        tempX--;
      }

      while(tempY - 1 >= 0){
        if(this.state.puzzle.tiles[tempY-1][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[tempY-1][p.x].value == ChessPieces.EnemyKing) {
          this.state.puzzle.tiles[tempY-1][p.x].tapped = true;
        }else{
          break;
        }
        tempY--;
      }

      tempX = p.x;
      tempY = p.y;

      while(tempX + 1 < maxX){
        if(this.state.puzzle.tiles[p.y][tempX+1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][tempX+1].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y][tempX+1].tapped = true;
        }else{
          break;
        }
        tempX++;
      }

      while(tempY + 1 < maxY){
        if(this.state.puzzle.tiles[tempY+1][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[tempY+1][p.x].value == ChessPieces.EnemyKing) {
          this.state.puzzle.tiles[tempY+1][p.x].tapped = true;
        }else{
          break;
        }
        tempY++;
      }
    }

    if(tappedTile.value == ChessPieces.Bishop){
      Position p = tappedTile.currentPosition;
      int tempX = p.x;
      int tempY = p.y;
      while(tempX - 1 >= 0 && tempY - 1 >= 0){
        if(this.state.puzzle.tiles[tempY-1][tempX-1].value == ChessPieces.Space || this.state.puzzle.tiles[tempY-1][tempX-1].value == ChessPieces.EnemyKing) {
          this.state.puzzle.tiles[tempY-1][tempX-1].tapped = true;
        }else{
          break;
        }
        tempX--;
        tempY--;
      }

      tempX = p.x;
      tempY = p.y;

      while(tempX - 1 >= 0 && tempY + 1 < maxY){
        if(this.state.puzzle.tiles[tempY+1][tempX-1].value == ChessPieces.Space || this.state.puzzle.tiles[tempY+1][tempX-1].value == ChessPieces.EnemyKing) {
          this.state.puzzle.tiles[tempY+1][tempX-1].tapped = true;
        }else{
          break;
        }
        tempX--;
        tempY++;
      }

      tempX = p.x;
      tempY = p.y;

      while(tempX + 1 < maxX && tempY - 1 >= 0){
        if(this.state.puzzle.tiles[tempY-1][tempX+1].value == ChessPieces.Space || this.state.puzzle.tiles[tempY-1][tempX+1].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[tempY-1][tempX+1].tapped = true;
        }else{
          break;
        }
        tempX++;
        tempY--;
      }

      tempX = p.x;
      tempY = p.y;

      while(tempX + 1 < maxX && tempY + 1 < maxY){
        if(this.state.puzzle.tiles[tempY+1][tempX+1].value == ChessPieces.Space || this.state.puzzle.tiles[tempY+1][tempX+1].value == ChessPieces.EnemyKing) {
          this.state.puzzle.tiles[tempY+1][tempX+1].tapped = true;
        }else{
          break;
        }
        tempX++;
        tempY++;
      }
    }

    if(tappedTile.value == ChessPieces.Queen){
      Position p = tappedTile.currentPosition;
      int tempX = p.x;
      int tempY = p.y;
      while(tempX - 1 >= 0 && tempY - 1 >= 0){
        if(this.state.puzzle.tiles[tempY-1][tempX-1].value == ChessPieces.Space || this.state.puzzle.tiles[tempY-1][tempX-1].value == ChessPieces.EnemyKing) {
          this.state.puzzle.tiles[tempY-1][tempX-1].tapped = true;
        }else{
          break;
        }
        tempX--;
        tempY--;
      }

      tempX = p.x;
      tempY = p.y;

      while(tempX - 1 >= 0 && tempY + 1 < maxY){
        if(this.state.puzzle.tiles[tempY+1][tempX-1].value == ChessPieces.Space || this.state.puzzle.tiles[tempY+1][tempX-1].value == ChessPieces.EnemyKing) {
          this.state.puzzle.tiles[tempY+1][tempX-1].tapped = true;
        }else{
          break;
        }
        tempX--;
        tempY++;
      }

      tempX = p.x;
      tempY = p.y;

      while(tempX + 1 < maxX && tempY - 1 >= 0){
        if(this.state.puzzle.tiles[tempY-1][tempX+1].value == ChessPieces.Space || this.state.puzzle.tiles[tempY-1][tempX+1].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[tempY-1][tempX+1].tapped = true;
        }else{
          break;
        }
        tempX++;
        tempY--;
      }

      tempX = p.x;
      tempY = p.y;

      while(tempX + 1 < maxX && tempY + 1 < maxY){
        if(this.state.puzzle.tiles[tempY+1][tempX+1].value == ChessPieces.Space || this.state.puzzle.tiles[tempY+1][tempX+1].value == ChessPieces.EnemyKing) {
          this.state.puzzle.tiles[tempY+1][tempX+1].tapped = true;
        }else{
          break;
        }
        tempX++;
        tempY++;
      }

      tempX = p.x;
      tempY = p.y;

      while(tempX - 1 >= 0){
        if(this.state.puzzle.tiles[p.y][tempX-1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][tempX-1].value == ChessPieces.EnemyKing) {
          this.state.puzzle.tiles[p.y][tempX-1].tapped = true;
        }else{
          break;
        }
        tempX--;
      }

      while(tempY - 1 >= 0){
        if(this.state.puzzle.tiles[tempY-1][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[tempY-1][p.x].value == ChessPieces.EnemyKing) {
          this.state.puzzle.tiles[tempY-1][p.x].tapped = true;
        }else{
          break;
        }
        tempY--;
      }

      tempX = p.x;
      tempY = p.y;

      while(tempX + 1 < maxX){
        if(this.state.puzzle.tiles[p.y][tempX+1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][tempX+1].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y][tempX+1].tapped = true;
        }else{
          break;
        }
        tempX++;
      }

      while(tempY + 1 < maxY){
        if(this.state.puzzle.tiles[tempY+1][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[tempY+1][p.x].value == ChessPieces.EnemyKing) {
          this.state.puzzle.tiles[tempY+1][p.x].tapped = true;
        }else{
          break;
        }
        tempY++;
      }
    }

    if(tappedTile.value == ChessPieces.KingTopLeft){
      Position p = tappedTile.currentPosition;
      this.state.puzzle.tiles[p.y][p.x].tapped = true;
      this.state.puzzle.tiles[p.y][p.x+1].tapped = true;
      this.state.puzzle.tiles[p.y+1][p.x].tapped = true;
      this.state.puzzle.tiles[p.y+1][p.x+1].tapped = true;
      if(p.y-1 >= 0 && p.x+1 < maxX){
        /// top
        if((this.state.puzzle.tiles[p.y-1][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-1][p.x].value == ChessPieces.End) &&
           (this.state.puzzle.tiles[p.y-1][p.x+1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-1][p.x+1].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y-1][p.x].tapped = true;
          this.state.puzzle.tiles[p.y-1][p.x+1].tapped = true;
        }
      }
      if(p.y+2 < maxY && p.x+1 < maxX){
        /// bottom
        if((this.state.puzzle.tiles[p.y+2][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+2][p.x].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y+2][p.x+1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+2][p.x+1].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y+2][p.x].tapped = true;
          this.state.puzzle.tiles[p.y+2][p.x+1].tapped = true;
        }
      }
      if(p.x-1 >= 0 && p.y+1 < maxY){
        /// left
        if((this.state.puzzle.tiles[p.y][p.x-1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][p.x-1].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y+1][p.x-1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+1][p.x-1].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y][p.x-1].tapped = true;
          this.state.puzzle.tiles[p.y+1][p.x-1].tapped = true;
        }
      }
      if(p.x+2 < maxX && p.y+1 < maxY){
        /// right
        if((this.state.puzzle.tiles[p.y][p.x+2].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][p.x+2].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y+1][p.x+2].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+1][p.x+2].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y][p.x+2].tapped = true;
          this.state.puzzle.tiles[p.y+1][p.x+2].tapped = true;
        }
      }
    }
    if(tappedTile.value == ChessPieces.KingTopRight){
      Position p = tappedTile.currentPosition;
      this.state.puzzle.tiles[p.y][p.x].tapped = true;
      this.state.puzzle.tiles[p.y][p.x-1].tapped = true;
      this.state.puzzle.tiles[p.y+1][p.x].tapped = true;
      this.state.puzzle.tiles[p.y+1][p.x-1].tapped = true;
      if(p.y-1 >= 0 && p.x-1 < maxX){
        /// top
        if((this.state.puzzle.tiles[p.y-1][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-1][p.x].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y-1][p.x-1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-1][p.x-1].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y-1][p.x].tapped = true;
          this.state.puzzle.tiles[p.y-1][p.x-1].tapped = true;
        }
      }
      if(p.y+2 < maxY && p.x-1 < maxX){
        /// bottom
        if((this.state.puzzle.tiles[p.y+2][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+2][p.x].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y+2][p.x-1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+2][p.x-1].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y+2][p.x].tapped = true;
          this.state.puzzle.tiles[p.y+2][p.x-1].tapped = true;
        }
      }
      if(p.x-2 >= 0 && p.y+1 < maxY){
        /// left
        if((this.state.puzzle.tiles[p.y][p.x-2].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][p.x-2].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y+1][p.x-2].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+1][p.x-2].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y][p.x-2].tapped = true;
          this.state.puzzle.tiles[p.y+1][p.x-2].tapped = true;
        }
      }
      if(p.x+1 < maxX && p.y+1 < maxY){
        /// right
        if((this.state.puzzle.tiles[p.y][p.x+1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][p.x+1].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y+1][p.x+1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+1][p.x+1].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y][p.x+1].tapped = true;
          this.state.puzzle.tiles[p.y+1][p.x+1].tapped = true;
        }
      }
    }
    if(tappedTile.value == ChessPieces.KingButtomLeft){
      Position p = tappedTile.currentPosition;
      this.state.puzzle.tiles[p.y][p.x].tapped = true;
      this.state.puzzle.tiles[p.y][p.x+1].tapped = true;
      this.state.puzzle.tiles[p.y-1][p.x].tapped = true;
      this.state.puzzle.tiles[p.y-1][p.x+1].tapped = true;
      if(p.y-2 >= 0 && p.x+1 < maxX){
        /// top
        if((this.state.puzzle.tiles[p.y-2][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-2][p.x].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y-2][p.x+1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-2][p.x+1].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y-2][p.x].tapped = true;
          this.state.puzzle.tiles[p.y-2][p.x+1].tapped = true;
        }
      }
      if(p.y+1 < maxY && p.x+1 < maxX){
        /// bottom
        if((this.state.puzzle.tiles[p.y+1][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+1][p.x].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y+1][p.x+1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+1][p.x+1].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y+1][p.x].tapped = true;
          this.state.puzzle.tiles[p.y+1][p.x+1].tapped = true;
        }
      }
      if(p.x-1 >= 0 && p.y-1 < maxY){
        /// left
        if((this.state.puzzle.tiles[p.y][p.x-1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][p.x-1].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y-1][p.x-1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-1][p.x-1].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y][p.x-1].tapped = true;
          this.state.puzzle.tiles[p.y-1][p.x-1].tapped = true;
        }
      }
      if(p.x+2 < maxX && p.y-1 < maxY){
        /// right
        if((this.state.puzzle.tiles[p.y][p.x+2].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][p.x+2].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y-1][p.x+2].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-1][p.x+2].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y][p.x+2].tapped = true;
          this.state.puzzle.tiles[p.y-1][p.x+2].tapped = true;
        }
      }
    }
    if(tappedTile.value == ChessPieces.KingButtomRight){
      Position p = tappedTile.currentPosition;
      this.state.puzzle.tiles[p.y][p.x].tapped = true;
      this.state.puzzle.tiles[p.y][p.x-1].tapped = true;
      this.state.puzzle.tiles[p.y-1][p.x].tapped = true;
      this.state.puzzle.tiles[p.y-1][p.x-1].tapped = true;
      if(p.y-2 >= 0 && p.x-1 < maxX){
        /// top
        if((this.state.puzzle.tiles[p.y-2][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-2][p.x].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y-2][p.x-1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-2][p.x-1].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y-2][p.x].tapped = true;
          this.state.puzzle.tiles[p.y-2][p.x-1].tapped = true;
        }
      }
      if(p.y+1 < maxY && p.x-1 < maxX){
        /// bottom
        if((this.state.puzzle.tiles[p.y+1][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+1][p.x].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y+1][p.x-1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+1][p.x-1].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y+1][p.x].tapped = true;
          this.state.puzzle.tiles[p.y+1][p.x-1].tapped = true;
        }
      }
      if(p.x-2 >= 0 && p.y-1 < maxY){
        /// left
        if((this.state.puzzle.tiles[p.y][p.x-2].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][p.x-2].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y-1][p.x-2].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-1][p.x-2].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y][p.x-2].tapped = true;
          this.state.puzzle.tiles[p.y-1][p.x-2].tapped = true;
        }
      }
      if(p.x+1 < maxX && p.y-1 < maxY){
        /// right
        if((this.state.puzzle.tiles[p.y][p.x+1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][p.x+1].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y-1][p.x+1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-1][p.x+1].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y][p.x+1].tapped = true;
          this.state.puzzle.tiles[p.y-1][p.x+1].tapped = true;
        }
      }
    }

  }

  void _onTileUnTapped(TileUnTapped event, Emitter<PuzzleState> emit,){
    final tappedTile = event.tile;
    tappedTile.tapped = false;

    int maxX = this.state.puzzle.tiles[0].length;
    int maxY = this.state.puzzle.tiles.length;

    if(tappedTile.value == ChessPieces.Pawn){
      Position p = tappedTile.currentPosition;
      /// may out of size, NEED to be fix

      if(p.x+1 < maxX){
        if(this.state.puzzle.tiles[p.y][p.x+1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][p.x+1].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y][p.x+1].tapped = false;
        }
      }
      if(p.x-1 >= 0){
        if(this.state.puzzle.tiles[p.y][p.x-1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][p.x-1].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y][p.x-1].tapped = false;
        }
      }
      if(p.y+1 < maxY){
        if(this.state.puzzle.tiles[p.y+1][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+1][p.x].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y+1][p.x].tapped = false;
        }
      }
      if(p.y-1 >= 0){
        if(this.state.puzzle.tiles[p.y-1][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-1][p.x].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y-1][p.x].tapped = false;
        }
      }
    }

    if(tappedTile.value == ChessPieces.Knight){
      Position p = tappedTile.currentPosition;
      if(p.y - 2 >= 0 && p.x - 1 >= 0){
        if(this.state.puzzle.tiles[p.y-2][p.x-1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-2][p.x-1].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y-2][p.x-1].tapped = false;
        }
      }
      if(p.y - 1 >= 0 && p.x - 2 >= 0){
        if(this.state.puzzle.tiles[p.y-1][p.x-2].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-1][p.x-2].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y-1][p.x-2].tapped = false;
        }
      }
      if(p.y + 1 < maxY && p.x - 2 >= 0){
        if(this.state.puzzle.tiles[p.y+1][p.x-2].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+1][p.x-2].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y+1][p.x-2].tapped = false;
        }
      }
      if(p.y + 2 < maxY && p.x - 1 >= 0){
        if(this.state.puzzle.tiles[p.y+2][p.x-1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+2][p.x-1].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y+2][p.x-1].tapped = false;
        }
      }
      if(p.y + 2 < maxY && p.x + 1 < maxX){
        if(this.state.puzzle.tiles[p.y+2][p.x+1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+2][p.x+1].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y+2][p.x+1].tapped = false;
        }
      }
      if(p.y + 1 < maxY && p.x + 2 < maxX){
        if(this.state.puzzle.tiles[p.y+1][p.x+2].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+1][p.x+2].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y+1][p.x+2].tapped = false;
        }
      }
      if(p.y - 1 >= 0 && p.x + 2 < maxX){
        if(this.state.puzzle.tiles[p.y-1][p.x+2].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-1][p.x+2].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y-1][p.x+2].tapped = false;
        }
      }
      if(p.y - 2 >= 0 && p.x + 1 < maxX){
        if(this.state.puzzle.tiles[p.y-2][p.x+1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-2][p.x+1].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y-2][p.x+1].tapped = false;
        }
      }
    }

    if(tappedTile.value == ChessPieces.Rook){
      Position p = tappedTile.currentPosition;
      int tempX = p.x;
      int tempY = p.y;

      while(tempX - 1 >= 0){
        if(this.state.puzzle.tiles[p.y][tempX-1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][tempX-1].value == ChessPieces.EnemyKing) {
          this.state.puzzle.tiles[p.y][tempX-1].tapped = false;
        }else{
          break;
        }
        tempX--;
      }

      while(tempY - 1 >= 0){
        if(this.state.puzzle.tiles[tempY-1][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[tempY-1][p.x].value == ChessPieces.EnemyKing) {
          this.state.puzzle.tiles[tempY-1][p.x].tapped = false;
        }else{
          break;
        }
        tempY--;
      }

      tempX = p.x;
      tempY = p.y;

      while(tempX + 1 < maxX){
        if(this.state.puzzle.tiles[p.y][tempX+1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][tempX+1].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y][tempX+1].tapped = false;
        }else{
          break;
        }
        tempX++;
      }

      while(tempY + 1 < maxY){
        if(this.state.puzzle.tiles[tempY+1][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[tempY+1][p.x].value == ChessPieces.EnemyKing) {
          this.state.puzzle.tiles[tempY+1][p.x].tapped = false;
        }else{
          break;
        }
        tempY++;
      }
    }

    if(tappedTile.value == ChessPieces.Bishop){
      Position p = tappedTile.currentPosition;
      int tempX = p.x;
      int tempY = p.y;
      while(tempX - 1 >= 0 && tempY - 1 >= 0){
        if(this.state.puzzle.tiles[tempY-1][tempX-1].value == ChessPieces.Space || this.state.puzzle.tiles[tempY-1][tempX-1].value == ChessPieces.EnemyKing) {
          this.state.puzzle.tiles[tempY-1][tempX-1].tapped = false;
        }else{
          break;
        }
        tempX--;
        tempY--;
      }

      tempX = p.x;
      tempY = p.y;

      while(tempX - 1 >= 0 && tempY + 1 < maxY){
        if(this.state.puzzle.tiles[tempY+1][tempX-1].value == ChessPieces.Space || this.state.puzzle.tiles[tempY+1][tempX-1].value == ChessPieces.EnemyKing) {
          this.state.puzzle.tiles[tempY+1][tempX-1].tapped = false;
        }else{
          break;
        }
        tempX--;
        tempY++;
      }

      tempX = p.x;
      tempY = p.y;

      while(tempX + 1 < maxX && tempY - 1 >= 0){
        if(this.state.puzzle.tiles[tempY-1][tempX+1].value == ChessPieces.Space || this.state.puzzle.tiles[tempY-1][tempX+1].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[tempY-1][tempX+1].tapped = false;
        }else{
          break;
        }
        tempX++;
        tempY--;
      }

      tempX = p.x;
      tempY = p.y;

      while(tempX + 1 < maxX && tempY + 1 < maxY){
        if(this.state.puzzle.tiles[tempY+1][tempX+1].value == ChessPieces.Space || this.state.puzzle.tiles[tempY+1][tempX+1].value == ChessPieces.EnemyKing) {
          this.state.puzzle.tiles[tempY+1][tempX+1].tapped = false;
        }else{
          break;
        }
        tempX++;
        tempY++;
      }
    }

    if(tappedTile.value == ChessPieces.Queen){
      Position p = tappedTile.currentPosition;
      int tempX = p.x;
      int tempY = p.y;
      while(tempX - 1 >= 0 && tempY - 1 >= 0){
        if(this.state.puzzle.tiles[tempY-1][tempX-1].value == ChessPieces.Space || this.state.puzzle.tiles[tempY-1][tempX-1].value == ChessPieces.EnemyKing) {
          this.state.puzzle.tiles[tempY-1][tempX-1].tapped = false;
        }else{
          break;
        }
        tempX--;
        tempY--;
      }

      tempX = p.x;
      tempY = p.y;

      while(tempX - 1 >= 0 && tempY + 1 < maxY){
        if(this.state.puzzle.tiles[tempY+1][tempX-1].value == ChessPieces.Space || this.state.puzzle.tiles[tempY+1][tempX-1].value == ChessPieces.EnemyKing) {
          this.state.puzzle.tiles[tempY+1][tempX-1].tapped = false;
        }else{
          break;
        }
        tempX--;
        tempY++;
      }

      tempX = p.x;
      tempY = p.y;

      while(tempX + 1 < maxX && tempY - 1 >= 0){
        if(this.state.puzzle.tiles[tempY-1][tempX+1].value == ChessPieces.Space || this.state.puzzle.tiles[tempY-1][tempX+1].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[tempY-1][tempX+1].tapped = false;
        }else{
          break;
        }
        tempX++;
        tempY--;
      }

      tempX = p.x;
      tempY = p.y;

      while(tempX + 1 < maxX && tempY + 1 < maxY){
        if(this.state.puzzle.tiles[tempY+1][tempX+1].value == ChessPieces.Space || this.state.puzzle.tiles[tempY+1][tempX+1].value == ChessPieces.EnemyKing) {
          this.state.puzzle.tiles[tempY+1][tempX+1].tapped = false;
        }else{
          break;
        }
        tempX++;
        tempY++;
      }

      tempX = p.x;
      tempY = p.y;

      while(tempX - 1 >= 0){
        if(this.state.puzzle.tiles[p.y][tempX-1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][tempX-1].value == ChessPieces.EnemyKing) {
          this.state.puzzle.tiles[p.y][tempX-1].tapped = false;
        }else{
          break;
        }
        tempX--;
      }

      while(tempY - 1 >= 0){
        if(this.state.puzzle.tiles[tempY-1][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[tempY-1][p.x].value == ChessPieces.EnemyKing) {
          this.state.puzzle.tiles[tempY-1][p.x].tapped = false;
        }else{
          break;
        }
        tempY--;
      }

      tempX = p.x;
      tempY = p.y;

      while(tempX + 1 < maxX){
        if(this.state.puzzle.tiles[p.y][tempX+1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][tempX+1].value == ChessPieces.EnemyKing){
          this.state.puzzle.tiles[p.y][tempX+1].tapped = false;
        }else{
          break;
        }
        tempX++;
      }

      while(tempY + 1 < maxY){
        if(this.state.puzzle.tiles[tempY+1][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[tempY+1][p.x].value == ChessPieces.EnemyKing) {
          this.state.puzzle.tiles[tempY+1][p.x].tapped = false;
        }else{
          break;
        }
        tempY++;
      }
    }

    if(tappedTile.value == ChessPieces.KingTopLeft){
      Position p = tappedTile.currentPosition;
      this.state.puzzle.tiles[p.y][p.x].tapped = false;
      this.state.puzzle.tiles[p.y][p.x+1].tapped = false;
      this.state.puzzle.tiles[p.y+1][p.x].tapped = false;
      this.state.puzzle.tiles[p.y+1][p.x+1].tapped = false;
      if(p.y-1 >= 0 && p.x+1 < maxX){
        /// top
        if((this.state.puzzle.tiles[p.y-1][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-1][p.x].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y-1][p.x+1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-1][p.x+1].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y-1][p.x].tapped = false;
          this.state.puzzle.tiles[p.y-1][p.x+1].tapped = false;
        }
      }
      if(p.y+2 < maxY && p.x+1 < maxX){
        /// bottom
        if((this.state.puzzle.tiles[p.y+2][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+2][p.x].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y+2][p.x+1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+2][p.x+1].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y+2][p.x].tapped = false;
          this.state.puzzle.tiles[p.y+2][p.x+1].tapped = false;
        }
      }
      if(p.x-1 >= 0 && p.y+1 < maxY){
        /// left
        if((this.state.puzzle.tiles[p.y][p.x-1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][p.x-1].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y+1][p.x-1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+1][p.x-1].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y][p.x-1].tapped = false;
          this.state.puzzle.tiles[p.y+1][p.x-1].tapped = false;
        }
      }
      if(p.x+2 < maxX && p.y+1 < maxY){
        /// right
        if((this.state.puzzle.tiles[p.y][p.x+2].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][p.x+2].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y+1][p.x+2].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+1][p.x+2].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y][p.x+2].tapped = false;
          this.state.puzzle.tiles[p.y+1][p.x+2].tapped = false;
        }
      }
    }
    if(tappedTile.value == ChessPieces.KingTopRight){
      Position p = tappedTile.currentPosition;
      this.state.puzzle.tiles[p.y][p.x].tapped = false;
      this.state.puzzle.tiles[p.y][p.x-1].tapped = false;
      this.state.puzzle.tiles[p.y+1][p.x].tapped = false;
      this.state.puzzle.tiles[p.y+1][p.x-1].tapped = false;
      if(p.y-1 >= 0 && p.x-1 < maxX){
        /// top
        if((this.state.puzzle.tiles[p.y-1][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-1][p.x].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y-1][p.x-1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-1][p.x-1].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y-1][p.x].tapped = false;
          this.state.puzzle.tiles[p.y-1][p.x-1].tapped = false;
        }
      }
      if(p.y+2 < maxY && p.x-1 < maxX){
        /// bottom
        if((this.state.puzzle.tiles[p.y+2][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+2][p.x].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y+2][p.x-1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+2][p.x-1].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y+2][p.x].tapped = false;
          this.state.puzzle.tiles[p.y+2][p.x-1].tapped = false;
        }
      }
      if(p.x-2 >= 0 && p.y+1 < maxY){
        /// left
        if((this.state.puzzle.tiles[p.y][p.x-2].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][p.x-2].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y+1][p.x-2].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+1][p.x-2].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y][p.x-2].tapped = false;
          this.state.puzzle.tiles[p.y+1][p.x-2].tapped = false;
        }
      }
      if(p.x+1 < maxX && p.y+1 < maxY){
        /// right
        if((this.state.puzzle.tiles[p.y][p.x+1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][p.x+1].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y+1][p.x+1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+1][p.x+1].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y][p.x+1].tapped = false;
          this.state.puzzle.tiles[p.y+1][p.x+1].tapped = false;
        }
      }
    }
    if(tappedTile.value == ChessPieces.KingButtomLeft){
      Position p = tappedTile.currentPosition;
      this.state.puzzle.tiles[p.y][p.x].tapped = false;
      this.state.puzzle.tiles[p.y][p.x+1].tapped = false;
      this.state.puzzle.tiles[p.y-1][p.x].tapped = false;
      this.state.puzzle.tiles[p.y-1][p.x+1].tapped = false;
      if(p.y-2 >= 0 && p.x+1 < maxX){
        /// top
        if((this.state.puzzle.tiles[p.y-2][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-2][p.x].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y-2][p.x+1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-2][p.x+1].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y-2][p.x].tapped = false;
          this.state.puzzle.tiles[p.y-2][p.x+1].tapped = false;
        }
      }
      if(p.y+1 < maxY && p.x+1 < maxX){
        /// bottom
        if((this.state.puzzle.tiles[p.y+1][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+1][p.x].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y+1][p.x+1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+1][p.x+1].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y+1][p.x].tapped = false;
          this.state.puzzle.tiles[p.y+1][p.x+1].tapped = false;
        }
      }
      if(p.x-1 >= 0 && p.y-1 < maxY){
        /// left
        if((this.state.puzzle.tiles[p.y][p.x-1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][p.x-1].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y-1][p.x-1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-1][p.x-1].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y][p.x-1].tapped = false;
          this.state.puzzle.tiles[p.y-1][p.x-1].tapped = false;
        }
      }
      if(p.x+2 < maxX && p.y-1 < maxY){
        /// right
        if((this.state.puzzle.tiles[p.y][p.x+2].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][p.x+2].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y-1][p.x+2].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-1][p.x+2].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y][p.x+2].tapped = false;
          this.state.puzzle.tiles[p.y-1][p.x+2].tapped = false;
        }
      }
    }
    if(tappedTile.value == ChessPieces.KingButtomRight){
      Position p = tappedTile.currentPosition;
      this.state.puzzle.tiles[p.y][p.x].tapped = false;
      this.state.puzzle.tiles[p.y][p.x-1].tapped = false;
      this.state.puzzle.tiles[p.y-1][p.x].tapped = false;
      this.state.puzzle.tiles[p.y-1][p.x-1].tapped = false;
      if(p.y-2 >= 0 && p.x-1 < maxX){
        /// top
        if((this.state.puzzle.tiles[p.y-2][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-2][p.x].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y-2][p.x-1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-2][p.x-1].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y-2][p.x].tapped = false;
          this.state.puzzle.tiles[p.y-2][p.x-1].tapped = false;
        }
      }
      if(p.y+1 < maxY && p.x-1 < maxX){
        /// bottom
        if((this.state.puzzle.tiles[p.y+1][p.x].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+1][p.x].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y+1][p.x-1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y+1][p.x-1].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y+1][p.x].tapped = false;
          this.state.puzzle.tiles[p.y+1][p.x-1].tapped = false;
        }
      }
      if(p.x-2 >= 0 && p.y-1 < maxY){
        /// left
        if((this.state.puzzle.tiles[p.y][p.x-2].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][p.x-2].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y-1][p.x-2].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-1][p.x-2].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y][p.x-2].tapped = false;
          this.state.puzzle.tiles[p.y-1][p.x-2].tapped = false;
        }
      }
      if(p.x+1 < maxX && p.y-1 < maxY){
        /// right
        if((this.state.puzzle.tiles[p.y][p.x+1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y][p.x+1].value == ChessPieces.End) &&
            (this.state.puzzle.tiles[p.y-1][p.x+1].value == ChessPieces.Space || this.state.puzzle.tiles[p.y-1][p.x+1].value == ChessPieces.End)){
          this.state.puzzle.tiles[p.y][p.x+1].tapped = false;
          this.state.puzzle.tiles[p.y-1][p.x+1].tapped = false;
        }
      }
    }

  }

  void _onSwapTiles(SwapTiles event,Emitter<PuzzleState> emit){
    final previoustiled = event.tappedtile;
    final tappedtile = event.nexttile;

    if(tappedtile.value == ChessPieces.EnemyKing){
      this.state.puzzle.tiles[previoustiled.currentPosition.y][previoustiled.currentPosition.x] = tappedtile.trunToSpace().copyWith(currentPosition: previoustiled.currentPosition);
    }else{
      this.state.puzzle.tiles[previoustiled.currentPosition.y][previoustiled.currentPosition.x] = tappedtile.copyWith(currentPosition: previoustiled.currentPosition);
    }

    this.state.puzzle.tiles[tappedtile.currentPosition.y][tappedtile.currentPosition.x] = previoustiled.copyWith(currentPosition: tappedtile.currentPosition);
    this.state.puzzle.tiles[previoustiled.currentPosition.y][previoustiled.currentPosition.x].tapped = false;
    this.state.puzzle.tiles[tappedtile.currentPosition.y][tappedtile.currentPosition.x].tapped = false;

    this.leftmovesteps--;
    if(this.leftmovesteps <= 0){
      this.add(PuzzleLose());
    }
  }

  NextDirection getNextDirection(Tile kingtopleft,Tile kingbottomright,Tile nextspace){
    Position kingtl = kingtopleft.currentPosition;
    Position kingbr = kingbottomright.currentPosition;
    Position space = nextspace.currentPosition;
    if(space.x > kingbr.x){
      return NextDirection.Right;
    }
    if(space.x < kingtl.x){
      return NextDirection.Left;
    }
    if(space.y > kingbr.y){
      return NextDirection.Bottom;
    }
    if(space.y < kingtl.y){
      return NextDirection.Top;
    }

    return NextDirection.Top;
  }

  void _onSwapKinigTiles(SwapKingTiles event , Emitter<PuzzleState> emit){
    /// implement swap king event handler
    final kingtopleft = event.kingtile[0];
    final kingtopright = event.kingtile[1];
    final kingbuttomleft = event.kingtile[2];
    final kingbuttomright = event.kingtile[3];
    final nextspace = event.nexttile;

    if(nextspace.value == ChessPieces.End){
      int star = _calculateStar();
      print("get star : " + star.toString());
      print("complete level : " + level.toString());
      emit(
        PuzzleWinState(level,star)
      );
    }else{
      /// first get the direction of next move
      NextDirection nextDirection = getNextDirection(kingtopleft, kingbuttomright, nextspace);
      print(nextDirection);
      /// next we use this direction to determine which algorithms king will use
      if(nextDirection == NextDirection.Top){
        this.state.puzzle.tiles
        ..[kingtopleft.currentPosition.y-1][kingtopleft.currentPosition.x] = kingtopleft.copyWith(currentPosition: Position(x: kingtopleft.currentPosition.x,y: kingtopleft.currentPosition.y-1))
        ..[kingtopleft.currentPosition.y-1][kingtopleft.currentPosition.x+1] = kingtopright.copyWith(currentPosition: Position(x: kingtopleft.currentPosition.x+1,y: kingtopleft.currentPosition.y-1))
        ..[kingtopleft.currentPosition.y][kingtopleft.currentPosition.x] = kingbuttomleft.copyWith(currentPosition: kingtopleft.currentPosition)
        ..[kingtopright.currentPosition.y][kingtopright.currentPosition.x] = kingbuttomright.copyWith(currentPosition: kingtopright.currentPosition)
        ..[kingbuttomleft.currentPosition.y][kingbuttomleft.currentPosition.x] = nextspace.copyWith(currentPosition: kingbuttomleft.currentPosition)
        ..[kingbuttomright.currentPosition.y][kingbuttomright.currentPosition.x] = nextspace.copyWith(currentPosition: kingbuttomright.currentPosition);
      }else if(nextDirection == NextDirection.Bottom){
        this.state.puzzle.tiles
          ..[kingtopleft.currentPosition.y+2][kingtopleft.currentPosition.x] = kingbuttomleft.copyWith(currentPosition: Position(x: kingtopleft.currentPosition.x,y: kingtopleft.currentPosition.y+2))
          ..[kingtopleft.currentPosition.y+2][kingtopleft.currentPosition.x+1] = kingbuttomright.copyWith(currentPosition: Position(x: kingtopleft.currentPosition.x+1,y: kingtopleft.currentPosition.y+2))
          ..[kingtopleft.currentPosition.y][kingtopleft.currentPosition.x] = nextspace.copyWith(currentPosition: kingtopleft.currentPosition)
          ..[kingtopright.currentPosition.y][kingtopright.currentPosition.x] = nextspace.copyWith(currentPosition: kingtopright.currentPosition)
          ..[kingbuttomleft.currentPosition.y][kingbuttomleft.currentPosition.x] = kingtopleft.copyWith(currentPosition: kingbuttomleft.currentPosition)
          ..[kingbuttomright.currentPosition.y][kingbuttomright.currentPosition.x] = kingtopright.copyWith(currentPosition: kingbuttomright.currentPosition);
      }else if(nextDirection == NextDirection.Left){
        this.state.puzzle.tiles
          ..[kingtopleft.currentPosition.y][kingtopleft.currentPosition.x-1] = kingtopleft.copyWith(currentPosition: Position(x: kingtopleft.currentPosition.x-1,y: kingtopleft.currentPosition.y))
          ..[kingtopleft.currentPosition.y+1][kingtopleft.currentPosition.x-1] = kingbuttomleft.copyWith(currentPosition: Position(x: kingtopleft.currentPosition.x-1,y: kingtopleft.currentPosition.y+1))
          ..[kingtopleft.currentPosition.y][kingtopleft.currentPosition.x] = kingtopright.copyWith(currentPosition: kingtopleft.currentPosition)
          ..[kingtopright.currentPosition.y][kingtopright.currentPosition.x] = nextspace.copyWith(currentPosition: kingtopright.currentPosition)
          ..[kingbuttomleft.currentPosition.y][kingbuttomleft.currentPosition.x] = kingbuttomright.copyWith(currentPosition: kingbuttomleft.currentPosition)
          ..[kingbuttomright.currentPosition.y][kingbuttomright.currentPosition.x] = nextspace.copyWith(currentPosition: kingbuttomright.currentPosition);
      }else if(nextDirection == NextDirection.Right){
        this.state.puzzle.tiles
          ..[kingtopleft.currentPosition.y][kingtopleft.currentPosition.x+2] = kingtopright.copyWith(currentPosition: Position(x: kingtopleft.currentPosition.x+2,y: kingtopleft.currentPosition.y))
          ..[kingtopleft.currentPosition.y+1][kingtopleft.currentPosition.x+2] = kingbuttomright.copyWith(currentPosition: Position(x: kingtopleft.currentPosition.x+2,y: kingtopleft.currentPosition.y+1))
          ..[kingtopleft.currentPosition.y][kingtopleft.currentPosition.x] = Tile(value:ChessPieces.Space,currentPosition: kingtopleft.currentPosition)
          ..[kingtopright.currentPosition.y][kingtopright.currentPosition.x] = kingtopleft.copyWith(currentPosition: kingtopright.currentPosition)
          ..[kingbuttomleft.currentPosition.y][kingbuttomleft.currentPosition.x] = Tile(value:ChessPieces.Space,currentPosition: kingbuttomleft.currentPosition)
          ..[kingbuttomright.currentPosition.y][kingbuttomright.currentPosition.x] = kingbuttomleft.copyWith(currentPosition: kingbuttomright.currentPosition);
      }
    }
    this.leftmovesteps--;
    if(this.leftmovesteps <= 0){
      this.add(PuzzleLose());
    }
  }

  void _onPuzzleLose(PuzzleLose event,Emitter<PuzzleState> emit){
    emit(
      PuzzleLoseState(),
    );
  }
}
