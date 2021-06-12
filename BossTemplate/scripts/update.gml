//So that hitboxes don't pile up.
obj_stage_main.hitstop = 0;
obj_stage_main.hitpause = false;

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

handle_cpu();
handle_fight();
if (get_gameplay_time() > 3)
	handle_camera();
handle_hitboxes();
handle_end_of_battle();


#define handle_hitboxes
with asset_get("pHitBox") if "hit_owner" in self {
	if (hitbox_timer == 0) {
        with hit_owner {
        	var attack_p = attack;
        	attack = other.attack
            reset_attack_grid(attack);
            custom_behavior(EN_EVENT.SET_ATTACK)
            with other set_hitboxes(id);
            reset_attack_grid(attack);
            attack = attack_p;
        }
    }
    hbox_group = -1;
    if (instance_exists(hit_owner)) {	
    	if (hit_owner.team == -1) {
			for (var i = 0; i < array_length(can_hit); i++)
				can_hit[i] = false;
		}
	    var p_touch = instance_place(x, y, oPlayer)
	    if (instance_exists(p_touch) && team != -1) {
	    	if (((("fake_stock" in p_touch) && p_touch.fake_stock > 0) || p_touch.clone || p_touch.custom_clone) && can_hit[p_touch.player]) {
	            if (!p_touch.perfect_dodged) {
	        		if (hit_owner.has_hit_en == 0) {
	            		with hit_owner custom_behavior(EN_EVENT.HIT_PLAYER)
	            		hit_owner.has_hit_en = 1
	        		}
	            }
	            else {
	            	if (!hit_owner.was_parried) {
		            	with hit_owner custom_behavior(EN_EVENT.GOT_PARRIED);
		            	print_debug("Parried enemy attack!")
						with obj_stage_main bonus_increment_value("Parry Bonus", p_touch.player, 20);
						hit_owner.was_parried = true;
	            	}
	            }
	        }
	    }
	    if (type != 2) {
	        var x_off = hit_owner.hg_x[hbox_num];
	        var y_off = hit_owner.hg_y[hbox_num];
	        x_pos = ((hit_owner.x + x_off * hit_owner.spr_dir) - obj_stage_main.x);
	        y_pos = ((hit_owner.y + y_off) - obj_stage_main.y);
	        hsp = hit_owner.hsp;
	        vsp = hit_owner.vsp;
	        spr_dir = hit_owner.spr_dir;
	    }
    }
}

#define custom_behavior(_eventID)
art_event = _eventID
user_event(6); //Custom behavior

#define handle_camera

var xview_min = view_get_wview()/2;
var yview_min = view_get_hview()/2;
var xview_max = room_width-view_get_wview()/2;
var yview_max = room_height-view_get_hview()/2;
var xview = view_get_xview()+view_get_wview()/2;
var yview = view_get_yview()+view_get_hview()/2;
var new_xview = cam_x;
var new_yview = cam_y;

if (!the_end) {
	if (ds_list_size(view_follow) > 0 && !instance_exists(view_focus)) {
		new_xview = xview;
		new_yview = yview;
		cam_x = 0;
		cam_y = 0;
		var actual = 0;
	    for (var i = 0; i < ds_list_size(view_follow); i++) {
	        if (instance_exists(view_follow[| i])) {
	        	if (variable_instance_exists(view_follow[| i], "fake_stock")) {
	        		if (view_follow[| i].fake_stock <= 0)
	        			ds_list_delete(view_follow, i);
	        	}
	        }
	        else
	        	ds_list_delete(view_follow, i);
	    }
	    for (var i = 0; i < ds_list_size(view_follow); i++) {
	    	if (!instance_exists(view_follow[| i]))
	    		continue;
			cam_x += view_follow[| i].x;
	    	cam_y += view_follow[| i].y;
	    }
	    if (ds_list_size(view_follow) > 1) {
		    cam_x /= ds_list_size(view_follow);
		    cam_y /= ds_list_size(view_follow);
	    }
	}
	if (instance_exists(view_focus)) {
		cam_x = view_focus.x;
		cam_y = view_focus.y;
	}
}

new_xview = clamp(lerp(new_xview, cam_x, 0.3),xview_min,xview_max);
new_yview = clamp(lerp(new_yview, cam_y, 0.15),yview_min,yview_max);
if (!the_end)
	set_view_position(new_xview,new_yview);

