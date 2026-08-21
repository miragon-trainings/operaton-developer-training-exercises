package io.miragon.training.adapter.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;

/**
 * Wires the two ways this service talks to the shared engine over {@code /engine-rest}:
 * a plain {@link RestClient} for the multipart model deployment, and the generated typed API for
 * driving the process.
 */
@Configuration
public class EngineClientConfig {

    /** Used by {@code EngineDeploymentAdapter} for the multipart model deployment. */
    @Bean
    public RestClient engineRestClient(@Value("${operaton.bpm.client.base-url}") String engineBaseUrl) {
        return RestClient.builder().baseUrl(engineBaseUrl).build();
    }

    // TODO Exercise 10: once the client is generated (see pom.xml), expose the typed ProcessDefinitionApi
    // as a bean so RemoteWelcomeKitProcessAdapter can drive the engine. Imports:
    //   org.operaton.rest.client.invoker.ApiClient, org.operaton.rest.client.api.ProcessDefinitionApi
    //
    // @Bean
    // public ApiClient operatonApiClient(@Value("${operaton.bpm.client.base-url}") String engineBaseUrl) {
    //     ApiClient apiClient = new ApiClient();
    //     apiClient.setBasePath(engineBaseUrl);
    //     return apiClient;
    // }
    //
    // @Bean
    // public ProcessDefinitionApi processDefinitionApi(ApiClient operatonApiClient) {
    //     return new ProcessDefinitionApi(operatonApiClient);
    // }
}
