import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../constants.dart';
import '../widgets/custom_font.dart';
import '../widgets/custom_dialogs.dart';
import '../widgets/custom_button.dart';
import '../widgets/post_card.dart';

import '../services/user_service.dart';
import '../services/post_service.dart';

import '../models/user.dart';
import '../models/post.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final PostService _postService = PostService();

  User? currentUser;

  List<Post> userPosts = [];

  bool isLoadingPosts = true;
  bool isFollowing = false;
  int followersCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // Load logged-in user and their posts
  Future<void> _loadUser() async {
    try {
      final user = await _userService.getUserData();

      if (!mounted) return;

      if (user == null) {
        setState(() {
          currentUser = null;
          userPosts = [];
          isLoadingPosts = false;
        });
        return;
      }

      // Get posts belonging to the logged-in user's ID
      final posts = await _postService.getPostsByUserId(user.id);

      if (!mounted) return;

      setState(() {
        currentUser = user;
        userPosts = posts;
        isLoadingPosts = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingPosts = false;
      });

      debugPrint('Error loading profile: $e');
    }
  }

  final Map<String, String> aboutInfo = {
    'Bio': 'coffee meg lover',
    'Location': 'Manila, Philippines',
    'Occupation': 'student only',
    'Website': 'https://hannahpadilla.dev',
  };

  final List<String> photos = [
    "https://static0.polygonimages.com/wordpress/wp-content/uploads/chorus/uploads/chorus_asset/file/12786939/adventure_time_stakes.jpg?w=1600&h=1200&fit=crop",
    "https://static.wikia.nocookie.net/adventuretimewithfinnandjake/images/8/8e/S7e2_bonnibel_and_Marceline_together.png/revision/latest?cb=20151106212703",
    "https://i.redd.it/wishing-i-could-live-in-marcelines-house-v0-m0oixhrvisi91.jpg?width=1920&format=pjpg&auto=webp&s=a5bc5ffc46ba6b1a6f68782f471c96f678c883fd",
    "https://static.wikia.nocookie.net/adventuretimewithfinnandjake/images/5/51/Marceline_and_Princess_Bubblegum_Domestic_Bliss.png/revision/latest/scale-to-width-down/1200?cb=20210703051731",
    "https://www.overlyanimated.com/wp-content/uploads/2015/11/Screen-Shot-2015-11-03-at-10.18.27-PM.png",
    "https://www.themarysue.com/wp-content/uploads/2020/11/perfect-episode-bubbline.jpg?fit=1200%2C675",
  ];

  @override
  Widget build(BuildContext context) {
    final String displayName =
        currentUser == null
            ? "Loading..."
            : currentUser!.firstName.isEmpty
                ? "Guest"
                : currentUser!.firstName;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // =========================
              // COVER PHOTO + PROFILE PIC
              // =========================

              Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl:
                          "https://static.wikia.nocookie.net/adventuretimewithfinnandjake/images/3/3f/Marceline%27s_House.png/revision/latest?cb=20120911035614",
                      fit: BoxFit.cover,
                      placeholder: (context, url) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorWidget: (context, url, error) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        );
                      },
                    ),
                  ),

                  Positioned(
                    bottom: -50,
                    left: 20,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl:
                                  currentUser?.image.isNotEmpty == true
                                      ? currentUser!.image
                                      : "https://via.placeholder.com/100",
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              placeholder: (context, url) {
                                return const CircularProgressIndicator();
                              },
                              errorWidget: (context, url, error) {
                                return const Icon(Icons.person);
                              },
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.grey[300],
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 55),

              // =========================
              // PROFILE DETAILS
              // =========================

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    CustomFont(
                      text: displayName,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black,
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        CustomFont(
                          text: '$followersCount',
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),

                        const SizedBox(width: 10),

                        const CustomFont(
                          text: 'followers',
                          fontSize: 15,
                          color: Colors.grey,
                        ),

                        const SizedBox(width: 10),

                        const Icon(
                          Icons.circle,
                          size: 5,
                          color: Colors.grey,
                        ),

                        const SizedBox(width: 5),

                        const CustomFont(
                          text: '1',
                          fontSize: 15,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),

                        const SizedBox(width: 5),

                        const CustomFont(
                          text: 'following',
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        CustomButton(
                          buttonName:
                              isFollowing ? 'Following' : 'Follow',
                          onPressed: () {
                            setState(() {
                              isFollowing = !isFollowing;

                              followersCount +=
                                  isFollowing ? 1 : -1;
                            });
                          },
                        ),

                        const SizedBox(width: 10),

                        CustomButton(
                          buttonName: 'Message',
                          onPressed: () {},
                          buttonType: 'outlined',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // =========================
              // TABS
              // =========================

              const TabBar(
                indicatorColor: FB_DARK_PRIMARY,
                tabs: [
                  Tab(text: 'Posts'),
                  Tab(text: 'About'),
                  Tab(text: 'Photos'),
                ],
              ),

              // =========================
              // TAB CONTENT
              // =========================

              SizedBox(
                height: 500,
                child: TabBarView(
                  children: [

                    // =====================
                    // POSTS
                    // =====================

                    _buildPosts(),

                    // =====================
                    // ABOUT
                    // =====================

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: aboutInfo.entries.map((entry) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 5,
                            ),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [

                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    '${entry.key}:',
                                    style: const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),

                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // =====================
                    // PHOTOS
                    // =====================

                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                        itemCount: photos.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              customShowImageDialog(
                                context,
                                imageUrl: photos[index],
                              );
                            },
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: photos[index],
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                                errorWidget:
                                    (context, url, error) {
                                  return const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================
  // BUILD USER POSTS
  // =============================

  Widget _buildPosts() {
    if (isLoadingPosts) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (userPosts.isEmpty) {
      return const Center(
        child: Text(
          'No posts yet.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: userPosts.length,
      itemBuilder: (context, index) {
        final post = userPosts[index];

        return NewsFeedCard(
  postId: post.id,
  userName: currentUser?.firstName ?? 'Guest',
          postContent: post.body,
          numOfLikes: post.likes,
          date: post.createdAt.isEmpty
              ? ''
              : post.createdAt,
          imageUrl: '',
          profileImageUrl:
              currentUser?.image ?? '',

          onLikeChanged: (newLikes) {
            setState(() {
              userPosts[index] = Post(
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
        );
      },
    );
  }
}