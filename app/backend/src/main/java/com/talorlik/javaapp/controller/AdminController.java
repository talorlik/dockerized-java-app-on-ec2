package com.talorlik.javaapp.controller;

import com.talorlik.javaapp.domain.User;
import com.talorlik.javaapp.dto.UserDtos.*;
import com.talorlik.javaapp.exception.ApiException;
import com.talorlik.javaapp.repository.UserRepository;
import com.talorlik.javaapp.service.AuditService;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.MediaType;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    private final UserRepository users;
    private final AuditService audit;

    public AdminController(UserRepository users, AuditService audit) {
        this.users = users;
        this.audit = audit;
    }

    @GetMapping("/users")
    public Map<String, Object> list(@AuthenticationPrincipal String adminEmail,
                                    @RequestParam(defaultValue = "0") int page,
                                    @RequestParam(defaultValue = "20") int size,
                                    @RequestParam(defaultValue = "createdAt") String sort,
                                    @RequestParam(defaultValue = "desc") String dir,
                                    @RequestParam(required = false) String q,
                                    @RequestParam(required = false) Boolean verified) {
        Sort.Direction d = "asc".equalsIgnoreCase(dir) ? Sort.Direction.ASC : Sort.Direction.DESC;
        Page<User> p = users.search(q, verified, PageRequest.of(page, Math.min(size, 100), Sort.by(d, sort)));
        return Map.of(
            "page", p.getNumber(),
            "size", p.getSize(),
            "total", p.getTotalElements(),
            "totalPages", p.getTotalPages(),
            "items", p.map(ProfileResponse::of).getContent()
        );
    }

    @GetMapping("/users/{id}")
    public ProfileResponse get(@PathVariable Long id) {
        return ProfileResponse.of(users.findById(id).orElseThrow(() -> new ApiException(404, "Not found.")));
    }

    @Transactional
    @PutMapping("/users/{id}")
    public ProfileResponse update(@AuthenticationPrincipal String adminEmail,
                                  @PathVariable Long id,
                                  @Valid @RequestBody AdminUpdateRequest req) {
        User u = users.findById(id).orElseThrow(() -> new ApiException(404, "Not found."));
        if (req.fullName() != null) u.setFullName(req.fullName());
        if (req.enabled() != null) u.setEnabled(req.enabled());
        if (Boolean.TRUE.equals(req.resetVerification())) u.setVerified(false);
        users.save(u);
        audit.record("ADMIN_USER_UPDATE", null, adminEmail, u.getEmail(), null);
        return ProfileResponse.of(u);
    }

    @Transactional
    @DeleteMapping("/users/{id}")
    public void delete(@AuthenticationPrincipal String adminEmail, @PathVariable Long id) {
        User u = users.findById(id).orElseThrow(() -> new ApiException(404, "Not found."));
        users.delete(u);
        audit.record("ADMIN_USER_DELETE", null, adminEmail, u.getEmail(), null);
    }

    @GetMapping(value = "/users.csv", produces = "text/csv")
    public void exportCsv(HttpServletResponse response) throws IOException {
        response.setContentType("text/csv; charset=utf-8");
        response.setHeader("Content-Disposition", "attachment; filename=users.csv");
        try (PrintWriter w = response.getWriter()) {
            w.println("id,email,full_name,verified,enabled,created_at,updated_at");
            for (User u : users.findAll()) {
                w.printf("%d,%s,%s,%s,%s,%s,%s%n",
                    u.getId(),
                    csv(u.getEmail()),
                    csv(u.getFullName()),
                    u.isVerified(),
                    u.isEnabled(),
                    u.getCreatedAt(),
                    u.getUpdatedAt());
            }
        }
    }

    private static String csv(String v) {
        if (v == null) return "";
        if (v.contains(",") || v.contains("\"") || v.contains("\n")) {
            return "\"" + v.replace("\"", "\"\"") + "\"";
        }
        return v;
    }
}
