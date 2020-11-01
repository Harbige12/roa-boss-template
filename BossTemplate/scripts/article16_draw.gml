gpu_set_blendenable(false);
gpu_set_colorwriteenable(false, false, false, true);
draw_set_alpha(0);
draw_rectangle_color(0,0, room_width,room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(space_alpha);
draw_circle_color(x, y, round(timer * 48), c_black, c_black, false);
gpu_set_blendenable(true);
gpu_set_colorwriteenable(true,true,true,true);
gpu_set_blendmode_ext(bm_dest_alpha,bm_inv_dest_alpha);
gpu_set_alphatestenable(true);
draw_sprite_tiled_ext(space_sprite, 2, round(bg_x), round(bg_y), 1, 1, c_white, space_alpha);
gpu_set_alphatestenable(false);
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);

var img_spd = 0.25;
var col = c_white;
if (instance_exists(hit_player_obj)) {
    col = get_player_hud_color(hit_player_obj.player)
}
if (timer * img_spd <= sprite_get_number(spark_sprite)) {
    draw_sprite_ext(spark_sprite, timer * img_spd, round(x), round(y), 1, 1, 0, col, 1);
}

img_spd = 0.1;
if (timer * img_spd <= sprite_get_number(lines_sprite)) {
    draw_sprite_ext(lines_sprite, timer * img_spd, view_get_xview() + view_get_wview() / 2, view_get_yview() + view_get_hview() / 2, 1, 1, 0, col, 1);
}