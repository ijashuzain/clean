import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_remote_datasource.g.dart';

@riverpod
TaskRemoteDataSource taskRemoteDataSource(Ref ref) {
  return const TaskRemoteDataSourceImpl();
}

abstract class TaskRemoteDataSource {
  Future<void> syncPendingChanges();
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  const TaskRemoteDataSourceImpl();

  @override
  Future<void> syncPendingChanges() async {
    // Reserved for future cloud integration.
  }
}
