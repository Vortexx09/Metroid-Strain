var previous_colour = draw_get_colour();
draw_set_colour(is_missile ? c_orange : c_aqua);
var trail_length = beam_speed * 0.6;
draw_line_width(x, y, x - beam_dx * trail_length, y - beam_dy * trail_length, is_missile ? 5 : 3);
draw_set_colour(previous_colour);
