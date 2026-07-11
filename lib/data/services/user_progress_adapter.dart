import 'package:hive/hive.dart';

import 'package:queens/domain/models/user_progress.dart';

class UserProgressAdapter extends TypeAdapter<UserProgress> {
  @override
  final int typeId = 0;

  @override
  UserProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    // Fields 3-8 are added in a later schema version. Older records simply
    // omit them, so each read tolerates a missing key with a default.
    return UserProgress(
      currentLevel: fields[0] as int? ?? 1,
      highestLevelCompleted: fields[1] as int? ?? 0,
      totalMoves: fields[2] as int? ?? 0,
      bestMoves: _readIntMap(fields[3]),
      bestTimeSeconds: _readIntMap(fields[4]),
      savedLevelNumber: fields[5] as int?,
      savedBoard: _readBoard(fields[6]),
      savedMoveCount: fields[7] as int? ?? 0,
      savedElapsedSeconds: fields[8] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, UserProgress obj) {
    writer.writeByte(9);
    writer.writeByte(0);
    writer.write(obj.currentLevel);
    writer.writeByte(1);
    writer.write(obj.highestLevelCompleted);
    writer.writeByte(2);
    writer.write(obj.totalMoves);
    writer.writeByte(3);
    writer.write(obj.bestMoves);
    writer.writeByte(4);
    writer.write(obj.bestTimeSeconds);
    writer.writeByte(5);
    writer.write(obj.savedLevelNumber);
    writer.writeByte(6);
    writer.write(obj.savedBoard);
    writer.writeByte(7);
    writer.write(obj.savedMoveCount);
    writer.writeByte(8);
    writer.write(obj.savedElapsedSeconds);
  }

  Map<int, int> _readIntMap(dynamic raw) {
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key as int, value as int));
    }
    return const {};
  }

  List<List<int>>? _readBoard(dynamic raw) {
    if (raw is List) {
      return raw
          .map<List<int>>(
            (row) => (row as List).map<int>((cell) => cell as int).toList(),
          )
          .toList();
    }
    return null;
  }
}
