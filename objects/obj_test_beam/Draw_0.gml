var previous_colour = draw_get_colour();
draw_set_colour(is_missile ? c_orange : (is_charged ? c_yellow : c_aqua));
var beam_width = is_charged ? 7 : (is_missile ? 5 : 3);
if (beam_steps_travelled == 0) {
    draw_circle(x, y, beam_width * 0.5, false);
} else {
    var trail_length = is_charged ? 1 : 0.6;
    draw_line_width(x, y, x - beam_dx * trail_length, y - beam_dy * trail_length, beam_width);
}
draw_set_colour(previous_colour);
