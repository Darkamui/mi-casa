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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RoomsTable rooms = $RoomsTable(this);
  late final $ChoresTable chores = $ChoresTable(this);
  late final $ChoreCompletionsTable choreCompletions = $ChoreCompletionsTable(
    this,
  );
  late final RoomsDao roomsDao = RoomsDao(this as AppDatabase);
  late final ChoresDao choresDao = ChoresDao(this as AppDatabase);
  late final ChoreCompletionsDao choreCompletionsDao = ChoreCompletionsDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    rooms,
    chores,
    choreCompletions,
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
          PrefetchHooks Function({bool roomId, bool choreCompletionsRefs})
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
              ({roomId = false, choreCompletionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (choreCompletionsRefs) db.choreCompletions,
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
      PrefetchHooks Function({bool roomId, bool choreCompletionsRefs})
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RoomsTableTableManager get rooms =>
      $$RoomsTableTableManager(_db, _db.rooms);
  $$ChoresTableTableManager get chores =>
      $$ChoresTableTableManager(_db, _db.chores);
  $$ChoreCompletionsTableTableManager get choreCompletions =>
      $$ChoreCompletionsTableTableManager(_db, _db.choreCompletions);
}
