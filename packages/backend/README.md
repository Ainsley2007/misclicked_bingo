# Bingo Backend API

A Dart Frog-based REST API for managing bingo games, teams, and proofs.

## Base URL

`http://localhost:8080` (development)

## Response Format

All API responses follow a consistent format.

### Success Response

```json
{
  "success": true,
  "data": {
    // Response data here
  }
}
```

### Error Response

```json
{
  "error": "Error message",
  "code": "ERROR_CODE",
  "details": {
    // Optional additional error details
  }
}
```

## HTTP Status Codes

- `200 OK` - Successful GET/PUT/PATCH request
- `201 Created` - Successful POST request
- `204 No Content` - Successful DELETE request
- `400 Bad Request` - Validation errors
- `401 Unauthorized` - Missing or invalid authentication
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `405 Method Not Allowed` - HTTP method not supported
- `500 Internal Server Error` - Server error

## Error Codes

- `UNAUTHORIZED` - Authentication required or failed
- `NOT_FOUND` - Requested resource not found
- `VALIDATION_ERROR` - Request validation failed
- `FORBIDDEN` - User lacks permission
- `GAME_NOT_STARTED` - Game has not started yet
- `GAME_ENDED` - Game has already ended
- `TEAM_FULL` - Team has reached maximum capacity
- `ALREADY_IN_TEAM` - User is already in a team
- `NOT_IN_TEAM` - User must be in a team
- `NOT_TEAM_CAPTAIN` - Action requires team captain role
- `INVALID_CREDENTIALS` - Login credentials invalid
- `RESOURCE_EXISTS` - Resource already exists
- `INTERNAL_ERROR` - Internal server error

## Architecture

### Service Layer

All business logic is encapsulated in services located in `/lib/services`:

- **GameService** - Game CRUD operations, returns `Game` objects
- **TeamsService** - Team management, returns `Team` objects
- **UserService** - User operations, returns `AppUser` objects
- **TilesService** - Tile completion and queries
- **ProofsService** - Proof uploads and management
- **BossService** - Boss data retrieval
- **ActivityService** - Activity tracking and stats
- **AuthService** - Discord OAuth and user authentication

### Dependency Injection

Services are automatically injected via Dart Frog middleware. All routes access services using:

```dart
final gameService = context.read<GameService>();
final userService = context.read<UserService>();
```

### Data Models

The API uses strongly-typed models from the `shared_models` package, shared between frontend and backend:

- `Game` - Game configuration and metadata
- `Team` - Team information
- `AppUser` - User profile data
- `BingoTile` - Tile definition with boss and unique items
- `TileProof` - Proof submission data
- `TileActivity` - Activity feed items
- `ProofStats` - Statistics aggregation

## Authentication

Authentication is handled via cookie-based JWT tokens. The `auth_token` cookie is automatically set after successful Discord OAuth login.

### Protected Routes

Most routes require authentication. The middleware automatically reads the JWT from cookies and provides the user ID in the request context.

## Endpoints

### Authentication

#### `GET /auth/discord/login`

Initiates Discord OAuth flow by redirecting to Discord authorization page.

**Response:**

- `302` Redirect to Discord OAuth

---

#### `GET /auth/discord/callback`

Handles Discord OAuth callback and sets authentication cookie.

**Query Parameters:**

- `code` (string, required) - Authorization code from Discord

**Response:**

- `302` Redirect to frontend with auth cookie set

**Errors:**

- `400` Missing authorization code
- `500` Authentication failed

---

#### `GET /auth/logout`

Logs out user by clearing authentication cookie.

**Response:**

```json
{
  "success": true,
  "data": {
    "message": "Logged out successfully"
  }
}
```

---

### User

#### `GET /me`

Get current authenticated user information.

**Authentication:** Required

**Response:**

```json
{
  "success": true,
  "data": {
    "id": "user-uuid",
    "discordId": "discord-id",
    "globalName": "Display Name",
    "username": "username",
    "avatar": "avatar-hash",
    "role": "user",
    "teamId": "team-uuid",
    "gameId": "game-uuid"
  }
}
```

