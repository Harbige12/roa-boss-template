# roa-boss-template
A guide and code repository on how to make bosses for Rivals of Aether.

By Harbige12.

# Introduction
So you've deceded to make a boss for Rivals of Aether, huh? This guide should make it easier to create the boss of your dreams, all using stage scripting.

Fist, make sure you're on the Rivals Workshop branch and are updated to at least 1.5.13. With that out of the way, let's get started.

# Absolutely Needed Code:
These are needed for the code to work.

Copy and paste these code snippets into the files specified.

## config.ini
Add this code here. This sets the rules to an infinte match.

```
[scripting_overrides]
stocks="0"
time="0"
teams="-1"
team_attack="-1"
hide_hud="-1"
```

## init.gml
This contains the variables for the fight state machine.

#### Code
```
boss_name = "REPLACE ME";
boss_fight_state = 0;
num_bosses = 1;

//Now, each boss has an index associated with it. The maximum index is num_bosses - 1.
boss_spawn_marker[0] = 1;
boss_article_index[0] = 1;
boss_article_id[0] = noone;

boss_state_timer = 0;
boss_healthbar_timer = 0;

hard_mode = is_aether_stage(); //Optional

player_count = 0;
dead_players = 0;
player_is_dead = array_create(5, 0);
player_boss_hits = array_create(5, 0);
dummy_player = -1;

shake_amount = 0;
```
#### Details
Variable              | Description
--------------------  | -----------
`boss_name`           | The name to display on the healthbar.
`boss_fight_state`    | The state of the state machine. 0 = Initialization; 1 = Intro, 2 = Fight, 3 = Death
`num_bosses`          | The number of bosses to spawn. Useful for bosses with multiple objects with a shared healthbar.
`boss_spawn_marker[i]`          | The stage marker index where the boss will spawn.
`boss_article_index[i]`          | The stage article that contains the boss code.
`boss_article_id[i]`          | The instance of the boss article.
`boss_state_timer`          | Number of frames that occurred in the current state.
`boss_healthbar_timer`          | Used for drawing the healthbar.
`hard_mode`          | (Optional) Used for setting boss hared modes. Aether stages are used to activate hard mode in this example.
`player_count`        | The number of players total in this match.
`dead_players`        | The number of dead players.
`player_is_dead`        | If the player with the specified array index is dead, this variable is set.
`player_boss_hits`        | The number of hits on the boss for the player with the specified array index.
`dummy_player`        | If we're playing with AI, this sacrifices a player for single player mode (or AI fights). More details on this later.
`shake_amount`        | The amount to shake the screen. Set to 0 to not shake the screen.


## other_init.gml
This contains player variables.

#### Code
```
fake_stock = 2;

cpu_target_timer = 0;

if (is_player_on(player)) {
    obj_stage_main.player_count++;
}
```
#### Details
Variable              | Description
--------------------  | -----------
`fake_stock`          | A "fake" stock count. We can't use normal stock or else the game will end prematurely if all players die.
`cpu_target_timer`    | Used for AI targeting.

## update.gml
This code handles all logic.

