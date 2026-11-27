if (reset_steps > 0) {
    reset_steps--;
    if (reset_steps == 0) {
        target_hp = max_health;
        last_damage = 0;
    }
}
