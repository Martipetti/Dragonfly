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

    before(): safeLanding()
    && if
    (
    (((Drone)thisJoinPoint.getArgs()[0]).getWrapperId() == 1)
    &&
    (((Drone)thisJoinPoint.getArgs()[0]).getDistanceDestiny() > 60)
    &&
    (((Drone)thisJoinPoint.getArgs()[0]).isOnWater())
    ){

        Drone drone = (Drone) thisJoinPoint.getArgs()[0];
        String label = drone.getLabel();
        AdaptationMetricsTracker.getInstance().markEvent(label + "_anomaly");
        moveASide(thisJoinPoint);
        AdaptationMetricsTracker.getInstance().markEvent(label + "_completion");
        QoSMetricsTracker.getInstance().incrementAdaptations(label);
    }

    boolean around(): safeLanding() {
        Drone drone = (Drone) thisJoinPoint.getArgs()[0];
        int wrapper = drone.getWrapperId();

        if (wrapper == 1) {
            double distance = drone.getDistanceDestiny();
            boolean strongRain = drone.isStrongRain();
            boolean strongWind = drone.isStrongWind();
            boolean isOnWater = drone.isOnWater();
            String label = drone.getLabel();

            if ((strongRain ^ strongWind) && distance <= 60) {
                AdaptationMetricsTracker.getInstance().markEvent(label + "_anomaly");
                if (isOnWater)
                    moveASide(thisJoinPoint);
                keepFlying(thisJoinPoint);
                QoSMetricsTracker.getInstance().incrementAdaptations(label);
                AdaptationMetricsTracker.getInstance().markEvent(label + "_completion");
                return false;
            }

            if (strongRain && strongWind && distance < 30) {
                AdaptationMetricsTracker.getInstance().markEvent(label + "_anomaly");
                if (isOnWater)
                    moveASide(thisJoinPoint);
                keepFlying(thisJoinPoint);
                QoSMetricsTracker.getInstance().incrementAdaptations(label);
                AdaptationMetricsTracker.getInstance().markEvent(label + "_completion");
                return false;
            }
        }
        return true;
    }

    after(): checkAndPrintIfLostDrone(){
        Drone drone = (Drone) thisJoinPoint.getArgs()[0];
        if (drone.getWrapperId() == 1) {
            String label = ((Drone) thisJoinPoint.getArgs()[0]).getLabel();
            AdaptationMetricsTracker.getInstance().logMetrics(label);
            QoSMetricsTracker.getInstance().logQoS(label);
            RuntimeCostTracker.getInstance().logRuntimeCost(label);
        }
    }


    void around(): applyEconomyMode()
    &&
    if
    (
    (((Drone)thisJoinPoint.getArgs()[0]).getWrapperId() == 1)
    ){
        // around applyEconomyMode
    }


    private void moveASide(JoinPoint thisJoinPoint) {

        Drone drone = (Drone) thisJoinPoint.getArgs()[0];

        DroneView droneView = DroneController.getInstance().getDroneViewFrom(drone.getUniqueID());
        CellView closerLandCellView = EnvironmentController.getInstance().getCloserLand(drone);
        //System.out.println("closerLandCellView: " + closerLandCellView.getRowPosition() + "," + closerLandCellView.getCollunmPosition());

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
        //drone.setEconomyMode(false);
        System.out.println("Drone["+drone.getLabel()+"] "+"Keep Flying");
        AdaptationMetricsTracker.getInstance().markEvent(drone.getLabel() + "_reaction");
        LoggerController.getInstance().print("Drone["+drone.getLabel()+"] "+"Keep Flying");
    }



}
