import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;
import '../../../core/services/api/api_service.dart';
import '../../../core/services/api/api_models.dart';
import '../../../data/models/card.dart' as card_model;
import '../../../data/models/requests/create_card_request.dart';
import '../../../data/models/requests/update_card_request.dart';
import '../../../data/models/card.dart';
import '../../../core/services/storage/storage_service.dart';
import '../../../core/network/dio_client.dart';
import 'card_event.dart';
import 'card_state.dart';
import '../../../core/utils/view_filter_builder.dart';

export 'card_event.dart';
export 'card_state.dart';

class CardBloc extends Bloc<CardEvent, CardState> {
  final ApiService _apiService;
  final StorageService _storageService;
  
  // Cache for user ID to user name mappings
  final Map<String, String> _userCache = {};
  Map<String, String> get userCache => _userCache;

  CardBloc(this._apiService, this._storageService) : super(CardInitial()) {
    on<LoadCards>(_onLoadCards);
    on<CreateCard>(_onCreateCard);
    on<UpdateCard>(_onUpdateCard);
    on<DeleteCard>(_onDeleteCard);
    on<MoveCard>(_onMoveCard);
    on<GetCardDetails>(_onGetCardDetails);
    on<AddCardComment>(_onAddCardComment);
    on<LoadCardComments>(_onLoadCardComments);
    on<DeleteCardComment>(_onDeleteCardComment);
    on<UpdateCardComment>(_onUpdateCardComment);
    on<ToggleCommentReaction>(_onToggleCommentReaction);
    on<ReplyToComment>(_onReplyToComment);
    on<LoadCardAttachments>(_onLoadCardAttachments);
    on<UploadCardAttachment>(_onUploadCardAttachment);
    on<DeleteCardAttachment>(_onDeleteCardAttachment);
    on<DeleteMultipleAttachments>(_onDeleteMultipleAttachments);
    on<RefreshCards>(_onRefreshCards);
    on<ClearCardError>(_onClearCardError);
  }

