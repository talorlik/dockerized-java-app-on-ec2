package com.talorlik.javaapp.util;

import io.github.bucket4j.Bandwidth;
import io.github.bucket4j.Bucket;

import java.time.Duration;
import java.util.concurrent.ConcurrentHashMap;

/**
 * In-memory token-bucket per (endpoint, key) pair. Sufficient for a small
 * fleet (per-instance counters); behind an ALB the practical surface is
 * still bounded by max instances. For a stricter global limit, swap to a
 * Redis-backed bucket or rely on the WAF rate-limit rule.
 */
public class RateLimiter {

    private final ConcurrentHashMap<String, Bucket> buckets = new ConcurrentHashMap<>();
    private final long limit;
    private final Duration window;

    public RateLimiter(long limit, Duration window) {
        this.limit = limit;
        this.window = window;
    }

    public boolean tryConsume(String key) {
        return buckets.computeIfAbsent(key, k -> Bucket.builder()
            .addLimit(Bandwidth.builder().capacity(limit).refillIntervally(limit, window).build())
            .build()
        ).tryConsume(1);
    }
}
