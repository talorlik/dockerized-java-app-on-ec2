package com.talorlik.javaapp.controller;

import com.talorlik.javaapp.dto.AuthDtos.*;
import com.talorlik.javaapp.security.JwtService;
import com.talorlik.javaapp.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService auth;
    private final JwtService jwt;

    public AuthController(AuthService auth, JwtService jwt) {
        this.auth = auth;
        this.jwt = jwt;
    }

    @PostMapping("/signup")
    public ResponseEntity<GenericResponse> signup(@Valid @RequestBody SignupRequest req) {
        auth.signup(req.email(), req.password(), req.fullName());
        // Generic accept response: never reveal whether the email pre-existed.
        return ResponseEntity.accepted().body(new GenericResponse("ok", "If the email is valid, a verification code has been sent."));
    }

    @PostMapping("/verify")
    public ResponseEntity<GenericResponse> verify(@Valid @RequestBody VerifyRequest req) {
        auth.verify(req.email(), req.code());
        return ResponseEntity.ok(new GenericResponse("ok", "Account verified."));
    }

    @PostMapping("/login")
    public ResponseEntity<TokenResponse> login(@Valid @RequestBody LoginRequest req) {
        String token = auth.login(req.email(), req.password());
        return ResponseEntity.ok(new TokenResponse(token, jwt.expirationSeconds()));
    }
}
