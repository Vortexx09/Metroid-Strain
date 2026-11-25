var previous_colour = draw_get_colour();
draw_set_colour(missile_selected ? c_orange : c_aqua);
var weapon_name = missile_selected ? "Misiles" : "Rayo";
draw_text(12, 12, missiles_unlocked ? weapon_name + "   [Q] Cambiar" : weapon_name);
draw_set_colour(previous_colour);
