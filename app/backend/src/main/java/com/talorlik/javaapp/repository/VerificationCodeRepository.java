package com.talorlik.javaapp.repository;

import com.talorlik.javaapp.domain.User;
import com.talorlik.javaapp.domain.VerificationCode;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.Optional;

public interface VerificationCodeRepository extends JpaRepository<VerificationCode, Long> {

    @Query("""
        SELECT v FROM VerificationCode v
        WHERE v.user = :user AND v.consumedAt IS NULL AND v.expiresAt > :now
        ORDER BY v.createdAt DESC
    """)
    Optional<VerificationCode> findActiveForUser(@Param("user") User user,
                                                 @Param("now") Instant now);

    @Modifying
    @Query("DELETE FROM VerificationCode v WHERE v.user = :user")
    void deleteAllForUser(@Param("user") User user);
}
