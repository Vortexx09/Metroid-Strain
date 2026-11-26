var next_x = x + beam_dx;
var next_y = y + beam_dy;
beam_life--;

if (beam_life <= 0
    || next_x < 0 || next_x >= room_width || next_y < 0 || next_y >= room_height
    || collision_line(x, y, next_x, next_y, [obj_test_solid, obj_test_ramp], true, true) != noone) {
    instance_destroy();
    exit;
}

x = next_x;
y = next_y;
beam_steps_travelled++;
