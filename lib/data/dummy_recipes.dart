import '../features/recipe/data/models/recipe_model.dart';

const List<RecipeModel> dummyRecipes = [
  RecipeModel(
    id: 1,
    title: 'Garlic Soy Chicken',
    category: 'Ayam',
    duration: '25 menit',
    emoji: '🍗',
    description: 'Ayam gurih dengan perpaduan bawang putih dan saus kecap yang sederhana.',
    ingredients: [
      '500 gram ayam',
      '3 siung bawang putih',
      '3 sdm kecap',
      '1 sdm minyak',
      'Garam secukupnya',
    ],
    instructions: [
      'Potong ayam menjadi beberapa bagian.',
      'Cincang bawang putih.',
      'Panaskan minyak dan tumis bawang putih.',
      'Masukkan ayam dan masak hingga matang.',
      'Tambahkan kecap dan aduk hingga merata.',
    ],
  ),

  RecipeModel(
    id: 2,
    title: 'Nasi Goreng Spesial',
    category: 'Nasi',
    duration: '20 menit',
    emoji: '🍚',
    description: 'Nasi goreng sederhana dengan telur dan bumbu rumahan.',
    ingredients: [
      '1 piring nasi',
      '1 butir telur',
      '2 siung bawang putih',
      '2 sdm kecap',
      'Garam secukupnya',
    ],
    instructions: [
      'Panaskan sedikit minyak.',
      'Tumis bawang putih hingga harum.',
      'Masukkan telur dan orak-arik.',
      'Masukkan nasi dan aduk.',
      'Tambahkan kecap dan garam.',
    ],
  ),

  RecipeModel(
    id: 3,
    title: 'Creamy Chicken Pasta',
    category: 'Pasta',
    duration: '30 menit',
    emoji: '🍝',
    description:
        'Pasta creamy dengan potongan ayam yang cocok untuk makan malam.',
    ingredients: [
      '200 gram pasta',
      '200 gram ayam',
      '150 ml susu',
      '2 siung bawang putih',
      'Keju secukupnya',
    ],
    instructions: [
      'Rebus pasta hingga matang.',
      'Potong ayam menjadi kecil.',
      'Tumis bawang putih dan ayam.',
      'Tambahkan susu.',
      'Masukkan pasta dan keju.',
    ],
  ),

  RecipeModel(
    id: 4,
    title: 'Beef Teriyaki',
    category: 'Daging',
    duration: '35 menit',
    emoji: '🥩',
    description: 'Daging sapi dengan saus teriyaki manis dan gurih.',
    ingredients: [
      '300 gram daging sapi',
      '1 bawang bombai',
      '3 sdm saus teriyaki',
      '1 sdm minyak',
    ],
    instructions: [
      'Iris tipis daging sapi.',
      'Iris bawang bombai.',
      'Panaskan minyak.',
      'Masukkan daging dan bawang.',
      'Tambahkan saus teriyaki.',
    ],
  ),

  RecipeModel(
    id: 5,
    title: 'Vegetable Stir Fry',
    category: 'Sayur',
    duration: '15 menit',
    emoji: '🥬',
    description: 'Tumis sayuran sederhana yang cepat dan mudah dibuat.',
    ingredients: ['Wortel', 'Brokoli', 'Kol', 'Bawang putih', 'Saus tiram'],
    instructions: [
      'Potong semua sayuran.',
      'Tumis bawang putih.',
      'Masukkan wortel dan brokoli.',
      'Tambahkan kol.',
      'Tambahkan saus tiram.',
    ],
  ),

  RecipeModel(
    id: 6,
    title: 'Chicken Curry',
    category: 'Ayam',
    duration: '40 menit',
    emoji: '🍛',
    description: 'Kari ayam hangat dengan kuah gurih dan rempah.',
    ingredients: [
      '500 gram ayam',
      '200 ml santan',
      'Bumbu kari',
      'Kentang',
      'Bawang merah',
    ],
    instructions: [
      'Potong ayam dan kentang.',
      'Tumis bumbu hingga harum.',
      'Masukkan ayam.',
      'Tambahkan santan.',
      'Masak hingga ayam matang.',
    ],
  ),

  RecipeModel(
    id: 7,
    title: 'Chocolate Pancake',
    category: 'Dessert',
    duration: '20 menit',
    emoji: '🥞',
    description:
        'Pancake lembut dengan rasa cokelat untuk sarapan atau dessert.',
    ingredients: [
      '150 gram tepung',
      '1 butir telur',
      '200 ml susu',
      'Cokelat bubuk',
      'Gula',
    ],
    instructions: [
      'Campurkan tepung dan cokelat.',
      'Tambahkan telur dan susu.',
      'Aduk hingga rata.',
      'Panaskan pan.',
      'Masak pancake hingga matang.',
    ],
  ),

  RecipeModel(
    id: 8,
    title: 'Beef Fried Rice',
    category: 'Nasi',
    duration: '25 menit',
    emoji: '🍳',
    description: 'Nasi goreng dengan potongan daging sapi dan bumbu sederhana.',
    ingredients: [
      '1 piring nasi',
      '150 gram daging sapi',
      '1 butir telur',
      'Kecap',
      'Bawang putih',
    ],
    instructions: [
      'Potong daging sapi.',
      'Tumis bawang putih.',
      'Masukkan daging.',
      'Tambahkan telur.',
      'Masukkan nasi dan kecap.',
    ],
  ),
];
