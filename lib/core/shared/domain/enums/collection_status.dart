enum CollectionStatus {
  announced('Announced'),
  shoppingList('Shopping List'),
  onTheWay('On the Way'),
  collected('Collected'),
  lended('Lended'),
  outOfPrint('Out of Print');

  const CollectionStatus(this.clientValue);
  final String clientValue;
}
