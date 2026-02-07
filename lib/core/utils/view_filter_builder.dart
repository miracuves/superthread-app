import '../services/api/api_models.dart';

/// A robust builder for creating [ViewPreviewRequest] objects.
/// 
/// This builder ensures that requests to `POST /views/preview` are never empty,
/// preventing 400 Bad Request errors from the API.
/// 
/// Usage:
/// ```dart
/// final request = ViewFilterBuilder()
///   .withCardFilters(myCardFilters)
///   .build();
/// ```
class ViewFilterBuilder {
  ViewCardFilters? _cardFilters;
  Map<String, dynamic>? _boardFilters;
  Map<String, dynamic>? _pageFilters;

  /// Sets the card filters.
  ViewFilterBuilder withCardFilters(ViewCardFilters? filters) {
    _cardFilters = filters;
    return this;
  }

  /// Sets the board filters.
  ViewFilterBuilder withBoardFilters(Map<String, dynamic>? filters) {
    _boardFilters = filters;
    return this;
  }

  /// Sets the page filters.
  ViewFilterBuilder withPageFilters(Map<String, dynamic>? filters) {
    _pageFilters = filters;
    return this;
  }

  /// Builds the [ViewPreviewRequest].
  /// 
  /// If no filters are set, a default safe filter is applied to prevent API errors.
  ViewPreviewRequest build({String type = 'card'}) {
    // Check if at least one filter is present
    final hasCardFilters = _cardFilters != null;
    final hasBoardFilters = _boardFilters != null && _boardFilters!.isNotEmpty;
    final hasPageFilters = _pageFilters != null && _pageFilters!.isNotEmpty;

    if (!hasCardFilters && !hasBoardFilters && !hasPageFilters) {
      // Apply safe default filter if no filters are provided
      // Using 'has_status: true' is a safe way to get "all active items"
      _cardFilters = const ViewCardFilters(
        archived: false,
      );
    }

    return ViewPreviewRequest(
      type: type,
      cardFilters: _cardFilters,
      boardFilters: _boardFilters,
      pageFilters: _pageFilters,
    );
  }
}
