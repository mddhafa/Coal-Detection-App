part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileSuccess extends ProfileState {
  final String message;

  ProfileSuccess({required this.message});
}

final class ProfileFailure extends ProfileState {
  final String error;

  ProfileFailure({required this.error});
}

class ProfileLoaded extends ProfileState {
  final User data;

  ProfileLoaded({required this.data});
}
