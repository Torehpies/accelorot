# DATA
- Business logic, API calls, caching, etc...
## MODELS
- Every data/object in database should have their own model.
- ex. machine_model.dart
## REPOSITORIES
- Handles business logic
- View models talks to repositories for the needed business logic
- Repositories uses one or more services to handle complex business logic
- Use abstract class for uniformity and expected interfaces
## SERVICES
- API calls for raw data from the database (CRUD)
- Lowest level in app or where data enters and exits
services/
| contracts/ -- abstract classes for services
| | machine_service.dart
| firebase/ -- implementations of contracts/services for firebase 
| | firebase_macAhine_service.dart -- implementation of machine_service for firebase
| local/ -- implementations of contracts for local db
| | local_machine_service.dart 


