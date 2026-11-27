function player_presentation_draw() {
    draw_sprite(sprite_index, image_index,
        x - 16 + sprite_get_xoffset(sprite_index),
        y - 16 + sprite_get_yoffset(sprite_index));
}

function player_presentation_draw_hud() {
    var previous_colour = draw_get_colour();
    draw_set_colour(missile_selected ? c_orange : c_aqua);
    var weapon_name = missile_selected ? "Misiles" : "Rayo";
    if (missiles_unlocked) {
        weapon_name += "   |   Munición: " + string(missile_ammo) + "   [Q] Cambiar";
    }
    draw_text(12, 12, weapon_name);
    draw_set_colour(weapon_overheated ? c_red : c_orange);
    draw_text(12, 30, "Calor " + string(weapon_heat) + "%" + (weapon_overheated ? "  Sobrecalentada" : ""));
    if (beam_charge_steps > beam_charge_delay) {
        var charge = (beam_charge_steps - beam_charge_delay) / (beam_charge_full - beam_charge_delay);
        draw_set_colour(charge >= 1 ? c_yellow : c_aqua);
        draw_text(12, 48, charge >= 1 ? "Rayo cargado" : "Carga " + string(floor(charge * 100)) + "%");
    } else if (missile_charge_steps > 0) {
        draw_set_colour(c_yellow);
        var charge = floor(100 * missile_charge_steps / missile_charge_duration);
        draw_text(12, 48, "Carga del misil: " + string(charge) + "%");
    }
    draw_set_colour(previous_colour);
}