  Future<void> _onLoadCards(
    LoadCards event,
    Emitter<CardState> emit,
  ) async {
    final currentState = state;
    final int page = event.page ?? 1;
    List<Card> oldCards = [];

    // If loading more, don't show full screen progress but track old cards
    if (page > 1 && currentState is CardLoadSuccess) {
      oldCards = currentState.cards;
    } else {
      emit(CardLoadInProgress());
    }

    try {
      final String? eventTeamId = (event.teamId != null && event.teamId!.isNotEmpty) ? event.teamId : null;
      final teamId = eventTeamId ?? await _storageService.getTeamId();
      
      if (teamId == null || teamId.isEmpty) {
        emit(const CardLoadFailure(error: 'Team ID not found'));
        return;
      }

      // Cards API requires archived parameter when no boardId/listId is provided.
      // API only supports archived=true when no boardId/listId is provided.
      // When boardId/listId are provided, we can use the archived parameter from the event.
      final bool noBoardOrList = event.boardId == null && event.listId == null;
      
      String? archivedParam;
      if (noBoardOrList) {
        // API only supports archived=true when no boardId/listId is provided
        archivedParam = "true";
      } else {
        // When boardId/listId are provided, use the archived parameter from event or default to "false"
        archivedParam = event.archived == true ? "true" : "false";
      }
      
      // Special case: if we have projectId/epicId but NO boardId, API still seems to require archived=true
      if (event.boardId == null && event.listId == null && (event.projectId != null || event.epicId != null)) {
        archivedParam = "true";
      }

      CardsResponse response = const CardsResponse(cards: []);
      final userId = await _storageService.getUserId();
      final ownerId = event.assignedToMe == true ? userId : event.assignedTo;

      if (noBoardOrList && event.projectId == null && event.epicId == null) {
        // STRATEGY: Try multiple endpoints to avoid 0 results
        bool success = false;
        
        // 1. Try standard getCards(archived: false)
        try {
          response = await _apiService.getCards(
            teamId,
            ownerId: event.assignedToMe == true ? await _storageService.getUserId() : event.assignedTo,
            status: event.status == 'all' ? null : event.status,
            archived: 'false',
            page: page,
            limit: event.limit ?? 50,
          );
          if (response.cards.isNotEmpty) success = true;
        } catch (e) {
          debugPrint('CardBloc error loading cards (Stage 1): $e');
        }

        // 2. Fallback to Search API if Stage 1 failed or returned 0
        if (!success) {
          try {
            final searchResponse = await _apiService.search(
              teamId,
              '', // Try empty query instead of *
              'cards',
              null,
              null,
              null,
              event.assignedToMe == true ? await _storageService.getUserId() : event.assignedTo,
              event.status == 'all' ? null : event.status,
              null,
              null,
              null,
              page,
              event.limit ?? 50,
            );

            final searchCards = searchResponse.results.map((searchResult) {
              return Card(
                id: searchResult.id,
                title: searchResult.title,
                description: searchResult.content,
                status: searchResult.status,
                teamId: searchResult.teamId ?? teamId,
                boardId: searchResult.boardId ?? 'global',
                listId: searchResult.listId,
                userId: '',
                createdAt: searchResult.createdAt ?? DateTime.now(),
                updatedAt: searchResult.updatedAt,
                assignedTo: searchResult.assignedTo,
              );
            }).toList();

            if (searchCards.isNotEmpty) {
              response = CardsResponse(
                cards: searchCards,
                total: searchResponse.totalCount,
                page: searchResponse.currentPage ?? page,
                limit: event.limit ?? 50,
              );
              success = true;
              debugPrint('   - Search Result: ${searchCards.length} cards');
            }
          } catch (e) {
            debugPrint('   - Search Failed: $e');
            // debugPrint('   - Search Failed: $e');
          }
        }

        // 3. Final Fallback: getAssignedCards (original 25-limit workaround)
        if (!success && page == 1) {
           try {
             final userId = await _storageService.getUserId();
             final previewRequest = ViewFilterBuilder()
                .withCardFilters(ViewCardFilters(
                   hasStatus: true,
                   archived: false,
                   include: userId != null && event.assignedToMe == true 
                       ? ViewIncludeFilters(members: [userId]) 
                       : (event.assignedTo != null ? ViewIncludeFilters(members: [event.assignedTo!]) : null),
                ))
                .build();
             response = await _apiService.getAssignedCards(teamId, previewRequest);
             debugPrint('   - Preview Result: ${response.cards.length} cards');
           } catch (e) {
             debugPrint('   - Preview Failed: $e');
             response = const CardsResponse(cards: []);
           }
        } else if (!success) {
           // If paging beyond 1 and failed, just return empty
           response = const CardsResponse(cards: []);
        }
      } else {
        // Specific board/list/project/epic context, use getCards
        try {
          response = await _apiService.getCards(
            teamId,
            boardId: event.boardId,
            listId: event.listId,
            projectId: event.projectId,
            epicId: event.epicId,
            ownerId: ownerId,
            status: event.status == 'all' ? null : event.status,
            archived: archivedParam,
            page: page,
            limit: event.limit ?? 50,
          );
        } catch (e) {
          // Helper to extract error message from DioException response body
          String getErrorMessage(dynamic error) {
            if (error is DioException) {
              final data = error.response?.data;
              if (data is Map && data['message'] != null) {
                return data['message'].toString().toLowerCase();
              }
            }
            return error.toString().toLowerCase();
          }
          
          final errorMsg = getErrorMessage(e);
          final errorStr = e.toString().toLowerCase();
          
          // Check for "only supports returning archived cards (?archived=true)"
          if ((errorMsg.contains('archived=true') || errorStr.contains('archived=true')) && archivedParam != 'true') {
             try {
                response = await _apiService.getCards(
                  teamId,
                  boardId: event.boardId,
                  listId: event.listId,
                  projectId: event.projectId,
                  epicId: event.epicId,
                  ownerId: ownerId,
                  status: event.status == 'all' ? null : event.status,
                  archived: 'true',
                  page: page,
                  limit: event.limit ?? 50,
                );
             } catch (e2) {
                rethrow;
             }
          }
          // If boardId was provided but failed (403/400), maybe it was an Epic ID?
          else if (event.boardId != null && (errorStr.contains('403') || errorStr.contains('400'))) {
             // Try with epicId and archived=true first (most common requirement)
             try {
                response = await _apiService.getCards(
                  teamId,
                  epicId: event.boardId, // Use boardId value as epicId
                  ownerId: ownerId,
                  status: event.status == 'all' ? null : event.status,
                  archived: 'true', // Start with archived=true since API often requires it
                  page: page,
                  limit: event.limit ?? 50,
                );
             } catch (e2) {
                // If archived=true also failed, try archived=false as last resort
                try {
                   response = await _apiService.getCards(
                     teamId,
                     epicId: event.boardId,
                     ownerId: ownerId,
                     status: event.status == 'all' ? null : event.status,
                     archived: 'false',
                     page: page,
                     limit: event.limit ?? 50,
                   );
                } catch (e3) {
                   rethrow;
                }
             }
          } else {
            rethrow;
          }
        }
      }

      final newCards = response.cards;
      final mergedCards = page > 1 ? [...oldCards, ...newCards] : newCards;

      emit(CardLoadSuccess(
        cards: mergedCards,
        hasMore: response.total != null && mergedCards.length < response.total!,
        currentPage: response.page ?? page,
      ));
    } catch (e) {
      debugPrint('CardBloc error loading cards: $e');
      if (e is DioException) {
        debugPrint('Dio error details: ${e.response?.data}');
        debugPrint('Request URI: ${e.requestOptions.uri}');
        debugPrint('Request body: ${e.requestOptions.data}');
      }
      
      String errorMessage = 'Failed to load cards';
      
      if (e is DioException) {
        final serverMessage = e.response?.data?['message']?.toString();
        if (serverMessage != null && serverMessage.isNotEmpty) {
          errorMessage = serverMessage;
        } else if (e.toString().contains('network')) {
          errorMessage = 'No internet connection';
        } else if (e.toString().contains('timeout')) {
          errorMessage = 'Connection timeout';
        } else if (e.response?.statusCode == 400) {
          errorMessage = 'Invalid request (400): ${e.response?.data}';
        } else {
          errorMessage = 'API Error ${e.response?.statusCode}: ${e.message}';
        }
      } else {
        errorMessage = 'Error: ${e.toString()}';
      }
      
      emit(CardLoadFailure(error: errorMessage));
    }
  }

