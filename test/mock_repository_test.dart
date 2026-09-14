import 'package:flutter_test/flutter_test.dart';
import 'package:yemeni_world/data/mock_repository.dart';

void main() {
  final repository = MockAppRepository();

  test('structured search finds translator in New Delhi', () async {
    final results = await repository.search(country: 'الهند', city: 'نيودلهي', categoryId: 'translation');
    expect(results, hasLength(1));
    expect(results.single.name, 'محمد علي');
  });

  test('free Arabic search handles filler words and letter variants', () async {
    final results = await repository.search(query: 'مترجم يمني في نيودلهي');
    expect(results.map((item) => item.id), contains('p1'));
  });

  test('nearby results are sorted by distance', () async {
    final results = await repository.search(nearby: true);
    expect(results, isNotEmpty);
    for (var index = 1; index < results.length; index++) {
      expect(results[index - 1].distanceKm! <= results[index].distanceKm!, isTrue);
    }
  });
}
