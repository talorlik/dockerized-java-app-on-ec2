package com.talorlik.javaapp.config;

import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient;
import software.amazon.awssdk.services.sesv2.SesV2Client;

@Configuration
@EnableConfigurationProperties(AppProperties.class)
public class AwsConfig {

    @Bean
    public SecretsManagerClient secretsManagerClient(AppProperties props) {
        return SecretsManagerClient.builder()
            .region(Region.of(props.getAws().getRegion()))
            .build();
    }

    @Bean
    public SesV2Client sesV2Client(AppProperties props) {
        return SesV2Client.builder()
            .region(Region.of(props.getAws().getRegion()))
            .build();
    }
}
