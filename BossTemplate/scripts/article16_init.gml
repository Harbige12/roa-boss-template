//The fancy boss kill effect. Use this article if you want.

timer = 0;
bg_x = x;
bg_y = y;
bg_spd = 5;
hit_player_obj = noone;

sprite_index = asset_get("empty_sprite");

spark_sprite = asset_get("fx_ko_spark");
lines_sprite = asset_get("fx_ko_lines");
space_sprite = asset_get("fx_ko_space");
circle_sprite = asset_get("fx_ko_circle");

with (obj_stage_main) music_stop();
space_alpha = 1;

depth = 30;

with (pHitBox) {
    if (player == obj_stage_main.player) {
        instance_destroy(id);
        continue;
    }
}