enum CollectionStatus {
  announced('Announced'),
  shoppingList('Shopping List'),
  collected('Collected'),
  lended('Lended'),
  outOfPrint('Out of Print');

  const CollectionStatus(this.clientValue);

  final String clientValue;
}
