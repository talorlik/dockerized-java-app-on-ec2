package com.talorlik.javaapp.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class AuthDtos {

    public record SignupRequest(
        @Email @NotBlank String email,
        @NotBlank @Size(min = 12, max = 128) String password,
        @NotBlank @Size(max = 255) String fullName
    ) {}

    public record VerifyRequest(
        @Email @NotBlank String email,
        @NotBlank @Size(min = 4, max = 32) String code
    ) {}

    public record LoginRequest(
        @Email @NotBlank String email,
        @NotBlank String password
    ) {}

    public record TokenResponse(String token, long expiresInSeconds) {}

    public record GenericResponse(String status, String message) {}
}
