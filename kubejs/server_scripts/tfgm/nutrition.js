"use strict";

const $BuiltInRegistries = Java.loadClass(
  "net.minecraft.core.registries.BuiltInRegistries",
);
const FOOD_MODS = new Set([
  "farmersdelight",
  "farmersdelight_tfc",
  "moredelight",
  "delightful",
  "cuisinedelight",
  "tfc_cuisine",
  "tfc_gourmet",
  "butchersdelightfoods",
  "rusticdelight",
  "survivorsdelight",
  "aquaculture",
  "survivorsaquaculture",
]);
const PROFILES = new Map();

function foods(namespace, paths, nutrients, decay) {
  paths
    .trim()
    .split(/\s+/)
    .forEach((path) => {
      PROFILES.set(`${namespace}:${path}`, {
        nutrients: nutrients,
        decay: decay,
      });
    });
}

const G = [1, 0, 0, 0, 0];
const F = [0, 1, 0, 0, 0];
const V = [0, 0, 1, 0, 0];
const P = [0, 0, 0, 1, 0];
const D = [0, 0, 0, 0, 1];
const GV = [1, 0, 1, 0, 0];
const GP = [1, 0, 0, 1, 0];
const GD = [1, 0, 0, 0, 1];
const GF = [1, 1, 0, 0, 0];
const FD = [0, 1, 0, 0, 1];
const VP = [0, 0, 1, 1, 0];
const VD = [0, 0, 1, 0, 1];
const GVP = [1, 0, 1, 1, 0];
const GPD = [1, 0, 0, 1, 1];
const GVD = [1, 0, 1, 0, 1];
const GFD = [1, 1, 0, 0, 1];
const GVPD = [1, 0, 1, 1, 1];
const NONE = [0, 0, 0, 0, 0];

// Farmer's Delight and its direct addons.
foods(
  "farmersdelight",
  "rice cooked_rice raw_pasta wheat_dough pie_crust",
  G,
  2,
);
foods(
  "farmersdelight",
  "cabbage cabbage_leaf onion tomato tomato_sauce pumpkin_slice",
  V,
  2,
);
foods(
  "farmersdelight",
  "minced_beef beef_patty chicken_cuts cooked_chicken_cuts bacon cooked_bacon cod_slice cooked_cod_slice salmon_slice cooked_salmon_slice mutton_chops cooked_mutton_chops ham smoked_ham bone_broth",
  P,
  2.5,
);
foods("farmersdelight", "milk_bottle", D, 1.5);
foods(
  "farmersdelight",
  "apple_cider melon_juice fruit_salad melon_popsicle",
  F,
  1.5,
);
foods(
  "farmersdelight",
  "mixed_salad nether_salad vegetable_soup pumpkin_soup ratatouille gleaming_salad",
  V,
  1.5,
);
foods(
  "farmersdelight",
  "fried_egg barbecue_stick chicken_soup fish_stew baked_cod_stew grilled_salmon roast_chicken honey_glazed_ham roasted_mutton_chops",
  P,
  2.25,
);
foods(
  "farmersdelight",
  "egg_sandwich chicken_sandwich hamburger bacon_sandwich mutton_wrap dumplings cabbage_rolls salmon_roll cod_roll kelp_roll kelp_roll_slice",
  GP,
  2,
);
foods(
  "farmersdelight",
  "stuffed_potato stuffed_pumpkin steak_and_potatoes shepherds_pie",
  GVP,
  2,
);
foods(
  "farmersdelight",
  "fried_rice mushroom_rice noodle_soup onion_soup vegetable_noodles",
  GV,
  1.75,
);
foods(
  "farmersdelight",
  "beef_stew bacon_and_eggs pasta_with_meatballs pasta_with_mutton_chop squid_ink_pasta",
  GVP,
  2,
);
foods("farmersdelight", "cake_slice chocolate_pie_slice hot_cocoa", GD, 1.5);
foods(
  "farmersdelight",
  "apple_pie_slice sweet_berry_cheesecake_slice",
  GFD,
  1.5,
);
foods("farmersdelight", "pumpkin_pie_slice", GVD, 1.5);
foods("farmersdelight", "glow_berry_custard", FD, 1.5);
foods("farmersdelight", "sweet_berry_cookie", GF, 1.5);
foods("farmersdelight", "honey_cookie", G, 1.5);