#define handle_fight
//Battle init check
if (!_init) {
	user_event(1);
	if (!player_bonus_default_on)
		player_bonus_default = array_create(0);
	if (array_length(player_bonus_extra) > 0)
		array_copy(player_bonus_default, max(0, array_length(player_bonus_default) - 1), player_bonus_extra, 0,  array_length(player_bonus_extra))
	_init = true;
}

//Custom update
user_event(2);

//Time bonus stuff


//Player death check
if (!in_training) {
	if (end_battle_cooldown > 0) {
		end_battle_cooldown--;
	}
	if (end_battle_cooldown == 0) {
		end_battle = true;
		end_battle_cooldown = -1;
	}
	
	if (dead_players >= player_count && !the_end) {
	    find_scores();
	    the_end = true;
	}
	
	//Battle end check
	if (end_battle) {
		end_battle_begin()
	}
}

//Active boss check
var i = 0;
var time_valid = true;

repeat ds_list_size(active_bosses) {
	if (!instance_exists(active_bosses[| i]))
    	ds_list_remove(active_bosses,active_bosses[| i])
    else {
    	if (active_bosses[| i].state == PS_SPAWN || active_bosses[| i].state == PS_DEAD)
    		time_valid = false;
    }
    i++;
}

if (time_valid && player_bonus_default_on && ds_list_size(active_bosses) > 0) {
	player_time_bonus ++;
	
	for (var i = 0; i < array_length(player_bonus_default); i++) {
		if (player_bonus_default[i].name == "Time Bonus") {
			for (var j = 0; j < array_length(player_bonus_default[i].score); j++) {
				player_bonus_default[i].score[j] = max(0, round(ease_linear(500, 0, player_time_bonus, player_time_bonus_max)));
			}
			break;
		}
	}
}
	

//Enemy check
if (active_enemy_timer <= active_enemy_timer_max) {
		active_enemy_timer ++;
	}

#define handle_cpu
//CPU player handling
var controlled_players = 0;
with (oPlayer) {
    if (clone || custom_clone || ("fake_stock" not in self)) continue;
    if (get_gameplay_time() == 2) ds_list_add(other.view_follow, id);
	if (!variable_instance_exists(id, "temp_level")) {
		controlled_players ++;
	}
}

if (get_match_setting(SET_TEAMS) == 1) {
    with (oPlayer) {
    	if (player != obj_stage_main.dummy_player)
    		set_player_team( player, 1 );
    	else
    		set_player_team( player, 2 );
    }
}

with (oPlayer) {
	if ("num" in self)
		continue;
    if (clone || custom_clone || ("fake_stock" not in self))
        continue;
	if (controlled_players <= 1) {
	    if (obj_stage_main.dummy_player <= 0) {
	        if (variable_instance_exists(id, "temp_level") && player >= obj_stage_main.player_count) {
	            if (fake_stock > 0) { 
	                fake_stock = 0;
	                obj_stage_main.dummy_player = player;
	                obj_stage_main.dead_players ++;
					obj_stage_main.player_boss_hits[player] = 0;
	            }
	        }
	    }
	}
	//Points
	obj_stage_main.player_display_hits[player] = lerp(obj_stage_main.player_display_hits[player], obj_stage_main.player_boss_hits[player], 0.5);
    //Fake stocks
    if (("fake_stock" in self) && fake_stock <= 0) {
        set_state(PS_WRAPPED);
        cpu_target_timer --
            
        if (cpu_target_timer <= 0) {
        	var found = noone
        	var enemy_num = 0;
	        with obj_stage_article if num == 6 enemy_num++;
        	var player_targ = random_func(0, enemy_num, true);
	        var i = 0;
	        with obj_stage_article if i == player_targ && num == 6 found = id; else i++;
            cpu_target = found;
            cpu_target_timer = 60;
        }
        if (instance_exists(cpu_target)) {
            //Check for alive bosses
            x = cpu_target.bbox_left + abs(cpu_target.bbox_right - cpu_target.bbox_left) / 2;
            y = cpu_target.bbox_top + abs(cpu_target.bbox_bottom - cpu_target.bbox_top) / 2;
            hsp = cpu_target.hsp;
            vsp = cpu_target.vsp;
        }
        else {
            hsp = 0;
            vsp = 0;
        }
        x = clamp(x, view_get_xview(), view_get_xview() + view_get_wview());
        y = clamp(y, view_get_yview(), view_get_yview() + view_get_hview());
        
        if (!hurtboxID.have_collision) {
	        invincible = true;
	        invince_time = 200;
        }
        go_through = false;
        fall_through = true;
        wrap_time = 196;
        visible = false;
        mask_index = asset_get("empty_sprite");
        state_timer = 1;
        player_solid = false;
    }
}

