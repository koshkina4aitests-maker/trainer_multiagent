import '../entities/progress_data.dart';

abstract class ProgressRepository {
  Future<ProgressSummary> getSummary({int days = 30});
}
