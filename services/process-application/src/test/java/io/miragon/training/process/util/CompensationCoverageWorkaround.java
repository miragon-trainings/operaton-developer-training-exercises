package io.miragon.training.process.util;

import org.operaton.bpm.engine.impl.cfg.AbstractProcessEnginePlugin;
import org.operaton.bpm.engine.impl.cfg.ProcessEngineConfigurationImpl;
import org.operaton.bpm.engine.impl.event.EventHandler;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * Works around a bug in Operaton Process Test Coverage 1.0.0: its compensation event handler declares
 * the event payload as non-null, but the engine throws compensation events without one, so every test
 * that compensates fails with a {@code NullPointerException}. This plugin removes that handler again,
 * after the coverage extension has registered it; the engine then uses its own handler. The report
 * still shows everything except the compensation boundary events. Without the coverage extension
 * (before Exercise 4) it does nothing.
 *
 * <p>This class is <b>provided</b> – you don't have to touch it.
 */
@Component
@Order(Ordered.LOWEST_PRECEDENCE)
public class CompensationCoverageWorkaround extends AbstractProcessEnginePlugin {

    private static final String NULL_UNSAFE_HANDLER =
            "org.operaton.community.process_test_coverage.engine.platform7.CompensationEventCoverageHandler";

    @Override
    public void preInit(ProcessEngineConfigurationImpl configuration) {
        List<EventHandler> customEventHandlers = configuration.getCustomEventHandlers();
        if (customEventHandlers != null) {
            customEventHandlers.removeIf(handler -> handler.getClass().getName().equals(NULL_UNSAFE_HANDLER));
        }
    }
}
