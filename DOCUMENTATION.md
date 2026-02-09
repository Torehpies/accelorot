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

## WRITING TESTS
- Use mockito package
### 1. Identify the target class and its dependencies.
a. What specific class are we testing (CUT class under test).
b. What abstract contracts does the CUT require in its constructor.

### 2. Define and generate mocks
a. Use @GenerateMocks: Add all necessary abstract contracts to the @GenerateMocks annotation in your test file.
b. Run build runner or just run this one so it constantly watches changes `dart run build_runner watch -d` and it will automatically generate `*.mocks.dart` files.
c. Initialize in your `setup()` method, initialize the mocks and inject them into the repository you are testing.

### 3. Arrange (define the scenario)
- define the specificc sequence of inputs yout mocks will return
- use `when()` function to define the behavior
a. Goal: simulate a succesful data fetch, a failure or an edge case
b. Data Stubbing: define the exact raw data, including technology specific types..

### 4. Act (code execution)
- call the single method on the Class Under Test that you intend to verify

### 5. Assert (verify the output)
- check the final output against your expectations.

### 6. Verify (check the interactions)
- use `verify()` to ensure the Class Under Test called its dependencies correctly. this verifies the business logic flow.
ex. verify if the certaian method is called exactly once, and was it called with the correct id?

Following this Arrange - Act - Assert (AAA) pattern using mocks ensure you are only testing the logic of one class at a time