**Errors:**

- `401` Unauthorized
- `404` User not found

---

### Games

#### `GET /games`

List all games.

**Authentication:** Required

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": "game-uuid",
      "code": "ABC123",
      "name": "Game Name",
      "teamSize": 5,
      "boardSize": 3,
      "gameMode": "blackout",
      "startTime": "2024-01-01T00:00:00.000Z",
      "endTime": "2024-01-02T00:00:00.000Z",
      "createdAt": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

---

#### `POST /games`

Create a new game.

**Authentication:** Required (Admin)

**Request Body:**

```json
{
  "name": "Game Name",
  "teamSize": 5,
  "boardSize": 3,
  "gameMode": "blackout",
  "startTime": "2024-01-01T00:00:00.000Z",
  "endTime": "2024-01-02T00:00:00.000Z",
  "tiles": [
    {
      "bossId": "boss-uuid",
      "description": "Optional description",
      "isAnyUnique": false,
      "isOrLogic": false,
      "anyNCount": 3,
      "points": 10,
      "uniqueItems": [
        {
          "itemName": "Item Name",
          "requiredCount": 1
        }
      ]
    }
  ]
}
```

**Response:** `201 Created`

```json
{
  "success": true,
  "data": {
    "id": "game-uuid",
    "code": "ABC123",
    "name": "Game Name",
    ...
  }
}
```

**Errors:**

- `400` Validation error (invalid game configuration)

---

#### `GET /games/:id`

Get game details by ID.

**Authentication:** Required

**Response:**

```json
{
  "success": true,
  "data": {
    "id": "game-uuid",
    "code": "ABC123",
    "name": "Game Name",
    "teamSize": 5,
    "boardSize": 3,
    "gameMode": "blackout",
    "startTime": "2024-01-01T00:00:00.000Z",
    "endTime": "2024-01-02T00:00:00.000Z",
    "createdAt": "2024-01-01T00:00:00.000Z"
  }
}
```

**Errors:**

- `404` Game not found

---

#### `PUT /games/:id`

Update game details.

**Authentication:** Required (Admin)

**Request Body:**

```json
{
  "name": "Updated Game Name"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "id": "game-uuid",
    "name": "Updated Game Name",
    ...
  }
}
```

**Errors:**

- `404` Game not found
- `400` Validation error

---

#### `DELETE /games/:id`

Delete a game.

**Authentication:** Required (Admin)

**Response:** `204 No Content`

---

#### `POST /games/:code/join`

Join a game by game code and create a team.

**Authentication:** Required

**Request Body:**

```json
{
  "teamName": "Team Name"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "game": { ... },
    "team": { ... }
  }
}
```

**Errors:**

- `400` Invalid game code or team name
- `404` Game not found

---

#### `GET /games/:id/activity`

Get recent activity for a game.

**Authentication:** Required

**Query Parameters:**

- `limit` (number, optional) - Maximum number of activities to return (default: 50)

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": "activity-id",
      "type": "PROOF_UPLOADED",
      "userId": "user-uuid",
      "username": "Username",
      "userAvatar": "avatar-hash",
      "tileId": "tile-uuid",
      "tileName": "Tile Name",
      "tileIconUrl": "https://...",
      "teamId": "team-uuid",
      "teamName": "Team Name",
      "teamColor": "#FF0000",
      "proofImageUrl": "https://...",
      "timestamp": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

---

#### `GET /games/:id/stats`

Get game statistics.

**Authentication:** Required

**Response:**

```json
{
  "success": true,
  "data": {
    "topProofUploaders": [
      {
        "userId": "user-uuid",
        "username": "Username",
        "avatar": "avatar-hash",
        "count": 10
      }
    ],
    "topTileCompleters": [...],
    "totalProofs": 100,
    "totalCompletions": 50
  }
}
```

---

### Tiles

#### `PUT /games/:gameId/tiles/:tileId`

Update a tile.

