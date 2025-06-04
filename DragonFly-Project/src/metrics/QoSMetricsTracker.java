package metrics;

import controller.LoggerController;

public class QoSMetricsTracker {
    private static QoSMetricsTracker instance = null;

    private int missionsCompleted = 0;
    private int missionsFailed = 0;
    private int adaptationsPerformed = 0;
    private int waterAvoided = 0;
    private int goodsLoosed = 0;

    private QoSMetricsTracker() {}

    public static QoSMetricsTracker getInstance() {
        if (instance == null) {
            instance = new QoSMetricsTracker();
        }
        return instance;
    }

    public void incrementMissionCompleted() { missionsCompleted++; }

    public void incrementMissionFailed() { missionsFailed++; }

    public void incrementAdaptations() { adaptationsPerformed++; }

    public void incrementWaterAvoided() { waterAvoided++; }

    public void incrementGoodsLoosed() { goodsLoosed++; }

    public void logQoS(String droneId) {
        LoggerController.getInstance().print("QoS for " + droneId + ":");
        LoggerController.getInstance().print("  Missions Completed: " + missionsCompleted);
        LoggerController.getInstance().print("  Missions Failed: " + missionsFailed);
        LoggerController.getInstance().print("  Adaptations: " + adaptationsPerformed);
        LoggerController.getInstance().print("  Water Avoided: " + waterAvoided);
        getQoSWeightedScore();
    }

    private void getQoSWeightedScore() {
        double score = (missionsCompleted * 2.0) + (waterAvoided * 1.5) + (adaptationsPerformed * 1.0)
                - (missionsFailed * 2.0) - (goodsLoosed * 3.0);
        LoggerController.getInstance().print("  Quality of service score: " + score);
        clear();
    }

    private void clear() {
        missionsCompleted = 0;
        missionsFailed = 0;
        adaptationsPerformed = 0;
        waterAvoided = 0;
        goodsLoosed = 0;
    }

}
