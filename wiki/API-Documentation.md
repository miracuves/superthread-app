# API Documentation

Complete reference for Superthread API endpoints.

## Base URLs

```
Production: https://api.superthread.com/v1
WebSocket: wss://api.superthread.com/realtime
```

## Authentication

### POST /auth/login
Login with email and password.

### POST /auth/refresh
Refresh access token.

### POST /auth/logout
Logout and invalidate tokens.

## Cards

### GET /{teamId}/cards
List cards with filters.

### GET /{teamId}/cards/{cardId}
Get card details.

### POST /{teamId}/cards
Create new card.

### PUT /{teamId}/cards/{cardId}
Update card.

### DELETE /{teamId}/cards/{cardId}
Delete card.

### Comments & Attachments
- GET /{teamId}/cards/{cardId}/comments
- POST /{teamId}/cards/{cardId}/comments
- PUT /{teamId}/cards/{cardId}/comments/{commentId}
- DELETE /{teamId}/cards/{cardId}/comments/{commentId}
- POST /{teamId}/cards/{cardId}/attachments
- DELETE /{teamId}/cards/{cardId}/attachments/{attachmentId}

## Boards

### GET /{teamId}/boards
List boards.

### POST /{teamId}/boards
Create board.

### GET /{teamId}/boards/{boardId}
Get board details.

### PUT /{teamId}/boards/{boardId}
Update board.

### DELETE /{teamId}/boards/{boardId}
Delete board.

## Search

### GET /{teamId}/search
Advanced search across entities.

### GET /{teamId}/search/suggestions
Get search suggestions.

## Notifications

### GET /{teamId}/notifications
Get notification history.

### POST /{teamId}/notifications/{notificationId}/read
Mark as read.

## Error Codes

| Code | Description |
|------|-------------|
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 422 | Validation Error |
| 500 | Server Error |

---

*See [Data Models](Data-Models) for response models.*
