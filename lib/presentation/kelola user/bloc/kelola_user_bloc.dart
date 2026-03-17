import 'package:bloc/bloc.dart';
import 'package:coalmobile_app/data/model/request/kelolauser_request_model.dart';
import 'package:coalmobile_app/data/model/response/kelolauser_response_model.dart';
import 'package:coalmobile_app/repository/kelolauser_repo.dart';
import 'package:meta/meta.dart';

part 'kelola_user_event.dart';
part 'kelola_user_state.dart';

class KelolaUserBloc extends Bloc<KelolaUserEvent, KelolaUserState> {
  final KelolauserRepo kelolauserRepo;

  KelolaUserBloc({required this.kelolauserRepo}) : super(KelolaUserInitial()) {
    on<GetKelolaUserList>(_onGetKelolaUserList);
    on<AddKelolaUser>(_onAddKelolaUser);
    on<GetKelolaUserById>(_onGetKelolaUserById);
    on<UpdateKelolaUser>(_onUpdateKelolaUser);
    on<DeleteKelolaUser>(_onDeleteKelolaUser);
    on<KelolaUserEvent>((event, emit) {});
  }

  Future<void> _onGetKelolaUserList(
    GetKelolaUserList event,
    Emitter<KelolaUserState> emit,
  ) async {
    emit(KelolaUserLoading());

    final result = await kelolauserRepo.getUsers();

    result.fold(
      (error) {
        print('[BLOC] Error: $error');
        emit(KelolaUserFailure(error: error));
      },
      (data) {
        print('[BLOC] Data didapat: ${data.data?.length} item');
        emit(KelolaUserLoaded(data: data.data ?? []));
      },
    );
  }

  Future<void> _onAddKelolaUser(
    AddKelolaUser event,
    Emitter<KelolaUserState> emit,
  ) async {
    emit(KelolaUserLoading());

    try {
      final result = await kelolauserRepo.addUser(
        event.kelolauserrequest.toMap(),
      );

      if (result["success"]) {
        emit(KelolaUserSuccess(message: result["message"]));
        add(GetKelolaUserList()); // Refresh list after adding
      } else {
        emit(KelolaUserFailure(error: result["message"]));
      }
    } catch (e) {
      emit(KelolaUserFailure(error: e.toString()));
    }
  }

  Future<void> _onGetKelolaUserById(
    GetKelolaUserById event,
    Emitter<KelolaUserState> emit,
  ) async {
    emit(KelolaUserLoading());

    final result = await kelolauserRepo.getUserById(int.parse(event.id));

    result.fold(
      (error) {
        print('[BLOC] Error: $error');
        emit(KelolaUserFailure(error: error));
      },
      (data) {
        emit(KelolaUserLoaded(data: [data]));
      },
    );
  }

  Future<void> _onUpdateKelolaUser(
    UpdateKelolaUser event,
    Emitter<KelolaUserState> emit,
  ) async {
    emit(KelolaUserLoading());

    try {
      await kelolauserRepo.updateUser(
        int.parse(event.id),
        event.kelolauserrequest.toMap(),
      );
      emit(KelolaUserSuccess(message: 'User berhasil diperbarui!'));
      add(GetKelolaUserList());
    } catch (e) {
      emit(KelolaUserFailure(error: e.toString()));
    }
  }

  Future<void> _onDeleteKelolaUser(
    DeleteKelolaUser event,
    Emitter<KelolaUserState> emit,
  ) async {
    emit(KelolaUserLoading());

    try {
      await kelolauserRepo.deleteUser(int.parse(event.id));
      emit(KelolaUserSuccess(message: 'User berhasil dihapus!'));
      add(GetKelolaUserList());
    } catch (e) {
      emit(KelolaUserFailure(error: e.toString()));
    }
  }
}
