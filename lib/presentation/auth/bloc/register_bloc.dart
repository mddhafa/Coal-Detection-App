import 'package:bloc/bloc.dart';
import 'package:coalmobile_app/data/model/request/register_request_model.dart';
import 'package:coalmobile_app/data/model/response/login_response_model.dart';
import 'package:coalmobile_app/repository/authrepo.dart';
import 'package:meta/meta.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final Authrepo authrepo;

  RegisterBloc({required this.authrepo}) : super(RegisterInitial()) {
    on<RegisterEvent>(_onRegisterRequested);
  }

  Future<void> _onRegisterRequested(
    RegisterEvent event,
    Emitter<RegisterState> emit,
  ) async {
    if (event is RegisterRequest) {
      emit(RegisterLoading());

      final result = await authrepo.register(event.requestModel);

      result.fold(
        (l) => emit(RegisterFailure(error: l)),
        (r) => emit(RegisterSuccess(responseModel: r)),
      );
    }
  }
}
