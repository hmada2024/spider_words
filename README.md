# Spider Words: An Interactive English Vocabulary Builder

Spider Words is a mobile application designed to make learning English vocabulary engaging and effective. It focuses on building vocabulary through categorized lists of words, interactive quizzes, and clear audio pronunciations. The app utilizes a local SQLite database to store vocabulary data, ensuring offline access and efficient data management.

## Key Features

*   **Categorized Vocabulary:** Explore vocabulary words organized into various categories like Adjectives, Nouns (Animals, Fruits, etc.), and Compound Words.
*   **Audio Pronunciation:** Listen to clear and accurate pronunciations for each vocabulary word, aiding in correct pronunciation and auditory learning.
*   **Visual Learning:** Many nouns are accompanied by relevant images, enhancing understanding and memorization through visual association.
*   **Interactive Quizzes:** Test your knowledge with two types of engaging quizzes:
    *   **Images Matching Quiz:** Match the correct word to the displayed image.
    *   **Nouns Matching Quiz:** Match the correct image to the spoken word.
    *   **Adjective Opposites Quiz:** Identify the opposite of a given adjective.
*   **Progress Tracking:** The quizzes track your score and the number of questions answered, providing insights into your learning progress.
*   **Category Filtering:** Focus your learning by filtering vocabulary lists and quizzes by specific categories.
*   **Animated Cards:** Vocabulary words are presented in visually appealing animated cards, making the learning experience more dynamic.
*   **Offline Access:** The app works offline, as all vocabulary data is stored locally in a SQLite database.
*   **Clean and Intuitive UI:**  A user-friendly interface with custom gradients and well-organized layouts ensures a smooth learning experience.

## Application Architecture

The application follows a structured architecture, separating concerns into distinct layers:

*   **`lib/data/`:** Contains the `database_helper.dart` file, responsible for managing the SQLite database connection, initialization, and data retrieval.
*   **`lib/models/`:** Defines the data models for the application, including:
    *   `adjective_model.dart`: Represents an adjective with its main form, opposite, examples, and audio data.
    *   `compound_word_model.dart`: Represents a compound word with its constituent parts, example, and audio data.
    *   `nouns_model.dart`: Represents a noun with its name, image, audio, and category.
*   **`lib/pages/`:** Holds the different screens or pages of the application, categorized into:
    *   **`common_pages/`:**  Contains general pages like `home_page.dart`, the app's main landing screen.
    *   **`vocabulary_pages/`:**  Features pages for browsing vocabulary lists:
        *   `adjectives_page.dart`: Displays a list of adjectives.
        *   `compound_words_page.dart`: Shows a list of compound words.
        *   `nouns_page.dart`: Presents a categorized list of nouns.
    *   **`quiz_pages/`:** Includes pages for the interactive quizzes:
        *   `images_matching_quiz_page.dart`: Implements the image matching quiz.
        *   `nouns_matching_quiz_page.dart`: Implements the noun matching quiz.
        *   `adjective_opposite_quiz_page.dart`: Implements the adjective opposites quiz.
*   **`lib/providers/`:** Manages the application's state using Riverpod. It contains providers for:
    *   `adjective_provider.dart`: Provides a `FutureProvider` for fetching the list of adjectives.
    *   `compound_word_provider.dart`: Provides a `FutureProvider` for fetching the list of compound words.
    *   `noun_provider.dart`: Provides a `FutureProvider` for fetching the list of nouns.
*   **`lib/utils/`:** Contains utility classes and constants:
    *   `app_constants.dart`: Defines application-wide constants like colors and sound paths for quizzes.
    *   `constants.dart`: Holds constants related to the database structure (table and column names).
    *   `screen_utils.dart`: Provides utility functions for getting screen dimensions.
    *   `string_formatter.dart`: Offers functions for formatting strings, such as category names.
