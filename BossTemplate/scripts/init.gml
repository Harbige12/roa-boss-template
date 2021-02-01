//This contains stage variables.
//This will include info about the boss's fighting state, if it's killed, etc.

active_bosses = ds_list_create();

//Aether mode = Hard mode
hard_mode = is_aether_stage();

//Number of players in this match.
player_count = 0;
dead_players = 0;

//Start of battle checks
_init = false;

//End of battle checks
end_battle = false;
lost_battle = false;
end_battle_cooldown = -1;
end_battle_phase = -1 // -1 = battle hasn't ended yet; >= 0 = total up scores and add bonuses;
end_battle_timer = 0;
the_end = false;

//Number of dead players
player_is_dead = array_create(5, 0);
player_boss_hits = array_create(5, 0);
player_display_hits = array_create(5, 0);

//Array of bonuses
//These are lightweight objects!
player_bonus_default_on = true;
player_time_bonus = 0;
player_time_bonus_max = 3600 * 3; //3 minutes
player_last_hit = 0;

player_bonus_default[0] = {
    name : "Time Bonus",
    score : array_create(5, 0)
}

player_bonus_default[1] = {
    name : "Parry Bonus",
    score : array_create(5, 0)
}

player_bonus_default[2] = {
    name : "No Lives Lost",
    score : array_create(5, 0)
}

player_bonus_default[3] = {
    name : "Last Hit",
    score : array_create(5, 0)
}

player_bonus_default[4] = {
    name : "Expert Mode Clear",
    score : array_create(5, 0)
}

player_bonus_extra = array_create(0);

//Camera logic
view_follow = ds_list_create();
view_focus = noone;
cam_x = 0;
cam_y = 0;

//Dummy player index
dummy_player = -1;

//Training mode check
in_training = get_training_cpu_action() != CPU_FIGHT

//Enemy HUD
active_enemy = noone;
active_enemy_timer = 0;
active_enemy_timer_max = 180;
enemy_health_hud_mode = 0; //0 = show health on HUD; 1 = show health on enemy; 2 = both; 3 = none

//Character compatibility
wet = false; //For Wizard

//Custom boss HUD stuff
hud_draw_default_healthbar = true; //Draws the healthbar.
hud_healthbar_spr = sprite_get("boss_hp_bar")
hud_healthbar_back_spr = sprite_get("boss_hp_back")
hud_percentbar_spr = sprite_get("boss_percent_back")
hud_bossbar_yoffset = 24
hud_healthbar_yspacing = 20;
hud_bossname_xoffset = 0
hud_bossname_yoffset = 32
hud_percent_xoffset = 80
hud_percent_yoffset = 8
