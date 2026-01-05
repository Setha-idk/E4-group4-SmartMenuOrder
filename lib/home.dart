import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lab3/consent/appbar.dart';
import 'package:lab3/consent/colors.dart';
import 'package:lab3/screen/recipe.dart';
import 'package:lab3/providers/get_provider.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  String selectedCategory = "All";

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final mealsAsync = ref.watch(mealsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appbar(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/background_img.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Text(
                    "Categories",
                    style: TextStyle(
                        fontSize: 20,
                        color: font,
                        fontFamily: 'ro',
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 120,
                  child: categoriesAsync.when(
                    data: (categories) {
                      return ListView.builder(
                        itemCount: categories.length + 1,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemBuilder: (context, index) {
                          bool isAll = index == 0;
                          var category = isAll ? null : categories[index - 1];
                          String name = isAll ? "All" : category!['category'];
                          String img = isAll ? "" : category!['categoryThumb'];
                          bool isSelected = selectedCategory == name;

                          return GestureDetector(
                            onTap: () => setState(() => selectedCategory = name),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? cardColor : background,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(5, 5))
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 70,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: isAll 
                                          ? null 
                                          : DecorationImage(
                                              image: NetworkImage(img),
                                              fit: BoxFit.contain,
                                            ),
                                      ),
                                      child: isAll 
                                        ? Icon(Icons.apps, size: 30, color: isSelected ? Colors.white : maincolor) 
                                        : null,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      name,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white : font),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => const Text("Error loading categories"),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  child: Text(
                    "Suggestions for you",
                    style: TextStyle(fontSize: 20, color: font, fontFamily: 'ro', fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 280, // Increased height to accommodate tags
                  child: mealsAsync.when(
                    data: (meals) {
                      final filtered = meals.where((m) {
                        if (selectedCategory == "All") return true;
                        return (m['category']?.toString() ?? "").contains(selectedCategory);
                      }).toList();
                      filtered.shuffle();
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: filtered.length > 5 ? 5 : filtered.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(right: 15, bottom: 5),
                          child: _buildMealCard(context, filtered[index]),
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => const Text("Error"),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  child: Text(
                    "Popular meals",
                    style: TextStyle(fontSize: 20, color: font, fontFamily: 'ro', fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                sliver: mealsAsync.when(
                  data: (meals) {
                    final filtered = meals.where((m) {
                      if (selectedCategory == "All") return true;
                      return (m['category']?.toString() ?? "").contains(selectedCategory);
                    }).toList();

                    return SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildMealCard(context, filtered[index]),
                        childCount: filtered.length,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 280, // Increased height to accommodate tags
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                    );
                  },
                  loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
                  error: (e, s) => const SliverToBoxAdapter(child: Text("Error")),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, Map<String, dynamic> meal) {
    final String category = meal['category'] ?? 'General';
    final String tags = meal['tags'] ?? ''; // Extract tags
    
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Recipe(meal: meal))),
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(5, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(image: NetworkImage(meal['mealThumb'] ?? ''), fit: BoxFit.cover),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                meal['meal'] ?? '', 
                maxLines: 1, 
                overflow: TextOverflow.ellipsis, 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                category,
                style: TextStyle(fontSize: 12, color: maincolor, fontWeight: FontWeight.bold),
              ),
            ),
            // Tag Display
            if (tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(
                  'tag: $tags',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: font.withValues(alpha: 0.6), fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
    );
  }
}