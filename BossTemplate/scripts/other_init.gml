//The number of fake stock.
//We do this so that the match doesn't end prematurely.
fake_stock = 2;

cpu_target_timer = 0;

if (is_player_on(player)) {
    with (obj_stage_main) {
        player_count++;
    }
}

no_lives_lost = true;

//Boss-specific code
cpu_target = noone;

