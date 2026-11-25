if (reset_steps > 0) {
    reset_steps--;
    if (reset_steps == 0) {
        health = max_health;
        last_damage = 0;
    }
}
