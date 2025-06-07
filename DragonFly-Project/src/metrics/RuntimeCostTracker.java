package metrics;

import controller.LoggerController;

import java.util.HashMap;
import java.util.Map;

public class RuntimeCostTracker {

    private static RuntimeCostTracker instance = null;
    private Map<String, Long> cycleStartTimestamps = new HashMap<>();
    private Map<String, Long> cycleDuration = new HashMap<>();

    private RuntimeCostTracker() {}

    public static RuntimeCostTracker getInstance() {
        if (instance == null) {
            instance = new RuntimeCostTracker();
        }
        return instance;
    }

    public void startCycle(String id) {
        cycleStartTimestamps.put(id, System.currentTimeMillis());
    }

    public void endCycle(String id) {
        Long start = cycleStartTimestamps.get(id);
        if (start != null) {
            long duration = System.currentTimeMillis() - start;
            cycleDuration.put(id, duration);
        }
    }

    public void logRuntimeCost(String id) {
        long totalTime = cycleDuration.getOrDefault(id, 0L);

        LoggerController.getInstance().print("Drone[" + id + "] Runtime Cost: " + totalTime/1000 + "s");
        clear(id);
    }

    private void clear(String id) {
        cycleDuration.remove(id);
    }
}
