package metrics;

import controller.LoggerController;

import java.util.HashMap;
import java.util.Map;

public class QoSMetricsTracker {
    private static QoSMetricsTracker instance = null;

    //private int missionsCompleted = 0;
    private Map<String, Integer> missionsCompleted = new HashMap<>();
    private Map<String, Integer> missionsFailed = new HashMap<>();
    private Map<String, Integer> adaptationsPerformed = new HashMap<>();
    private Map<String, Integer> waterAvoided = new HashMap<>();
    private Map<String, Integer> goodsLoosed = new HashMap<>();

    private QoSMetricsTracker() {}

    public static QoSMetricsTracker getInstance() {
        if (instance == null) {
            instance = new QoSMetricsTracker();
        }
        return instance;
    }

    public void incrementMissionCompleted(String id) { 
        int completed = missionsCompleted.getOrDefault(id, -1);
        if (completed == -1) {
            missionsCompleted.put(id, 1);
        } else {
            missionsCompleted.put(id, completed + 1);
        }
    }

    public void incrementMissionFailed(String id) {
        int failed = missionsFailed.getOrDefault(id, -1);
        if (failed == -1) {
            missionsFailed.put(id, 1);
        } else {
            missionsFailed.put(id, failed + 1);
        }
    }

    public void incrementAdaptations(String id) {
        int adaptation = adaptationsPerformed.getOrDefault(id, -1);
        if (adaptation == -1) {
            adaptationsPerformed.put(id, 1);
        } else {
            adaptationsPerformed.put(id, adaptation + 1);
        }
    }

    public void incrementWaterAvoided(String id) {
        int avoided = waterAvoided.getOrDefault(id, -1);
        if (avoided == -1) {
            waterAvoided.put(id, 1);
        } else {
            waterAvoided.put(id, avoided + 1);
        }
    }

    public void incrementGoodsLoosed(String id) {
        int loosed = goodsLoosed.getOrDefault(id, -1);
        if (loosed == -1) {
            goodsLoosed.put(id, 1);
        } else {
            goodsLoosed.put(id, loosed + 1);
        }
    }

    public void logQoS(String id) {
        LoggerController.getInstance().print("QoS for Drone[" + id + "]");
        LoggerController.getInstance().print("- Missions Completed: " + missionsCompleted.getOrDefault(id, 0));
        LoggerController.getInstance().print("- Missions Failed: " + missionsFailed.getOrDefault(id, 0));
        LoggerController.getInstance().print("- Adaptations: " + adaptationsPerformed.getOrDefault(id, 0));
        LoggerController.getInstance().print("- Water Avoided: " + waterAvoided.getOrDefault(id, 0));
        LoggerController.getInstance().print("- Goods Loosed: " + goodsLoosed.getOrDefault(id, 0));
        getQoSWeightedScore(id);
    }

    private void getQoSWeightedScore(String id) {
        double score = (missionsCompleted.getOrDefault(id, 0) * 2.0) 
                + (waterAvoided.getOrDefault(id, 0) * 1.5) 
                + (adaptationsPerformed.getOrDefault(id, 0) * 1.0)
                - (missionsFailed.getOrDefault(id, 0) * 2.0) 
                - (goodsLoosed.getOrDefault(id, 0) * 3.0);
        LoggerController.getInstance().print("QoS score: " + score);
        clear(id);
    }

    private void clear(String id) {
        missionsCompleted.remove(id);
        missionsFailed.remove(id);
        adaptationsPerformed.remove(id);
        waterAvoided.remove(id);
        goodsLoosed.remove(id);
    }

}
