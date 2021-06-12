if (get_gameplay_time() <= 2)
    exit;

var hud_x = 0;
var hud_y = 480;
var hud_size = 224;
var hud_padding = 16;
var hud_max_width = (hud_size + hud_padding) * 4;
var hud_width = (hud_size + hud_padding) * player_count;
var hud_offset = (hud_max_width - hud_width) / 2;

//Healthbar
var i = 0;
var hbar_y = -80;

draw_enemy_healthbar();

repeat ds_list_size(active_bosses) {
    var boss = active_bosses[| i];
    var hbar_x = (view_get_wview() / 2) - (sprite_get_width(obj_stage_main.hud_healthbar_spr) / 2);
    var hbar_y_top = sprite_get_height(obj_stage_main.hud_healthbar_spr) * -2;
    var hbar_y = hbar_y_top;
    var hbar_yoff = (sprite_get_height(obj_stage_main.hud_healthbar_spr) + obj_stage_main.hud_healthbar_yspacing) * i;
    var hbar_fill = 0;
    var hbar_color = c_white;
    var show_percent = true;
    var hbar_percent = 0;
    var hbar_shake_x = 0;
    var hbar_shake_y = 0;
    
    with (boss) {
        hbar_color = char_hud_color;
        show_percent = hitpoints_max <= 0;
        hbar_percent = percent;
        
        if (show_percent) {
            hbar_x = (view_get_wview() / 2) - (sprite_get_width(obj_stage_main.hud_percentbar_spr) / 2);
            hbar_yoff = 68 * i;
        }
        if (hitstun > 15 && hitpause > 0) {
            hbar_shake_x = round(-2 + random_func(1, 4, true) / 2) * 2;
            hbar_shake_y = round(-2 + random_func(1, 4, true) / 2) * 2;
        }
        switch(battle_state) {
            case 0:
                hbar_y = hbar_y_top;
                hbar_fill = 0;
            break;
            
            case 1:
                if (show_healthbar) {
                    if (battle_state_timer <= 30)
                        hbar_y = lerp(hbar_y_top, obj_stage_main.hud_bossbar_yoffset + hbar_yoff, battle_state_timer / 30)
                    else
                        hbar_y = obj_stage_main.hud_bossbar_yoffset + hbar_yoff
                    if (boss_healthbar_timer > 0) {
                        if (boss_healthbar_timer < 56) 
                            hbar_fill = ease_linear(0, 1, round(boss_healthbar_timer), 56);
                        else {
                            hbar_fill = 1
                        }
                    }
                    else
                        hbar_fill = 0;
                }
                else {
                    hbar_y = hbar_y_top;
                    hbar_fill = 0;
                }
            break;
            
            case 2:
                var hp_total = 0;
                var hp_sum = 0;
                hbar_y = obj_stage_main.hud_bossbar_yoffset + hbar_yoff;
                hp_total += hitpoints_max;
                hp_sum += hitpoints_max - percent;
                if (array_length(health_children) > 0) {
                    for (var i = 0; i < array_length(health_children); i++) {
                        with (health_children[i]) {
                            hp_total += hitpoints_max;
                            hp_sum += hitpoints_max - percent;
                        }
                    }
                }
                if (health_parent != -1 && health_parent != id) {
                    with (health_parent) {
                        hp_total += hitpoints_max;
                        hp_sum += hitpoints_max - percent;
                    }
                }
                if (hp_total != 0)
                    hbar_fill = hp_sum / hp_total;
            break;
            case 3:
                if (battle_state_timer <= 60)
                    hbar_y = lerp(obj_stage_main.hud_bossbar_yoffset + hbar_yoff, hbar_y_top, battle_state_timer / 60)
                else
                    hbar_y = hbar_y_top;
            break;
        }
        var xx = hbar_x + obj_stage_main.hud_bossname_xoffset;
        var yy = hbar_y + obj_stage_main.hud_bossname_yoffset;
        var str = char_name;
        if (obj_stage_main.hud_draw_default_healthbar) { 
            if (!show_percent) {
                draw_set_font(asset_get("medFont"));
                draw_set_halign(fa_left)
                
                draw_sprite(obj_stage_main.hud_healthbar_back_spr, 0, hbar_x + hbar_shake_x, hbar_y + hbar_shake_y);
                draw_sprite_part_ext(obj_stage_main.hud_healthbar_spr, 0, 0, 0, sprite_get_width(obj_stage_main.hud_healthbar_spr) * hbar_fill, 
                    sprite_get_height(obj_stage_main.hud_healthbar_spr), hbar_x + hbar_shake_x, hbar_y + hbar_shake_y, 1, 1, hitpause <= 0 ? hbar_color : c_white, 1);
                draw_text_trans_outline(xx, yy, str, 1, -1, 1, 1, 0, c_white, c_black, 1);
            }
            else {
                
                draw_sprite(obj_stage_main.hud_percentbar_spr, 0, hbar_x + hbar_shake_x, hbar_y + hbar_shake_y);
                draw_set_font(asset_get("roaLBLFont"));
                draw_set_halign(fa_right)
                draw_text_trans_outline(hbar_x + obj_stage_main.hud_percent_xoffset, hbar_y + obj_stage_main.hud_percent_yoffset, hbar_percent, 1, -1, 1, 1, 0, c_white, c_black, 1);
                
                draw_set_font(asset_get("medFont"));
                draw_set_halign(fa_left)
                draw_text_trans_outline(hbar_x + obj_stage_main.hud_percent_xoffset + 6, hbar_y + obj_stage_main.hud_percent_yoffset + 8, "%", 1, -1, 1, 1, 0, c_white, c_black, 1);
                draw_set_halign(fa_right)
                draw_text_trans_outline(xx - 32, yy, str, 1, -1, 1, 1, 0, c_white, c_black, 1);
            }
        }
    }
    i++;
}


