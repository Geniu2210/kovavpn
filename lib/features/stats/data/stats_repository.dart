import 'package:fpdart/fpdart.dart';
import 'package:kovavpn/core/utils/exception_handler.dart';
import 'package:kovavpn/features/stats/model/stats_failure.dart';
import 'package:kovavpn/hiddifycore/generated/v2/hcore/hcore.pb.dart';
import 'package:kovavpn/hiddifycore/hiddify_core_service.dart';
import 'package:kovavpn/utils/custom_loggers.dart';

abstract interface class StatsRepository {
  Stream<Either<StatsFailure, SystemInfo>> watchStats();
}

class StatsRepositoryImpl with ExceptionHandler, InfraLogger implements StatsRepository {
  StatsRepositoryImpl({required this.singbox});

  final HiddifyCoreService singbox;

  @override
  Stream<Either<StatsFailure, SystemInfo>> watchStats() {
    return singbox.watchStats().handleExceptions(StatsUnexpectedFailure.new);
  }
}
