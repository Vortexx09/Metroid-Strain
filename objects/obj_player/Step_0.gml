player_shooting_step();
var fire_pressed = keyboard_check_pressed(ord("Z"));
var movement = player_movement_step(fire_pressed);
if (is_undefined(movement)) {
    beam_charge_steps = 0;
    if (hanging) {
        shoot_pose_steps = 0;
        animator.hang(!facing_right);
    } else {
        animator.update(facing_right ? 1 : -1, false, true, false, false);
    }
    exit;
}

var charged_shot = player_shooting_prepare(fire_pressed);
var firing_now = !is_undefined(charged_shot);
var aim = player_shooting_aim(movement.grounded && movement.moving);
if (movement.grounded) {
    spin_jump = false;
    wall_jump_steps = 0;
} else if (firing_now && spin_jump) {
    spin_jump = false;
    wall_jump_steps = 0;
    horizontal_remainder = 0;
}

var aim_style = PlayerIdleAim.Forward;
if (aim.y < 0) {
    aim_style = aim.x == 0 ? PlayerIdleAim.Up : PlayerIdleAim.DiagonalUp;
} else if (aim.y > 0) {
    aim_style = aim.x == 0 ? PlayerIdleAim.Down : PlayerIdleAim.DiagonalDown;
}

var look_direction = facing_right ? 1 : -1;
if (!spin_jump && aim.x != 0) {
    look_direction = aim.x;
    facing_right = aim.x > 0;
}
animator.update(look_direction, movement.moving, movement.grounded, shoot_pose_steps > 0,
    false, aim_style, spin_jump, movement.jump_progress, fire_pressed, firing_now);
if (firing_now) {
    player_shooting_fire(movement.terrain, aim, charged_shot);
}
