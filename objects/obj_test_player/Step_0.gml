var move_left = keyboard_check(vk_left) || keyboard_check(ord("A"));
var move_right = keyboard_check(vk_right) || keyboard_check(ord("D"));
var up_pressed = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"));
var space_pressed = keyboard_check_pressed(vk_space);
var jump_pressed = space_pressed || up_pressed;
var horizontal_step = move_right - move_left;

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

if (jump_pressed && !place_meeting(x, y + 1, obj_test_solid)) {
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

if (horizontal_step != 0) {
    facing_right = horizontal_step > 0;
}

var start_x = x;
var side_solid = noone;
repeat (abs(horizontal_step) * horizontal_speed) {
    side_solid = instance_place(x + horizontal_step, y, obj_test_solid);
    if (side_solid != noone) {
        wall_jump_steps = 0;
        break;
    }
    x += horizontal_step;
}

if (jump_pressed && place_meeting(x, y + 1, obj_test_solid)) {
    vertical_speed = -jump_speed;
    vertical_remainder = 0;
    spin_jump = horizontal_step != 0;
}
vertical_speed = min(vertical_speed + gravity_per_step, terminal_speed);

if (side_solid != noone && vertical_speed >= 0
    && !place_meeting(x, y + 1, obj_test_solid)) {
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
            clear_path = !place_meeting(x, check_y, obj_test_solid);
        }
        for (var offset = 1; clear_path && offset <= mask_width; offset++) {
            clear_path = !place_meeting(x + horizontal_step * offset, stand_y, obj_test_solid);
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
    if (place_meeting(x, y + vertical_step, obj_test_solid)) {
        vertical_speed = 0;
        vertical_remainder = 0;
        break;
    }
    y += vertical_step;
}

var next_state;
var next_sprite;
var grounded = vertical_speed >= 0 && place_meeting(x, y + 1, obj_test_solid);
if (grounded) {
    spin_jump = false;
    wall_jump_steps = 0;
    if (x != start_x) {
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