#define create_enemy(spawn_x, spawn_y, enemyID)
var e = instance_create(spawn_x, spawn_y, "obj_stage_article", 6);
e.spawn_variables[0] = enemyID;
return e;


#define find_scores
//Finding scores
var winner = ds_list_create();
ds_list_add(winner, -1, -1, -1, -1)
for (var i = 1; i < 5; i++) { //i is the current player being checked. j is the player it's being compared to.
	if (!is_player_on(i))
		continue;
	var place = player_count - 1;
	for (var j = 1; j < 5; j++) {
		if i == j continue; //lol same player
		if (!is_player_on(j)) continue;
		var score1 = player_boss_hits[i];
		var score2 = player_boss_hits[j];
		if score1 >= score2 {
			place--;
		}
	}
	//print_debug(string(place))
    winner[| place] = i;
}

//Move the dummy player to the last index if we win
//Else, move it in first.

if (dead_players < player_count && !lost_battle) {
	for (var l = 0; l < ds_list_size(winner); l++) {
		if (winner[| l] == dummy_player) {
			ds_list_delete(winner, l);
			ds_list_insert(winner, player_count - 1, dummy_player);
		}
	}
}
else {
	for (var l = 0; l < ds_list_size(winner); l++) {
		if (winner[| l] == dummy_player) {
			ds_list_delete(winner, l);
			ds_list_insert(winner, 0, dummy_player);
		}
	}
}

print_debug(string(ds_list_to_array(winner)));
ds_list_destroy(view_follow);
end_match(winner[| 0], winner[| 1], winner[| 2], winner[| 3]);

#define lock_player
var lookat = noone;
with (obj_stage_article) {
	if (get_article_script(id) == 1) {
		if (enemy_id == 0)
			lookat = id;
	}
}

with (oPlayer) {
	if ((("fake_stock" in self) && fake_stock > 0) || ("fake_stock" not in self)) {
		hsp = 0;
		state = PS_SPAWN;
		can_move = false;
		
		if (instance_exists(lookat))
			spr_dir = lookat.x < x ? -1 : 1;
		
		left_down = false;
		left_pressed = false;
		left_hard_pressed = false;
		right_down = false;
		right_pressed = false;
		right_hard_pressed = false;
		
		up_down = false;
		down_down = false;
		attack_down = false;
		special_down = false;
		shield_down = false;
		jump_down = false;
		
		move_cooldown[AT_JAB] = 10;
    	move_cooldown[AT_FTILT] = 10;
    	move_cooldown[AT_DTILT] = 10;
    	move_cooldown[AT_UTILT] = 10;
    	move_cooldown[AT_FSTRONG] = 10;
    	move_cooldown[AT_DSTRONG] = 10;
    	move_cooldown[AT_USTRONG] = 10;
    	move_cooldown[AT_DATTACK] = 10;
    	move_cooldown[AT_FAIR] = 10;
    	move_cooldown[AT_BAIR] = 10;
    	move_cooldown[AT_DAIR] = 10;
    	move_cooldown[AT_DAIR] = 10;
    	move_cooldown[AT_UAIR] = 10;
    	move_cooldown[AT_NAIR] = 10;
    	move_cooldown[AT_FSPECIAL] = 10;
    	move_cooldown[AT_DSPECIAL] = 10;
    	move_cooldown[AT_USPECIAL] = 10;
    	move_cooldown[AT_NSPECIAL] = 10;
    	move_cooldown[AT_EXTRA_1] = 10;
    	move_cooldown[AT_EXTRA_2] = 10;
    	move_cooldown[AT_EXTRA_3] = 10;
    	move_cooldown[AT_FSPECIAL_AIR] = 10;
    	move_cooldown[AT_DSPECIAL_AIR] = 10;
    	move_cooldown[AT_NSPECIAL_AIR] = 10;
	}
}
clear_button_buffer(PC_LEFT_HARD_PRESSED);
clear_button_buffer(PC_RIGHT_HARD_PRESSED);
clear_button_buffer(PC_UP_HARD_PRESSED);
clear_button_buffer(PC_DOWN_HARD_PRESSED);
clear_button_buffer(PC_LEFT_STRONG_PRESSED);
clear_button_buffer(PC_RIGHT_STRONG_PRESSED);
clear_button_buffer(PC_UP_STRONG_PRESSED);
clear_button_buffer(PC_DOWN_STRONG_PRESSED);
clear_button_buffer(PC_LEFT_STICK_PRESSED);
clear_button_buffer(PC_RIGHT_STICK_PRESSED);
clear_button_buffer(PC_UP_STICK_PRESSED);
clear_button_buffer(PC_DOWN_STICK_PRESSED);
clear_button_buffer(PC_JUMP_PRESSED);
clear_button_buffer(PC_ATTACK_PRESSED);
clear_button_buffer(PC_SHIELD_PRESSED);
clear_button_buffer(PC_SPECIAL_PRESSED);
clear_button_buffer(PC_STRONG_PRESSED);
clear_button_buffer(PC_TAUNT_PRESSED);

