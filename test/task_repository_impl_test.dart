import 'package:app/core/error/exceptions.dart';
import 'package:app/data/datasources/firestore/task_datasource.dart';
import 'package:app/data/models/task_model.dart';
import 'package:app/data/repositories/task_repository_impl.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/calendar_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/calendar/v3.dart';

part 'task_repository_impl_create_update_tests.dart';
part 'task_repository_impl_delete_sync_tests.dart';
part 'task_repository_impl_test_doubles.dart';

void main() {
  registerTaskRepositoryCreateUpdateTests();
  registerTaskRepositoryDeleteSyncTests();
}
