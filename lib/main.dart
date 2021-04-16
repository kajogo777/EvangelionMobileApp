import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/app.dart';
import 'src/blocs/common.dart';
import 'src/data/repositories.dart';
import 'src/data/services.dart';

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();

  NotificationService.initializeReminders();

  runApp(MultiRepositoryProvider(
    providers: [
      RepositoryProvider<ChallengeRepository>(
        create: (context) => ChallengeRepository(),
      ),
      RepositoryProvider<PostRepository>(
        create: (context) => PostRepository(),
      ),
      RepositoryProvider<ProfileRepository>(
        create: (context) => ProfileRepository(),
      ),
    ],
    child: App(),
  ));
}
