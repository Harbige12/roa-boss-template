timer++;

bg_x += bg_spd;
bg_y += bg_spd;

if (timer >= 90) {
    space_alpha = lerp(1, 0, (timer - 90) / 15);
    
    if (space_alpha <= 0) {
        instance_destroy();
        exit;
    }
}
else {
    if (timer < 30)
        shake_camera(16, 2);
        

    with (oPlayer) {
        hitpause = true;
        attack_invince = true;
        invince_time = 3;
        hitstop = 3;
        hitstop_full = 3;
        //Neo Mario
        if ("stomp_bounce" in self) {
			stomp_bounce = true;
			stomp_parried = true;
        }
    }
    
    with (obj_stage_article) {
        if (num == 6) {
            invincible = 3;
            hitpause = 3;
        }
    }
}



with (pHitBox) {
    if (orig_player = obj_stage_main.player) {
        instance_destroy(id);
        continue;
    }
}