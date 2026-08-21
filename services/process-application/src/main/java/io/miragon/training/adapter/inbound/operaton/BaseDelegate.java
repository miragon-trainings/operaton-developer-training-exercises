package io.miragon.training.adapter.inbound.operaton;

// TODO Exercise 3: Uncomment this class (remove the /* and */ lines).
//  It needs the Operaton engine that you switch on in Exercise 1.
/*
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
*/
