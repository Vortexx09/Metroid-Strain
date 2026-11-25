function player_shooting_init() {
    shot_cooldown = 0;
    shot_interval = 10;
    missile_interval = 20;
    missiles_unlocked = false;
    missile_selected = false;
    shoot_pose_steps = 0;
    shoot_facing_right = true;
}

function player_shooting_step() {
    shot_cooldown = max(0, shot_cooldown - 1);
    shoot_pose_steps = max(0, shoot_pose_steps - 1);

    if (missiles_unlocked && keyboard_check_pressed(ord("Q"))) {
        missile_selected = !missile_selected;
    }
}

function player_shooting_fire(_terrain) {
    if (shot_cooldown > 0 || !keyboard_check(ord("Z"))) {
        return;
    }

    var aim_x = keyboard_check(ord("L")) - keyboard_check(ord("J"));
    var aim_y = keyboard_check(ord("K")) - keyboard_check(ord("I"));
    if (aim_x == 0 && aim_y == 0) {
        aim_x = facing_right ? 1 : -1;
    }

    var shot_angle = point_direction(0, 0, aim_x, aim_y);
    var beam_x = x + 16;
    var beam_y = y + 12;
    var muzzle_x = beam_x + lengthdir_x(14, shot_angle);
    var muzzle_y = beam_y + lengthdir_y(14, shot_angle);
    if (collision_line(beam_x, beam_y, muzzle_x, muzzle_y, _terrain, true, true) == noone) {
        instance_create_layer(muzzle_x, muzzle_y, layer, obj_test_beam,
            { direction: shot_angle, is_missile: missile_selected });
    }

    shot_cooldown = missile_selected ? missile_interval : shot_interval;
    shoot_pose_steps = aim_y == 0 ? shot_interval : 0;
    shoot_facing_right = aim_x > 0;
}
