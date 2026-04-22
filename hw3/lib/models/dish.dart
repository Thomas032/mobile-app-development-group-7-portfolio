class Dish {
  final String name;
  final double price;
  final String description;
  final String details;
  final String ingredients;
  final String imagePath;

  const Dish({
    required this.name,
    required this.price,
    required this.description,
    required this.details,
    required this.ingredients,
    required this.imagePath,
  });
}

const Map<String, List<Dish>> menu = {
  'Starters': [
    Dish(
      name: 'Bruschetta',
      price: 6.50,
      description: 'Toasted bread with tomatoes & basil',
      details:
          'Crispy sourdough topped with fresh roma tomatoes, garlic, and hand-torn basil. Drizzled with extra virgin olive oil and a pinch of sea salt.',
      ingredients:
          'Sourdough bread, roma tomatoes, garlic, fresh basil, extra virgin olive oil, sea salt, black pepper.',
      imagePath: 'assets/dishes/bruschetta.jpg',
    ),
    Dish(
      name: 'Antipasto Misto',
      price: 9.50,
      description: 'Selection of Italian cured meats & marinated vegetables',
      details:
          'A generous board of prosciutto di Parma, salame Milano, mortadella, marinated artichoke hearts, Castelvetrano olives, sun-dried tomatoes, and grilled peppers. Served with grissini and fresh focaccia.',
      ingredients:
          'Prosciutto di Parma, salame Milano, mortadella, artichoke hearts, Castelvetrano olives, sun-dried tomatoes, grilled peppers, focaccia, grissini.',
      imagePath: 'assets/dishes/antipasto_misto.jpg',
    ),
  ],
  'Main Courses': [
    Dish(
      name: 'Pizza Margherita',
      price: 11.00,
      description: 'San Marzano tomato, fior di latte, fresh basil',
      details:
          'Our Neapolitan-style pizza is baked in a wood-fired oven at 450 °C for 90 seconds. The dough is cold-fermented for 48 hours for a light, airy crust. Topped with crushed San Marzano tomatoes, hand-torn fior di latte mozzarella, and fresh basil added after baking.',
      ingredients:
          'Tipo 00 flour, water, sea salt, yeast, San Marzano tomatoes, fior di latte mozzarella, fresh basil, extra virgin olive oil.',
      imagePath: 'assets/dishes/pizza_margherita.jpg',
    ),
    Dish(
      name: 'Pasta Carbonara',
      price: 13.50,
      description: 'Classic Roman pasta with egg & guanciale',
      details:
          'Traditional Roman recipe with spaghetti, crispy guanciale, egg yolk, Pecorino Romano, and freshly cracked black pepper. No cream — just as it should be.',
      ingredients:
          'Spaghetti, guanciale, egg yolks, Pecorino Romano, black pepper.',
      imagePath: 'assets/dishes/pasta_carbonara.jpg',
    ),
    Dish(
      name: 'Branzino al Forno',
      price: 19.50,
      description: 'Oven-roasted sea bass with capers & cherry tomatoes',
      details:
          'Whole Mediterranean sea bass roasted in a hot oven with cherry tomatoes, capers, Taggiasca olives, white wine, and fresh thyme. Finished with a squeeze of Amalfi lemon and served with roasted potatoes.',
      ingredients:
          'Mediterranean sea bass, cherry tomatoes, capers, Taggiasca olives, white wine, fresh thyme, Amalfi lemon, garlic, extra virgin olive oil, roasted potatoes.',
      imagePath: 'assets/dishes/branzino_al_forno.jpg',
    ),
    Dish(
      name: 'Osso Buco alla Milanese',
      price: 22.00,
      description: 'Braised veal shank with gremolata & saffron risotto',
      details:
          'Cross-cut veal shank slow-braised in white wine, broth, and soffritto until fall-off-the-bone tender. Finished with a bright gremolata of lemon zest, garlic, and parsley. Served with a classic saffron risotto alla Milanese.',
      ingredients:
          'Veal shank, white wine, beef broth, onion, carrot, celery, canned tomatoes, lemon zest, garlic, flat-leaf parsley, Arborio rice, saffron, Parmigiano Reggiano, butter.',
      imagePath: 'assets/dishes/osso_buco.jpg',
    ),
  ],
  'Desserts': [
    Dish(
      name: 'Tiramisu',
      price: 7.00,
      description: 'Classic Italian dessert with mascarpone',
      details:
          'Layers of espresso-soaked ladyfingers and silky mascarpone cream, dusted with rich cocoa powder. Made fresh in-house every morning.',
      ingredients:
          'Savoiardi ladyfingers, mascarpone, espresso, egg yolks, sugar, dark cocoa powder.',
      imagePath: 'assets/dishes/tiramisu.jpg',
    ),
    Dish(
      name: 'Panna Cotta',
      price: 6.50,
      description: 'Silky vanilla cream with wild berry coulis',
      details:
          'Delicate set cream made with fresh double cream, vanilla bean, and just enough gelatin to hold its shape. Unmoulded tableside and finished with a vibrant coulis of wild strawberries, raspberries, and blackberries.',
      ingredients:
          'Double cream, whole milk, vanilla bean, sugar, gelatin, wild strawberries, raspberries, blackberries.',
      imagePath: 'assets/dishes/panna_cotta.jpg',
    ),
  ],
  'Drinks': [
    Dish(
      name: 'Sparkling Water',
      price: 2.50,
      description: '500 ml bottle',
      details: 'Chilled 500 ml sparkling mineral water.',
      ingredients: 'Sparkling mineral water.',
      imagePath: 'assets/dishes/sparkling_water.jpg',
    ),
    Dish(
      name: 'Limonata Artigianale',
      price: 4.50,
      description: 'House-made Amalfi lemon lemonade',
      details:
          'Freshly pressed Amalfi lemons, still water, a touch of cane sugar, and fresh mint. Made to order and served over ice.',
      ingredients: 'Amalfi lemons, still water, cane sugar, fresh mint, ice.',
      imagePath: 'assets/dishes/limonata.jpg',
    ),
    Dish(
      name: 'Aperol Spritz',
      price: 7.00,
      description: 'Aperol, Prosecco & a splash of soda',
      details:
          'The classic Italian aperitivo: three parts Prosecco DOC, two parts Aperol, one part soda water, served over ice with a slice of orange.',
      ingredients: 'Aperol, Prosecco DOC, soda water, orange slice, ice.',
      imagePath: 'assets/dishes/aperol_spritz.jpg',
    ),
    Dish(
      name: 'House Wine',
      price: 5.50,
      description: 'Red or white, 200 ml glass',
      details:
          'Our rotating house selection of Italian regional wines. Ask your waiter which varieties are available today.',
      ingredients: 'Italian regional wine (ask your waiter for today\'s selection).',
      imagePath: 'assets/dishes/house_wine.jpg',
    ),
  ],
};
