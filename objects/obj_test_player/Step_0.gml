player_shooting_step();

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

player_shooting_fire(movement.terrain);

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
