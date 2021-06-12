//
if (hit_player_obj.clone || hit_player_obj.custom_clone || ("fake_stock" not in hit_player_obj))
    exit;
if (!in_training) {
    hit_player_obj.fake_stock -= 1;
    hit_player_obj.no_lives_lost = false;
}

if (hit_player_obj.fake_stock <= 0) {
    dead_players ++;
    player_is_dead[hit_player_obj.player] = 1;
    player_boss_hits[hit_player_obj.player] /= 2;
}