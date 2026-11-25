beam_life--;
if (beam_life <= 0) {
    instance_destroy();
    exit;
}

// Resolve nearby impacts in travel order so the first obstacle stops the shot.
repeat (beam_speed) {
    var next_x = x + beam_dx;
    var next_y = y + beam_dy;
    if (next_x < 0 || next_x >= room_width || next_y < 0 || next_y >= room_height
        || collision_line(x, y, next_x, next_y, terrain, true, true) != noone) {
        instance_destroy();
        exit;
    }

    var target = collision_line(x, y, next_x, next_y, obj_test_target, false, true);
    if (target != noone) {
        target.apply_damage(shot_damage);
        instance_destroy();
        exit;
    }

    x = next_x;
    y = next_y;
}