#define end_battle_begin()
if (end_battle_phase < 0) {
	end_battle_phase = 0;
	if (!lost_battle) {
		var p_total = player_count - dead_players;
		if (p_total > 1)
			bonus_increment_value("Last Hit", player_last_hit, 50);
		if (hard_mode) {
			bonus_increment_value("Expert Mode Clear", -1, 50);
		}
		with (oPlayer) {
			if (clone || custom_clone || ("fake_stock" not in self)) continue;
			if (fake_stock <= 0) continue;
			
			if (no_lives_lost) {
				bonus_increment_value("No Lives Lost", player, 100);
			}
		}
	}
}

#define handle_end_of_battle()
var bonuses_total = array_length(player_bonus_default);

if (end_battle_phase > -1) {
	if (bonuses_total == 0 || lost_battle) {
		if (!the_end) {
			the_end = true;
			find_scores();
		}
	}
	else {
		if (!the_end) {
			end_battle_timer ++;
		}
		var skip = true
		for (var i = 1; i < array_length(player_bonus_default[end_battle_phase].score); i++) {
			if (player_bonus_default[end_battle_phase].score[i] != 0) {
				skip = false;
			}
		}
		
		if (skip) {
			end_battle_timer = 120;
		}
		if (end_battle_timer == 1) {
			sound_play(asset_get("mfx_coin"))
		}
		if (end_battle_timer == 80 && !skip) {
			sound_play(asset_get("mfx_confirm"))
			for (var i = 1; i < array_length(player_bonus_default[end_battle_phase].score); i++) {
				if (!player_is_dead[i])
					obj_stage_main.player_boss_hits[i] += player_bonus_default[end_battle_phase].score[i];
			}
		}
	
		if (end_battle_timer == 120) {
			
			if (end_battle_phase >= bonuses_total - 1 && !the_end) {
				the_end = true;
				find_scores();
			}
			else {
				end_battle_phase++;
				end_battle_timer = 0;
			}
			
		}
	}
}