  Future<void> _onCreateCard(
    CreateCard event,
    Emitter<CardState> emit,
  ) async {
    final currentState = state;
    try {
      final teamId = event.teamId ?? await _storageService.getTeamId();
      if (teamId == null) {
        emit(CardOperationFailure(
          error: 'Team ID not found',
          previousState: currentState,
        ));
        return;
      }

      final CreateCardRequest request = event.request ??
          CreateCardRequest(
            title: event.title ?? '',
            content: event.description,
            boardId: event.boardId ?? '',
            listId: event.listId,
            ownerId: event.assignedTo,
            tags: event.tags,
            status: event.status,
          );

      final response = await _apiService.createCard(teamId, request);

      if (currentState is CardLoadSuccess) {
        final updatedCards = [response.card, ...currentState.cards];
        emit(currentState.copyWith(cards: updatedCards));
      }

      emit(CardOperationSuccess(
        message: 'Card created successfully',
        previousState: currentState,
      ));
    } catch (e) {
      String errorMessage = 'Failed to create card';

      if (e.toString().contains('network')) {
        errorMessage = 'No internet connection';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Authentication required';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Access denied';
      } else if (e.toString().contains('400')) {
        errorMessage = 'Invalid card data';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error occurred';
      }

      emit(CardOperationFailure(
        error: errorMessage,
        previousState: currentState,
      ));
    }
  }

  Future<void> _onUpdateCard(
    UpdateCard event,
    Emitter<CardState> emit,
  ) async {
    final currentState = state;
    try {
      final teamId = await _storageService.getTeamId();
      if (teamId == null) {
        emit(CardOperationFailure(
          error: 'Team ID not found',
          previousState: currentState,
        ));
        return;
      }

      final UpdateCardRequest request = event.request ??
          UpdateCardRequest(
            title: event.title,
            content: event.description,
            listId: event.listId,
            status: event.status,
            ownerId: event.assignedTo,
            tags: event.tags,
          );

      final response =
          await _apiService.updateCard(teamId, event.cardId, request);

      if (currentState is CardLoadSuccess) {
        final updatedCards = currentState.cards.map((card) {
          return card.id == event.cardId ? response.card : card;
        }).toList();
        emit(currentState.copyWith(cards: updatedCards));
      }

      if (currentState is CardDetailsLoaded &&
          currentState.card.id == event.cardId) {
        emit(CardDetailsLoaded(card: response.card));
      }

      emit(CardOperationSuccess(
        message: 'Card updated successfully',
        previousState: currentState,
      ));
    } catch (e) {
      String errorMessage = 'Failed to update card';

      if (e.toString().contains('network')) {
        errorMessage = 'No internet connection';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Authentication required';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Access denied';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Card not found';
      } else if (e.toString().contains('400')) {
        errorMessage = 'Invalid card data';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error occurred';
      }

      emit(CardOperationFailure(
        error: errorMessage,
        previousState: currentState,
      ));
    }
  }

