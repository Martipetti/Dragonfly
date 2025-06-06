package wrappers;

import controller.DroneController;
import controller.EnvironmentController;
import controller.LoggerController;
import metrics.AdaptationMetricsTracker;
import model.entity.drone.Drone;
import model.entity.drone.DroneBusinessObject;
import org.aspectj.lang.JoinPoint;
import view.CellView;
import view.drone.DroneView;

public aspect WrapperFunction {

    pointcut safeLanding(): call (* model.entity.drone.DroneBusinessObject.safeLanding(*));
    pointcut applyEconomyMode(): call (* model.entity.drone.DroneBusinessObject.applyEconomyMode(*));

    boolean around(): safeLanding() {
        Drone drone = (Drone) thisJoinPoint.getArgs()[0];
        int wrapper = drone.getWrapperId();

        if (wrapper != 8) {
            return proceed();
        }

        double distance = drone.getDistanceDestiny();
        double totalDistance = drone.getDistanceSource() + distance;
        double distanceFactor = distance/totalDistance;

        double battery = drone.getCurrentBattery();
        double totalBattery = drone.getInitialBattery();
        double batteryFactor = 1 - (battery / totalBattery);

        double strongWindPenalty = drone.isStrongWind() ? 1 : 0;
        double strongRainPenalty = drone.isOnWater() ? 1 : 0;
        double waterPenalty = drone.isOnWater() ? 1 : 0;

        double utilityFunction =
                0.3 * distanceFactor +
                0.4 * batteryFactor +
                0.075 * strongRainPenalty +
                0.075 * strongWindPenalty +
                0.15 * waterPenalty;

        LoggerController.getInstance().print("Drone["+drone.getLabel()+"] Utility Function: "+utilityFunction);

        if (battery == 0){
            return true;
        }
        if (utilityFunction < 0.3) {
            keepFlying(drone);
            return false;
        } else if (utilityFunction < 0.5) {
            moveASide(drone);
            return false;
        } else {
            moveASide(drone);
            drone.setIsSafeland(true);
            return true;
        }

    }

    void around(): applyEconomyMode() {
        Drone drone = (Drone) thisJoinPoint.getArgs()[0];
        if (drone.getWrapperId() == 8){

        }
    }

    private void keepFlying(Drone drone) {
        System.out.println("Drone["+drone.getLabel()+"] "+"Keep Flying");
    }

    private void moveASide(Drone drone) {
        DroneView droneView = DroneController.getInstance().getDroneViewFrom(drone.getUniqueID());
        CellView closerLandCellView = EnvironmentController.getInstance().getCloserLand(drone);

        System.out.println("Drone["+drone.getLabel()+"] "+"Move Aside");
        LoggerController.getInstance().print("Drone["+drone.getLabel()+"] "+"Move Aside");

        while (drone.isOnWater()) {
            String goDirection = DroneBusinessObject.closeDirection(droneView.getCurrentCellView(), closerLandCellView);
            DroneBusinessObject.goTo(drone, goDirection);
        }
    }

}
