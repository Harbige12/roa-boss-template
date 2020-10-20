//draw stuff for enemy
draw_set_alpha(1);

//Enum declarations (DO NOT EDIT)

//Event Enum
enum EN_EVENT {
    INIT,
    ANIMATION,
    PRE_DRAW,
    POST_DRAW,
    UPDATE,
    DEATH,
    SET_ATTACK,
    ATTACK_UPDATE,
    GOT_HIT,
    GOT_PARRIED,
    HIT_PLAYER,
    PARRY
}

if !_init exit; //Only draw stuff after initializing
if in_render {
    custom_behavior(EN_EVENT.PRE_DRAW);
    
    if (super_armor) {
        var offset = 2;
        for (var ix = -offset; ix <= offset; ix += offset) {  
             for (var iy = -offset; iy <= offset; iy += offset) {  
                gpu_set_fog(1, c_white, 0, 0);
                draw_sprite_ext(sprite_index,image_index,x + ix,y + iy,image_xscale * spr_dir,image_yscale,image_angle,image_blend,image_alpha);
                gpu_set_fog(0, 0, 0, 0);
             }
        }
    }
    
    draw_sprite_ext(sprite_index,image_index,x,y,image_xscale * spr_dir,image_yscale,image_angle,image_blend,image_alpha);
    if ((hitpause > 5 && knockback_adj != 0) || (knockback_adj == 0 && hitpause > 0)) {
        gpu_set_fog(1, c_white, 0, 0); 
            draw_sprite_ext(sprite_index,image_index,x,y,image_xscale * spr_dir,image_yscale,image_angle,c_white,0.5);
        gpu_set_fog(0, 0, 0, 0);
    }
    
    draw_enemy_healthbar();
    
    custom_behavior(EN_EVENT.POST_DRAW); 
    
    if debug {
        draw_sprite_ext(hurtbox_spr,-1,x,y,image_xscale * spr_dir,image_yscale,0,c_white,0.6);
        draw_debug_text(x-128,y,string(attack_down));
        draw_debug_text(x-128,y+16,string(down_down));
        draw_debug_text(x-128,y-16,string(up_down));
        draw_debug_text(x-112,y,string(right_down));
        draw_debug_text(x-144,y,string(left_down));
        draw_debug_text(x-100,y,string(jump_down));
        draw_debug_text(x-100,y-32,string(shield_down));
        draw_debug_text(x,y-32,string(get_state_name(state)));
        //draw_debug_text(x-64,y+32,string(get_attack_name(attack)));
        //if instance_exists(last_hitbox) draw_debug_text(x-64,y+32,string(last_hitbox.hbox_group));
        //if instance_exists(hit_id) draw_debug_text(x-64,y+32,string(hit_id.hbox_group));
        draw_debug_text(x+32,y,string(kb_angle));
        draw_debug_text(x+32,y+32,string(is_free));
        draw_debug_text(x+64,y,string([hsp,vsp]));
        /*draw_debug_text(x+16,y+32,string(!(place_meeting(x,y+1,asset_get("solid_32_obj")) || 
                      place_meeting(x,y+1,asset_get("jumpthrough_32_obj")) || 
                      place_meeting(x,y+1,obj_stage_article_solid) ||
                      place_meeting(x,y+1,obj_stage_article_platform))));*/
        if array_length_1d(custom_args) > 1 && custom_args[1] != 0 {
        draw_sprite(custom_args[1],0,x,y);
    }
    
    }
}
#define get_attack_name(_attack) //get the name of an attack

switch _attack {
    case AT_JAB:
        return "AT_JAB";
    case AT_DATTACK:
        return "AT_DATTACK";
    case AT_FTILT:
        return "AT_FTILT";
    case AT_DTILT:
        return "AT_DTILT";
    case AT_UTILT:
        return "AT_UTILT";
    case AT_NAIR:
        return "AT_NAIR";
    case AT_FAIR:
        return "AT_FAIR";
    case AT_UAIR:
        return "AT_UAIR";
    case AT_DAIR:
        return "AT_DAIR";
    case AT_BAIR:
        return "AT_BAIR";
    case AT_FSTRONG:
        return "AT_FSTRONG";
    case AT_USTRONG:
        return "AT_USTRONG";
    case AT_DSTRONG:
        return "AT_DSTRONG";
    case AT_DSPECIAL:
        return "AT_DSPECIAL";
    case AT_USPECIAL:
        return "AT_USPECIAL";
    case AT_FSPECIAL:
        return "AT_FSPECIAL";
    case AT_NSPECIAL:
        return "AT_FSPECIAL";
    case AT_DSPECIAL_AIR:
        return "AT_DSPECIAL_AIR";
    case AT_USPECIAL_GROUND:
        return "AT_USPECIAL_GROUND";
    case AT_FSPECIAL_AIR:
        return "AT_FSPECIAL_AIR";
    case AT_NSPECIAL_AIR:
        return "AT_FSPECIAL_AIR";
    case AT_TAUNT:
        return "AT_TAUNT";
    case AT_DTHROW:
        return "AT_DTHROW";
    case AT_FTHROW:
        return "AT_FTHROW";
    case AT_NTHROW:
        return "AT_NTHROW";
    case AT_UTHROW:
        return "AT_UTHROW";
    case AT_FSTRONG_2:
        return "AT_FSTRONG_2";
    case AT_USTRONG_2:
        return "AT_USTRONG_2";
    case AT_DSTRONG_2:
        return "AT_DSTRONG_2";
    case AT_TAUNT_2:
        return "AT_TAUNT_2";
    case AT_EXTRA_1:
        return "AT_EXTRA_1";
    case AT_EXTRA_2:
        return "AT_EXTRA_2";
    case AT_EXTRA_3:
        return "AT_EXTRA_3";
}

#define draw_enemy_healthbar()
//Contributed by Harbige
if (!is_boss) {
    if (obj_stage_main.enemy_health_hud_mode == 1 || obj_stage_main.enemy_health_hud_mode == 2) {
        if (hitpoints_max > 0) {
            if (char_healthbar != noone) {
                var hbar_fill = lerp(1, 0, percent / hitpoints_max);
                draw_sprite_ext(char_healthbar,0,x - 34,y-char_height*2-22,1,1,0,c_white,1);
                draw_sprite_part_ext(char_healthbar, 1, 0, 0, 64 * hbar_fill, 16, x - 34, y-char_height*2-22, 1, 1, char_hud_color, 1);
            }
        }
        else draw_debug_text(x-10,y-(char_height*2)-20,string(percent)+"%");
        
        draw_sprite_ext(char_arrow,0,x-10,y-char_height*2-6,1,1,0,char_hud_color,1);
    }
    else {
        if (hitpoints_max == 0) {
             draw_debug_text(x-10,y-(char_height*2)-20,string(percent)+"%");
            
            draw_sprite_ext(char_arrow,0,x-10,y-char_height*2-6,1,1,0,char_hud_color,1);
        }
    }
}

#define custom_behavior(_eventID)
art_event = _eventID
user_event(6); //Custom behavior