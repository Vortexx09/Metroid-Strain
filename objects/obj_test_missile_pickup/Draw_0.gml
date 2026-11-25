var previous_colour = draw_get_colour();
draw_set_colour(c_orange);
draw_roundrect(x - 9, y - 9, x + 9, y + 9, false);
draw_set_colour(c_black);
draw_text(x - 5, y - 7, "M");
draw_set_colour(previous_colour);