#define set_hitboxes(_hbox)
with (obj_stage_main) {
    var par = get_hitbox_value(_hbox.attack, _hbox.hbox_num, HG_PARENT_HITBOX);
    if (par == 0) par = _hbox.hbox_num;
    
    _hbox.type = get_hitbox_value(_hbox.attack, _hbox.hbox_num, HG_HITBOX_TYPE);
    if (_hbox.type == 0)
        _hbox.type = 1;
    _hbox.length = get_hitbox_value(_hbox.attack, _hbox.hbox_num, HG_LIFETIME);
    _hbox.x_pos = get_hitbox_value(_hbox.attack, _hbox.hbox_num, HG_HITBOX_X);
    _hbox.y_pos = get_hitbox_value(_hbox.attack, _hbox.hbox_num, HG_HITBOX_Y);
    _hbox.image_xscale = get_hitbox_value(_hbox.attack, par, HG_WIDTH) / 200;
    _hbox.image_yscale = get_hitbox_value(_hbox.attack, par, HG_HEIGHT) / 200;
    var spr = get_hitbox_value(_hbox.attack, par, HG_SHAPE);
    switch (spr) {
        case 0:  _hbox.sprite_index = asset_get("hitbox_circle_spr"); break;
        case 1:  _hbox.sprite_index = asset_get("hitbox_square_spr"); break;
        case 2:  _hbox.sprite_index = asset_get("hitbox_rounded_rectangle"); break;
    }
    _hbox.mask_index = _hbox.sprite_index;
    _hbox.image_alpha = 0.5;
    _hbox.hit_priority = get_hitbox_value(_hbox.attack, par, HG_PRIORITY);
    _hbox.damage = get_hitbox_value(_hbox.attack, par, HG_DAMAGE);
    _hbox.kb_angle = get_hitbox_value(_hbox.attack, par, HG_ANGLE);
    _hbox.kb_value = get_hitbox_value(_hbox.attack, par, HG_BASE_KNOCKBACK);
    _hbox.kb_scale = get_hitbox_value(_hbox.attack, par, HG_KNOCKBACK_SCALING);
    _hbox.effect = get_hitbox_value(_hbox.attack, par, HG_EFFECT);
    _hbox.hitpause = get_hitbox_value(_hbox.attack, par, HG_BASE_HITPAUSE);
    _hbox.hitpause_growth = get_hitbox_value(_hbox.attack, par, HG_HITPAUSE_SCALING);
    _hbox.hit_effect = get_hitbox_value(_hbox.attack, par, HG_VISUAL_EFFECT);
    _hbox.hit_effect_x = get_hitbox_value(_hbox.attack, par, HG_VISUAL_EFFECT_X_OFFSET);
    _hbox.hit_effect_y = get_hitbox_value(_hbox.attack, par, HG_VISUAL_EFFECT_Y_OFFSET);
    _hbox.fx_particles = get_hitbox_value(_hbox.attack, par, HG_HIT_PARTICLE_NUM);
    _hbox.sound_effect = get_hitbox_value(_hbox.attack, par, HG_HIT_SFX);
    _hbox.hit_flipper = get_hitbox_value(_hbox.attack, par, HG_ANGLE_FLIPPER);
    _hbox.extra_hitpause = get_hitbox_value(_hbox.attack, par, HG_EXTRA_HITPAUSE);
    _hbox.groundedness = get_hitbox_value(_hbox.attack, par, HG_GROUNDEDNESS);
    _hbox.camera_shake = get_hitbox_value(_hbox.attack, par, HG_EXTRA_CAMERA_SHAKE);
    _hbox.proj_break = get_hitbox_value(_hbox.attack, par, HG_IGNORES_PROJECTILES);
    _hbox.no_other_hit = get_hitbox_value(_hbox.attack, par, HG_HIT_LOCKOUT);
    _hbox.hbox_group = get_hitbox_value(_hbox.attack, _hbox.hbox_num, HG_HITBOX_GROUP);
    _hbox.hitstun_factor = get_hitbox_value(_hbox.attack, _hbox.hbox_num, HG_HITSTUN_MULTIPLIER);
    _hbox.dumb_di_mult = get_hitbox_value(_hbox.attack, _hbox.hbox_num, HG_DRIFT_MULTIPLIER);
    _hbox.sdi_mult = get_hitbox_value(_hbox.attack, _hbox.hbox_num, HG_SDI_MULTIPLIER) + 1;
    _hbox.can_tech = get_hitbox_value(_hbox.attack, _hbox.hbox_num, HG_TECHABLE);
    _hbox.force_flinch = get_hitbox_value(_hbox.attack, _hbox.hbox_num, HG_FORCE_FLINCH);
    _hbox.bkb_final = get_hitbox_value(_hbox.attack, _hbox.hbox_num, HG_FINAL_BASE_KNOCKBACK);
    _hbox.throws_rock = get_hitbox_value(_hbox.attack, _hbox.hbox_num, HG_THROWS_ROCK);
    if (_hbox.kb_angle == 361)
        _hbox.draw_angle = 45
    else
        _hbox.draw_angle = _hbox.kb_angle
    if (_hbox.hit_owner.spr_dir == -1)
        _hbox.draw_angle = (180 - _hbox.draw_angle)
    if (_hbox.hit_flipper == 5)
        _hbox.draw_angle = (180 - _hbox.draw_angle)
    
    if (_hbox.type == 2) {
    	_hbox.image_alpha = 1;
        _hbox.hbox_group = -1;
        if (get_hitbox_value(_hbox.attack, par, HG_PROJECTILE_MASK) <= 0) {
	    	_hbox.mask_index = _hbox.sprite_index
	    	_hbox.uses_sprite_collision = 0;
        }
        else {
        	_hbox.mask_index = get_hitbox_value(_hbox.attack, par, HG_PROJECTILE_MASK);
	    	_hbox.uses_sprite_collision = 1;
	    	_hbox.image_xscale = _hbox.spr_dir;
	    	_hbox.image_yscale = 1;
        }
    	_hbox.draw_xscale = _hbox.spr_dir;
    	_hbox.draw_yscale = 1;
        _hbox.sprite_index = get_hitbox_value(_hbox.attack, par, HG_PROJECTILE_SPRITE) != 0 ? get_hitbox_value(_hbox.attack, par, HG_PROJECTILE_SPRITE) : asset_get("empty_sprite");
        _hbox.img_spd = get_hitbox_value(_hbox.attack, par, HG_PROJECTILE_ANIM_SPEED);
        if (_hbox.hsp == 0)
            _hbox.hsp = get_hitbox_value(_hbox.attack, _hbox.hbox_num, HG_PROJECTILE_HSPEED) * _hbox.hit_owner.spr_dir;
        if (_hbox.vsp == 0)
            _hbox.vsp = get_hitbox_value(_hbox.attack, _hbox.hbox_num, HG_PROJECTILE_VSPEED);
        _hbox.grav = get_hitbox_value(_hbox.attack, par, HG_PROJECTILE_GRAVITY);
        _hbox.frict = get_hitbox_value(_hbox.attack, par, HG_PROJECTILE_GROUND_FRICTION	);
        _hbox.air_friction = get_hitbox_value(_hbox.attack, par, HG_PROJECTILE_AIR_FRICTION);
        _hbox.walls = get_hitbox_value(_hbox.attack, par, HG_PROJECTILE_WALL_BEHAVIOR);
        _hbox.grounds = get_hitbox_value(_hbox.attack, par, HG_PROJECTILE_GROUND_BEHAVIOR);
        _hbox.enemies = get_hitbox_value(_hbox.attack, par, HG_PROJECTILE_ENEMY_BEHAVIOR);
        _hbox.unbashable = get_hitbox_value(_hbox.attack, par, HG_PROJECTILE_UNBASHABLE);
        _hbox.projectile_parry_stun = get_hitbox_value(_hbox.attack, par, HG_PROJECTILE_PARRY_STUN);
        _hbox.does_not_reflect = get_hitbox_value(_hbox.attack, par, HG_PROJECTILE_DOES_NOT_REFLECT);
        _hbox.transcendent = get_hitbox_value(_hbox.attack, par, HG_PROJECTILE_IS_TRANSCENDENT);
        _hbox.destroy_fx = get_hitbox_value(_hbox.attack, par, HG_PROJECTILE_DESTROY_EFFECT);
        _hbox.plasma_safe = get_hitbox_value(_hbox.attack, par, HG_PROJECTILE_PLASMA_SAFE);
        _hbox.spr_dir = _hbox.hsp == 0 ? 1 : sign(_hbox.hsp);
    }
}

