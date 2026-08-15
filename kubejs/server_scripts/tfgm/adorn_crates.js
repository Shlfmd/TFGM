"use strict";

// Adorn food crates are craftable from TFC food (see the pack overrides in
// kubejs/data/adorn/recipes/crates/pack). Remove their unpack recipes so a crate
// never hands back fresh, decay-free TFC food.
const ADORN_FOOD_UNPACK = [
  "adorn:crates/unpack/apple",
  "adorn:crates/unpack/beetroot",
  "adorn:crates/unpack/carrot",
  "adorn:crates/unpack/potato",
  "adorn:crates/unpack/melon",
  "adorn:crates/unpack/sugar_cane",
  "adorn:crates/unpack/wheat",
];

ServerEvents.recipes((event) => {
  ADORN_FOOD_UNPACK.forEach((id) => event.remove({ id: id }));
});