*   **`lib/widgets/`:**  Houses reusable UI components, organized into:
    *   **`common_widgets/`:** Contains generic widgets used throughout the app:
        *   `category_filter_widget.dart`: A dropdown widget for filtering content by category.
        *   `custom_app_bar.dart`: A customized app bar with a title and optional actions.
        *   `custom_gradient.dart`: A widget for applying a custom linear gradient to the background.
        *   `custom_home_button.dart`: A styled button used on the home page.
    *   **`quiz_widgets/`:**  Includes widgets specific to the quiz functionality:
        *   `images_matching_quiz_content.dart`: The UI content for the image matching quiz.
        *   `images_matching_quiz_logic.dart`: The business logic for the image matching quiz (using `ChangeNotifier`).
        *   `nouns_matching_quiz_content.dart`: The UI content for the noun matching quiz.
        *   `nouns_matching_quiz_logic.dart`: The business logic for the noun matching quiz (using `ChangeNotifier`).
        *   `correct_wrong_message.dart`: Displays "Correct!" or "Wrong!" messages during quizzes.
        *   `adjective_opposite_quiz_content.dart`: The UI content for the adjective opposites quiz.
        *   `adjective_opposite_quiz_logic.dart`: The business logic for the adjective opposites quiz (using `ChangeNotifier`).
    *   **`vocabulary_widgets/`:**  Contains widgets for displaying vocabulary items:
        *   `adjective_card.dart`: Displays an interactive card for an adjective.
        *   `adjective_list.dart`:  Renders a list of `AdjectiveCard` widgets.
        *   `compound_word_card.dart`: Displays an interactive card for a compound word.
        *   `noun_item.dart`: Displays an interactive card for a noun.
        *   `noun_list.dart`: Renders a list of `NounItem` widgets.
*   **`lib/main.dart`:** The entry point of the application, responsible for setting up the app's theme, routes, and providers.

## Database Structure (`assets/nouns.db`)

The application utilizes an SQLite database named `nouns.db`. The database schema includes the following tables:

*   **`sqlite_sequence`:** (System Table) Used internally by SQLite to manage auto-incrementing columns.
    *   `name`:  Name of the table.
    *   `seq`:  Current sequence number.

*   **`default_assets`:** Stores default image and audio assets.
    *   `id` (`INTEGER`): Unique identifier for the asset.
    *   `category` (`TEXT`): Category of the asset.
    *   `image` (`BLOB`): Binary data for the image.
    *   `audio` (`BLOB`): Binary data for the audio.

*   **`nouns`:** Stores individual noun vocabulary words.
    *   `id` (`INTEGER`): Unique identifier for the noun.
    *   `name` (`TEXT`): The noun itself.
    *   `image` (`BLOB`): Binary data for the noun's image.
    *   `audio` (`BLOB`): Binary data for the noun's audio pronunciation.
    *   `category` (`TEXT`): The category the noun belongs to (e.g., "animal", "fruit").

*   **`adjectives`:** Stores adjective vocabulary words with examples and opposites.
    *   `id` (`INTEGER`): Unique identifier for the adjective.
    *   `main_adjective` (`TEXT`): The primary form of the adjective.
    *   `main_example` (`TEXT`): An example sentence using the main adjective.
    *   `reverse_adjective` (`TEXT`): The opposite of the main adjective.
    *   `reverse_example` (`TEXT`): An example sentence using the reverse adjective.
    *   `main_adjective_audio` (`BLOB`): Audio for the main adjective.
    *   `reverse_adjective_audio` (`BLOB`): Audio for the reverse adjective.
    *   `main_example_audio` (`BLOB`): Audio for the main example sentence.
    *   `reverse_example_audio` (`BLOB`): Audio for the reverse example sentence.

*   **`compound_words`:** Stores compound word vocabulary.
    *   `id` (`INTEGER`): Unique identifier for the compound word.
    *   `main` (`TEXT`): The compound word itself.
    *   `part1` (`TEXT`): The first part of the compound word.
    *   `part2` (`TEXT`): The second part of the compound word.
    *   `example` (`TEXT`): An example sentence using the compound word.
    *   `main_audio` (`BLOB`): Audio for the compound word.
    *   `example_audio` (`BLOB`): Audio for the example sentence.

## Key File Descriptions

