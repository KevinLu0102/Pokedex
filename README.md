# Pokédex iOS App

## Overview

This project is an iOS application that implements a Pokédex using the PokéAPI v2. The application allows users to browse a list of Pokémon, view detailed information about each Pokémon, and mark their favorite Pokémon.

For the Traditional Chinese version of the README, please see [README-zh-TW.md](README-zh-tw.md).

## Main Features

**Pokémon List**:

- Display basic information
- Clicking on a list item takes the user to the Pokémon detail page
- Automatically load more Pokémon data when the user scrolls to the bottom
- Implement a filter to show only the user's favorite Pokémon

**Pokémon Detail**:

- PokémonID
- Name
- Type
- Image
- Evolution chain, clicking on a Pokémon in the evolution chain take the user to its detail page
- Base stats
- Pokémon description
- Allow users to mark/unmark a Pokémon as a "favorite"

## Additional Features

- Display the Pokémon list in both List and Grid formats
- Cache network requests to increase loading speed

## Development Environment

- UIKit
- Xcode 15.2
- Swift 5
- iOS 16.0
- CocoaPods 1.15.2
- Ruby 3.3.0
- MacOS 14.1

## Third-Party Libraries

- SDWebImage

## Installing the Application

To use the Pokédex iOS application, follow these steps:

1. Open Xcode, select Integrate -> Clone from the top menu -> Paste the URL

2. Open the terminal and make sure CocoaPods is installed on your computer

3. Right-click on the Pokedex folder -> Open in Terminal -> Run "pod install"

4. Open Pokedex.xcworkspace 

5. Select Product -> Run from the top menu to run the application on a simulator or connected iOS device

## Design Patterns

The Pokédex iOS application utilizes the following design patterns:

- MVVM: The application follows the MVVM architectural pattern, separating data models, UI components, and business logic into different layers

- Singleton: The APIService and FavoriteService classes are implemented as singletons to provide a single instance for making API calls and managing favorite Pokémon throughout the application

- Delegate: The application uses the delegate pattern to handle data for List and Grid

## About the Code

To improve code readability, maintainability, and extensibility, I did the following during development:

- Custom error handling: Defined custom error types NetworkError using Enum in APIService, covering various possible error scenarios and providing more explicit and meaningful error messages for easier error handling and testing

- Unified management and parsing of favorites: Other parts of the code don't need to repeat the parsing, reading, and writing logic, they can access and manipulate data simply through FavoriteService methods, reducing duplicate code

- Following API naming conventions: When defining Structs, kept property names consistent with API fields, improving code readability and making it easy to cross-reference code with API documentation

- Using custom types to encapsulate data: By encapsulating returned data in a custom type, a unified type can be used to access the data without needing to create multiple independent data structures 

- Reusable custom views: EmptyFavoriteView, HeaderView can be directly instantiated and used when other parts of the code need to display similar screens

- Unified data interface: In PokémonListViewController, both List and Grid use the same data from viewModel, avoiding duplicate data retrieval logic

- Data availability: In loadPokémonDetail of PokémonDetailViewModel, improved data availability to prevent the entire page from being unable to display due to a single API request failure, allowing users to still see successfully fetched data

- Centralized management of Identifiers: Defined all Cell Identifiers in the Constants Struct to avoid needing modifications in multiple places and reduce manual input errors

To enhance the user experience, I did the following during development:

- Show loading animation when loading more: When scrolling to the bottom triggers loading more data, show a loading animation to provide visual feedback that the application is fetching data

- Visualized Stats data: Dynamically calculate and set the height of the Stats background based on each Pokémon's base stats, providing an intuitive data display

- No favorites screen: When switching favorite status, display "You haven't collected any Pokémon yet" when there is no data, to avoid users thinking data loading failed

## LLM Assistance 

To accelerate development, here's what it helped me with during the development process:

- Generated APIService, allowing me to use it anywhere during development

- Generated FavoriteService to centrally manage favorite data

- Generated Enum for network request failures with custom error descriptions

- Generated loading animation that appears at the bottom of TableView when scrolled, including close functionality

- Generated a View for no favorites state that can be directly instantiated and used where needed

- Generated functionality to display star symbols in different styles and colors based on viewModel's favorite status

- Generated Structs based on API JSON data

- Provided code review

- Used MARK comments for categorization, easy to search and manage