foods("moredelight", "bread_slice toast", G, 2);
foods("moredelight", "toast_with_honey", G, 1.5);
foods(
  "moredelight",
  "toast_with_sweet_berries toast_with_glow_berries toast_with_blueberries chocolate_popsicle",
  GF,
  1.5,
);
foods(
  "moredelight",
  "toast_with_cheese toast_with_chocolate toast_with_peanut_butter",
  GD,
  1.5,
);
foods(
  "moredelight",
  "diced_potatoes mashed_potatoes carrot_soup tomato_sandwich potato_salad",
  V,
  1.75,
);
foods("moredelight", "omelette toast_with_egg", P, 2);
foods(
  "moredelight",
  "cooked_rice_with_beef cooked_rice_with_chicken_cuts cooked_rice_with_porkchop diced_potatoes_with_beef diced_potatoes_with_chicken_cuts diced_potatoes_with_porkchop chicken_sandwich_with_egg_and_tomato egg_with_bacon_sandwich simple_hamburger steak_sandwich steak_with_egg_sandwich porkchop_sandwich",
  GVP,
  2,
);
foods(
  "moredelight",
  "creamy_pasta_with_chicken_cuts creamy_pasta_with_ham hamburger_with_cheese hamburger_with_egg loaded_hamburger",
  GPD,
  2,
);
foods("moredelight", "diced_potatoes_with_egg_and_tomato chicken_salad", VP, 2);

// Cuisine Delight's recipes state the ingredients in their output names.
foods("cuisinedelight", "fried_egg", P, 2);
foods(
  "cuisinedelight",
  "fried_mushroom vegetable_fried_rice vegetable_pasta vegetable_platter",
  GV,
  1.75,
);
foods("cuisinedelight", "fried_pasta fried_rice", G, 1.75);
foods(
  "cuisinedelight",
  "fried_meat_and_melon ham_fried_rice meat_fried_rice meat_pasta meat_platter meat_with_seafood mixed_fried_rice mixed_pasta seafood_fried_rice seafood_pasta seafood_platter",
  GP,
  2,
);
foods(
  "cuisinedelight",
  "meat_with_vegetables seafood_with_vegetables scrambled_egg_and_tomato suspicious_mix",
  VP,
  2,
);

// Survivor's Delight only adds a player food directly; its other food support
// is tags and recipes for the namespaces covered above.
foods("survivorsdelight", "golden_carrot", V, 1.5);

// Butcher's Delight Foods: every listed item is a cut of meat.
foods(
  "butchersdelightfoods",
  "sheeploin beeftenderloin goat_loin porkloin sheepshank ham llamma_ribs beefribs goat_shank llama_loin legcow sheeprack goatrack porkribs llama_leg",
  P,
  3,
);
foods(
  "butchersdelightfoods",
  "cookedsheepshank coockedbeeftenderloin cooked_llama_loin cooked_goat_loin cooked_llama_leg cookedbeefribs cooked_goat_rack cookedporkloin cooked_goat_shank cooked_leg_cow cookedporkribs cooked_ham cooked_llama_ribs cooked_sheeploin cookedsheeprack",
  P,
  2.25,
);

// Aquaculture fish are explicitly tagged as raw TFC meat by Survivor's
// Aquaculture, but do not expose vanilla FoodProperties.
foods(
  "aquaculture",
  "atlantic_cod blackfish pacific_halibut atlantic_halibut atlantic_herring pink_salmon pollock rainbow_trout bayad boulti capitaine synodontis smallmouth_bass bluegill brown_trout carp catfish gar minnow muskellunge perch arapaima piranha tambaqui brown_shrooma red_shrooma jellyfish red_grouper tuna fish_fillet_raw fish_fillet_cooked",
  P,
  3,
);
foods("aquaculture", "sushi", GP, 1.75);
foods("aquaculture", "turtle_soup", VP, 2);