#define bonus_increment_value(_bonus_name, _player, _added_score)
with (obj_stage_main) {
	for (var i = 0; i < array_length(player_bonus_default); i++) {
		if (string_lower(player_bonus_default[i].name) == string_lower(_bonus_name)) {
			if (_player == -1) {
				for (var j = 1; j < array_length(player_bonus_default[i].score); j++) {
					player_bonus_default[i].score[j] += _added_score;
				}
			}
			else {
				player_bonus_default[i].score[_player] += _added_score;
			}
			break;
		}
	}
}
#define reset_attack_grid(_attack)
with obj_stage_main { //Main stage script object
    for (var i = 0; i <= 20; i++) {
        set_attack_value(_attack, i, 0);
    }
    if (other.ag_num_windows > 0)
    for (var w = 1; w <= other.ag_num_windows; w++) {
        for (var i = 0; i <= 13; i++) {
            set_window_value(_attack, w, i, 0);
        }
        set_window_value(_attack, w, 24, 0);
        set_window_value(_attack, w, 26, 0);
        set_window_value(_attack, w, 31, 0);
        set_window_value(_attack, w, 32, 0);
        set_window_value(_attack, w, 57, 0);
        set_window_value(_attack, w, 58, 0);
        set_window_value(_attack, w, 59, 0);
        set_window_value(_attack, w, 60, 0);
    }
    if (other.hg_num_hitboxes > 0)
    for (var w = 1; w <= other.hg_num_hitboxes; w++) {
        for (var i = 0; i <= 60; i++) {
            set_hitbox_value(_attack, w, i, 0);
        }
    }
}