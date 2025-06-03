package metrics;

import controller.LoggerController;

import java.util.HashMap;
import java.util.Map;

public class AdaptationMetricsTracker {
    private static AdaptationMetricsTracker instance = null;
    private Map<String, Long> eventTimestamps = new HashMap<>();

    private AdaptationMetricsTracker() {}

    public static AdaptationMetricsTracker getInstance() {
        if (instance == null) {
            instance = new AdaptationMetricsTracker();
        }
        return instance;
    }

    public void markEvent(String key) {
        eventTimestamps.put(key, System.currentTimeMillis());
    }

    private long getReactionTime(String id) {
        Long detection = eventTimestamps.get(id + "_anomaly");
        Long reaction = eventTimestamps.get(id + "_reaction");
        if (detection != null && reaction != null) {
            return reaction - detection;
        }
        return -1;
    }

    private long getAdaptationTime(String id) {
        Long detection = eventTimestamps.get(id + "_anomaly");
        Long completion = eventTimestamps.get(id + "_completion");
        if (detection != null && completion != null) {
            return completion - detection;
        }
        return -1;
    }


    public void logMetrics(String id) {
        long reactionTime = getReactionTime(id);
        long adaptationTime = getAdaptationTime(id);
        if (reactionTime != -1 && adaptationTime != -1) {
            LoggerController.getInstance().print("Drone["+id+"] Reaction Time "+reactionTime+"ms");
            LoggerController.getInstance().print("Drone["+id+"] Adaptation Time "+adaptationTime+"ms");
        } else {
            LoggerController.getInstance().print("Drone["+id+"] No Reaction Time and Adaptation Time found");
        }
    }
}