**Authentication:** Required (Admin)

**Request Body:**

```json
{
  "bossId": "boss-uuid",
  "description": "Tile description",
  "isAnyUnique": false,
  "isOrLogic": false,
  "anyNCount": 3,
  "uniqueItems": [
    {
      "itemName": "Item Name",
      "requiredCount": 1
    }
  ]
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "success": true
  }
}
```

**Errors:**

- `403` Admin access required
- `400` Validation error

---

#### `PUT /games/:gameId/tiles/:tileId/complete`

Toggle tile completion status.

**Authentication:** Required

**Response:**

```json
{
  "success": true,
  "data": {
    "status": "completed"
  }
}
```

**Errors:**

- `403` User must be in a team, game not started, or game ended
- `404` Game not found
- `400` Missing required proofs

---

#### `POST /games/:gameId/tiles/:tileId/uncomplete-all`

Uncomplete a tile for all teams.

**Authentication:** Required (Admin)

**Request Body:**

```json
{
  "deleteProofs": false
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "success": true
  }
}
```

**Errors:**

- `403` Admin access required

---

### Teams

#### `PATCH /teams/:id`

Update team details.

**Authentication:** Required (Team Captain)

**Request Body:**

```json
{
  "color": "#FF0000"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "id": "team-uuid",
    "gameId": "game-uuid",
    "name": "Team Name",
    "captainUserId": "user-uuid",
    "color": "#FF0000",
    "createdAt": "2024-01-01T00:00:00.000Z"
  }
}
```

**Errors:**

- `404` Team not found
- `403` Only team captain can update
- `400` Invalid color format

---

#### `DELETE /teams/:id`

Disband a team.

**Authentication:** Required (Team Captain)

**Response:** `204 No Content`

**Errors:**

- `404` Team not found
- `403` Only team captain can disband

---

### Bosses

#### `GET /bosses`

Get all bosses with their unique items.

**Authentication:** Required

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": "boss-uuid",
      "name": "Boss Name",
      "type": "NORMAL",
      "iconUrl": "https://...",
      "uniqueItems": ["Item 1", "Item 2"]
    }
  ]
}
```

---

### Proofs

#### `POST /proofs/upload-url`

Get a presigned URL for uploading proof images.

**Authentication:** Required

**Request Body:**

```json
{
  "gameId": "game-uuid",
  "fileName": "screenshot.png"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "uploadUrl": "https://...",
    "publicUrl": "https://...",
    "objectKey": "key"
  }
}
```

**Errors:**

- `403` User must be in a team
- `400` Missing required fields

---

### Public Endpoints

Public endpoints do not require authentication.

#### `GET /public/games`

List all public games.

**Response:** Same as `GET /games`

---

#### `GET /public/games/:id`

Get public game details.

**Response:** Same as `GET /games/:id`

---

#### `GET /public/games/:id/activity`

Get public game activity.

**Response:** Same as `GET /games/:id/activity`

---

#### `GET /public/games/:id/stats`

Get public game statistics.

**Response:** Same as `GET /games/:id/stats`

---

## Development

### Running Locally

```bash
cd packages/backend
dart run bin/server.dart
```

### Environment Variables

Required environment variables:

- `DISCORD_CLIENT_ID` - Discord OAuth client ID
- `DISCORD_CLIENT_SECRET` - Discord OAuth client secret
- `DISCORD_REDIRECT_URI` - Discord OAuth redirect URI
- `FRONTEND_ORIGIN` - Frontend URL for CORS
- `JWT_SECRET` - Secret key for JWT signing
- `R2_ACCOUNT_ID` - Cloudflare R2 account ID
- `R2_ACCESS_KEY_ID` - Cloudflare R2 access key
- `R2_SECRET_ACCESS_KEY` - Cloudflare R2 secret key
- `R2_BUCKET_NAME` - Cloudflare R2 bucket name
- `R2_PUBLIC_URL` - Public URL for R2 bucket

### Database

The backend uses Drift (SQLite) for local development. Database migrations are handled automatically.
