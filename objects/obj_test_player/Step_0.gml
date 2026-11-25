var move_left = keyboard_check(vk_left) || keyboard_check(ord("A"));
var move_right = keyboard_check(vk_right) || keyboard_check(ord("D"));
var jump_pressed = keyboard_check_pressed(vk_space)
    || keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"));

var horizontal_step = move_right - move_left;
repeat (abs(horizontal_step) * move_speed) {
    if (place_meeting(x + horizontal_step, y, obj_test_solid)) {
        break;
    }
    x += horizontal_step;
}

if (jump_pressed && place_meeting(x, y + 1, obj_test_solid)) {
    vertical_speed = -jump_speed;
    vertical_remainder = 0;
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
