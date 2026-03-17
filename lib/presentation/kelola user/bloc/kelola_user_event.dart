part of 'kelola_user_bloc.dart';

@immutable
sealed class KelolaUserEvent {}

class GetKelolaUserList extends KelolaUserEvent {}

class AddKelolaUser extends KelolaUserEvent {
  final KelolaUserRequestModel kelolauserrequest;
  AddKelolaUser({required this.kelolauserrequest});
}

class GetKelolaUserById extends KelolaUserEvent {
  final String id;
  GetKelolaUserById({required this.id});
}

class UpdateKelolaUser extends KelolaUserEvent {
  final String id;
  final KelolaUserRequestModel kelolauserrequest;
  UpdateKelolaUser({required this.id, required this.kelolauserrequest});
}

class DeleteKelolaUser extends KelolaUserEvent {
  final String id;
  DeleteKelolaUser({required this.id});
}
