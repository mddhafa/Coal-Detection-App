part of 'kelola_user_bloc.dart';

@immutable
sealed class KelolaUserState {}

final class KelolaUserInitial extends KelolaUserState {}

final class KelolaUserLoading extends KelolaUserState {}

final class KelolaUserSuccess extends KelolaUserState {
  final String message;

  KelolaUserSuccess({required this.message});
}

final class KelolaUserFailure extends KelolaUserState {
  final String error;

  KelolaUserFailure({required this.error});
}

class KelolaUserLoaded extends KelolaUserState {
  final List<dynamic> data;

  KelolaUserLoaded({required this.data});
}
