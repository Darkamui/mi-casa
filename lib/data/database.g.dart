// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $RoomsTable extends Rooms with TableInfo<$RoomsTable, Room> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roomTypeIdMeta = const VerificationMeta(
    'roomTypeId',
  );
  @override
  late final GeneratedColumn<String> roomTypeId = GeneratedColumn<String>(
    'room_type_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    roomTypeId,
    name,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rooms';
  @override
  VerificationContext validateIntegrity(
    Insertable<Room> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('room_type_id')) {
      context.handle(
        _roomTypeIdMeta,
        roomTypeId.isAcceptableOrUnknown(
          data['room_type_id']!,
          _roomTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_roomTypeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Room map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Room(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      roomTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_type_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RoomsTable createAlias(String alias) {
    return $RoomsTable(attachedDatabase, alias);
  }
}

class Room extends DataClass implements Insertable<Room> {
  final String id;
  final String roomTypeId;
  final String? name;
  final int sortOrder;
  final DateTime createdAt;
  const Room({
    required this.id,
    required this.roomTypeId,
    this.name,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['room_type_id'] = Variable<String>(roomTypeId);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RoomsCompanion toCompanion(bool nullToAbsent) {
    return RoomsCompanion(
      id: Value(id),
      roomTypeId: Value(roomTypeId),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory Room.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Room(
      id: serializer.fromJson<String>(json['id']),
      roomTypeId: serializer.fromJson<String>(json['roomTypeId']),
      name: serializer.fromJson<String?>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'roomTypeId': serializer.toJson<String>(roomTypeId),
      'name': serializer.toJson<String?>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Room copyWith({
    String? id,
    String? roomTypeId,
    Value<String?> name = const Value.absent(),
    int? sortOrder,
    DateTime? createdAt,
  }) => Room(
    id: id ?? this.id,
    roomTypeId: roomTypeId ?? this.roomTypeId,
    name: name.present ? name.value : this.name,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  Room copyWithCompanion(RoomsCompanion data) {
    return Room(
      id: data.id.present ? data.id.value : this.id,
      roomTypeId: data.roomTypeId.present
          ? data.roomTypeId.value
          : this.roomTypeId,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Room(')
          ..write('id: $id, ')
          ..write('roomTypeId: $roomTypeId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, roomTypeId, name, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Room &&
          other.id == this.id &&
          other.roomTypeId == this.roomTypeId &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class RoomsCompanion extends UpdateCompanion<Room> {
  final Value<String> id;
  final Value<String> roomTypeId;
  final Value<String?> name;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RoomsCompanion({
    this.id = const Value.absent(),
    this.roomTypeId = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoomsCompanion.insert({
    required String id,
    required String roomTypeId,
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       roomTypeId = Value(roomTypeId),
       createdAt = Value(createdAt);
  static Insertable<Room> custom({
    Expression<String>? id,
    Expression<String>? roomTypeId,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roomTypeId != null) 'room_type_id': roomTypeId,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoomsCompanion copyWith({
    Value<String>? id,
    Value<String>? roomTypeId,
    Value<String?>? name,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return RoomsCompanion(
      id: id ?? this.id,
      roomTypeId: roomTypeId ?? this.roomTypeId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (roomTypeId.present) {
      map['room_type_id'] = Variable<String>(roomTypeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomsCompanion(')
          ..write('id: $id, ')
          ..write('roomTypeId: $roomTypeId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChoresTable extends Chores with TableInfo<$ChoresTable, Chore> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChoresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
    'room_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rooms (id)',
    ),
  );
  static const VerificationMeta _taskDefinitionIdMeta = const VerificationMeta(
    'taskDefinitionId',
  );
  @override
  late final GeneratedColumn<String> taskDefinitionId = GeneratedColumn<String>(
    'task_definition_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isRemovedMeta = const VerificationMeta(
    'isRemoved',
  );
  @override
  late final GeneratedColumn<bool> isRemoved = GeneratedColumn<bool>(
    'is_removed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_removed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    roomId,
    taskDefinitionId,
    isRemoved,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chores';
  @override
  VerificationContext validateIntegrity(
    Insertable<Chore> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('task_definition_id')) {
      context.handle(
        _taskDefinitionIdMeta,
        taskDefinitionId.isAcceptableOrUnknown(
          data['task_definition_id']!,
          _taskDefinitionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_taskDefinitionIdMeta);
    }
    if (data.containsKey('is_removed')) {
      context.handle(
        _isRemovedMeta,
        isRemoved.isAcceptableOrUnknown(data['is_removed']!, _isRemovedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Chore map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Chore(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      roomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_id'],
      )!,
      taskDefinitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_definition_id'],
      )!,
      isRemoved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_removed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ChoresTable createAlias(String alias) {
    return $ChoresTable(attachedDatabase, alias);
  }
}

class Chore extends DataClass implements Insertable<Chore> {
  final String id;
  final String roomId;
  final String taskDefinitionId;
  final bool isRemoved;
  final DateTime createdAt;
  const Chore({
    required this.id,
    required this.roomId,
    required this.taskDefinitionId,
    required this.isRemoved,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['room_id'] = Variable<String>(roomId);
    map['task_definition_id'] = Variable<String>(taskDefinitionId);
    map['is_removed'] = Variable<bool>(isRemoved);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ChoresCompanion toCompanion(bool nullToAbsent) {
    return ChoresCompanion(
      id: Value(id),
      roomId: Value(roomId),
      taskDefinitionId: Value(taskDefinitionId),
      isRemoved: Value(isRemoved),
      createdAt: Value(createdAt),
    );
  }

  factory Chore.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Chore(
      id: serializer.fromJson<String>(json['id']),
      roomId: serializer.fromJson<String>(json['roomId']),
      taskDefinitionId: serializer.fromJson<String>(json['taskDefinitionId']),
      isRemoved: serializer.fromJson<bool>(json['isRemoved']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'roomId': serializer.toJson<String>(roomId),
      'taskDefinitionId': serializer.toJson<String>(taskDefinitionId),
      'isRemoved': serializer.toJson<bool>(isRemoved),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Chore copyWith({
    String? id,
    String? roomId,
    String? taskDefinitionId,
    bool? isRemoved,
    DateTime? createdAt,
  }) => Chore(
    id: id ?? this.id,
    roomId: roomId ?? this.roomId,
    taskDefinitionId: taskDefinitionId ?? this.taskDefinitionId,
    isRemoved: isRemoved ?? this.isRemoved,
    createdAt: createdAt ?? this.createdAt,
  );
  Chore copyWithCompanion(ChoresCompanion data) {
    return Chore(
      id: data.id.present ? data.id.value : this.id,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      taskDefinitionId: data.taskDefinitionId.present
          ? data.taskDefinitionId.value
          : this.taskDefinitionId,
      isRemoved: data.isRemoved.present ? data.isRemoved.value : this.isRemoved,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Chore(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('taskDefinitionId: $taskDefinitionId, ')
          ..write('isRemoved: $isRemoved, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, roomId, taskDefinitionId, isRemoved, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Chore &&
          other.id == this.id &&
          other.roomId == this.roomId &&
          other.taskDefinitionId == this.taskDefinitionId &&
          other.isRemoved == this.isRemoved &&
          other.createdAt == this.createdAt);
}

class ChoresCompanion extends UpdateCompanion<Chore> {
  final Value<String> id;
  final Value<String> roomId;
  final Value<String> taskDefinitionId;
  final Value<bool> isRemoved;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ChoresCompanion({
    this.id = const Value.absent(),
    this.roomId = const Value.absent(),
    this.taskDefinitionId = const Value.absent(),
    this.isRemoved = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChoresCompanion.insert({
    required String id,
    required String roomId,
    required String taskDefinitionId,
    this.isRemoved = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       roomId = Value(roomId),
       taskDefinitionId = Value(taskDefinitionId),
       createdAt = Value(createdAt);
  static Insertable<Chore> custom({
    Expression<String>? id,
    Expression<String>? roomId,
    Expression<String>? taskDefinitionId,
    Expression<bool>? isRemoved,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roomId != null) 'room_id': roomId,
      if (taskDefinitionId != null) 'task_definition_id': taskDefinitionId,
      if (isRemoved != null) 'is_removed': isRemoved,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChoresCompanion copyWith({
    Value<String>? id,
    Value<String>? roomId,
    Value<String>? taskDefinitionId,
    Value<bool>? isRemoved,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ChoresCompanion(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      taskDefinitionId: taskDefinitionId ?? this.taskDefinitionId,
      isRemoved: isRemoved ?? this.isRemoved,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (taskDefinitionId.present) {
      map['task_definition_id'] = Variable<String>(taskDefinitionId.value);
    }
    if (isRemoved.present) {
      map['is_removed'] = Variable<bool>(isRemoved.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChoresCompanion(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('taskDefinitionId: $taskDefinitionId, ')
          ..write('isRemoved: $isRemoved, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChoreCompletionsTable extends ChoreCompletions
    with TableInfo<$ChoreCompletionsTable, ChoreCompletion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChoreCompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _choreIdMeta = const VerificationMeta(
    'choreId',
  );
  @override
  late final GeneratedColumn<String> choreId = GeneratedColumn<String>(
    'chore_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chores (id)',
    ),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualDurationMinutesMeta =
      const VerificationMeta('actualDurationMinutes');
  @override
  late final GeneratedColumn<double> actualDurationMinutes =
      GeneratedColumn<double>(
        'actual_duration_minutes',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    choreId,
    completedAt,
    actualDurationMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chore_completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChoreCompletion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chore_id')) {
      context.handle(
        _choreIdMeta,
        choreId.isAcceptableOrUnknown(data['chore_id']!, _choreIdMeta),
      );
    } else if (isInserting) {
      context.missing(_choreIdMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('actual_duration_minutes')) {
      context.handle(
        _actualDurationMinutesMeta,
        actualDurationMinutes.isAcceptableOrUnknown(
          data['actual_duration_minutes']!,
          _actualDurationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualDurationMinutesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChoreCompletion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChoreCompletion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      choreId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chore_id'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      actualDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_duration_minutes'],
      )!,
    );
  }

  @override
  $ChoreCompletionsTable createAlias(String alias) {
    return $ChoreCompletionsTable(attachedDatabase, alias);
  }
}

class ChoreCompletion extends DataClass implements Insertable<ChoreCompletion> {
  final String id;
  final String choreId;
  final DateTime completedAt;
  final double actualDurationMinutes;
  const ChoreCompletion({
    required this.id,
    required this.choreId,
    required this.completedAt,
    required this.actualDurationMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chore_id'] = Variable<String>(choreId);
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['actual_duration_minutes'] = Variable<double>(actualDurationMinutes);
    return map;
  }

  ChoreCompletionsCompanion toCompanion(bool nullToAbsent) {
    return ChoreCompletionsCompanion(
      id: Value(id),
      choreId: Value(choreId),
      completedAt: Value(completedAt),
      actualDurationMinutes: Value(actualDurationMinutes),
    );
  }

  factory ChoreCompletion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChoreCompletion(
      id: serializer.fromJson<String>(json['id']),
      choreId: serializer.fromJson<String>(json['choreId']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      actualDurationMinutes: serializer.fromJson<double>(
        json['actualDurationMinutes'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'choreId': serializer.toJson<String>(choreId),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'actualDurationMinutes': serializer.toJson<double>(actualDurationMinutes),
    };
  }

  ChoreCompletion copyWith({
    String? id,
    String? choreId,
    DateTime? completedAt,
    double? actualDurationMinutes,
  }) => ChoreCompletion(
    id: id ?? this.id,
    choreId: choreId ?? this.choreId,
    completedAt: completedAt ?? this.completedAt,
    actualDurationMinutes: actualDurationMinutes ?? this.actualDurationMinutes,
  );
  ChoreCompletion copyWithCompanion(ChoreCompletionsCompanion data) {
    return ChoreCompletion(
      id: data.id.present ? data.id.value : this.id,
      choreId: data.choreId.present ? data.choreId.value : this.choreId,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      actualDurationMinutes: data.actualDurationMinutes.present
          ? data.actualDurationMinutes.value
          : this.actualDurationMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChoreCompletion(')
          ..write('id: $id, ')
          ..write('choreId: $choreId, ')
          ..write('completedAt: $completedAt, ')
          ..write('actualDurationMinutes: $actualDurationMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, choreId, completedAt, actualDurationMinutes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChoreCompletion &&
          other.id == this.id &&
          other.choreId == this.choreId &&
          other.completedAt == this.completedAt &&
          other.actualDurationMinutes == this.actualDurationMinutes);
}

class ChoreCompletionsCompanion extends UpdateCompanion<ChoreCompletion> {
  final Value<String> id;
  final Value<String> choreId;
  final Value<DateTime> completedAt;
  final Value<double> actualDurationMinutes;
  final Value<int> rowid;
  const ChoreCompletionsCompanion({
    this.id = const Value.absent(),
    this.choreId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.actualDurationMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChoreCompletionsCompanion.insert({
    required String id,
    required String choreId,
    required DateTime completedAt,
    required double actualDurationMinutes,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       choreId = Value(choreId),
       completedAt = Value(completedAt),
       actualDurationMinutes = Value(actualDurationMinutes);
  static Insertable<ChoreCompletion> custom({
    Expression<String>? id,
    Expression<String>? choreId,
    Expression<DateTime>? completedAt,
    Expression<double>? actualDurationMinutes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (choreId != null) 'chore_id': choreId,
      if (completedAt != null) 'completed_at': completedAt,
      if (actualDurationMinutes != null)
        'actual_duration_minutes': actualDurationMinutes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChoreCompletionsCompanion copyWith({
    Value<String>? id,
    Value<String>? choreId,
    Value<DateTime>? completedAt,
    Value<double>? actualDurationMinutes,
    Value<int>? rowid,
  }) {
    return ChoreCompletionsCompanion(
      id: id ?? this.id,
      choreId: choreId ?? this.choreId,
      completedAt: completedAt ?? this.completedAt,
      actualDurationMinutes:
          actualDurationMinutes ?? this.actualDurationMinutes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (choreId.present) {
      map['chore_id'] = Variable<String>(choreId.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (actualDurationMinutes.present) {
      map['actual_duration_minutes'] = Variable<double>(
        actualDurationMinutes.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChoreCompletionsCompanion(')
          ..write('id: $id, ')
          ..write('choreId: $choreId, ')
          ..write('completedAt: $completedAt, ')
          ..write('actualDurationMinutes: $actualDurationMinutes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntropyStatesTable extends EntropyStates
    with TableInfo<$EntropyStatesTable, EntropyState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntropyStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _choreIdMeta = const VerificationMeta(
    'choreId',
  );
  @override
  late final GeneratedColumn<String> choreId = GeneratedColumn<String>(
    'chore_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chores (id)',
    ),
  );
  static const VerificationMeta _lastCompletedAtMeta = const VerificationMeta(
    'lastCompletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastCompletedAt =
      GeneratedColumn<DateTime>(
        'last_completed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _learnedRisePerHourMeta =
      const VerificationMeta('learnedRisePerHour');
  @override
  late final GeneratedColumn<double> learnedRisePerHour =
      GeneratedColumn<double>(
        'learned_rise_per_hour',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    choreId,
    lastCompletedAt,
    learnedRisePerHour,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entropy_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntropyState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chore_id')) {
      context.handle(
        _choreIdMeta,
        choreId.isAcceptableOrUnknown(data['chore_id']!, _choreIdMeta),
      );
    } else if (isInserting) {
      context.missing(_choreIdMeta);
    }
    if (data.containsKey('last_completed_at')) {
      context.handle(
        _lastCompletedAtMeta,
        lastCompletedAt.isAcceptableOrUnknown(
          data['last_completed_at']!,
          _lastCompletedAtMeta,
        ),
      );
    }
    if (data.containsKey('learned_rise_per_hour')) {
      context.handle(
        _learnedRisePerHourMeta,
        learnedRisePerHour.isAcceptableOrUnknown(
          data['learned_rise_per_hour']!,
          _learnedRisePerHourMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {choreId};
  @override
  EntropyState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntropyState(
      choreId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chore_id'],
      )!,
      lastCompletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_completed_at'],
      ),
      learnedRisePerHour: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}learned_rise_per_hour'],
      ),
    );
  }

  @override
  $EntropyStatesTable createAlias(String alias) {
    return $EntropyStatesTable(attachedDatabase, alias);
  }
}

class EntropyState extends DataClass implements Insertable<EntropyState> {
  final String choreId;
  final DateTime? lastCompletedAt;
  final double? learnedRisePerHour;
  const EntropyState({
    required this.choreId,
    this.lastCompletedAt,
    this.learnedRisePerHour,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chore_id'] = Variable<String>(choreId);
    if (!nullToAbsent || lastCompletedAt != null) {
      map['last_completed_at'] = Variable<DateTime>(lastCompletedAt);
    }
    if (!nullToAbsent || learnedRisePerHour != null) {
      map['learned_rise_per_hour'] = Variable<double>(learnedRisePerHour);
    }
    return map;
  }

  EntropyStatesCompanion toCompanion(bool nullToAbsent) {
    return EntropyStatesCompanion(
      choreId: Value(choreId),
      lastCompletedAt: lastCompletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCompletedAt),
      learnedRisePerHour: learnedRisePerHour == null && nullToAbsent
          ? const Value.absent()
          : Value(learnedRisePerHour),
    );
  }

  factory EntropyState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntropyState(
      choreId: serializer.fromJson<String>(json['choreId']),
      lastCompletedAt: serializer.fromJson<DateTime?>(json['lastCompletedAt']),
      learnedRisePerHour: serializer.fromJson<double?>(
        json['learnedRisePerHour'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'choreId': serializer.toJson<String>(choreId),
      'lastCompletedAt': serializer.toJson<DateTime?>(lastCompletedAt),
      'learnedRisePerHour': serializer.toJson<double?>(learnedRisePerHour),
    };
  }

  EntropyState copyWith({
    String? choreId,
    Value<DateTime?> lastCompletedAt = const Value.absent(),
    Value<double?> learnedRisePerHour = const Value.absent(),
  }) => EntropyState(
    choreId: choreId ?? this.choreId,
    lastCompletedAt: lastCompletedAt.present
        ? lastCompletedAt.value
        : this.lastCompletedAt,
    learnedRisePerHour: learnedRisePerHour.present
        ? learnedRisePerHour.value
        : this.learnedRisePerHour,
  );
  EntropyState copyWithCompanion(EntropyStatesCompanion data) {
    return EntropyState(
      choreId: data.choreId.present ? data.choreId.value : this.choreId,
      lastCompletedAt: data.lastCompletedAt.present
          ? data.lastCompletedAt.value
          : this.lastCompletedAt,
      learnedRisePerHour: data.learnedRisePerHour.present
          ? data.learnedRisePerHour.value
          : this.learnedRisePerHour,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntropyState(')
          ..write('choreId: $choreId, ')
          ..write('lastCompletedAt: $lastCompletedAt, ')
          ..write('learnedRisePerHour: $learnedRisePerHour')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(choreId, lastCompletedAt, learnedRisePerHour);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntropyState &&
          other.choreId == this.choreId &&
          other.lastCompletedAt == this.lastCompletedAt &&
          other.learnedRisePerHour == this.learnedRisePerHour);
}

class EntropyStatesCompanion extends UpdateCompanion<EntropyState> {
  final Value<String> choreId;
  final Value<DateTime?> lastCompletedAt;
  final Value<double?> learnedRisePerHour;
  final Value<int> rowid;
  const EntropyStatesCompanion({
    this.choreId = const Value.absent(),
    this.lastCompletedAt = const Value.absent(),
    this.learnedRisePerHour = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntropyStatesCompanion.insert({
    required String choreId,
    this.lastCompletedAt = const Value.absent(),
    this.learnedRisePerHour = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : choreId = Value(choreId);
  static Insertable<EntropyState> custom({
    Expression<String>? choreId,
    Expression<DateTime>? lastCompletedAt,
    Expression<double>? learnedRisePerHour,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (choreId != null) 'chore_id': choreId,
      if (lastCompletedAt != null) 'last_completed_at': lastCompletedAt,
      if (learnedRisePerHour != null)
        'learned_rise_per_hour': learnedRisePerHour,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntropyStatesCompanion copyWith({
    Value<String>? choreId,
    Value<DateTime?>? lastCompletedAt,
    Value<double?>? learnedRisePerHour,
    Value<int>? rowid,
  }) {
    return EntropyStatesCompanion(
      choreId: choreId ?? this.choreId,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      learnedRisePerHour: learnedRisePerHour ?? this.learnedRisePerHour,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (choreId.present) {
      map['chore_id'] = Variable<String>(choreId.value);
    }
    if (lastCompletedAt.present) {
      map['last_completed_at'] = Variable<DateTime>(lastCompletedAt.value);
    }
    if (learnedRisePerHour.present) {
      map['learned_rise_per_hour'] = Variable<double>(learnedRisePerHour.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntropyStatesCompanion(')
          ..write('choreId: $choreId, ')
          ..write('lastCompletedAt: $lastCompletedAt, ')
          ..write('learnedRisePerHour: $learnedRisePerHour, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RunsTable extends Runs with TableInfo<$RunsTable, Run> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<EnergyLevel, String> energyLevel =
      GeneratedColumn<String>(
        'energy_level',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<EnergyLevel>($RunsTable.$converterenergyLevel);
  static const VerificationMeta _momentumChainLengthMeta =
      const VerificationMeta('momentumChainLength');
  @override
  late final GeneratedColumn<int> momentumChainLength = GeneratedColumn<int>(
    'momentum_chain_length',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    endedAt,
    energyLevel,
    momentumChainLength,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Run> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('momentum_chain_length')) {
      context.handle(
        _momentumChainLengthMeta,
        momentumChainLength.isAcceptableOrUnknown(
          data['momentum_chain_length']!,
          _momentumChainLengthMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Run map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Run(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      energyLevel: $RunsTable.$converterenergyLevel.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}energy_level'],
        )!,
      ),
      momentumChainLength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}momentum_chain_length'],
      )!,
    );
  }

  @override
  $RunsTable createAlias(String alias) {
    return $RunsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EnergyLevel, String, String> $converterenergyLevel =
      const EnumNameConverter<EnergyLevel>(EnergyLevel.values);
}

class Run extends DataClass implements Insertable<Run> {
  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final EnergyLevel energyLevel;
  final int momentumChainLength;
  const Run({
    required this.id,
    required this.startedAt,
    this.endedAt,
    required this.energyLevel,
    required this.momentumChainLength,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    {
      map['energy_level'] = Variable<String>(
        $RunsTable.$converterenergyLevel.toSql(energyLevel),
      );
    }
    map['momentum_chain_length'] = Variable<int>(momentumChainLength);
    return map;
  }

  RunsCompanion toCompanion(bool nullToAbsent) {
    return RunsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      energyLevel: Value(energyLevel),
      momentumChainLength: Value(momentumChainLength),
    );
  }

  factory Run.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Run(
      id: serializer.fromJson<String>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      energyLevel: $RunsTable.$converterenergyLevel.fromJson(
        serializer.fromJson<String>(json['energyLevel']),
      ),
      momentumChainLength: serializer.fromJson<int>(
        json['momentumChainLength'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'energyLevel': serializer.toJson<String>(
        $RunsTable.$converterenergyLevel.toJson(energyLevel),
      ),
      'momentumChainLength': serializer.toJson<int>(momentumChainLength),
    };
  }

  Run copyWith({
    String? id,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    EnergyLevel? energyLevel,
    int? momentumChainLength,
  }) => Run(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    energyLevel: energyLevel ?? this.energyLevel,
    momentumChainLength: momentumChainLength ?? this.momentumChainLength,
  );
  Run copyWithCompanion(RunsCompanion data) {
    return Run(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      energyLevel: data.energyLevel.present
          ? data.energyLevel.value
          : this.energyLevel,
      momentumChainLength: data.momentumChainLength.present
          ? data.momentumChainLength.value
          : this.momentumChainLength,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Run(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('energyLevel: $energyLevel, ')
          ..write('momentumChainLength: $momentumChainLength')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, startedAt, endedAt, energyLevel, momentumChainLength);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Run &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.energyLevel == this.energyLevel &&
          other.momentumChainLength == this.momentumChainLength);
}

class RunsCompanion extends UpdateCompanion<Run> {
  final Value<String> id;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<EnergyLevel> energyLevel;
  final Value<int> momentumChainLength;
  final Value<int> rowid;
  const RunsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.energyLevel = const Value.absent(),
    this.momentumChainLength = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RunsCompanion.insert({
    required String id,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    required EnergyLevel energyLevel,
    this.momentumChainLength = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startedAt = Value(startedAt),
       energyLevel = Value(energyLevel);
  static Insertable<Run> custom({
    Expression<String>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? energyLevel,
    Expression<int>? momentumChainLength,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (energyLevel != null) 'energy_level': energyLevel,
      if (momentumChainLength != null)
        'momentum_chain_length': momentumChainLength,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RunsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<EnergyLevel>? energyLevel,
    Value<int>? momentumChainLength,
    Value<int>? rowid,
  }) {
    return RunsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      energyLevel: energyLevel ?? this.energyLevel,
      momentumChainLength: momentumChainLength ?? this.momentumChainLength,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (energyLevel.present) {
      map['energy_level'] = Variable<String>(
        $RunsTable.$converterenergyLevel.toSql(energyLevel.value),
      );
    }
    if (momentumChainLength.present) {
      map['momentum_chain_length'] = Variable<int>(momentumChainLength.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RunsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('energyLevel: $energyLevel, ')
          ..write('momentumChainLength: $momentumChainLength, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RoomsTable rooms = $RoomsTable(this);
  late final $ChoresTable chores = $ChoresTable(this);
  late final $ChoreCompletionsTable choreCompletions = $ChoreCompletionsTable(
    this,
  );
  late final $EntropyStatesTable entropyStates = $EntropyStatesTable(this);
  late final $RunsTable runs = $RunsTable(this);
  late final RoomsDao roomsDao = RoomsDao(this as AppDatabase);
  late final ChoresDao choresDao = ChoresDao(this as AppDatabase);
  late final ChoreCompletionsDao choreCompletionsDao = ChoreCompletionsDao(
    this as AppDatabase,
  );
  late final EntropyStateDao entropyStateDao = EntropyStateDao(
    this as AppDatabase,
  );
  late final RunsDao runsDao = RunsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    rooms,
    chores,
    choreCompletions,
    entropyStates,
    runs,
  ];
}

typedef $$RoomsTableCreateCompanionBuilder = RoomsCompanion Function({
  required String id,
  required String roomTypeId,
  Value<String?> name,
  Value<int> sortOrder,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$RoomsTableUpdateCompanionBuilder = RoomsCompanion Function({
  Value<String> id,
  Value<String> roomTypeId,
  Value<String?> name,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$RoomsTableReferences
    extends BaseReferences<_$AppDatabase, $RoomsTable, Room> {
  $$RoomsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ChoresTable, List<Chore>> _choresRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.chores,
    aliasName: 'rooms__id__chores__room_id',
  );

  $$ChoresTableProcessedTableManager get choresRefs {
    final manager = $$ChoresTableTableManager(
      $_db,
      $_db.chores,
    ).filter((f) => f.roomId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_choresRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoomsTableFilterComposer extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roomTypeId => $composableBuilder(
    column: $table.roomTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> choresRefs(
    Expression<bool> Function($$ChoresTableFilterComposer f) f,
  ) {
    final $$ChoresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chores,
      getReferencedColumn: (t) => t.roomId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChoresTableFilterComposer(
            $db: $db,
            $table: $db.chores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoomsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roomTypeId => $composableBuilder(
    column: $table.roomTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get roomTypeId => $composableBuilder(
    column: $table.roomTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> choresRefs<T extends Object>(
    Expression<T> Function($$ChoresTableAnnotationComposer a) f,
  ) {
    final $$ChoresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chores,
      getReferencedColumn: (t) => t.roomId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChoresTableAnnotationComposer(
            $db: $db,
            $table: $db.chores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoomsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoomsTable,
          Room,
          $$RoomsTableFilterComposer,
          $$RoomsTableOrderingComposer,
          $$RoomsTableAnnotationComposer,
          $$RoomsTableCreateCompanionBuilder,
          $$RoomsTableUpdateCompanionBuilder,
          (Room, $$RoomsTableReferences),
          Room,
          PrefetchHooks Function({bool choresRefs})
        > {
  $$RoomsTableTableManager(_$AppDatabase db, $RoomsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> roomTypeId = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoomsCompanion(
                id: id,
                roomTypeId: roomTypeId,
                name: name,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String roomTypeId,
                Value<String?> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => RoomsCompanion.insert(
                id: id,
                roomTypeId: roomTypeId,
                name: name,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$RoomsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({choresRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (choresRefs) db.chores],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (choresRefs)
                    await $_getPrefetchedData<Room, $RoomsTable, Chore>(
                      currentTable: table,
                      referencedTable: $$RoomsTableReferences._choresRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$RoomsTableReferences(db, table, p0).choresRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.roomId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RoomsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoomsTable,
      Room,
      $$RoomsTableFilterComposer,
      $$RoomsTableOrderingComposer,
      $$RoomsTableAnnotationComposer,
      $$RoomsTableCreateCompanionBuilder,
      $$RoomsTableUpdateCompanionBuilder,
      (Room, $$RoomsTableReferences),
      Room,
      PrefetchHooks Function({bool choresRefs})
    >;
typedef $$ChoresTableCreateCompanionBuilder = ChoresCompanion Function({
  required String id,
  required String roomId,
  required String taskDefinitionId,
  Value<bool> isRemoved,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ChoresTableUpdateCompanionBuilder = ChoresCompanion Function({
  Value<String> id,
  Value<String> roomId,
  Value<String> taskDefinitionId,
  Value<bool> isRemoved,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$ChoresTableReferences
    extends BaseReferences<_$AppDatabase, $ChoresTable, Chore> {
  $$ChoresTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoomsTable _roomIdTable(_$AppDatabase db) =>
      db.rooms.createAlias('chores__room_id__rooms__id');

  $$RoomsTableProcessedTableManager get roomId {
    final $_column = $_itemColumn<String>('room_id')!;

    final manager = $$RoomsTableTableManager(
      $_db,
      $_db.rooms,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roomIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ChoreCompletionsTable, List<ChoreCompletion>>
  _choreCompletionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.choreCompletions,
    aliasName: 'chores__id__chore_completions__chore_id',
  );

  $$ChoreCompletionsTableProcessedTableManager get choreCompletionsRefs {
    final manager = $$ChoreCompletionsTableTableManager(
      $_db,
      $_db.choreCompletions,
    ).filter((f) => f.choreId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _choreCompletionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EntropyStatesTable, List<EntropyState>>
  _entropyStatesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.entropyStates,
    aliasName: 'chores__id__entropy_states__chore_id',
  );

  $$EntropyStatesTableProcessedTableManager get entropyStatesRefs {
    final manager = $$EntropyStatesTableTableManager(
      $_db,
      $_db.entropyStates,
    ).filter((f) => f.choreId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_entropyStatesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ChoresTableFilterComposer
    extends Composer<_$AppDatabase, $ChoresTable> {
  $$ChoresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskDefinitionId => $composableBuilder(
    column: $table.taskDefinitionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRemoved => $composableBuilder(
    column: $table.isRemoved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$RoomsTableFilterComposer get roomId {
    final $$RoomsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomId,
      referencedTable: $db.rooms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomsTableFilterComposer(
            $db: $db,
            $table: $db.rooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> choreCompletionsRefs(
    Expression<bool> Function($$ChoreCompletionsTableFilterComposer f) f,
  ) {
    final $$ChoreCompletionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.choreCompletions,
      getReferencedColumn: (t) => t.choreId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChoreCompletionsTableFilterComposer(
            $db: $db,
            $table: $db.choreCompletions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> entropyStatesRefs(
    Expression<bool> Function($$EntropyStatesTableFilterComposer f) f,
  ) {
    final $$EntropyStatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entropyStates,
      getReferencedColumn: (t) => t.choreId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntropyStatesTableFilterComposer(
            $db: $db,
            $table: $db.entropyStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChoresTableOrderingComposer
    extends Composer<_$AppDatabase, $ChoresTable> {
  $$ChoresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskDefinitionId => $composableBuilder(
    column: $table.taskDefinitionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRemoved => $composableBuilder(
    column: $table.isRemoved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoomsTableOrderingComposer get roomId {
    final $$RoomsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomId,
      referencedTable: $db.rooms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomsTableOrderingComposer(
            $db: $db,
            $table: $db.rooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChoresTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChoresTable> {
  $$ChoresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskDefinitionId => $composableBuilder(
    column: $table.taskDefinitionId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRemoved =>
      $composableBuilder(column: $table.isRemoved, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$RoomsTableAnnotationComposer get roomId {
    final $$RoomsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomId,
      referencedTable: $db.rooms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomsTableAnnotationComposer(
            $db: $db,
            $table: $db.rooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> choreCompletionsRefs<T extends Object>(
    Expression<T> Function($$ChoreCompletionsTableAnnotationComposer a) f,
  ) {
    final $$ChoreCompletionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.choreCompletions,
      getReferencedColumn: (t) => t.choreId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChoreCompletionsTableAnnotationComposer(
            $db: $db,
            $table: $db.choreCompletions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> entropyStatesRefs<T extends Object>(
    Expression<T> Function($$EntropyStatesTableAnnotationComposer a) f,
  ) {
    final $$EntropyStatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entropyStates,
      getReferencedColumn: (t) => t.choreId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntropyStatesTableAnnotationComposer(
            $db: $db,
            $table: $db.entropyStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChoresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChoresTable,
          Chore,
          $$ChoresTableFilterComposer,
          $$ChoresTableOrderingComposer,
          $$ChoresTableAnnotationComposer,
          $$ChoresTableCreateCompanionBuilder,
          $$ChoresTableUpdateCompanionBuilder,
          (Chore, $$ChoresTableReferences),
          Chore,
          PrefetchHooks Function({
            bool roomId,
            bool choreCompletionsRefs,
            bool entropyStatesRefs,
          })
        > {
  $$ChoresTableTableManager(_$AppDatabase db, $ChoresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChoresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChoresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChoresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> roomId = const Value.absent(),
                Value<String> taskDefinitionId = const Value.absent(),
                Value<bool> isRemoved = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChoresCompanion(
                id: id,
                roomId: roomId,
                taskDefinitionId: taskDefinitionId,
                isRemoved: isRemoved,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String roomId,
                required String taskDefinitionId,
                Value<bool> isRemoved = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ChoresCompanion.insert(
                id: id,
                roomId: roomId,
                taskDefinitionId: taskDefinitionId,
                isRemoved: isRemoved,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ChoresTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                roomId = false,
                choreCompletionsRefs = false,
                entropyStatesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (choreCompletionsRefs) db.choreCompletions,
                    if (entropyStatesRefs) db.entropyStates,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (roomId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.roomId,
                            referencedTable: $$ChoresTableReferences
                                ._roomIdTable(db),
                            referencedColumn: $$ChoresTableReferences
                                ._roomIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (choreCompletionsRefs)
                        await $_getPrefetchedData<
                          Chore,
                          $ChoresTable,
                          ChoreCompletion
                        >(
                          currentTable: table,
                          referencedTable: $$ChoresTableReferences
                              ._choreCompletionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChoresTableReferences(
                                db,
                                table,
                                p0,
                              ).choreCompletionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.choreId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (entropyStatesRefs)
                        await $_getPrefetchedData<
                          Chore,
                          $ChoresTable,
                          EntropyState
                        >(
                          currentTable: table,
                          referencedTable: $$ChoresTableReferences
                              ._entropyStatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChoresTableReferences(
                                db,
                                table,
                                p0,
                              ).entropyStatesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.choreId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ChoresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChoresTable,
      Chore,
      $$ChoresTableFilterComposer,
      $$ChoresTableOrderingComposer,
      $$ChoresTableAnnotationComposer,
      $$ChoresTableCreateCompanionBuilder,
      $$ChoresTableUpdateCompanionBuilder,
      (Chore, $$ChoresTableReferences),
      Chore,
      PrefetchHooks Function({
        bool roomId,
        bool choreCompletionsRefs,
        bool entropyStatesRefs,
      })
    >;
typedef $$ChoreCompletionsTableCreateCompanionBuilder =
    ChoreCompletionsCompanion Function({
      required String id,
      required String choreId,
      required DateTime completedAt,
      required double actualDurationMinutes,
      Value<int> rowid,
    });
typedef $$ChoreCompletionsTableUpdateCompanionBuilder =
    ChoreCompletionsCompanion Function({
      Value<String> id,
      Value<String> choreId,
      Value<DateTime> completedAt,
      Value<double> actualDurationMinutes,
      Value<int> rowid,
    });

final class $$ChoreCompletionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ChoreCompletionsTable, ChoreCompletion> {
  $$ChoreCompletionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ChoresTable _choreIdTable(_$AppDatabase db) =>
      db.chores.createAlias('chore_completions__chore_id__chores__id');

  $$ChoresTableProcessedTableManager get choreId {
    final $_column = $_itemColumn<String>('chore_id')!;

    final manager = $$ChoresTableTableManager(
      $_db,
      $_db.chores,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_choreIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChoreCompletionsTableFilterComposer
    extends Composer<_$AppDatabase, $ChoreCompletionsTable> {
  $$ChoreCompletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualDurationMinutes => $composableBuilder(
    column: $table.actualDurationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  $$ChoresTableFilterComposer get choreId {
    final $$ChoresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.choreId,
      referencedTable: $db.chores,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChoresTableFilterComposer(
            $db: $db,
            $table: $db.chores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChoreCompletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChoreCompletionsTable> {
  $$ChoreCompletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualDurationMinutes => $composableBuilder(
    column: $table.actualDurationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChoresTableOrderingComposer get choreId {
    final $$ChoresTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.choreId,
      referencedTable: $db.chores,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChoresTableOrderingComposer(
            $db: $db,
            $table: $db.chores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChoreCompletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChoreCompletionsTable> {
  $$ChoreCompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualDurationMinutes => $composableBuilder(
    column: $table.actualDurationMinutes,
    builder: (column) => column,
  );

  $$ChoresTableAnnotationComposer get choreId {
    final $$ChoresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.choreId,
      referencedTable: $db.chores,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChoresTableAnnotationComposer(
            $db: $db,
            $table: $db.chores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChoreCompletionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChoreCompletionsTable,
          ChoreCompletion,
          $$ChoreCompletionsTableFilterComposer,
          $$ChoreCompletionsTableOrderingComposer,
          $$ChoreCompletionsTableAnnotationComposer,
          $$ChoreCompletionsTableCreateCompanionBuilder,
          $$ChoreCompletionsTableUpdateCompanionBuilder,
          (ChoreCompletion, $$ChoreCompletionsTableReferences),
          ChoreCompletion,
          PrefetchHooks Function({bool choreId})
        > {
  $$ChoreCompletionsTableTableManager(
    _$AppDatabase db,
    $ChoreCompletionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChoreCompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChoreCompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChoreCompletionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> choreId = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<double> actualDurationMinutes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChoreCompletionsCompanion(
                id: id,
                choreId: choreId,
                completedAt: completedAt,
                actualDurationMinutes: actualDurationMinutes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String choreId,
                required DateTime completedAt,
                required double actualDurationMinutes,
                Value<int> rowid = const Value.absent(),
              }) => ChoreCompletionsCompanion.insert(
                id: id,
                choreId: choreId,
                completedAt: completedAt,
                actualDurationMinutes: actualDurationMinutes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChoreCompletionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({choreId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (choreId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.choreId,
                        referencedTable: $$ChoreCompletionsTableReferences
                            ._choreIdTable(db),
                        referencedColumn: $$ChoreCompletionsTableReferences
                            ._choreIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ChoreCompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChoreCompletionsTable,
      ChoreCompletion,
      $$ChoreCompletionsTableFilterComposer,
      $$ChoreCompletionsTableOrderingComposer,
      $$ChoreCompletionsTableAnnotationComposer,
      $$ChoreCompletionsTableCreateCompanionBuilder,
      $$ChoreCompletionsTableUpdateCompanionBuilder,
      (ChoreCompletion, $$ChoreCompletionsTableReferences),
      ChoreCompletion,
      PrefetchHooks Function({bool choreId})
    >;
typedef $$EntropyStatesTableCreateCompanionBuilder =
    EntropyStatesCompanion Function({
      required String choreId,
      Value<DateTime?> lastCompletedAt,
      Value<double?> learnedRisePerHour,
      Value<int> rowid,
    });
typedef $$EntropyStatesTableUpdateCompanionBuilder =
    EntropyStatesCompanion Function({
      Value<String> choreId,
      Value<DateTime?> lastCompletedAt,
      Value<double?> learnedRisePerHour,
      Value<int> rowid,
    });

final class $$EntropyStatesTableReferences
    extends BaseReferences<_$AppDatabase, $EntropyStatesTable, EntropyState> {
  $$EntropyStatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ChoresTable _choreIdTable(_$AppDatabase db) =>
      db.chores.createAlias('entropy_states__chore_id__chores__id');

  $$ChoresTableProcessedTableManager get choreId {
    final $_column = $_itemColumn<String>('chore_id')!;

    final manager = $$ChoresTableTableManager(
      $_db,
      $_db.chores,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_choreIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EntropyStatesTableFilterComposer
    extends Composer<_$AppDatabase, $EntropyStatesTable> {
  $$EntropyStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get lastCompletedAt => $composableBuilder(
    column: $table.lastCompletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get learnedRisePerHour => $composableBuilder(
    column: $table.learnedRisePerHour,
    builder: (column) => ColumnFilters(column),
  );

  $$ChoresTableFilterComposer get choreId {
    final $$ChoresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.choreId,
      referencedTable: $db.chores,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChoresTableFilterComposer(
            $db: $db,
            $table: $db.chores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntropyStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $EntropyStatesTable> {
  $$EntropyStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get lastCompletedAt => $composableBuilder(
    column: $table.lastCompletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get learnedRisePerHour => $composableBuilder(
    column: $table.learnedRisePerHour,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChoresTableOrderingComposer get choreId {
    final $$ChoresTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.choreId,
      referencedTable: $db.chores,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChoresTableOrderingComposer(
            $db: $db,
            $table: $db.chores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntropyStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntropyStatesTable> {
  $$EntropyStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get lastCompletedAt => $composableBuilder(
    column: $table.lastCompletedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get learnedRisePerHour => $composableBuilder(
    column: $table.learnedRisePerHour,
    builder: (column) => column,
  );

  $$ChoresTableAnnotationComposer get choreId {
    final $$ChoresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.choreId,
      referencedTable: $db.chores,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChoresTableAnnotationComposer(
            $db: $db,
            $table: $db.chores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntropyStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntropyStatesTable,
          EntropyState,
          $$EntropyStatesTableFilterComposer,
          $$EntropyStatesTableOrderingComposer,
          $$EntropyStatesTableAnnotationComposer,
          $$EntropyStatesTableCreateCompanionBuilder,
          $$EntropyStatesTableUpdateCompanionBuilder,
          (EntropyState, $$EntropyStatesTableReferences),
          EntropyState,
          PrefetchHooks Function({bool choreId})
        > {
  $$EntropyStatesTableTableManager(_$AppDatabase db, $EntropyStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntropyStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntropyStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntropyStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> choreId = const Value.absent(),
                Value<DateTime?> lastCompletedAt = const Value.absent(),
                Value<double?> learnedRisePerHour = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntropyStatesCompanion(
                choreId: choreId,
                lastCompletedAt: lastCompletedAt,
                learnedRisePerHour: learnedRisePerHour,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String choreId,
                Value<DateTime?> lastCompletedAt = const Value.absent(),
                Value<double?> learnedRisePerHour = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntropyStatesCompanion.insert(
                choreId: choreId,
                lastCompletedAt: lastCompletedAt,
                learnedRisePerHour: learnedRisePerHour,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EntropyStatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({choreId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (choreId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.choreId,
                        referencedTable: $$EntropyStatesTableReferences
                            ._choreIdTable(db),
                        referencedColumn: $$EntropyStatesTableReferences
                            ._choreIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EntropyStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntropyStatesTable,
      EntropyState,
      $$EntropyStatesTableFilterComposer,
      $$EntropyStatesTableOrderingComposer,
      $$EntropyStatesTableAnnotationComposer,
      $$EntropyStatesTableCreateCompanionBuilder,
      $$EntropyStatesTableUpdateCompanionBuilder,
      (EntropyState, $$EntropyStatesTableReferences),
      EntropyState,
      PrefetchHooks Function({bool choreId})
    >;
typedef $$RunsTableCreateCompanionBuilder = RunsCompanion Function({
  required String id,
  required DateTime startedAt,
  Value<DateTime?> endedAt,
  required EnergyLevel energyLevel,
  Value<int> momentumChainLength,
  Value<int> rowid,
});
typedef $$RunsTableUpdateCompanionBuilder = RunsCompanion Function({
  Value<String> id,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<EnergyLevel> energyLevel,
  Value<int> momentumChainLength,
  Value<int> rowid,
});

class $$RunsTableFilterComposer extends Composer<_$AppDatabase, $RunsTable> {
  $$RunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EnergyLevel, EnergyLevel, String>
  get energyLevel => $composableBuilder(
    column: $table.energyLevel,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get momentumChainLength => $composableBuilder(
    column: $table.momentumChainLength,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RunsTableOrderingComposer extends Composer<_$AppDatabase, $RunsTable> {
  $$RunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get energyLevel => $composableBuilder(
    column: $table.energyLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get momentumChainLength => $composableBuilder(
    column: $table.momentumChainLength,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RunsTable> {
  $$RunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EnergyLevel, String> get energyLevel =>
      $composableBuilder(
        column: $table.energyLevel,
        builder: (column) => column,
      );

  GeneratedColumn<int> get momentumChainLength => $composableBuilder(
    column: $table.momentumChainLength,
    builder: (column) => column,
  );
}

class $$RunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RunsTable,
          Run,
          $$RunsTableFilterComposer,
          $$RunsTableOrderingComposer,
          $$RunsTableAnnotationComposer,
          $$RunsTableCreateCompanionBuilder,
          $$RunsTableUpdateCompanionBuilder,
          (Run, BaseReferences<_$AppDatabase, $RunsTable, Run>),
          Run,
          PrefetchHooks Function()
        > {
  $$RunsTableTableManager(_$AppDatabase db, $RunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<EnergyLevel> energyLevel = const Value.absent(),
                Value<int> momentumChainLength = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RunsCompanion(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                energyLevel: energyLevel,
                momentumChainLength: momentumChainLength,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                required EnergyLevel energyLevel,
                Value<int> momentumChainLength = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RunsCompanion.insert(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                energyLevel: energyLevel,
                momentumChainLength: momentumChainLength,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RunsTable,
      Run,
      $$RunsTableFilterComposer,
      $$RunsTableOrderingComposer,
      $$RunsTableAnnotationComposer,
      $$RunsTableCreateCompanionBuilder,
      $$RunsTableUpdateCompanionBuilder,
      (Run, BaseReferences<_$AppDatabase, $RunsTable, Run>),
      Run,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RoomsTableTableManager get rooms =>
      $$RoomsTableTableManager(_db, _db.rooms);
  $$ChoresTableTableManager get chores =>
      $$ChoresTableTableManager(_db, _db.chores);
  $$ChoreCompletionsTableTableManager get choreCompletions =>
      $$ChoreCompletionsTableTableManager(_db, _db.choreCompletions);
  $$EntropyStatesTableTableManager get entropyStates =>
      $$EntropyStatesTableTableManager(_db, _db.entropyStates);
  $$RunsTableTableManager get runs => $$RunsTableTableManager(_db, _db.runs);
}
