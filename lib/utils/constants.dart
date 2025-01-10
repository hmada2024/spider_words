class Constants {
  static const String databaseName = 'nouns.db';

  // Nouns Table
  static const String nounsTable = 'nouns';
  static const String nounIdColumn = 'id';
  static const String nounNameColumn = 'name';
  static const String nounImageColumn = 'image';
  static const String nounAudioColumn = 'audio';
  static const String nounCategoryColumn = 'category';

  // Noun Categories
  static const String categoryAnimal = 'animal';
  static const String categoryBird = 'bird';
  static const String categoryFruit = 'fruit';
  static const String categoryVegetable = 'vegetable';
  static const String categoryHomeStuff = 'home_stuff';
  static const String categorySchoolSupplies = 'school_supplies';
  static const String categoryStationery = 'Stationery';
  static const String categoryTools = 'Tools';
  static const String categoryElectronics = 'Electronics';
  static const String categoryColor = 'color';
  static const String categoryJobs = 'jobs';

  // Adjectives Table
  static const String adjectivesTable = 'adjectives';
  static const String adjectiveIdColumn = 'id';
  static const String mainAdjectiveColumn = 'main_adjective';
  static const String mainExampleColumn = 'main_example';
  static const String reverseAdjectiveColumn = 'reverse_adjective';
  static const String reverseExampleColumn = 'reverse_example';
  static const String mainAdjectiveAudioColumn = 'main_adjective_audio';
  static const String reverseAdjectiveAudioColumn = 'reverse_adjective_audio';
  static const String mainExampleAudioColumn = 'main_example_audio';
  static const String reverseExampleAudioColumn = 'reverse_example_audio';

  // Compound Words Table
  static const String compoundWordsTable = 'compound_words';
  static const String compoundWordIdColumn = 'id';
  static const String compoundWordMainColumn = 'main';
  static const String compoundWordPart1Column = 'part1';
  static const String compoundWordPart2Column = 'part2';
  static const String compoundWordExampleColumn = 'example';
  static const String compoundWordMainAudioColumn = 'main_audio';
  static const String compoundWordExampleAudioColumn = 'example_audio';

  // Default Assets Table
  static const String defaultAssetsTable = 'default_assets';
  static const String defaultAssetIdColumn = 'id';
  static const String defaultAssetCategoryColumn = 'category';
  static const String defaultAssetImageColumn = 'image';
  static const String defaultAssetAudioColumn = 'audio';
}
