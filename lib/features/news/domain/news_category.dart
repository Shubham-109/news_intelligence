/// Business desks the feed is organised around.
enum NewsCategory {
  business('Business'),
  markets('Markets'),
  economy('Economy'),
  banking('Banking'),
  energy('Energy'),
  technology('Technology');

  const NewsCategory(this.label);

  final String label;
}
