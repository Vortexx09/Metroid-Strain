var previous_colour = draw_get_colour();
draw_set_colour(c_aqua);
draw_line_width(x, y, x - beam_dx * 0.6, y - beam_dy * 0.6, 3);
draw_set_colour(previous_colour);
