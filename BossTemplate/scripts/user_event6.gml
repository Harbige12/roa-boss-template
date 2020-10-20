//Custom AI Behavior. see article6 code for details.
//Enemy Enum (edit this for custom enemy declarations)
enum EN {
	BLANK
};

//Enum Declarations, DO NOT EDIT
enum TR {
    NEAR,
    FAR,
    RANDOM,
    LOW,
    HIGH,
    CUSTOM
}

//Event Enum, DO NOT EDIT
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
//

//Put custom enemy behavior here.
switch (enem_id) {
    case EN.BLANK:
        switch (art_event) {
        	case EN_EVENT.INIT:
        		
        	break;
        	
        	case EN_EVENT.SET_ATTACK:
                with (obj_stage_main) {
                	switch (other.attack) {
                		case AT_JAB:
                			//Put attack data here!
                		break
                	}
                }
            break;
        }
    break;
}

//Extra functions (edit these if you want)

//Calculate an hspeed from the enemy's vspeed, gravity, and target point.
#define arc_calc_x_speed(x1, y1, x2, y2, vspd, g)
var dX = x2 - x1;
var dY = y2 - y1;
if (dX == 0) {
	return 0;
}
var sq = abs(vspd * vspd) / (g * g) - (dY / g);

if (sq < 0) {
	return 0;
}
var t = (abs(vspd) / g) + sqrt(sq);
return dX / t;

//Standard boss death.
#define boss_death()
invincible = 100;
if (state_timer == 1) {
	 with (obj_stage_main) {
        var death = instance_create(other.x, other.y, "obj_stage_article", 16);
        
        sound_play(sound_get("sfx_boss_dead"));
    }
    state_timer = 2;
}

//Standard enemy death
#define standard_death()
invincible = 100;
ignores_walls = true;
can_be_grounded = false;
sprite_index = enemy_sprite_get(sprite_name,"hurt");
if hitpause > 1 {
    state_timer = 0;
} else {
    image_index += 0.35;
    if (state_timer == 2) {
    	kb_power += 2;
        kb_power *= 2;
        if !is_free && kb_angle > 3.14159 && kb_angle < 3.14159*2 vsp = kb_power*sin(kb_angle);
        else if !is_free vsp = -abs(kb_power*dsin(kb_angle));
        else vsp = -kb_power*dsin(kb_angle);
        hsp = kb_power*dcos(kb_angle);
        if hsp != 0 spr_dir = -sign(hsp);
    }
    old_hsp = hsp;
    old_vsp = vsp;
    //hitstun--;
    if !is_free vsp = -8 * knockback_adj;
    if (state_timer >= 30) {
        destroyed = true;
    	sound_play(asset_get("sfx_ell_explosion_medium"))
    	spawn_hit_fx(x, y - char_height, 143)
    }
}

//Calculate a vspeed based on a target position and gravity.
#define y_speed_aim(_originY, _targetY, _accel)
var dir = 0;
if (_accel > 0) dir = -1; else dir = 1;
if (dir < 0 && _targetY > _originY) || (dir > 0 && _targetY < _originY)
	_targetY = _originY + 24 * dir;
_accel = abs(_accel);

var substitution = 2 * _accel * abs(_targetY - _originY);
if (substitution <= 0)
	return 0;

var new_vsp = sqrt(substitution) * dir;
return new_vsp;

//DO NOT EDIT BELLOW
#define create_enemy(spawn_x, spawn_y, enemyID)
var e = instance_create(spawn_x, spawn_y, "obj_stage_article", 6);
e.spawn_variables[0] = enemyID;
return e;
#define enemy_sprite_get(_name,_sprite) //Get the sprite of this article
return sprite_get(string(_name)+"_"+string(_sprite));
#define place_meet(__x,__y) //get place_meeting for the usual suspects
/*return (collision_rectangle(__x-colis_width/2,__y-colis_height,__x+colis_width/2,__y,asset_get("solid_32_obj"),true,true) ||
       collision_rectangle(__x-colis_width/2,__y-colis_height,__x+colis_width/2,__y,obj_stage_article_solid,true,true) ||
       collision_rectangle(__x-colis_width/2,__y-colis_height,__x+colis_width/2,__y,asset_get("jumpthrough_32_obj"),true,true) ||
       collision_rectangle(__x-colis_width/2,__y-colis_height,__x+colis_width/2,__y,obj_stage_article_platform,true,true));*/
return (place_meeting(__x,__y,asset_get("solid_32_obj")) || 
        place_meeting(__x,__y,obj_stage_article_solid) || 
        place_meeting(__x,__y,asset_get("jumpthrough_32_obj")) || 
        place_meeting(__x,__y,obj_stage_article_platform));

#define position_meet(__x,__y) //get place_meeting for the usual suspects
/*return (collision_rectangle(__x-colis_width/2,__y-colis_height,__x+colis_width/2,__y,asset_get("solid_32_obj"),true,true) ||
       collision_rectangle(__x-colis_width/2,__y-colis_height,__x+colis_width/2,__y,obj_stage_article_solid,true,true) ||
       collision_rectangle(__x-colis_width/2,__y-colis_height,__x+colis_width/2,__y,asset_get("jumpthrough_32_obj"),true,true) ||
       collision_rectangle(__x-colis_width/2,__y-colis_height,__x+colis_width/2,__y,obj_stage_article_platform,true,true));;*/

return (position_meeting(__x,__y,asset_get("solid_32_obj")) || 
        position_meeting(__x,__y,obj_stage_article_solid) || 
        position_meeting(__x,__y,asset_get("jumpthrough_32_obj")) || 
        position_meeting(__x,__y,obj_stage_article_platform));    
#define place_meet_solid(__x,__y) //get place_meeting for the usual suspects
/*return (collision_rectangle(__x-colis_width/2,__y-colis_height,__x+colis_width/2,__y,asset_get("solid_32_obj"),true,true) ||
       collision_rectangle(__x-colis_width/2,__y-colis_height,__x+colis_width/2,__y,obj_stage_article_solid,true,true));*/
return (place_meeting(__x,__y,asset_get("solid_32_obj")) || 
    place_meeting(__x,__y,obj_stage_article_solid));  
#define place_meet_plat(__x,__y) //get place_meeting for the usual suspects
/*return (collision_rectangle(__x-colis_width/2,__y-colis_height,__x+colis_width/2,__y,asset_get("jumpthrough_32_obj"),true,true) ||
       collision_rectangle(__x-colis_width/2,__y-colis_height,__x+colis_width/2,__y,obj_stage_article_platform,true,true));*/
return (place_meeting(__x,__y,asset_get("jumpthrough_32_obj")) || 
    place_meeting(__x,__y,obj_stage_article_platform));
  
#define get_plat(__x,__y)
var _plat = instance_position(__x,__y,obj_stage_article_platform);
if instance_exists(_plat) && (y <= _plat.y + 4 && vsp >= 0) return _plat;
return instance_position(__x,__y,asset_get("jumpthrough_32_obj"));