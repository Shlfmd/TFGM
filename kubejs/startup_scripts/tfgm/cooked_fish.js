"use strict";

// Cooked whole-fish variants for Aquaculture fish. Aquaculture (and Survivor's
// Aquaculture) ship no cooked whole-fish items, so raw fish had a TFC raw
// penalty with no cooked payoff. These items give every Aquaculture fish the
// same raw->cooked path as a native TFC fish. The 3 species TFC already has a
// cooked item for (smallmouth bass, bluegill, rainbow trout) grill straight
// into TFC's item instead, so they are not registered here.
// Textures are generated from each raw sprite; TFC nutrition lives in
// data/tfc/tfc/food_items/tfgm/cooked_*.json; heating recipes in
// data/tfgm/recipes/heating/cook_*.json.
const COOKED_FISH = [
  "atlantic_cod",
  "blackfish",
  "pacific_halibut",
  "atlantic_halibut",
  "atlantic_herring",
  "pink_salmon",
  "pollock",
  "bayad",
  "boulti",
  "capitaine",
  "synodontis",
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
];

function titleCase(id) {
  return id
    .split("_")
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join(" ");
}

StartupEvents.registry("item", (event) => {
  COOKED_FISH.forEach((fish) => {
    // Vanilla food props make it edible; TFC's food_items entry supplies the
    // real nutrition/decay and replaces these values in game.
    event
      .create(`cooked_${fish}`)
      .displayName(`Cooked ${titleCase(fish)}`)
      .texture(`kubejs:item/cooked_${fish}`)
      .food((food) => food.hunger(4).saturation(0.3))
      .tag("tfc:foods");
  });
});
