package metrics;

import controller.LoggerController;

import java.util.HashMap;
import java.util.Map;

public class FailureAvoidanceMetricTracker {
    private static FailureAvoidanceMetricTracker instance = null;

    private Map<String, Integer> failureAvoidance = new HashMap<>();

    private FailureAvoidanceMetricTracker() {}

    public static FailureAvoidanceMetricTracker getInstance() {
        if (instance == null) {
            instance = new FailureAvoidanceMetricTracker();
        }
        return instance;
    }

    public void addFailureAvoidance(String id) {
        failureAvoidance.put(id, failureAvoidance.getOrDefault(id, 0) + 1);
    }

    public void logFailureAvoidance() {
        if (failureAvoidance.isEmpty()) {
            return;
        }

        double totalAvoidance = 0;
        for (Integer value : failureAvoidance.values()) {
            totalAvoidance += value;
        }

        double averageAvoidance = totalAvoidance / failureAvoidance.size();

        LoggerController.getInstance().print("Average Robustness: " + (int) averageAvoidance*100 +"%");
        LoggerController.getInstance().print("Per Drone Robustness:");
        failureAvoidance.forEach((droneId, value) ->
                LoggerController.getInstance().print("- Drone[" + droneId + "]: " + value));

    }
}
