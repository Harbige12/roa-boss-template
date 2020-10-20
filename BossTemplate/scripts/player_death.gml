//
if (!in_training)
    hit_player_obj.fake_stock -= 1;

if (hit_player_obj.fake_stock <= 0) {
    dead_players ++;
    player_is_dead[hit_player_obj.player] = 1;
    player_boss_hits[hit_player_obj.player] /= 2;
}