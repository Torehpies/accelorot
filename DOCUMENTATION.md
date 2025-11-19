# Accel-O-Rot
## UI LAYER
## DATA LAYER
- Business logic for the app.
#### Models
- Representation of documents/data in the database.
#### Repositories
- This is what view model talks to.
- Orchestrator/uses different services to do complicated business logic.
- Handles caching.
- Error handling.
#### Services
- Raw data handling CRUD for database.
### MODELS
#### user.dart
- Data in /users

#### team.dart
- Data in /teams

#### team_member.dart
- Data in /teams/{teamId}/members

#### pending_member.dart
- Data in /teams/{teamId}/pending_members

### REPOSITORIES
- 

### SERVICES
