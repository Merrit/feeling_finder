import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:feeling_finder/src/logs/logging_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppInitial()) {
    instance = this;
  }

  static late AppCubit instance;

  /// The user has requested to quit the app.
  void quit() {
    LoggingManager.instance.close();
    exit(0);
  }
}