// Rustic Delight.
foods(
  "rusticdelight",
  "bell_pepper_green bell_pepper_red bell_pepper_yellow bell_pepper_slice_green bell_pepper_slice_red bell_pepper_slice_yellow roasted_bell_pepper_green roasted_bell_pepper_red roasted_bell_pepper_yellow roasted_bell_pepper_slice_green roasted_bell_pepper_slice_red roasted_bell_pepper_slice_yellow potato_slices baked_potato_slices fried_mushrooms",
  V,
  2,
);
foods(
  "rusticdelight",
  "calamari calamari_slice cooked_calamari cooked_calamari_slice fried_calamari fried_chicken coffee_braised_beef",
  P,
  2.5,
);
foods(
  "rusticdelight",
  "bell_pepper_pasta bell_pepper_roll_green bell_pepper_roll_red bell_pepper_roll_yellow spring_rolls fried_dumplings",
  GV,
  1.75,
);
foods("rusticdelight", "calamari_roll", GP, 1.75);
foods(
  "rusticdelight",
  "bell_pepper_soup stuffed_bell_pepper_green stuffed_bell_pepper_red stuffed_bell_pepper_yellow potato_salad sweet_salad",
  V,
  1.75,
);
foods(
  "rusticdelight",
  "batter fried_dough pancake chocolate_pancake pumpkin_pancake honey_pancake cherry_blossom_pancake vegetable_pancake",
  G,
  1.75,
);
foods(
  "rusticdelight",
  "cherry_blossom_cheesecake_slice syrup_cheesecake_slice milk_coffee",
  GD,
  1.5,
);
foods(
  "rusticdelight",
  "fruit_beignet cherry_blossom_cookie coffee_cookie syrup_cookie",
  G,
  1.5,
);
foods("rusticdelight", "cherry_blossom_roll", G, 1.5);
foods(
  "rusticdelight",
  "coffee chocolate_coffee dark_coffee honey_coffee roasted_coffee_beans golden_coffee_beans syrup_coffee cooking_oil",
  NONE,
  1,
);
foods("rusticdelight", "syrup syrup_sandwich", G, 1.5);

// Delightful's crops, meat, and composed meals.
foods(
  "delightful",
  "acorn roasted_acorn nut_dough honey_glazed_walnut rock_candy source_berry_cookie smore",
  G,
  2,
);
foods("delightful", "cantaloupe_slice salmonberries", F, 2);
foods(
  "delightful",
  "cactus_flesh cactus_steak cactus_soup cactus_soup_cup cactus_chili field_salad",
  V,
  1.75,
);
foods(
  "delightful",
  "aged_roe caviar animal_fat raw_goat cooked_goat venison_chops cooked_venison_chops venison_stew venison_stew_cup crab_rangoon sinigang sinigang_cup mutton_pie_slice",
  P,
  2.5,
);
foods(
  "delightful",
  "cantaloupe_bread chorus_muffin nut_butter_and_jam_sandwich roe_blini roe_roll salmon_and_roe_blini chunkwich",
  GP,
  1.75,
);
foods(
  "delightful",
  "cheeseburger deluxe_cheeseburger coconut_curry stuffed_cantaloupe",
  GVP,
  2,
);
foods(
  "delightful",
  "baklava_slice blueberry_pie_slice chorus_pie_slice gloomgourd_pie_slice green_apple_pie_slice mulberry_pie_slice passion_fruit_tart_slice salmonberry_pie_slice source_berry_pie_slice",
  GVD,
  1.5,
);
foods(
  "delightful",
  "matcha_ice_cream matcha_latte matcha_milkshake salmonberry_ice_cream salmonberry_milkshake source_berry_ice_cream source_berry_milkshake berry_matcha_latte",
  D,
  1.5,
);
foods(
  "delightful",
  "cantaloupe_gummy matcha_gummy salmonberry_gummy source_berry_gummy cantaloupe_popsicle glow_jam_cookie",
  F,
  1.5,
);
foods("delightful", "cooked_marshmallow_stick marshmallow_stick", G, 1.5);
foods("delightful", "wrapped_cantaloupe", F, 1.5);
foods(
  "delightful",
  "azalea_tea lavender_tea green_tea_leaf matcha ender_nectar long_prickly_pear_juice prickly_pear_juice animal_oil_bottle nut_butter_bottle jam_jar glow_jam_jar",
  NONE,
  1,
);

