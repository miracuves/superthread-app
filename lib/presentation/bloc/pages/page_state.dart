import 'package:equatable/equatable.dart';
import '../../../data/models/page.dart';

abstract class PageState extends Equatable {
  const PageState();

  @override
  List<Object?> get props => [];
}

class PageInitial extends PageState {
  const PageInitial();
}

class PageLoadInProgress extends PageState {
  const PageLoadInProgress();
}

class PageLoadSuccess extends PageState {
  final List<Page> pages;
  final bool hasMore;
  final int currentPage;

  const PageLoadSuccess({
    required this.pages,
    this.hasMore = false,
    this.currentPage = 1,
  });

  PageLoadSuccess copyWith({
    List<Page>? pages,
    bool? hasMore,
    int? currentPage,
  }) {
    return PageLoadSuccess(
      pages: pages ?? this.pages,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [pages, hasMore, currentPage];
}

class PageLoadFailure extends PageState {
  final String error;

  const PageLoadFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class PageDetailsLoaded extends PageState {
  final Page page;

  const PageDetailsLoaded({required this.page});

  @override
  List<Object?> get props => [page];
}

class PageOperationSuccess extends PageState {
  final String message;
  final Page? page;
  final PageState previousState;

  const PageOperationSuccess({
    required this.message, 
    this.page,
    required this.previousState,
  });

  @override
  List<Object?> get props => [message, page, previousState];
}

class PageOperationFailure extends PageState {
  final String error;
  final PageState? previousState;

  const PageOperationFailure({required this.error, this.previousState});

  @override
  List<Object?> get props => [error, previousState];
}

