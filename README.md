# Padilla Long Exam 2
# Models
-defines the structure of the data used by the application
-main models used are user.dart, post.dart, and comment.dart.
-use the fromJson() factory method to convert the JSON response from the API into Dart objects and toJson() method is also provided to convert the Dart objects back into JSON when needed which allows the rest of the application to work with structured Dart objects instead of directly handling JSON data.

# user model (user.dart) 
-stores information about the logged-in user, including the user ID, username, email, first name, last name, profile image, access token, and refresh token. 

# post model (post.dart) 
-represents the posts retrieved from the API and contains information such as the post ID, user ID, post body, likes, dislikes, and dates. 

# comment model (comment.dart) 
-represents comments associated with a post and contains the comment ID, post ID, user ID, comment body, and username.

# Services
-service layer is responsible for communicating with the API. 
-uses user_service.dart, post__service.dart, and comment_service.dart to separate API operations from the user interface.
-separating these operations into services keeps the HTTP requests and API processing outside of the screen files
-this makes the code easier to organize and maintain.

# user service (user_service.dart) 
-handles user-related operations such as logging in, retrieving saved user information, and logging out. 
-when user logs in successfully, returned user information is converted into a User object and saved locally using SharedPreferences. -saved information can later be retrieved by other screens that need information about the currently logged-in user.

# post service (post__service.dart) 
-handles retrieving posts from the API
-getPosts() function retrieves posts for the news feed, while getPostsByUserId() retrieves posts associated with a specific user. 
-API response is converted into Post objects before being returned to the screen.

# comment service handles (comment_service.dart)
-comment-related API operations
-getCommentsByPostId() function retrieves comments belonging to a specific post, while addComment() sends a new comment containing the post ID, user ID, and comment body to the API
-returned data is converted into a Comment object.

# Screens and Widgets
-responsible for displaying the data and responding to user interactions

# SplashScreen 
-uses UserService to check whether user information has already been saved locally
-if a user is found, the application proceeds to the home screen
-if no saved user is found, the application redirects to the login screen

# NewsFeedScreen 
-uses PostService to retrieve posts from the API. 
-returned Post objects are stored in the screen and passed to NewsFeedCard, which displays the post information. 
-NewsFeedCard also handles user interactions such as liking a post, opening the detailed post screen, and viewing comments.

# DetailScreen 
-provides a more detailed view of a selected post and handles the comment functionality
-when screen is opened, it uses CommentService to retrieve the comments associated with the selected post
-comments are then displayed using the CommentCard widget.
-when the user adds a comment, the DetailScreen first uses UserService to retrieve the currently logged-in user's information
-the user's ID is then passed together with the post ID and comment body to CommentService, after the API returns the new comment, it is converted into a Comment object and displayed on the screen.

# CommentCard (comment_card.dart)
-responsible only for displaying an individual comment
-receives a Comment object and uses its username and comment body to create the comment interface.


The Models to Services to Screens structure allows the application to separate data, API communication, and user interface responsibilities. Models define what the data looks like, services handle communication with the API and local storage, while screens and widgets use the returned model objects to display information to the user.
