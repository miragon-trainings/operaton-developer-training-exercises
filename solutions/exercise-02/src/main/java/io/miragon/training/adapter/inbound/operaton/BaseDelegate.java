package io.miragon.training.adapter.inbound.operaton;

import org.operaton.bpm.engine.delegate.DelegateExecution;
import org.operaton.bpm.engine.delegate.JavaDelegate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class BaseDelegate implements JavaDelegate {

    protected final Logger log = LoggerFactory.getLogger(getClass());

    @Override
    public void execute(DelegateExecution execution) throws Exception {
        try {
            executeTask(execution);
        } catch (Exception e) {
            log.error("Delegate execution failed for process instance {}", execution.getProcessInstanceId(), e);
            throw e;
        }
    }

    protected abstract void executeTask(DelegateExecution execution);
}
