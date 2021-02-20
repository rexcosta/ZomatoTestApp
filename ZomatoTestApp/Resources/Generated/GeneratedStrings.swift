// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation
import ZomatoFoundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum Accessibility {
    internal enum Screen {
      internal enum Restaurants {
        /// Filter restaurants
        internal static let filterButton = L10n.tr("Accessibility", "screen.restaurants.filterButton")
        internal enum List {
          internal enum Element {
            /// Dislike this restaurant
            internal static let buttonDislike = L10n.tr("Accessibility", "screen.restaurants.list.element.buttonDislike")
            /// Like this restaurant
            internal static let buttonLike = L10n.tr("Accessibility", "screen.restaurants.list.element.buttonLike")
            /// The cuisines of the restaurant
            internal static let labelCuisines = L10n.tr("Accessibility", "screen.restaurants.list.element.labelCuisines")
            /// Distance to the restaurant
            internal static let labelDistance = L10n.tr("Accessibility", "screen.restaurants.list.element.labelDistance")
            /// The name of the restaurant
            internal static let labelName = L10n.tr("Accessibility", "screen.restaurants.list.element.labelName")
            /// The price of the restaurant
            internal static let labelPriceRange = L10n.tr("Accessibility", "screen.restaurants.list.element.labelPriceRange")
            /// The timings of the restaurant
            internal static let labelTimings = L10n.tr("Accessibility", "screen.restaurants.list.element.labelTimings")
          }
        }
      }
    }
  }
  internal enum Localizable {
    internal enum Global {
      internal enum Button {
        /// Cancel
        internal static let cancel = L10n.tr("Localizable", "global.button.cancel")
        /// Ok
        internal static let ok = L10n.tr("Localizable", "global.button.ok")
        /// Retry
        internal static let retry = L10n.tr("Localizable", "global.button.retry")
      }
      internal enum Restaurant {
        internal enum Pricerange {
          /// Cheap
          internal static let cheap = L10n.tr("Localizable", "global.restaurant.pricerange.cheap")
          /// Expensive
          internal static let expensive = L10n.tr("Localizable", "global.restaurant.pricerange.expensive")
          /// Moderate
          internal static let moderate = L10n.tr("Localizable", "global.restaurant.pricerange.moderate")
          /// No cost provided
          internal static let unknow = L10n.tr("Localizable", "global.restaurant.pricerange.unknow")
          /// Very Expensive
          internal static let veryExpensive = L10n.tr("Localizable", "global.restaurant.pricerange.veryExpensive")
        }
      }
    }
    internal enum Screen {
      internal enum Permissions {
        internal enum Location {
          /// Location
          internal static let title = L10n.tr("Localizable", "screen.permissions.location.title")
        }
      }
      internal enum Restaurants {
        /// Zomato
        internal static let title = L10n.tr("Localizable", "screen.restaurants.title")
        internal enum Filter {
          /// Apply
          internal static let applyFilter = L10n.tr("Localizable", "screen.restaurants.filter.applyFilter")
          /// Filter by price range
          internal static let priceRange = L10n.tr("Localizable", "screen.restaurants.filter.priceRange")
          /// Filter
          internal static let title = L10n.tr("Localizable", "screen.restaurants.filter.title")
          internal enum Sort {
            /// Sort using location
            internal static let location = L10n.tr("Localizable", "screen.restaurants.filter.sort.location")
          }
        }
        internal enum List {
          internal enum Element {
            /// %.0fm away
            internal static func distance(_ p1: Float) -> LocalizedString {
              return L10n.tr("Localizable", "screen.restaurants.list.element.distance", p1)
            }
            /// Distance not available
            internal static let noDistance = L10n.tr("Localizable", "screen.restaurants.list.element.noDistance")
          }
        }
        internal enum Status {
          /// Trying to acquire your location to present you the restaurants near you.
          internal static let acquiringLocation = L10n.tr("Localizable", "screen.restaurants.status.acquiringLocation")
          /// Nothing to see in your area. Maybe you should talk with your local restaurants to sign in! Thanks!
          internal static let empty = L10n.tr("Localizable", "screen.restaurants.status.empty")
          /// Fetching more content for you to see!
          internal static let loadingMore = L10n.tr("Localizable", "screen.restaurants.status.loadingMore")
          /// Hi! Please wait a bit while we load you data based in your location. Can we retry?
          internal static let refreshing = L10n.tr("Localizable", "screen.restaurants.status.refreshing")
          internal enum LoadingMore {
            /// Ups! Something went wrong while retrieving more results
            internal static let error = L10n.tr("Localizable", "screen.restaurants.status.loadingMore.error")
          }
          internal enum Refreshing {
            /// Ups! Something went wrong
            internal static let error = L10n.tr("Localizable", "screen.restaurants.status.refreshing.error")
          }
        }
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> LocalizedString {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)

    return LocalizedString(
        key: key,
        value: String(format: format, locale: Locale.current, arguments: args)
    )
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
