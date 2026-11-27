var player = collision_rectangle(x - 9, y - 9, x + 9, y + 9, obj_player, false, true);
if (player != noone) {
    player.missiles_unlocked = true;
    player.missile_ammo += 5;
    instance_destroy();
}
