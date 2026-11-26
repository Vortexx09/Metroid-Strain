var previous_colour = draw_get_colour();
draw_set_colour(missile_selected ? c_orange : c_aqua);
var weapon_name = missile_selected ? "Misiles" : "Rayo";
draw_text(12, 12, missiles_unlocked ? weapon_name + "   [Q] Cambiar" : weapon_name);
if (beam_charge_steps > beam_charge_delay) {
    var charge = (beam_charge_steps - beam_charge_delay) / (beam_charge_full - beam_charge_delay);
    draw_set_colour(charge >= 1 ? c_yellow : c_aqua);
    draw_text(12, 30, charge >= 1 ? "Rayo cargado" : "Carga " + string(floor(charge * 100)) + "%");
}
draw_set_colour(previous_colour);
