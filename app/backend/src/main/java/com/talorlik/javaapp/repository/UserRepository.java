package com.talorlik.javaapp.repository;

import com.talorlik.javaapp.domain.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmailIgnoreCase(String email);

    boolean existsByEmailIgnoreCase(String email);

    @Query("""
        SELECT u FROM User u
        WHERE (:q IS NULL OR LOWER(u.email) LIKE LOWER(CONCAT('%', :q, '%'))
                          OR LOWER(u.fullName) LIKE LOWER(CONCAT('%', :q, '%')))
          AND (:verified IS NULL OR u.verified = :verified)
    """)
    Page<User> search(@Param("q") String q,
                      @Param("verified") Boolean verified,
                      Pageable pageable);
}
