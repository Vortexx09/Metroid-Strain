var move_left = keyboard_check(vk_left) || keyboard_check(ord("A"));
var move_right = keyboard_check(vk_right) || keyboard_check(ord("D"));
var jump_pressed = keyboard_check_pressed(vk_space)
    || keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"));

var horizontal_step = move_right - move_left;
if (horizontal_step != 0) {
    facing_right = horizontal_step > 0;
}

var start_x = x;
repeat (abs(horizontal_step) * move_speed) {
    if (place_meeting(x + horizontal_step, y, obj_test_solid)) {
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
