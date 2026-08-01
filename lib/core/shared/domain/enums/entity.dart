import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum Entity {
  book('Book', 'Books', FontAwesomeIcons.book),
  work('Work', 'Works', FontAwesomeIcons.fileLines),
  creator('Creator', 'Creators', FontAwesomeIcons.userPen),
  duplicateCreator('Duplicate Creator', 'Duplicate Creators', FontAwesomeIcons.usersSlash),
  publisher('Publisher', 'Publishers', FontAwesomeIcons.building),
  reader('Reader', 'Readers', FontAwesomeIcons.smile),
  sequence('Sequence', 'Sequences', FontAwesomeIcons.layerGroup),
  sequenceVolume('Sequence Volume', 'Sequence Volumes', FontAwesomeIcons.listOl);

  const Entity(this.clientSingularValue, this.clientPluralValue, this.icon);
  final String clientSingularValue;
  final String clientPluralValue;
  final dynamic icon;
}
