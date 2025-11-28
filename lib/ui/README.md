# UI
ui/
| core/ -- shared ui files such as common buttons, fields, app themes etc.
| | ui/
| | | primary_button.dart
| | themes/
| | | light_theme.dart
| <feature name>/ -- folder for each specific view/screen/feature ex. forgot_password
| | view_model/ -- ui logic for the certain screen and talks to repositories to do business logic
| | | forgot_password_view_model.dart
| | widgets/
| | | forgot_password_view.dart -- ui file itself talks to its own view_model for logic.
| | | <other related ui> -- ui files for this certain feature only or a remake of a shared ui widget
