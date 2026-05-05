package com.talorlik.javaapp.unit;

import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import static org.assertj.core.api.Assertions.assertThat;

class PasswordPolicyTest {

    @Test
    void bcrypt_hash_verifies() {
        var encoder = new BCryptPasswordEncoder(10);
        String hash = encoder.encode("CorrectHorseBatteryStaple");
        assertThat(encoder.matches("CorrectHorseBatteryStaple", hash)).isTrue();
        assertThat(encoder.matches("wrong", hash)).isFalse();
    }
}
