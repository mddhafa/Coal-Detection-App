part of 'recaps_bloc.dart';

@immutable
sealed class RecapsEvent {}

class GenerateDailyRecap extends RecapsEvent {}

class GenerateWeeklyRecap extends RecapsEvent {}

class GenerateMonthlyRecap extends RecapsEvent {}

class GetDailyRecap extends RecapsEvent {}

class GetWeeklyRecap extends RecapsEvent {}

class GetMonthlyRecap extends RecapsEvent {}

class RecapsRequested extends RecapsEvent {
  final String token;

  RecapsRequested({required this.token});
}

class FetchRecapsRequested extends RecapsEvent {
  final String token;

  FetchRecapsRequested({required this.token});
}