#### Code
```
//CPU player handling
var controlled_players = 0;
with (asset_get("oPlayer")) {
    if (clone) continue;
	if (!variable_instance_exists(id, "ai_target"))
		controlled_players ++;
}

with (asset_get("oPlayer")) {
    if (clone)
        continue;
	if (controlled_players <= 1) {
	    if (obj_stage_main.dummy_player <= 0) {
	        if (variable_instance_exists(id, "ai_target") && player >= obj_stage_main.player_count) {
	            if (fake_stock > 0) { 
	                fake_stock = 0;
	                obj_stage_main.dummy_player = player;
	                obj_stage_main.dead_players ++;
	            }
	        }
	    }
	}
    //Fake stocks
    if (fake_stock <= 0) {
        set_state(PS_RESPAWN);
        var chosen = other.boss_article_id[random_func(0, other.num_bosses - 1, true)];
        if (instance_exists(chosen)) {
            cpu_target_timer --
            
            if (cpu_target_timer <= 0) {
            //Check for alive bosses
                x = chosen.x;
                y = chosen.y;
                hsp = chosen.hsp;
                vsp = chosen.vsp;
            }
        }
        else {
            var mx = get_marker_x(other.boss_spawn_marker[0]);
            var my = get_marker_y(other.boss_spawn_marker[0]);

            if (mx == -1 || my == -1) {
                print_debug("The boss marker was not found!");
                print_debug("Boss object: " + other.boss_article_index[0]);
                continue;
            }
            x = mx;
            y = my;
            hsp = 0;
            vsp = 0;
        }
        
        x = clamp(x, view_get_xview(), view_get_xview() + view_get_wview());
        y = clamp(y, view_get_yview(), view_get_yview() + view_get_hview());
        
        invincible = true;
        invince_time = 100;
        go_trough = true;
        fall_through = true;
        hitstop = 100;
        visible = false;
        state_timer = 0;
    }
}

//Screen shaker
if (shake_amount > 0) {
    var xview = view_get_xview()+view_get_wview()/2;
    var yview = view_get_yview()+view_get_hview()/2;
    var xview_min = view_get_wview()/2;
    var yview_min = view_get_hview()/2;
    var xview_max = room_width-xview_min;
    var yview_max = room_height-yview_min;
    
    var new_xview = clamp(clamp(xview+random_func(3,shake_amount,true),xview-shake_amount,xview+shake_amount),xview_min,xview_max);
    var new_yview = clamp(clamp(yview+random_func(4,shake_amount,true),yview-shake_amount,yview+shake_amount),yview_min,yview_max);
    if (get_gameplay_time() % 3 == 0)
        set_view_position(new_xview,new_yview);
}

//Player death check
if (dead_players >= player_count) {
    find_scores();
}

//This is the boss fight state machine.
switch (boss_fight_state) {
    case 0: //Initializing the boss (DON'T EDIT THIS UNLESS YOU KNOW WHAT YOU'RE DOING)
        
        boss_state_timer ++;
        
        if (boss_state_timer < 240) {
            music_stop();
        }
        if (boss_state_timer == 240) {
            var success = true;
            for (var i = 0; i < num_bosses; i++) {
                var mx = get_marker_x(boss_spawn_marker[i]);
                var my = get_marker_y(boss_spawn_marker[i]);

                if (mx == -1 || my == -1) {
                    print_debug("The boss marker was not found!");
                    print_debug("Boss object: " + boss_article_index[i]);
                    success = false;
                    continue;
                }

                boss_article_id[i] = instance_create(mx, my, "obj_stage_article", boss_article_index[i]);

                if (!variable_instance_exists(boss_article_id[i], "hitpoints")) {
                    with (boss_article_index[i]) instance_destroy();
                    print_debug("The spawned boss has no hitpoints variable, which is required.");
                    print_debug("Boss object: " + boss_article_index[i]);
                    success = false;
                    continue;
                }
            }

            if (success) {
                boss_state_timer = 0;
                boss_fight_state = 1;
            }
        }
    break;
    case 1:
        boss_state_timer ++;
        if (boss_healthbar_timer == 0) {
            music_play_file("music_loop");
            var ready = true;
            for (var i = 0; i < num_bosses; i++) {
                if (!instance_exists(boss_article_id[i]))
                    continue;
                if (variable_instance_exists(boss_article_id[i], "done_intro")) {
                    if (!boss_article_id[i].done_intro)
                        ready = false;
                }
            }

            if (ready)
                boss_healthbar_timer = 1;
        }
        else {
            boss_healthbar_timer ++;
            if (boss_healthbar_timer % 2 == 0) {
                sound_play( sound_get("sfx_boss_hp_tick"));
            }

            if (boss_healthbar_timer >= 56) {
                boss_healthbar_timer = 0;
                boss_fight_state = 2;
                for (var i = 0; i < num_bosses; i++) {
                    if (!instance_exists(boss_article_id[i]))
                        continue;
                    if (variable_instance_exists(boss_article_id[i], "start_fight")) {
                        boss_article_id[i].start_fight = true;
                        boss_state_timer = 0;
                    }
                }
            }

        }
    break;
    case 2:
        boss_state_timer ++;

        //Check for alive bosses
        var done = true;
        for (var i = 0; i < num_bosses; i++) {
            if (instance_exists(boss_article_id[i]))
                done = false;
        }

        if (done) {
            boss_state_timer = 0;
            boss_fight_state = 3;
        }
    break;
    case 3:
        boss_state_timer ++;

        if (boss_state_timer == 16) {
           find_scores();
        }
    break;
}

#define find_scores
//Finding scores
var place;
var winner = array_create(4, 0);
for (var i = 1; i < 5; i++) { //i is the current player being checked. j is the player it's being compared to.
	place = 3; //Last place
	for (var j = 1; j < 5; j++) {
		if i == j continue; //lol same player
		var score1 = player_boss_hits[i] / (1 + player_is_dead[i]);
		var score2 = player_boss_hits[j] / (1 + player_is_dead[j]);
		if score1 > score2 {
			place--;
		}
	}
    if winner[place] != 0 winner[place] = -1; else winner[place] = i;
}

end_match(winner[0], winner[1], winner[2], winner[3]);
```

