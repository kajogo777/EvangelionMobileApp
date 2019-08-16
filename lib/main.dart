import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/app.dart';
import 'src/blocs/blocs.dart';
import 'src/data/repositories.dart';

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();

  runApp(RepositoryProvider(
    builder: (context) => ChallengeRepository(),
    child: App(),
  ));
}
