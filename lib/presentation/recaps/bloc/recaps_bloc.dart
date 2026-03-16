import 'package:bloc/bloc.dart';
import 'package:coalmobile_app/data/model/response/recaps_response_model.dart';
import 'package:coalmobile_app/repository/recap_repo.dart';
import 'package:meta/meta.dart';

part 'recaps_event.dart';
part 'recaps_state.dart';

class RecapsBloc extends Bloc<RecapsEvent, RecapsState> {
  final MonitoringRepo recapRepo;

  RecapsBloc({required this.recapRepo}) : super(RecapsInitial()) {
    on<GenerateDailyRecap>(_onGenerateDaily);
    on<GenerateWeeklyRecap>(_onGenerateWeekly);
    on<GenerateMonthlyRecap>(_onGenerateMonthly);
    on<GetDailyRecap>(_onGetDailyRecap);
    on<GetWeeklyRecap>(_onGetWeeklyRecap);
    on<GetMonthlyRecap>(_onGetMonthlyRecap);
  }

  Future<void> _onGenerateDaily(
    GenerateDailyRecap event,
    Emitter<RecapsState> emit,
  ) async {
    emit(RecapsLoading());

    final result = await recapRepo.generateDailyRecap();

    result.fold((error) => emit(RecapsFailure(error: error)), (message) {
      add(GetDailyRecap());
    });
  }

  Future<void> _onGenerateWeekly(
    GenerateWeeklyRecap event,
    Emitter<RecapsState> emit,
  ) async {
    emit(RecapsLoading());

    final result = await recapRepo.generateWeeklyRecap();

    result.fold((error) => emit(RecapsFailure(error: error)), (message) {
      add(GetWeeklyRecap());
    });
  }

  Future<void> _onGenerateMonthly(
    GenerateMonthlyRecap event,
    Emitter<RecapsState> emit,
  ) async {
    emit(RecapsLoading());

    final result = await recapRepo.generateMonthlyRecap();

    result.fold((error) => emit(RecapsFailure(error: error)), (message) {
      add(GetMonthlyRecap());
    });
  }

  Future<void> _onGetDailyRecap(
    GetDailyRecap event,
    Emitter<RecapsState> emit,
  ) async {
    emit(RecapsLoading());

    final result = await recapRepo.getDailyRecap();

    result.fold(
      (error) => emit(RecapsFailure(error: error)),
      (response) => emit(RecapsLoaded(data: response.data ?? [])),
    );
  }

  Future<void> _onGetWeeklyRecap(
    GetWeeklyRecap event,
    Emitter<RecapsState> emit,
  ) async {
    emit(RecapsLoading());

    final result = await recapRepo.getWeeklyRecap();

    result.fold(
      (error) => emit(RecapsFailure(error: error)),
      (response) => emit(RecapsLoaded(data: response.data ?? [])),
    );
  }

  Future<void> _onGetMonthlyRecap(
    GetMonthlyRecap event,
    Emitter<RecapsState> emit,
  ) async {
    emit(RecapsLoading());

    final result = await recapRepo.getMonthlyRecap();

    result.fold(
      (error) => emit(RecapsFailure(error: error)),
      (response) => emit(RecapsLoaded(data: response.data ?? [])),
    );
  }
}