#### Details
1. The first part of the code handles stocks and the dummy player.
..* The dummy player is a player sacrificed for single player modes. Only applies if there is one controlled player.
2. The screen shaker code is used to shake the screen.
3. The boss state machine handles logic for bosses. No need to edit this.
3. find_scores() handles the final score count. Credit to Giik for the original code in The Sandbox. Edit this to see fit.

## draw_hud.gml
This will draw the HUD elements.

#### Code
```
var hud_x = 0;
var hud_y = 480;
var hud_size = 224;
var hud_padding = 16;
var hud_max_width = (hud_size + hud_padding) * 4;
var hud_width = (hud_size + hud_padding) * player_count;
var hud_offset = (hud_max_width - hud_width) / 2;

var hbar_x = view_get_wview() / 2;
var hbar_y = 24;
var hbar_fill = 0;

//Healthbar

switch(boss_fight_state) {
    case 0:
        hbar_y = -64;
        hbar_fill = 0;
    break;
    
    case 1:
        if (boss_state_timer <= 30)
            hbar_y = lerp(-64, 24, boss_state_timer / 30)
        else
            hbar_y = 24
        if (boss_healthbar_timer > 0) {
            if (boss_healthbar_timer < 56) 
                hbar_fill = ease_linear(0, 1, round(boss_healthbar_timer), 56);
            else {
                hbar_fill = 1
            }
        }
        else
            hbar_fill = 0;
    break;
    
    case 2:
        var hp_total = 0;
        var hp_sum = 0;
        for (var i = 0; i < num_bosses; i++)  {
            if (!instance_exists(boss_article_id[i]))
                continue;
            hp_total += boss_article_id[i].hitpoints_max;
            hp_sum += boss_article_id[i].hitpoints;
        }
        if (hp_total != 0)
            hbar_fill = hp_sum / hp_total;
    break;
    case 3:
        if (boss_state_timer <= 60)
            hbar_y = lerp(24, -64, boss_state_timer / 60)
        else
            hbar_y = -64
}

//Player HUD
var dx = hud_x + 8 + (dummy_player - 1) * (hud_size + hud_padding) + hud_offset;
if (dummy_player <= 0)
    dx = hud_x + 8 + (player_count) * (hud_size + hud_padding) + hud_offset;
draw_sprite(sprite_get("hud_difficulty"), hard_mode, dx, hud_y)

var xx = hbar_x - 320;
var yy = hbar_y + 32
var str = boss_name;

draw_set_font(asset_get("medFont"));
draw_set_halign(fa_left)

draw_sprite(sprite_get("boss_hp_back"), 0, hbar_x, hbar_y);
draw_sprite_part(sprite_get("boss_hp_bar"), 0, 0, 0, 640 * hbar_fill, 26, hbar_x - 320, hbar_y);

draw_text_color(xx + 2, yy - 2, str, c_black,c_black,c_black,c_black,1)
draw_text_color(xx - 2, yy - 2, str, c_black,c_black,c_black,c_black,1)
draw_text_color(xx + 2 , yy + 2, str, c_black,c_black,c_black,c_black,1)
draw_text_color(xx - 2, yy + 2, str, c_black,c_black,c_black,c_black,1)
draw_text_color(xx, yy, str, c_white,c_white,c_white,c_white,1)

draw_set_font(asset_get("roaLBLFont"));
draw_set_halign(fa_center)
xx = dx + 120;
yy = hud_y + 20
str = hard_mode ? "EXPERT" : "NORMAL";
var col = hard_mode ? c_maroon : c_white;

draw_text_color(xx + 2, yy - 2, str, c_black,c_black,c_black,c_black,1)
draw_text_color(xx - 2, yy - 2, str, c_black,c_black,c_black,c_black,1)
draw_text_color(xx + 2 , yy + 2, str, c_black,c_black,c_black,c_black,1)
draw_text_color(xx - 2, yy + 2, str, c_black,c_black,c_black,c_black,1)
draw_text_color(xx, yy, str, col,col,col,col,1)

with (asset_get("oPlayer")) {
    if (clone)
        continue;
    if (other.dummy_player != player ) {
        with (obj_stage_main) {
            draw_set_font(asset_get("roaLBLFont"));
            draw_set_halign(fa_left)
            
            var dx = hud_x + 8 + (other.player - 1) * (hud_size + hud_padding) + hud_offset;
            draw_sprite_ext(sprite_get("hud_life_counter"), 0, dx, hud_y - 36, 1, 1, 0, get_player_hud_color(other.player), 1);
    		
    		var xx = dx + 72;
    		var yy = hud_y - 36
    		var str = other.fake_stock;
    		draw_text_color(xx + 2, yy - 2, str, c_black,c_black,c_black,c_black,1)
    		draw_text_color(xx - 2, yy - 2, str, c_black,c_black,c_black,c_black,1)
    		draw_text_color(xx + 2 , yy + 2, str, c_black,c_black,c_black,c_black,1)
    		draw_text_color(xx - 2, yy + 2, str, c_black,c_black,c_black,c_black,1)
    		draw_text_color(xx, yy, str, c_white,c_white,c_white,c_white,1)
    		
            draw_set_font(asset_get("fName"));
            draw_set_halign(fa_left)
            
    		xx = dx;
    		yy = hud_y - 56
    		str = "Damage: " + string(round(player_boss_hits[other.player]));
    		draw_text_color(xx + 2, yy - 2, str, c_black,c_black,c_black,c_black,1)
    		draw_text_color(xx - 2, yy - 2, str, c_black,c_black,c_black,c_black,1)
    		draw_text_color(xx + 2 , yy + 2, str, c_black,c_black,c_black,c_black,1)
    		draw_text_color(xx - 2, yy + 2, str, c_black,c_black,c_black,c_black,1)
    		draw_text_color(xx, yy, str, c_white,c_white,c_white,c_white,1)
        }
    }
}
```
#### Details
The images used are in this repository. You may replace them, but the code might need to be adjusted.

## player_death.gml
This handles losing stocks.

#### Code
```
hit_player_obj.fake_stock -= 1;

if (hit_player_obj.fake_stock <= 0) {
    dead_players ++;
    player_is_dead[hit_player_obj.player] = 1;
}
```
# Coding the boss
Go inside the repository to check out boss creation.