// TFC Gourmet: profiles follow the historical parent recipes at the last
// commit before upstream removed this mod (b8310fd2^).
foods(
  "tfc_gourmet",
  "ox_milk_bucket sheep_milk_bucket alpaca_milk_bucket curdled_ox_milk_bucket curdled_sheep_milk_bucket curdled_alpaca_milk_bucket ox_curd sheep_curd alpaca_curd ox_brinza sheep_brinza alpaca_brinza ox_brinza_slice sheep_brinza_slice alpaca_brinza_slice tzatziki syrniki raw_syrniki",
  D,
  1.5,
);
foods(
  "tfc_gourmet",
  "plant_mix sliced_cabbage adjika sauerkraut kimchi greek_salad hummus raw_falafel falafel gazpacho ratatouille fresh_onion_soup potato_stew pea_soup minestrone schi",
  V,
  1.75,
);
foods("tfc_gourmet", "adjika_bread", GV, 1.75);
foods("tfc_gourmet", "lent_soup", VP, 1.75);
foods("tfc_gourmet", "fresh_onion_soup_bread", GVD, 1.75);
foods(
  "tfc_gourmet",
  "dried_chamomile_leaves dried_mint_leaves dried_nettle_leaves dried_rosehip_leaves cocoa_bucket coffee_bucket compote_bucket kvass_bucket lemonade_bucket nalivka_bucket tea_chamomile_bucket tea_mint_bucket tea_nettle_bucket tea_rosehip_bucket",
  NONE,
  1,
);
foods(
  "tfc_gourmet",
  "porridge porridge_with_honey porridge_with_fruits mamaliga raw_crepes crepes raw_oladyi oladyi raw_croissants croissants",
  G,
  1.75,
);
foods(
  "tfc_gourmet",
  "margarita_pizza four_cheeses_pizza raw_margarita_pizza raw_four_cheeses_pizza raw_khachapuri khachapuri raw_quiche quiche tiramisu",
  GD,
  1.75,
);
foods(
  "tfc_gourmet",
  "pepperoni_pizza hawaiian_pizza four_meats_pizza neapolitano_pizza raw_pepperoni_pizza raw_hawaiian_pizza raw_four_meats_pizza raw_neapolitano_pizza raw_bratwurst bratwurst raw_bulgogi bulgogi raw_kiev_cutlets kiev_cutlets raw_tandoori_chicken tandoori_chicken raw_tonkatsu tonkatsu raw_takoyaki takoyaki",
  GP,
  2.25,
);
foods(
  "tfc_gourmet",
  "raw_placinda placinda raw_lavash_wrap lavash_wrap raw_pelmeni pelmeni raw_vareniki vareniki raw_chebureki chebureki pasta_with_adjika risotto fried_rice",
  GV,
  1.75,
);
foods(
  "tfc_gourmet",
  "borscht solyanka zama curry goulash pho bouillabaisse ramen_with_bacon ramen_with_beef ramen_with_camelidae ramen_with_chevon biryani dolma spaghetti_bolognese pasta_carbonara kharcho shurpa fish_soup fish_soup_tomato cabbage_with_meat",
  GVP,
  2,
);
foods("tfc_gourmet", "okroshka kholodnik", VP, 1.75);

const AQUACULTURE_FISH = new Set([
  "atlantic_cod",
  "blackfish",
  "pacific_halibut",
  "atlantic_halibut",
  "atlantic_herring",
  "pink_salmon",
  "pollock",
  "rainbow_trout",
  "bayad",
  "boulti",
  "capitaine",
  "synodontis",
  "smallmouth_bass",
  "bluegill",
  "brown_trout",
  "carp",
  "catfish",
  "gar",
  "minnow",
  "muskellunge",
  "perch",
  "arapaima",
  "piranha",
  "tambaqui",
  "brown_shrooma",
  "red_shrooma",
  "jellyfish",
  "red_grouper",
  "tuna",
]);

TFCEvents.data((event) => {
  const missing = [];
  let registered = 0;
  $BuiltInRegistries.ITEM.entrySet().forEach((entry) => {
    const id = entry.getKey().location();
    const key = id.toString();
    if (!FOOD_MODS.has(id.getNamespace())) return;
    const nativeFood = entry.getValue().getFoodProperties();
    const fish =
      id.getNamespace() === "aquaculture" && AQUACULTURE_FISH.has(id.getPath());
    if (nativeFood === null && !fish) return;
    const profile = PROFILES.get(key);
    if (profile === undefined) {
      missing.push(key);
      return;
    }
    event.foodItem(key, (food) => {
      const hunger = nativeFood === null ? 4 : nativeFood.getNutrition();
      if (hunger > 0) food.hunger(hunger);
      if (nativeFood !== null)
        food.saturation(nativeFood.getSaturationModifier());
      food.decayModifier(profile.decay);
      const [grain, fruit, vegetables, protein, dairy] = profile.nutrients;
      if (grain) food.grain(grain);
      if (fruit) food.fruit(fruit);
      if (vegetables) food.vegetables(vegetables);
      if (protein) food.protein(protein);
      if (dairy) food.dairy(dairy);
    });
    registered++;
  });
  console.info(
    `[TFGM] Registered explicit TFC nutrition for ${registered} fork foods.`,
  );
  if (missing.length) {
    throw new Error(
      `[TFGM] Missing explicit nutrition profiles: ${missing.join(", ")}`,
    );
  }
});
