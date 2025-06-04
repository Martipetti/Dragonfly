package metrics;

import controller.LoggerController;

import java.util.HashMap;
import java.util.Map;

public class AdaptationMetricsTracker {
    private static AdaptationMetricsTracker instance = null;
    private Map<String, Long> eventTimestamps = new HashMap<>();
    private int adaptation = 1;

    private AdaptationMetricsTracker() {}

    public static AdaptationMetricsTracker getInstance() {
        if (instance == null) {
            instance = new AdaptationMetricsTracker();
        }
        return instance;
    }

    public void markEvent(String key) {
        String adaptationKey = key + "_" + adaptation;
        if (key.contains("_completion")) {
            adaptation++;
        }
        eventTimestamps.put(adaptationKey, System.currentTimeMillis());
    }

    private long getReactionTime(String id, int adaptation) {
        Long detection = eventTimestamps.get(id + "_anomaly" + "_" + adaptation);
        Long reaction = eventTimestamps.get(id + "_reaction" + "_" + adaptation);
        if (detection != null && reaction != null) {
            return reaction - detection;
        }
        return -1;
    }

    private long getAdaptationTime(String id, int adaptation) {
        Long detection = eventTimestamps.get(id + "_anomaly" + "_" + adaptation);
        Long completion = eventTimestamps.get(id + "_completion" + "_" + adaptation);
        if (detection != null && completion != null) {
            return completion - detection;
        }
        return -1;
    }


    public void logMetrics(String id) {
        int adaptation = 1;

        while (true) {
            long reactionTime = getReactionTime(id, adaptation);
            long adaptationTime = getAdaptationTime(id, adaptation);
            if (reactionTime != -1 && adaptationTime != -1) {
                LoggerController.getInstance().print("Drone["+id+"] Reaction Time "+reactionTime+"ms");
                LoggerController.getInstance().print("Drone["+id+"] Adaptation Time "+adaptationTime+"ms");
            } else {
                break;
            }
            adaptation++;
        }
        clear();
    }

    private void clear() {
        eventTimestamps.clear();
        adaptation = 1;
    }
}
