import '../../../../core/shared/domain/utils/string_extensions.dart';
import '../../domain/entities/scan/scanned_name_entity.dart';

class ScannedNameModel extends ScannedNameEntity {
  const ScannedNameModel({required super.name, super.otherName});

  factory ScannedNameModel.fromMap(Map<String, dynamic> map) => ScannedNameModel(
    name: (map['name'] as String? ?? '').toTitleCase(),
    otherName: (map['otherName'] as String?)?.toTitleCase(),
  );
}