  Future<void> _onDeleteCard(
    DeleteCard event,
    Emitter<CardState> emit,
  ) async {
    final currentState = state;
    try {
      final teamId = await _storageService.getTeamId();
      if (teamId == null) {
        emit(CardOperationFailure(
          error: 'Team ID not found',
          previousState: currentState,
        ));
        return;
      }

      await _apiService.deleteCard(teamId, event.cardId);

      if (currentState is CardLoadSuccess) {
        final updatedCards = currentState.cards
            .where((card) => card.id != event.cardId)
            .toList();
        emit(currentState.copyWith(cards: updatedCards));
      }

      emit(CardOperationSuccess(
        message: 'Card deleted successfully',
        previousState: currentState,
      ));
    } catch (e) {
      String errorMessage = 'Failed to delete card';

      if (e.toString().contains('network')) {
        errorMessage = 'No internet connection';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Authentication required';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Access denied';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Card not found';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error occurred';
      }

      emit(CardOperationFailure(
        error: errorMessage,
        previousState: currentState,
      ));
    }
  }

  Future<void> _onMoveCard(
    MoveCard event,
    Emitter<CardState> emit,
  ) async {
    final currentState = state;
    try {
      final teamId = await _storageService.getTeamId();
      if (teamId == null) {
        emit(CardOperationFailure(
          error: 'Team ID not found',
          previousState: currentState,
        ));
        return;
      }

      final UpdateCardRequest updateRequest = UpdateCardRequest(
        listId: event.newListId,
      );

      final response =
          await _apiService.updateCard(teamId, event.cardId, updateRequest);

      if (currentState is CardLoadSuccess) {
        final updatedCards = currentState.cards.map((card) {
          return card.id == event.cardId ? response.card : card;
        }).toList();
        emit(currentState.copyWith(cards: updatedCards));
      }

      emit(CardOperationSuccess(
        message: 'Card moved successfully',
        previousState: currentState,
      ));
    } catch (e) {
      String errorMessage = 'Failed to move card';

      if (e.toString().contains('network')) {
        errorMessage = 'No internet connection';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Authentication required';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Access denied';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Card not found';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error occurred';
      }

      emit(CardOperationFailure(
        error: errorMessage,
        previousState: currentState,
      ));
    }
  }

  Future<void> _onGetCardDetails(
    GetCardDetails event,
    Emitter<CardState> emit,
  ) async {
    try {
      final teamId = await _storageService.getTeamId();
      if (teamId == null) {
        emit(const CardLoadFailure(error: 'Team ID not found'));
        return;
      }

      final response = await _apiService.getCard(teamId, event.cardId);
      
      // Fetch team members early to support mentions
      await _fetchAndCacheUsers(teamId);
      
      emit(CardDetailsLoaded(card: response.card));
    } catch (e) {
      String errorMessage = 'Failed to load card details';

      if (e.toString().contains('network')) {
        errorMessage = 'No internet connection';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Authentication required';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Access denied';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Card not found';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error occurred';
      }

      emit(CardLoadFailure(error: errorMessage));
    }
  }

  Future<void> _onAddCardComment(
    AddCardComment event,
    Emitter<CardState> emit,
  ) async {
    final currentState = state;
    try {
      final teamId = await _storageService.getTeamId();
      if (teamId == null) {
        emit(const CardLoadFailure(error: 'Team ID not found'));
        return;
      }

      // Fetch and cache users if not already cached
      await _fetchAndCacheUsers(teamId);

      final response =
          await _apiService.addCardComment(teamId, event.request);
      
      // Enrich the new comment with user name
      final enrichedComment = _enrichCommentsWithUserNames([response.comment]).first;

      if (state is CardDetailsLoaded) {
        final current = (state as CardDetailsLoaded).card;
        final updatedComments =
            _upsertComment(current.comments ?? [], enrichedComment);
        emit(CardDetailsLoaded(
            card: current.copyWith(comments: updatedComments)));
      }

      emit(CardCommentsLoaded(comments: [enrichedComment]));
      emit(CardOperationSuccess(
          message: 'Comment added', previousState: currentState));
    } catch (e) {
      emit(CardLoadFailure(error: 'Failed to add comment: ${e.toString()}'));
    }
  }