*   **`lib/data/database_helper.dart`:** Manages the SQLite database. It handles database initialization (copying from assets on first launch), provides methods to query data from different tables (`getAdjectives`, `getNouns`, `getCompoundWords`, `getNounsByCategory`, `getNounsForMatchingQuiz`).
*   **`lib/main.dart`:** The application's entry point. It initializes the Flutter app, sets up the `ProviderScope` for state management, defines the app's theme, and configures the navigation routes for different pages. It also registers providers for `AudioPlayer` and `DatabaseHelper`.
*   **`lib/pages/vocabulary_pages/adjectives_page.dart`:** Displays a scrollable list of adjectives. It fetches adjective data using `adjectivesProvider` and uses `AdjectiveList` to render the cards. It includes a `RefreshIndicator` for updating data.
*   **`lib/pages/vocabulary_pages/nouns_page.dart`:**  Presents a categorized list of nouns. It uses `nounsProvider` to fetch data and allows filtering by category using `CategoryFilterDropdown`. The `NounList` widget displays the nouns.
*   **`lib/pages/vocabulary_pages/compound_words_page.dart`:** Shows a list of compound words, fetched using `compoundWordsProvider`. It uses `CompoundWordCard` to display each compound word.
*   **`lib/pages/quiz_pages/images_matching_quiz_page.dart`:** Implements the image matching quiz. It uses `matchingQuizLogicProvider` to manage the quiz state and `ImagesMatchingQuizContent` to display the UI. It allows filtering questions by category.
*   **`lib/pages/quiz_pages/nouns_matching_quiz_page.dart`:** Implements the noun matching quiz (matching audio to images). It uses `audioImageMatchingQuizLogicProvider` for state management and `NounsMatchingQuizContent` for the UI. It supports category filtering.
*   **`lib/widgets/vocabulary_widgets/adjective_card.dart`:**  Displays a single adjective card with its main form, opposite, example sentences, and audio playback buttons. It uses animations for a more engaging experience.
*   **`lib/widgets/vocabulary_widgets/noun_item.dart`:**  Displays a single noun card with its image, name, and audio playback button. It incorporates animations for a smooth presentation.
*   **`lib/widgets/vocabulary_widgets/compound_word_card.dart`:**  Displays a card for a compound word, showing the word, its parts, an example sentence, and audio playback options.
*   **`lib/widgets/quiz_widgets/images_matching_quiz_logic.dart`:**  Contains the business logic for the image matching quiz, managing the current question, answer options, score, and handling user interactions.
*   **`lib/widgets/quiz_widgets/nouns_matching_quiz_logic.dart`:** Contains the business logic for the noun matching quiz, managing the quiz flow and state.
*   **`lib/widgets/quiz_widgets/adjective_opposite_quiz_logic.dart`:** Manages the state and logic for the adjective opposites quiz.
*   **`lib/widgets/quiz_widgets/images_matching_quiz_content.dart`:**  Builds the UI for the image matching quiz, displaying the current noun, image options, and feedback.
*   **`lib/widgets/quiz_widgets/nouns_matching_quiz_content.dart`:** Builds the UI for the noun matching quiz, showing the audio prompt and image options.
*   **`lib/widgets/quiz_widgets/adjective_opposite_quiz_content.dart`:** Builds the UI for the adjective opposites quiz, displaying the adjective, example, and answer options.
*   **`lib/widgets/common_widgets/category_filter_widget.dart`:** A reusable dropdown widget that allows users to filter lists and quizzes by category.
*   **`lib/widgets/common_widgets/custom_app_bar.dart`:** A custom app bar widget used throughout the application for consistent styling.
*   **`lib/widgets/common_widgets/custom_gradient.dart`:** A widget that applies a predefined linear gradient to its child, used for background styling.
*   **`lib/widgets/common_widgets/custom_home_button.dart`:** A styled button used on the home page for navigating to different sections of the app.

## Getting Started

To run the application, you will need to have Flutter installed on your machine.

1. Clone the repository.
2. Navigate to the project directory in your terminal.
3. Run `flutter pub get` to install the dependencies.
4. Run `flutter run` to launch the application on your connected device or emulator.

## Contributing

Contributions to the Spider Words project are welcome! Please feel free to submit pull requests or open issues for bugs or feature requests.

## License

[Add your license information here]