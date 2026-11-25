var player = collision_rectangle(x - 9, y - 9, x + 9, y + 9,
    [obj_player, obj_test_player], false, true);
if (player != noone) {
    player.missiles_unlocked = true;
    instance_destroy();
}
