import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/measurements_state.dart';
import '../service/measurements_service.dart';

part 'measurements_repository.g.dart';

abstract interface class MeasurementsRepository {
  MeasurementsState loadInitial();
}

class MeasurementsRepositoryImpl implements MeasurementsRepository {
  const MeasurementsRepositoryImpl(this._service);

  final MeasurementsService _service;

  @override
  MeasurementsState loadInitial() => _service.loadInitial();
}

@riverpod
MeasurementsRepository measurementsRepository(MeasurementsRepositoryRef ref) {
  return MeasurementsRepositoryImpl(ref.watch(measurementsServiceProvider));
}
