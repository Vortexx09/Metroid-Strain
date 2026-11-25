if (room == rm_overworld) {
    exit;
}

var previous_colour = draw_get_colour();
draw_set_colour(missile_selected ? c_orange : c_aqua);
var weapon_name = missile_selected ? "Misiles" : "Rayo";
draw_text(12, 12, missiles_unlocked ? weapon_name + "   [Q] Cambiar" : weapon_name);
draw_set_colour(weapon_overheated ? c_red : c_orange);
draw_text(12, 30, "Calor " + string(weapon_heat) + "%" + (weapon_overheated ? "  Sobrecalentada" : ""));
draw_set_colour(previous_colour);
