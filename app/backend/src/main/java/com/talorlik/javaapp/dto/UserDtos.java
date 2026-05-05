package com.talorlik.javaapp.dto;

import com.talorlik.javaapp.domain.Role;
import com.talorlik.javaapp.domain.User;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.time.Instant;
import java.util.Set;
import java.util.stream.Collectors;

public class UserDtos {

    public record ProfileResponse(
        Long id,
        String email,
        String fullName,
        boolean verified,
        boolean enabled,
        Set<String> roles,
        Instant createdAt,
        Instant updatedAt
    ) {
        public static ProfileResponse of(User u) {
            return new ProfileResponse(
                u.getId(),
                u.getEmail(),
                u.getFullName(),
                u.isVerified(),
                u.isEnabled(),
                u.getRoles().stream().map(Role::getName).collect(Collectors.toSet()),
                u.getCreatedAt(),
                u.getUpdatedAt()
            );
        }
    }

    public record ProfileUpdateRequest(
        @NotBlank @Size(max = 255) String fullName
    ) {}

    public record AdminUpdateRequest(
        @Size(max = 255) String fullName,
        Boolean enabled,
        Boolean resetVerification
    ) {}
}