//Player HUD
var dx = hud_x + 8 + (dummy_player - 1) * (hud_size + hud_padding) + hud_offset;
var dy = hud_y;
var ds = sprite_get("hud_difficulty");
if (dummy_player <= 0) {
    dx = 576;
    dy = hbar_y + 36;
    ds = sprite_get("hud_difficulty_s")
}

draw_sprite(ds, hard_mode, dx, dy)

draw_set_font(asset_get("roaLBLFont"));
if (dummy_player <= 0) 
    draw_set_font(asset_get("medFont"));
draw_set_halign(fa_center)
xx = dx + 120;
yy = dy + 20;
if (dummy_player <= 0)
    yy = dy + 4;
str = hard_mode ? "EXPERT" : "NORMAL";
var col = hard_mode ? c_maroon : c_white;

draw_text_trans_outline(xx, yy, str, 1, -1, 1, 1, 0, col, c_black, 1)

for (var i = 1; i <= player_count; i++) {
    with (asset_get("oPlayer")) {
        if (clone || custom_clone || ("fake_stock" not in self))
            continue;
        if (other.dummy_player != i && player == i) {
            with (obj_stage_main) {
                draw_set_font(asset_get("roaLBLFont"));
                draw_set_halign(fa_left)
                
                var dx = hud_x + 8 + (i - 1) * (hud_size + hud_padding) + hud_offset;
                draw_sprite_ext(sprite_get("hud_life_counter"), 0, dx, hud_y - 36, 1, 1, 0, get_player_hud_color(i), 1);
        		
        		var xx = dx + 72;
        		var yy = hud_y - 36
        		var str = other.fake_stock;
        		if (in_training)
        		    str = "X"
        		draw_text_trans_outline(xx, yy, str, 1, -1, 1, 1, 0, c_white, c_black, 1)
        		
                draw_set_font(asset_get("fName"));
                draw_set_halign(fa_left)
                
        		xx = dx;
        		yy = hud_y - 56
        		str = "Score: " + string(round(player_display_hits[i]));
        		draw_text_trans_outline(xx, yy, str, 1, -1, 1, 1, 0, c_white, c_black, 1)
        		
                var bonuses_total = array_length(player_bonus_default);

        		if (end_battle_phase > -1 && end_battle_phase < bonuses_total) {
                    draw_set_font(asset_get("fName"));
                    draw_set_halign(fa_left)
        		    if (end_battle_timer < 80) {
        		        var bonus = player_bonus_default[end_battle_phase];
        		        if (bonus.score[i] != 0 && !player_is_dead[i]) {
                    		xx = dx;
                    		yy = hud_y - min(ease_quadIn(56, 72, end_battle_timer, 16), 72);
                    		var str_sign = bonus.score[i] < 0 ? "-" : "+";
                    		str = bonus.name + " " + str_sign + string(bonus.score[i]);
        		            draw_text_trans_outline(xx, yy, str, 1, -1, 1, 1, 0, c_white, c_black, 1)
        		        }
        		    }
        		}
            }
        }
    }
}
user_event(3);
#define draw_text_trans_outline(_x, _y, str, separ, w, xscale, yscale, angl, text_colour, outline_colour, alph)
for (i = - 1; i < 2; i++) for (j = -1; j < 2; j++) draw_text_ext_transformed_color(_x+i*2,_y+j*2,str,separ, w, xscale, yscale, angl, outline_colour, outline_colour, outline_colour, outline_colour, 1);
draw_text_ext_transformed_color(_x,_y,str,separ, w, xscale, yscale, angl, text_colour, text_colour, text_colour, text_colour, 1);
#define draw_enemy_healthbar()
if (enemy_health_hud_mode == 0 || enemy_health_hud_mode == 2) {
    if (active_enemy_timer < active_enemy_timer_max) {
        if (instance_exists(active_enemy)) {
            //Icon
            draw_sprite(active_enemy.char_icon, 0, 2, 112)
            draw_sprite(sprite_get("enemy_hud_border"), 0, 2, 112)
            
            //Name
            draw_set_halign(fa_left)
            draw_set_font(asset_get("fName"))
            draw_text_trans_outline(50, 120, active_enemy.char_name, 1, 960, 1, 1, 0, c_white, c_black, 1)
            
            //Healthbar
            if (active_enemy.hitpoints_max > 0) {
                var hbar_scale = clamp(active_enemy.hitpoints_max, 24, 208) / 24;
                var hbar_fill = lerp(1, 0, active_enemy.percent / active_enemy.hitpoints_max);
                draw_sprite_ext(sprite_get("enemy_hud_hp"),0, 50, 136, 1, 1,0,c_white,1);
                draw_sprite_part_ext(sprite_get("enemy_hud_hp"), 1, 0, 0, 48 * hbar_fill, 16, 50, 136, 1, 1, active_enemy.char_hud_color, 1);
                
            }
            else {
                draw_set_font(asset_get("medFont"))
                draw_debug_text(50,160,string(active_enemy.percent)+"%");
            }
        
        }
    }
}
