import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/ai_service.dart';

class CareerRoadmapState {
  final bool isLoading;
  final String? errorMessage;
  final Map<String, dynamic>? roadmapData;

  CareerRoadmapState({
    this.isLoading = false,
    this.errorMessage,
    this.roadmapData,
  });

  CareerRoadmapState copyWith({
    bool? isLoading,
    String? errorMessage,
    Map<String, dynamic>? roadmapData,
  }) {
    return CareerRoadmapState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      roadmapData: roadmapData ?? this.roadmapData,
    );
  }
}

class CareerRoadmapNotifier extends Notifier<CareerRoadmapState> {
  @override
  CareerRoadmapState build() => CareerRoadmapState();

  Future<bool> generateRoadmap({
    required String targetRole,
    required String currentCondition,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final data = await AiService.instance.generateCareerRoadmap(
        targetRole: targetRole,
        currentCondition: currentCondition,
      );
      state = state.copyWith(isLoading: false, roadmapData: data);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  void reset() {
    state = CareerRoadmapState();
  }
}

final careerRoadmapProvider =
    NotifierProvider<CareerRoadmapNotifier, CareerRoadmapState>(
  CareerRoadmapNotifier.new,
);
