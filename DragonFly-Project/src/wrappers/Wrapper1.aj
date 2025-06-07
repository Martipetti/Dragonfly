package wrappers;

import controller.DroneController;
import controller.EnvironmentController;
import controller.LoggerController;
import metrics.AdaptationMetricsTracker;
import metrics.QoSMetricsTracker;
import metrics.RuntimeCostTracker;
import model.entity.drone.Drone;
import model.entity.drone.DroneBusinessObject;
import org.aspectj.lang.JoinPoint;
import view.CellView;
import view.drone.DroneView;

public aspect Wrapper1 {

    pointcut safeLanding(): call (* model.entity.drone.DroneBusinessObject.safeLanding(*));
    pointcut applyEconomyMode(): call (* model.entity.drone.DroneBusinessObject.applyEconomyMode(*));
    pointcut checkAndPrintIfLostDrone(): call (* model.entity.drone.DroneBusinessObject.checkAndPrintIfLostDrone(*));

    before(): safeLanding() {
        Drone drone = (Drone) thisJoinPoint.getArgs()[0];
        int wrapper = drone.getWrapperId();

        if (wrapper != 1) {
            return;
        }

        double distance = drone.getDistanceDestiny();
        boolean isOnWater = drone.isOnWater();
        String label = drone.getLabel();

        if (distance > 60 && isOnWater) {
            AdaptationMetricsTracker.getInstance().markEvent(label + "_anomaly");
            moveASide(thisJoinPoint);
            AdaptationMetricsTracker.getInstance().markEvent(label + "_completion");
            QoSMetricsTracker.getInstance().incrementAdaptations(label);
        }
    }

    boolean around(): safeLanding() {
        Drone drone = (Drone) thisJoinPoint.getArgs()[0];
        int wrapper = drone.getWrapperId();

        if (wrapper != 1) {
            return proceed();
        }

        double distance = drone.getDistanceDestiny();
        boolean strongRain = drone.isStrongRain();
        boolean strongWind = drone.isStrongWind();
        boolean isOnWater = drone.isOnWater();
        String label = drone.getLabel();
        double battery = drone.getCurrentBattery();

        if (!(strongRain & strongWind) && distance <= 60 && battery > 0) {
            AdaptationMetricsTracker.getInstance().markEvent(label + "_anomaly");
            if (isOnWater)
                moveASide(thisJoinPoint);
            keepFlying(thisJoinPoint);
            QoSMetricsTracker.getInstance().incrementAdaptations(label);
            AdaptationMetricsTracker.getInstance().markEvent(label + "_completion");
            return false;
        }

        if (strongRain && strongWind && distance < 30 && battery > 0) {
            AdaptationMetricsTracker.getInstance().markEvent(label + "_anomaly");
            if (isOnWater)
                moveASide(thisJoinPoint);
            keepFlying(thisJoinPoint);
            QoSMetricsTracker.getInstance().incrementAdaptations(label);
            AdaptationMetricsTracker.getInstance().markEvent(label + "_completion");
            return false;
        }

        moveASide(thisJoinPoint);
        drone.setIsSafeland(true);
        return true;
    }

    after(): checkAndPrintIfLostDrone(){
        Drone drone = (Drone) thisJoinPoint.getArgs()[0];

        if (drone.getWrapperId() != 1) {
            return;
        }

        String label = ((Drone) thisJoinPoint.getArgs()[0]).getLabel();
        AdaptationMetricsTracker.getInstance().logMetrics(label);
        QoSMetricsTracker.getInstance().logQoS(label);
        RuntimeCostTracker.getInstance().logRuntimeCost(label);
    }


    void around(): applyEconomyMode() {
        Drone drone = (Drone) thisJoinPoint.getArgs()[0];
        if (drone.getWrapperId() != 1) {
            proceed();
        }
    }


    private void moveASide(JoinPoint thisJoinPoint) {
        Drone drone = (Drone) thisJoinPoint.getArgs()[0];

        DroneView droneView = DroneController.getInstance().getDroneViewFrom(drone.getUniqueID());
        CellView closerLandCellView = EnvironmentController.getInstance().getCloserLand(drone);

        System.out.println("Drone["+drone.getLabel()+"] "+"Move Aside");
        LoggerController.getInstance().print("Drone["+drone.getLabel()+"] "+"Move Aside");
        AdaptationMetricsTracker.getInstance().markEvent(drone.getLabel() + "_reaction");

        while (drone.isOnWater()) {
            String goDirection = DroneBusinessObject.closeDirection(droneView.getCurrentCellView(), closerLandCellView);
            DroneBusinessObject.goTo(drone, goDirection);
        }

    }

    private void keepFlying(JoinPoint thisJoinPoint) {
        Drone drone = (Drone) thisJoinPoint.getArgs()[0];
        System.out.println("Drone["+drone.getLabel()+"] "+"Keep Flying");
        AdaptationMetricsTracker.getInstance().markEvent(drone.getLabel() + "_reaction");
        LoggerController.getInstance().print("Drone["+drone.getLabel()+"] "+"Keep Flying");
    }

}
