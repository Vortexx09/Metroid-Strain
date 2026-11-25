shot_cooldown = max(0, shot_cooldown - 1);
shoot_pose_steps = max(0, shoot_pose_steps - 1);

if (missiles_unlocked && keyboard_check_pressed(ord("Q"))) {
    missile_selected = !missile_selected;
}

var movement = player_movement_step();
if (is_undefined(movement)) {
    if (hanging) {
        shoot_pose_steps = 0;
    }
    exit;
}

var next_state;
var next_sprite;
var grounded = movement.grounded;

if (shot_cooldown == 0 && keyboard_check(ord("Z"))) {
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
    if (collision_line(beam_x, beam_y, muzzle_x, muzzle_y, movement.terrain, true, true) == noone) {
        instance_create_layer(muzzle_x, muzzle_y, layer, obj_test_beam,
            { direction: shot_angle, is_missile: missile_selected });
    }

    shot_cooldown = missile_selected ? missile_interval : shot_interval;
    shoot_pose_steps = aim_y == 0 ? shot_interval : 0;
    shoot_facing_right = aim_x > 0;
}

if (grounded) {
    spin_jump = false;
    wall_jump_steps = 0;
    if (shoot_pose_steps > 0) {
        if (movement.moving) {
            next_state = "run_shoot";
            next_sprite = shoot_facing_right ? spr_samus_runshoot_r : spr_samus_runshoot_l;
        } else {
            next_state = "idle_shoot";
            next_sprite = shoot_facing_right ? spr_samus_idleshoot_r : spr_samus_idleshoot_l;
        }
    } else if (movement.moving) {
        next_state = "run";
        next_sprite = facing_right ? spr_samus_run_r : spr_samus_run_l;
    } else {
        next_state = "idle";
        next_sprite = facing_right ? spr_samus_idle_r : spr_samus_idle_l;
    }
} else if (spin_jump) {
    next_state = "spin_jump";
    next_sprite = facing_right ? spr_samus_runjump_r : spr_samus_runjump_l;
} else {
    next_state = "jump";
    next_sprite = facing_right ? spr_samus_idlejump_r : spr_samus_idlejump_l;
}

if (sprite_index != next_sprite) {
    var next_frame = next_state == animation_state ? image_index : 0;
    sprite_index = next_sprite;
    image_index = next_frame;
}
animation_state = next_state;

if (animation_state == "jump") {
    // Play the upright jump once, following the rise and fall.
    image_speed = 0;
    var jump_progress = clamp((vertical_speed + jump_speed) / (2 * jump_speed), 0, 1);
    image_index = min(image_number - 1, floor(jump_progress * image_number));
} else {
    image_speed = 1;
}
