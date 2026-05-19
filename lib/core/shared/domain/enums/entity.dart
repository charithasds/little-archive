import 'package:flutter/material.dart';

enum Entity {
  book('Book', 'Books', Icons.book_rounded),
  work('Work', 'Works', Icons.article_rounded),
  author('Author', 'Authors', Icons.person_rounded),
  translator('Translator', 'Translators', Icons.translate_rounded),
  publisher('Publisher', 'Publishers', Icons.business_rounded),
  reader('Reader', 'Readers', Icons.face_rounded),
  sequence('Sequence', 'Sequences', Icons.layers_rounded),
  sequenceVolume('Sequence Volume', 'Sequence Volumes', Icons.format_list_numbered_rounded);

  const Entity(this.clientSingularValue, this.clientPluralValue, this.icon);
  final String clientSingularValue;
  final String clientPluralValue;
  final IconData icon;
}
