import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/usecases/match_publishers_usecase.dart';

export '../../domain/usecases/match_publishers_usecase.dart';

part 'match_publishers_usecase_provider.g.dart';

@riverpod
MatchPublishersUseCase matchPublishersUseCase(Ref ref) => const MatchPublishersUseCase();