  Future<void> _onLoadCardComments(
    LoadCardComments event,
    Emitter<CardState> emit,
  ) async {
    try {
      final teamId = await _storageService.getTeamId();
      if (teamId == null) {
        emit(const CardLoadFailure(error: 'Team ID not found'));
        return;
      }

      // Fetch and cache users if not already cached
      await _fetchAndCacheUsers(teamId);

      final response = await _apiService.getCardComments(teamId, event.cardId);
      
      // Enrich comments with user names from cache
      // Comments are already nested from API (children.child_comments -> replies)
      final enrichedComments = _enrichCommentsWithUserNames(response.comments);

      if (state is CardDetailsLoaded) {
        final current = (state as CardDetailsLoaded).card;
        emit(CardDetailsLoaded(
            card: current.copyWith(comments: enrichedComments)));
      }

      emit(CardCommentsLoaded(comments: enrichedComments));
    } catch (e) {
      emit(CardLoadFailure(error: 'Failed to load comments: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteCardComment(
    DeleteCardComment event,
    Emitter<CardState> emit,
  ) async {
    try {
      final teamId = await _storageService.getTeamId();
      if (teamId == null) {
        emit(const CardLoadFailure(error: 'Team ID not found'));
        return;
      }

      await _apiService.deleteCardComment(
          teamId, event.commentId);

      if (state is CardDetailsLoaded) {
        final current = (state as CardDetailsLoaded).card;
        final updated =
            _removeCommentTree(current.comments ?? [], event.commentId);
        emit(CardDetailsLoaded(card: current.copyWith(comments: updated)));
      }

      emit(const CardOperationSuccess(
          message: 'Comment deleted', previousState: CardInitial()));
    } catch (e) {
      emit(CardLoadFailure(error: 'Failed to delete comment: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateCardComment(
    UpdateCardComment event,
    Emitter<CardState> emit,
  ) async {
    final prevState = state;
    try {
      final teamId = await _storageService.getTeamId();
      if (teamId == null) {
        emit(const CardLoadFailure(error: 'Team ID not found'));
        return;
      }

      final response = await _apiService.updateCardComment(
        teamId,
        event.commentId,
        event.request,
      );

      if (state is CardDetailsLoaded) {
        final current = (state as CardDetailsLoaded).card;
        final updated =
            _upsertComment(current.comments ?? [], response.comment);
        emit(CardDetailsLoaded(card: current.copyWith(comments: updated)));
      }

      emit(CardCommentsLoaded(comments: [response.comment]));
      emit(CardOperationSuccess(
          message: 'Comment updated', previousState: prevState));
    } catch (e) {
      emit(CardLoadFailure(error: 'Failed to update comment: ${e.toString()}'));
    }
  }

  Future<void> _onReplyToComment(
    ReplyToComment event,
    Emitter<CardState> emit,
  ) async {
    final prevState = state;
    try {
      final teamId = await _storageService.getTeamId();
      if (teamId == null) {
        emit(const CardLoadFailure(error: 'Team ID not found'));
        return;
      }

      // Fetch and cache users if not already cached
      await _fetchAndCacheUsers(teamId);

      final response =
          await _apiService.addCommentReply(teamId, event.parentCommentId, event.request);
      
      debugPrint('Reply added successfully: id=${response.comment.id}, parentId=${response.comment.parentCommentId}');

      // Reload all comments to ensure the reply appears in the UI
      // This is more reliable than trying to update the local state
      // because the state keeps changing (CardCommentsLoaded, CardAttachmentsLoaded, etc.)
      final cardId = event.request.cardId;
      if (cardId != null) {
        debugPrint('Reloading comments for card $cardId...');
        final commentsResponse = await _apiService.getCardComments(teamId, cardId);
        
        // Comments are already nested from API (children.child_comments -> replies)
        final enrichedComments = _enrichCommentsWithUserNames(commentsResponse.comments);
        
        // Update the appropriate state
        if (prevState is CardDetailsLoaded) {
          final current = prevState.card;
          emit(CardDetailsLoaded(card: current.copyWith(comments: enrichedComments)));
        } else {
          emit(CardCommentsLoaded(comments: enrichedComments));
        }
      }

      emit(CardOperationSuccess(
          message: 'Reply added', previousState: prevState));
    } catch (e) {
      emit(CardLoadFailure(error: 'Failed to add reply: ${e.toString()}'));
    }
  }

  Future<void> _onToggleCommentReaction(
    ToggleCommentReaction event,
    Emitter<CardState> emit,
  ) async {
    final prevState = state;
    try {
      final teamId = await _storageService.getTeamId();
      if (teamId == null) {
        emit(const CardLoadFailure(error: 'Team ID not found'));
        return;
      }

      final response = await _apiService.toggleCommentReaction(
        teamId,
        event.commentId,
        event.request,
      );

      if (state is CardDetailsLoaded) {
        final current = (state as CardDetailsLoaded).card;
        final updated =
            _upsertComment(current.comments ?? [], response.comment);
        emit(CardDetailsLoaded(card: current.copyWith(comments: updated)));
      }

      emit(CardCommentsLoaded(comments: [response.comment]));
      emit(CardOperationSuccess(
          message: 'Reaction updated', previousState: prevState));
    } catch (e) {
      // Handle 404 specifically - reactions endpoint not supported
      if (e is DioException && e.response?.statusCode == 404) {
        emit(const CardLoadFailure(
            error: 'Comment reactions are not supported yet. This feature will be available in a future update.'));
      } else {
        emit(CardLoadFailure(error: 'Failed to update reaction: ${e.toString()}'));
      }
    }
  }

  Future<void> _onLoadCardAttachments(
    LoadCardAttachments event,
    Emitter<CardState> emit,
  ) async {
    try {
      final teamId = await _storageService.getTeamId();
      if (teamId == null) {
        emit(const CardLoadFailure(error: 'Team ID not found'));
        return;
      }

      final response =
          await _apiService.getCardAttachments(teamId, event.cardId);

      if (state is CardDetailsLoaded) {
        final current = (state as CardDetailsLoaded).card;
        emit(CardDetailsLoaded(
            card: current.copyWith(attachments: response.attachments)));
      }

      emit(CardAttachmentsLoaded(attachments: response.attachments));
    } catch (e) {
      // Handle 404 errors gracefully - treat as "no attachments"
      if (e is DioException && e.response?.statusCode == 404) {
        // Card has no attachments or endpoint doesn't exist
        if (state is CardDetailsLoaded) {
          final current = (state as CardDetailsLoaded).card;
          emit(CardDetailsLoaded(
              card: current.copyWith(attachments: <Attachment>[])));
        }
        emit(const CardAttachmentsLoaded(attachments: <Attachment>[]));
        return;
      }
      
      // For other errors, show appropriate error message
      String errorMessage = 'Failed to load attachments';
      
      if (e is DioException) {
        if (e.toString().contains('network')) {
          errorMessage = 'No internet connection';
        } else if (e.toString().contains('timeout')) {
          errorMessage = 'Connection timeout';
        } else if (e.response?.statusCode == 401) {
          errorMessage = 'Authentication required';
        } else if (e.response?.statusCode == 403) {
          errorMessage = 'Access denied';
        } else if (e.response?.statusCode == 500) {
          errorMessage = 'Server error occurred';
        }
      }
      
      emit(CardLoadFailure(error: errorMessage));
    }
  }

  Future<void> _onUploadCardAttachment(
    UploadCardAttachment event,
    Emitter<CardState> emit,
  ) async {
    final previousState = state;
    try {
      final teamId = await _storageService.getTeamId();
      if (teamId == null) {
        emit(const CardLoadFailure(error: 'Team ID not found'));
        return;
      }

      final dioClient = DioClient(_storageService);
      final fileName = p.basename(event.file.path);
      final formData = FormData.fromMap({
        'file':
            await MultipartFile.fromFile(event.file.path, filename: fileName),
      });

      await dioClient.dio.post(
        '/$teamId/cards/${event.cardId}/attachments',
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) {
            emit(CardAttachmentUploadProgress(progress: sent / total));
          }
        },
      );

      final response =
          await _apiService.getCardAttachments(teamId, event.cardId);

      if (state is CardDetailsLoaded) {
        final current = (state as CardDetailsLoaded).card;
        emit(CardDetailsLoaded(
            card: current.copyWith(attachments: response.attachments)));
      }

      emit(CardAttachmentsLoaded(attachments: response.attachments));
      emit(CardOperationSuccess(
          message: 'Attachment uploaded', previousState: previousState));
    } catch (e) {
      emit(CardLoadFailure(error: 'Failed to upload attachment'));
    }
  }

  Future<void> _onDeleteCardAttachment(
    DeleteCardAttachment event,
    Emitter<CardState> emit,
  ) async {
    final currentState = state;
    try {
      final teamId = await _storageService.getTeamId();
      if (teamId == null) {
        emit(const CardLoadFailure(error: 'Team ID not found'));
        return;
      }

      await _apiService.deleteCardAttachment(
          teamId, event.cardId, event.attachmentId);

      if (state is CardDetailsLoaded) {
        final current = (state as CardDetailsLoaded).card;
        final updated = (current.attachments ?? <Attachment>[])
            .where((a) => a.id != event.attachmentId)
            .toList();
        emit(CardDetailsLoaded(card: current.copyWith(attachments: updated)));
      }

      emit(CardOperationSuccess(
          message: 'Attachment deleted', previousState: currentState));
    } catch (e) {
      emit(CardLoadFailure(error: 'Failed to delete attachment'));
    }
  }

  Future<void> _onDeleteMultipleAttachments(
    DeleteMultipleAttachments event,
    Emitter<CardState> emit,
  ) async {
    final currentState = state;
    try {
      final teamId = await _storageService.getTeamId();
      if (teamId == null) {
        emit(const CardLoadFailure(error: 'Team ID not found'));
        return;
      }

      for (final id in event.attachmentIds) {
        await _apiService.deleteCardAttachment(teamId, event.cardId, id);
      }

      if (state is CardDetailsLoaded) {
        final current = (state as CardDetailsLoaded).card;
        final updated = (current.attachments ?? [])
            .where((a) => !event.attachmentIds.contains(a.id))
            .toList();
        emit(CardDetailsLoaded(card: current.copyWith(attachments: updated)));
      }

      emit(CardOperationSuccess(
          message: 'Attachments deleted', previousState: currentState));
    } catch (e) {
      emit(CardOperationFailure(
          error: 'Failed to delete attachments', previousState: currentState));
    }
  }

  Future<void> _onRefreshCards(
    RefreshCards event,
    Emitter<CardState> emit,
  ) async {
    emit(CardLoadInProgress());

    try {
      final teamId = event.teamId;
      if (teamId.isEmpty) {
        emit(const CardLoadFailure(error: 'Team ID not found'));
        return;
      }

      final bool noBoardOrList = (event.boardId == null || event.boardId!.isEmpty) && 
                                 (event.listId == null || event.listId!.isEmpty);

      CardsResponse response;
      if (noBoardOrList) {
        // Same workaround as _onLoadCards: fetch via boards
        try {
          debugPrint('🔍 CardBloc Refresh Stage 1: Fetching via boards...');
          final boardsResponse = await _apiService.getBoards(
            teamId,
            archived: "false",
            page: 1,
            limit: 100,
          );
          
          final allCards = <Card>[];
          for (final board in boardsResponse.boards) {
            try {
              final boardCardsResponse = await _apiService.getCards(
                teamId,
                boardId: board.id,
                archived: "false",
                page: 1,
                limit: 1000,
              );
              allCards.addAll(boardCardsResponse.cards);
            } catch (e) {
              debugPrint('Failed to load cards for board ${board.id}: $e');
            }
          }
          
          response = CardsResponse(
            cards: allCards,
            total: allCards.length,
            page: 1,
            limit: allCards.length,
          );
          debugPrint('   - Refresh Success: ${allCards.length} cards aggregated');
        } catch (e) {
          debugPrint('   - Refresh Stage 1 failed: $e. Falling back to assigned cards...');
          // Fallback to ViewPreviewRequest
          final userId = await _storageService.getUserId();
          final request = ViewFilterBuilder()
             .withCardFilters(ViewCardFilters(
                hasStatus: true,
                archived: false,
                include: userId != null ? ViewIncludeFilters(members: [userId]) : null,
             ))
             .build();
          response = await _apiService.getAssignedCards(teamId, request);
        }
      } else {
        response = await _apiService.getCards(
          teamId,
          boardId: event.boardId,
          listId: event.listId,
          page: 1,
          limit: 1000,
        );
      }

      emit(CardLoadSuccess(
        cards: response.cards,
        hasMore:
            response.total != null && response.cards.length < response.total!,
        currentPage: response.page ?? 1,
      ));
    } catch (e) {
      String errorMessage = 'Failed to refresh cards';

      if (e.toString().contains('network')) {
        errorMessage = 'No internet connection';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Authentication required';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Access denied';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Cards not found';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error occurred';
      }

      emit(CardLoadFailure(error: errorMessage));
    }
  }

  Future<void> _onClearCardError(
    ClearCardError event,
    Emitter<CardState> emit,
  ) async {
    if (state is CardOperationFailure) {
      emit((state as CardOperationFailure).previousState);
    } else if (state is CardOperationSuccess) {
      emit((state as CardOperationSuccess).previousState);
    }
  }

  List<Comment> _upsertComment(List<Comment> existing, Comment updated, {int depth = 0}) {
    // Prevent stack overflow with deeply nested comments (max 10 levels)
    const maxDepth = 10;
    if (depth >= maxDepth) return existing;
    
    bool found = false;
    final List<Comment> result = existing.map((comment) {
      if (comment.id == updated.id) {
        found = true;
        return updated;
      }
      if (comment.replies != null && comment.replies!.isNotEmpty) {
        final updatedReplies = _upsertComment(comment.replies!, updated, depth: depth + 1);
        if (updatedReplies != comment.replies) {
          return comment.copyWith(replies: updatedReplies);
        }
      }
      return comment;
    }).toList();

    if (!found) {
      // If it's a reply, try to place under parent
      if (updated.parentCommentId != null && depth < maxDepth) {
        final List<Comment> placed = result.map((comment) {
          if (comment.id == updated.parentCommentId) {
            final replies = <Comment>[...(comment.replies ?? <Comment>[])]
              ..add(updated);
            found = true;
            return comment.copyWith(replies: replies);
          }
          if (comment.replies != null && comment.replies!.isNotEmpty) {
            final nested = _upsertComment(comment.replies!, updated, depth: depth + 1);
            if (nested != comment.replies) {
              found = true;
              return comment.copyWith(replies: nested);
            }
          }
          return comment;
        }).toList();
        if (found) return placed;
      }

      return [...result, updated];
    }

    return result;
  }

  List<Comment> _removeCommentTree(List<Comment> existing, String targetId, {int depth = 0}) {
    // Prevent stack overflow with deeply nested comments (max 10 levels)
    const maxDepth = 10;
    if (depth >= maxDepth) return existing;
    
    final List<Comment> result = [];
    for (final comment in existing) {
      if (comment.id == targetId) {
        continue;
      }
      if (comment.replies != null && comment.replies!.isNotEmpty) {
        final updatedReplies = _removeCommentTree(comment.replies!, targetId, depth: depth + 1);
        result.add(comment.copyWith(replies: updatedReplies));
      } else {
        result.add(comment);
      }
    }
    return result;
  }

  /// Build a comment tree from a flat list of comments
  /// Groups replies under their parent comments based on parentCommentId
  List<Comment> _buildCommentTree(List<Comment> flatComments) {
    debugPrint('Building comment tree from ${flatComments.length} flat comments');
    
    // Create a map for quick lookup
    final Map<String, Comment> commentMap = {};
    final List<Comment> rootComments = [];
    
    // First pass: create map of all comments
    for (final comment in flatComments) {
      commentMap[comment.id] = comment;
    }
    
    // Second pass: build tree structure
    for (final comment in flatComments) {
      if (comment.parentCommentId == null || comment.parentCommentId!.isEmpty) {
        // This is a root comment
        rootComments.add(comment);
      } else {
        // This is a reply - find parent and add to its replies
        final parentId = comment.parentCommentId!;
        final parent = commentMap[parentId];
        
        if (parent != null) {
          // Add this comment to parent's replies
          final updatedReplies = <Comment>[
            ...(parent.replies ?? <Comment>[]),
            comment,
          ];
          commentMap[parentId] = parent.copyWith(replies: updatedReplies);
        } else {
          // Parent not found - treat as root comment
          debugPrint('Parent comment $parentId not found for comment ${comment.id}, treating as root');
          rootComments.add(comment);
        }
      }
    }
    
    // Third pass: rebuild root comments with updated replies
    final result = rootComments.map((root) {
      return commentMap[root.id] ?? root;
    }).toList();
    
    debugPrint('Built comment tree: ${result.length} root comments');
    return result;
  }

  /// Fetch team users and cache their names
  /// Only fetches if cache is empty to avoid redundant API calls
  Future<void> _fetchAndCacheUsers(String teamId) async {
    if (_userCache.isNotEmpty) {
      debugPrint('User cache already populated with ${_userCache.length} users');
      return; // Already cached
    }
    
    try {
      debugPrint('Fetching team users for caching...');
      final response = await _apiService.getTeamUsers(teamId, limit: 1000);
      
      debugPrint('Received ${response.users.length} users from API');
      
      for (final user in response.users) {
        _userCache[user.id] = user.name;
        debugPrint('Cached user: ${user.id} -> ${user.name}');
      }
      
      debugPrint('Successfully cached ${_userCache.length} users');
    } catch (e) {
      debugPrint('Failed to fetch users for caching: $e');
      // Don't throw - we can still show comments with user IDs
    }
  }

  /// Enrich comments with user names from cache
  /// Recursively processes replies as well
  List<Comment> _enrichCommentsWithUserNames(List<Comment> comments) {
    debugPrint('Enriching ${comments.length} comments with user names');
    
    return comments.map((comment) {
      // Get user name from cache
      final userName = _userCache[comment.authorId];
      
      debugPrint('Comment ${comment.id}: authorId=${comment.authorId}, cached name=$userName, current name=${comment.authorName}');
      
      // Recursively enrich replies
      final enrichedReplies = comment.replies != null
          ? _enrichCommentsWithUserNames(comment.replies!)
          : null;
      
      // If we have a user name, update the comment
      if (userName != null && userName.isNotEmpty) {
        debugPrint('Enriching comment ${comment.id} with user name: $userName');
        return comment.copyWith(
          authorName: userName,
          replies: enrichedReplies,
        );
      }
      
      // If no user name but we have replies, update replies only
      if (enrichedReplies != null) {
        return comment.copyWith(replies: enrichedReplies);
      }
      
      debugPrint('No user name found for comment ${comment.id}, keeping: ${comment.authorName}');
      return comment;
    }).toList();
  }
}
