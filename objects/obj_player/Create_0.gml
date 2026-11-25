animator = new PlayerAnimator(id);
animator.update(0, false, true, false, false);
if (room == rm_overworld) {
    preview_jump_time = 0;
} else {
    mask_index = spr_test_square;
    player_movement_init();
    player_shooting_init();
}
