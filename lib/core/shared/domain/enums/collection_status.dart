/// Represents the physical ownership or acquisition status of a book in a collection.
enum CollectionStatus {
  /// The book has been announced but is not yet available for purchase.
  announced('Announced'),

  /// The user intends to buy the book.
  shoppingList('Shopping List'),

  /// The book is currently in the user's collection.
  collected('Collected'),

  /// The book has been lent to someone else.
  lended('Lended'),

  /// The book is no longer being printed and may be hard to find.
  outOfPrint('Out of Print');

  const CollectionStatus(this.clientValue);

  /// The human-readable string representation of the collection status.
  final String clientValue;
}
