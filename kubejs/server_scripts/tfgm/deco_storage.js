"use strict";

// Decorative Storage food blocks are craftable from TFC food (see the fill
// overrides in kubejs/data/deco_storage/recipes). Remove their extractor recipes
// so breaking a filled block never hands back fresh, decay-free TFC food.
const DECO_FOOD_EXTRACTORS = [
  "deco_storage:barrel_with_apples_undo_recipe",
  "deco_storage:basket_with_apples_undo_recipe",
  "deco_storage:crate_with_apples_undo_recipe",
  "deco_storage:barrel_with_beetroots_undo_recipe",
  "deco_storage:basket_with_beetroots_undo_recipe",
  "deco_storage:crate_with_beetroots_undo_recipe",
  "deco_storage:hanging_beetroots_undo_recipe",
  "deco_storage:barrel_with_carrots_undo_recipe",
  "deco_storage:basket_with_carrots_undo_recipe",
  "deco_storage:crate_with_carrots_undo_recipe",
  "deco_storage:hanging_carrots_undo_recipe",
  "deco_storage:barrel_with_potatoes_undo_recipe",
  "deco_storage:basket_with_potatoes_undo_recipe",
  "deco_storage:crate_with_potatoes_undo_recipe",
  "deco_storage:barrel_with_cabbage_undo_recipe",
  "deco_storage:crate_with_cabbage_undo_recipe",
  "deco_storage:barrel_with_onions_undo_recipe",
  "deco_storage:basket_with_onions_undo_recipe",
  "deco_storage:crate_with_onions_undo_recipe",
  "deco_storage:barrel_with_tomatoes_undo_recipe",
  "deco_storage:basket_with_tomatoes_undo_recipe",
  "deco_storage:crate_with_tomatoes_undo_recipe",
  "deco_storage:barrel_with_rice_undo_recipe",
  "deco_storage:crate_with_rice_undo_recipe",
  "deco_storage:barrel_with_melons_undo_recipe",
  "deco_storage:crate_with_melons_undo_recipe",
  "deco_storage:barrel_with_pumpkins_undo_recipe",
  "deco_storage:crate_with_pumpkins_undo_recipe",
  "deco_storage:barrel_with_cod_undo_recipe",
  "deco_storage:basket_with_cod_undo_recipe",
  "deco_storage:hanging_cod_undo_recipe",
  "deco_storage:barrel_with_salmon_undo_recipe",
  "deco_storage:basket_with_salmon_undo_recipe",
  "deco_storage:hanging_salmon_undo_recipe",
  "deco_storage:barrel_with_tropical_fish_undo_recipe",
  "deco_storage:basket_with_tropical_fish_undo_recipe",
  "deco_storage:hanging_tropical_fish_undo_recipe",
  "deco_storage:barrel_with_sugar_cane_undo_recipe",
];

ServerEvents.recipes((event) => {
  DECO_FOOD_EXTRACTORS.forEach((id) => event.remove({ id: id }));
});
