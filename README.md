# Hannah M. Padilla 
## INF233
## CTADMOBL Advance Mobile Programming

## Lab Activity 2

product.dart = model
Model
-represents the data 
-from json to dart 
-how data look
-Data

product_service.dart = service 
Service
-the one that communicates with the internet 
-GET, POST, API response, Decodes and Converts JSON
-like a messenger between app and API
-process of data
-API communication

Screen
-ask for the data 
-renders 
-display of data 
-User Interface


FutureBuilder
-waits for the API
-three situations (loading, something went wrong, successful)

Overall, application has separate responsibilities of handling data, communicating with the API, and displaying the user interface. The Model represents the product data, the Service handles communication with the API, and the Screen is responsible for displaying the data.

## Lab Activity 2
cart.dart - model
-represents the structure of the data received from the DummyJSON Cart API
-contains the cart ID, user ID, products, quantities, prices, totals, and other cart information
-inside this is CartProduct, that represents each product inside the cart.
-there is copyWith(), product's quantity can be updated without modifying the original object or affecting the other products in the cart. (nagrereset kasi ibang quantity kapag nag aadjust ng iba)

cart_service.dart - service
-responsible for communicating with the DummyJSON API.
-contains methods for 
retrieving carts = 
retrieving a specific user's cart = getCartByUserId() method uses the /carts/user/{userId}
adding products to a cart = addToCart() method sends the user ID, product ID, and quantity to /carts/add
updating cart quantities = updateCart() uses the PUT /carts/{cartId} endpoint with merge: true to update a product's quantity.


cart_screen.dart = screen
-responsible for displaying the cart information to the user
-screen loads, it calls _loadCart(), which passes widget.userId to CartService.getCartByUserId()
-JSON data is converted into a Cart object through Cart.fromJson()
-uses _cart.products to display each product, including its image, title, price, and quantity
-quantity buttons call _updateQuantity(), which communicates with the service and updates the corresponding product in the local cart state
-reuses the existing ProductDetailScreen
-When a user taps a product image or product information inside the cart, _openProduct() calls ProductService.getProductById(product.id)
-product returned by the API is then passed to ProductDetailScreen. This means the cart does not need its own separate product-detail screen;

The updated design pattern separates the cart into the model, service, and screen, where the model handles cart data, the service handles API requests, and the screen displays the cart and user interactions. For getById, the cart ID is used with the /carts/{cartId} endpoint to retrieve a specific cart, while /carts/user/{userId} is used when we want to retrieve the cart belonging to a specific user.
