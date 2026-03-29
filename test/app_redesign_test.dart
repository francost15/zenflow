import 'package:app/domain/entities/course.dart';
import 'package:app/domain/entities/habit.dart';
import 'package:app/domain/entities/task.dart';
import 'package:app/domain/repositories/auth_repository.dart';
import 'package:app/domain/repositories/calendar_repository.dart';
import 'package:app/domain/repositories/course_repository.dart';
import 'package:app/domain/repositories/habit_repository.dart';
import 'package:app/domain/repositories/task_repository.dart';
import 'package:app/presentation/blocs/auth/auth_bloc.dart';
import 'package:app/presentation/blocs/auth/auth_event.dart';
import 'package:app/presentation/blocs/course/course.dart';
import 'package:app/presentation/blocs/streaks/streaks_bloc.dart';
import 'package:app/presentation/blocs/task/task_bloc.dart';
import 'package:app/presentation/screens/courses/courses_screen.dart';
import 'package:app/presentation/screens/profile/profile_screen.dart';
import 'package:app/presentation/screens/streaks/streaks_screen.dart';
import 'package:app/presentation/widgets/dialogs/create_task_dialog.dart';
import 'package:app/presentation/widgets/heatmap_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/calendar/v3.dart' show Event;
import 'package:intl/date_symbol_data_local.dart';

part 'app_redesign_cases.dart';
part 'app_redesign_test_doubles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('es_ES');
  });

  registerAppRedesignTests();
}
