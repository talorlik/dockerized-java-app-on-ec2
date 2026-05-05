package com.talorlik.javaapp.controller;

import com.talorlik.javaapp.domain.User;
import com.talorlik.javaapp.dto.UserDtos.*;
import com.talorlik.javaapp.exception.ApiException;
import com.talorlik.javaapp.repository.UserRepository;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/profile")
public class ProfileController {

    private final UserRepository users;

    public ProfileController(UserRepository users) { this.users = users; }

    @GetMapping
    public ResponseEntity<ProfileResponse> me(@AuthenticationPrincipal String email) {
        User u = users.findByEmailIgnoreCase(email).orElseThrow(() -> new ApiException(404, "Not found."));
        return ResponseEntity.ok(ProfileResponse.of(u));
    }

    @Transactional
    @PutMapping
    public ResponseEntity<ProfileResponse> update(@AuthenticationPrincipal String email,
                                                   @Valid @RequestBody ProfileUpdateRequest req) {
        User u = users.findByEmailIgnoreCase(email).orElseThrow(() -> new ApiException(404, "Not found."));
        // Email is intentionally not modifiable.
        u.setFullName(req.fullName());
        users.save(u);
        return ResponseEntity.ok(ProfileResponse.of(u));
    }
}
