package com.talorlik.javaapp.exception;

import com.talorlik.javaapp.dto.AuthDtos.GenericResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ApiException.class)
    public ResponseEntity<GenericResponse> api(ApiException e) {
        return ResponseEntity.status(e.getStatus()).body(new GenericResponse("error", e.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<GenericResponse> validation(MethodArgumentNotValidException e) {
        return ResponseEntity.badRequest().body(new GenericResponse("error", "Invalid request."));
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<GenericResponse> denied(AccessDeniedException e) {
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(new GenericResponse("error", "Forbidden."));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<GenericResponse> unhandled(Exception e) {
        // Do not leak the message - return a generic 500.
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(new GenericResponse("error", "Internal server error."));
    }
}
