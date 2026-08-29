import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../widgets/post_card.dart';
import '../widgets/carousel_card.dart';
import '../services/post_service.dart';
import '../models/post.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final PostService _postService = PostService();

  List<Post> posts = [];
  bool isLoading = true;

  final List<Map<String, String>> carouselItems = [
    {
      "businessName": "Frankie's",
      "sponsorLabel": "Sponsored",
      "logo": "assets/images/frankies.png",
      "image": "assets/images/frankies1.jpeg",
      "description":
          "Craving wings? Try Frankie's famous Salted Egg Chicken and enjoy every bite!",
      "button": "Order Now",
    },
    {
      "businessName": "SaladStop!",
      "sponsorLabel": "Sponsored",
      "logo": "assets/images/salad.jpeg",
      "image": "assets/images/salad1.jpeg",
      "description":
          "Fresh, healthy, and delicious salads made just the way you like them.",
      "button": "Order Now",
    },
    {
      "businessName": "Stuff'd",
      "sponsorLabel": "Sponsored",
      "logo": "assets/images/stuffd.jpeg",
      "image": "assets/images/stuffd1.jpg",
      "description":
          "Enjoy delicious kebabs, burritos, and quesadillas packed with flavor.",
      "button": "Visit Us",
    },
    {
      "businessName": "Coraline",
      "sponsorLabel": "Sponsored",
      "logo": "assets/images/coraline.jpg",
      "image": "assets/images/coraline1.jpg",
      "description":
          "Experience Coraline on the big screen again. Book your tickets today!",
      "button": "Book Now",
    },
    {
      "businessName": "Amici",
      "sponsorLabel": "Sponsored",
      "logo": "assets/images/amici.jpeg",
      "image": "assets/images/amici1.jpg",
      "description":
          "Authentic Italian pasta, pizza, and desserts made for sharing.",
      "button": "Reserve Now",
    },
    {
      "businessName": "H&M",
      "sponsorLabel": "Sponsored",
      "logo": "assets/images/h&m.png",
      "image": "assets/images/h&m1.png",
      "description":
          "Discover the latest fashion trends and refresh your wardrobe today.",
      "button": "Shop Now",
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

// Loads posts from the API through PostService and updates the news feed.
  Future<void> _loadPosts() async {
    try {
      final loadedPosts = await _postService.getPosts();

      if (!mounted) return;

      setState(() {
        posts = loadedPosts;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      debugPrint('Error loading posts: $e');
    }
  }
// Builds the advertisement carousel displayed between posts.
  Widget _facebookAdCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 390,
        viewportFraction: 0.92,
        enlargeCenterPage: false,
        enableInfiniteScroll: true,
      ),
      items: carouselItems.map((item) {
        return CarouselCard(
          businessName: item["businessName"]!,
          sponsorLabel: item["sponsorLabel"]!,
          logoAsset: item["logo"]!,
          imageAsset: item["image"]!,
          description: item["description"]!,
          buttonText: item["button"]!,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (posts.isEmpty) {
      return const Center(
        child: Text(
          'No posts found.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NewsFeedCard(
  postId: post.id,
  userName: 'User ${post.userId}',
  postContent: post.body,
  numOfLikes: post.likes,
  date: post.createdAt,
  imageUrl: '',
  profileImageUrl: '',
  onLikeChanged: (newLikes) {
    setState(() {
      posts[index] = Post(
        id: post.id,
        postId: post.postId,
        userId: post.userId,
        body: post.body,
        likes: newLikes,
        dislikes: post.dislikes,
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
      );
    });
  },
),

            // Advertisement after each of the first 4 posts
            if (index < 4) ...[
              const SizedBox(height: 15),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Advertisement / Promotion",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              _facebookAdCarousel(),

              const SizedBox(height: 20),
            ],
          ],
        );
      },
    );
  }
}