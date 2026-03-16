part of 'recaps_bloc.dart';

@immutable
abstract class RecapsState {}

class RecapsInitial extends RecapsState {}

class RecapsLoading extends RecapsState {}

class RecapsSuccess extends RecapsState {
  final String message;

  RecapsSuccess({required this.message});
}

class RecapsFailure extends RecapsState {
  final String error;

  RecapsFailure({required this.error});
}

class RecapsLoaded extends RecapsState {
  final List<Datum> data;

  RecapsLoaded({required this.data});
}
