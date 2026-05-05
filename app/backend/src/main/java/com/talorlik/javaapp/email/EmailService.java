package com.talorlik.javaapp.email;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.talorlik.javaapp.config.AppProperties;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient;
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueRequest;
import software.amazon.awssdk.services.sesv2.SesV2Client;
import software.amazon.awssdk.services.sesv2.model.*;

@Service
public class EmailService {

    private static final Logger log = LoggerFactory.getLogger(EmailService.class);

    private final SesV2Client ses;
    private final SecretsManagerClient sm;
    private final AppProperties props;
    private final ObjectMapper mapper = new ObjectMapper();

    private String fromAddress;

    public EmailService(SesV2Client ses, SecretsManagerClient sm, AppProperties props) {
        this.ses = ses;
        this.sm = sm;
        this.props = props;
    }

    @PostConstruct
    void init() throws Exception {
        if (!props.getSes().isEnabled()) {
            log.info("SES disabled - emails will be logged only");
            this.fromAddress = "no-reply@local";
            return;
        }
        var resp = sm.getSecretValue(GetSecretValueRequest.builder()
            .secretId(props.getSecrets().getSesSecretName())
            .build());
        JsonNode json = mapper.readTree(resp.secretString());
        this.fromAddress = json.get("from_address").asText();
    }

    public void sendVerificationCode(String to, String code) {
        String subject = "Your verification code";
        String body = """
            Hello,

            Your verification code is: %s

            This code expires in %d minutes. If you did not request this, ignore this email.
            """.formatted(code, props.getVerification().getTtlMinutes());

        if (!props.getSes().isEnabled()) {
            log.info("[email-fake] to={} subject={} bodyChars={}", to, subject, body.length());
            return;
        }

        try {
            ses.sendEmail(SendEmailRequest.builder()
                .fromEmailAddress(fromAddress)
                .destination(Destination.builder().toAddresses(to).build())
                .content(EmailContent.builder()
                    .simple(Message.builder()
                        .subject(Content.builder().data(subject).build())
                        .body(Body.builder().text(Content.builder().data(body).build()).build())
                        .build())
                    .build())
                .build());
        } catch (Exception e) {
            // Don't include 'code' in the error message - it's user-bound secret material.
            log.error("SES send failed for {}: {}", to, e.getClass().getSimpleName());
            throw e;
        }
    }
}
