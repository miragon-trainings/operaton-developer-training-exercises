package io.miragon.training.adapter.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * The REST client of the Operaton remote adapter ({@code c7-rest-client}) maps process variables with a
 * Jackson 2 {@link ObjectMapper}, which Spring Boot 4 no longer auto-configures (it only provides Jackson 3).
 */
@Configuration
public class Jackson2ObjectMapperConfig {

    @Bean
    public ObjectMapper jackson2ObjectMapper() {
        return new ObjectMapper().findAndRegisterModules();
    }
}
