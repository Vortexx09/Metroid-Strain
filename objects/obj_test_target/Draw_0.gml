var previous_colour = draw_get_colour();
draw_set_colour(health > 0 ? c_lime : c_gray);
draw_rectangle(x, y, x + 31, y + 31, true);
draw_rectangle(x + 12, y + 12, x + 19, y + 19, false);
draw_text(x - 6, y - 18, string(health) + "/" + string(max_health));
if (last_damage > 0) {
    draw_text(x - 6, y - 34, "-" + string(last_damage));
}
draw_set_colour(previous_colour);
