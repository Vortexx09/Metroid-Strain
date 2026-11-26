function weapon_projectile_init() {
    beam_speed = is_missile ? 16 : 12;
    beam_dx = lengthdir_x(1, direction);
    beam_dy = lengthdir_y(1, direction);
    beam_life = 60;
}

function weapon_projectile_step() {
    beam_life--;
    if (beam_life <= 0) {
        instance_destroy();
        return;
    }

    // Resolve nearby impacts in travel order so the first obstacle stops the shot.
    repeat (beam_speed) {
        var next_x = x + beam_dx;
        var next_y = y + beam_dy;
        if (next_x < 0 || next_x >= room_width || next_y < 0 || next_y >= room_height) {
            instance_destroy();
            return;
        }

        if (collision_line(x, y, next_x, next_y, terrain, true, true) != noone) {
            weapon_audio_impact(is_missile);
            instance_destroy();
            return;
        }

        var target = collision_line(x, y, next_x, next_y, obj_test_target, false, true);
        if (target != noone) {
            target.apply_damage(shot_damage);
            weapon_audio_impact(is_missile);
            instance_destroy();
            return;
        }

        x = next_x;
        y = next_y;
    }
}

function weapon_projectile_draw() {
    var previous_colour = draw_get_colour();
    draw_set_colour(is_charged ? c_yellow : (is_missile ? c_orange : c_aqua));
    var trail_length = beam_speed * 0.6;
    var trail_width = is_charged ? 7 : (is_missile ? 5 : 3);
    draw_line_width(x, y, x - beam_dx * trail_length, y - beam_dy * trail_length, trail_width);
    draw_set_colour(previous_colour);
}
