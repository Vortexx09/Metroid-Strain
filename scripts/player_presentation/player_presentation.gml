function player_presentation_draw() {
    if (room == rm_overworld) {
        draw_self();
    } else {
        draw_sprite(sprite_index, image_index, x - 16, y - 16);
    }
}

function player_presentation_draw_hud() {
    if (room == rm_overworld) {
        return;
    }

    var previous_colour = draw_get_colour();
    draw_set_colour(missile_selected ? c_orange : c_aqua);
    var weapon_name = missile_selected ? "Misiles" : "Rayo";
    if (missiles_unlocked) {
        weapon_name += "   |   Munición: " + string(missile_ammo) + "   [Q] Cambiar";
    }
    draw_text(12, 12, weapon_name);
    draw_set_colour(weapon_overheated ? c_red : c_orange);
    draw_text(12, 30, "Calor " + string(weapon_heat) + "%" + (weapon_overheated ? "  Sobrecalentada" : ""));
    if (missile_charge_steps > 0) {
        draw_set_colour(c_yellow);
        draw_text(12, 48, "Carga del misil: "
            + string(floor(100 * missile_charge_steps / missile_charge_duration)) + "%");
    }
    draw_set_colour(previous_colour);
}
