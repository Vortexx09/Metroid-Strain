var move_left = keyboard_check(vk_left) || keyboard_check(ord("A"));
var move_right = keyboard_check(vk_right) || keyboard_check(ord("D"));
var up_pressed = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"));
var space_pressed = keyboard_check_pressed(vk_space);
var jump_pressed = space_pressed || up_pressed;
var input_direction = move_right - move_left;
var horizontal_step = input_direction;
shot_cooldown = max(0, shot_cooldown - 1);
shoot_pose_steps = max(0, shoot_pose_steps - 1);

if (hanging) {
    if (up_pressed) {
        x = climb_x;
        y = climb_y;
        hanging = false;
        animation_state = "idle";
        sprite_index = facing_right ? spr_samus_idle_r : spr_samus_idle_l;
        image_index = 0;
        image_speed = 1;
        exit;
    }

    var away_from_ledge = facing_right ? -1 : 1;
    if (!space_pressed || horizontal_step != away_from_ledge) {
        exit;
    }

    hanging = false;
    vertical_speed = -jump_speed;
    vertical_remainder = 0;
    spin_jump = true;
    jump_pressed = false;
}

var terrain = [obj_test_solid, obj_test_ramp];
var following_ground = vertical_speed >= 0 && place_meeting(x, y + 1, terrain);

if (jump_pressed && !following_ground) {
    var wall_side = facing_right ? 1 : -1;
    if (!place_meeting(x + wall_side, y, obj_test_solid)) {
        wall_side = -wall_side;
    }

    if (place_meeting(x + wall_side, y, obj_test_solid)) {
        wall_jump_direction = -wall_side;
        wall_jump_steps = wall_jump_duration;
        vertical_speed = -jump_speed;
        vertical_remainder = 0;
        spin_jump = true;
        jump_pressed = false;
    }
}

var horizontal_speed = move_speed;
if (wall_jump_steps > 0) {
    horizontal_step = wall_jump_direction;
    horizontal_speed = wall_jump_speed;
    wall_jump_steps--;
}

if (spin_jump) {
    if (horizontal_step == 0) {
        horizontal_step = spin_direction;
    }
    spin_direction = horizontal_step;
}

if (horizontal_step != 0) {
    facing_right = horizontal_step > 0;
}

var start_x = x;
var side_solid = noone;
repeat (abs(horizontal_step) * horizontal_speed) {
    var next_x = x + horizontal_step;
    side_solid = instance_place(next_x, y, obj_test_solid);
    if (side_solid != noone) {
        wall_jump_steps = 0;
        break;
    }
    if (place_meeting(next_x, y, obj_test_ramp)) {
        if (!following_ground || place_meeting(next_x, y - 1, terrain)) {
            break;
        }
        y--;
    } else if (following_ground && !place_meeting(next_x, y + 1, terrain)
        && (place_meeting(x, y + 1, obj_test_ramp) || place_meeting(next_x, y + 2, obj_test_ramp))
        && place_meeting(next_x, y + 2, terrain)) {
        y++;
    }
    x = next_x;
    following_ground = following_ground && place_meeting(x, y + 1, terrain);
}

if (jump_pressed && place_meeting(x, y + 1, terrain)) {
    vertical_speed = -jump_speed;
    vertical_remainder = 0;
    spin_jump = horizontal_step != 0;
    spin_direction = horizontal_step;
}
vertical_speed = min(vertical_speed + gravity_per_step, terminal_speed);

if (side_solid != noone && input_direction == horizontal_step && vertical_speed >= 0
    && !place_meeting(x, y + 1, terrain)) {
    // Use the same collision query as horizontal movement to find the wall.
    var ledge_top = side_solid.bbox_top;
    var ledge_offset = ledge_top - y;
    if (ledge_offset >= -2 && ledge_offset <= 16) {
        var hang_y = ledge_top - 8;
        var stand_y = ledge_top - sprite_get_height(mask_index);
        var mask_width = sprite_get_width(mask_index);
        var stand_x = x + horizontal_step * mask_width;

        // Check the climb route before allowing the grab.
        var clear_path = true;
        for (var check_y = hang_y; clear_path && check_y >= stand_y; check_y--) {
            clear_path = !place_meeting(x, check_y, terrain);
        }
        for (var offset = 1; clear_path && offset <= mask_width; offset++) {
            clear_path = !place_meeting(x + horizontal_step * offset, stand_y, terrain);
        }

        if (clear_path && place_meeting(stand_x, stand_y + 1, obj_test_solid)) {
            y = hang_y;
            climb_x = stand_x;
            climb_y = stand_y;
            vertical_speed = 0;
            vertical_remainder = 0;
            spin_jump = false;
            wall_jump_steps = 0;
            hanging = true;
            shoot_pose_steps = 0;
            animation_state = "hang";
            sprite_index = facing_right ? spr_samus_idlejump_r : spr_samus_idlejump_l;
            image_index = 1;
            image_speed = 0;
            exit;
        }
    }
}

vertical_remainder += vertical_speed;
var vertical_pixels = sign(vertical_remainder) * floor(abs(vertical_remainder));
vertical_remainder -= vertical_pixels;
var vertical_step = sign(vertical_pixels);
repeat (abs(vertical_pixels)) {
    if (place_meeting(x, y + vertical_step, terrain)) {
        vertical_speed = 0;
        vertical_remainder = 0;
        break;
    }
    y += vertical_step;
}

var next_state;
var next_sprite;
var grounded = vertical_speed >= 0 && place_meeting(x, y + 1, terrain);

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
    if (collision_line(beam_x, beam_y, muzzle_x, muzzle_y, terrain, true, true) == noone) {
        instance_create_layer(muzzle_x, muzzle_y, layer, obj_test_beam, { direction: shot_angle });
    }

    shot_cooldown = shot_interval;
    shoot_pose_steps = aim_y == 0 ? shot_interval : 0;
    shoot_facing_right = aim_x > 0;
}

if (grounded) {
    spin_jump = false;
    wall_jump_steps = 0;
    if (shoot_pose_steps > 0) {
        if (x != start_x) {
            next_state = "run_shoot";
            next_sprite = shoot_facing_right ? spr_samus_runshoot_r : spr_samus_runshoot_l;
        } else {
            next_state = "idle_shoot";
            next_sprite = shoot_facing_right ? spr_samus_idleshoot_r : spr_samus_idleshoot_l;
        }
    } else if (x != start_x) {
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
