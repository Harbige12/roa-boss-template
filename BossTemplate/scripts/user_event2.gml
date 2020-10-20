//Use this to call custom update functions.

/*
If you want to create an enemy on a timer, make a timer variable and at the time you want it to spawn, call this function (replace [marker_num] with your marker):
create_enemy(get_marker_x([marker_num]), get_marker_y([marker_num]), [enemy_id])
*/

//DO NOT EDIT BELOW!
#define create_enemy(spawn_x, spawn_y, enemyID)
var e = instance_create(spawn_x, spawn_y, "obj_stage_article", 6);
e.spawn_variables[0] = enemyID;
return e;