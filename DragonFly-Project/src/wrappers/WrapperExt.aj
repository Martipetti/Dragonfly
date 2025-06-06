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

public aspect WrapperExt {
    pointcut safeLanding(): call (* model.entity.drone.DroneBusinessObject.safeLanding(*));
    pointcut applyEconomyMode(): call (* model.entity.drone.DroneBusinessObject.applyEconomyMode(*));
    pointcut checkAndPrintIfLostDrone(): call (* model.entity.drone.DroneBusinessObject.checkAndPrintIfLostDrone(*));
    pointcut goDestinyAutomatic() : call (void controller.DroneAutomaticController.goDestinyAutomatic(*));

    static private int attemptsToAvoid = 0;

    Object around(): goDestinyAutomatic() {
        Drone drone = (Drone) thisJoinPoint.getArgs()[0];
        String label = drone.getLabel();

        if (drone.hasObstaclesInFront() && drone.getWrapperId() == 9) {
            attemptsToAvoid++;
            System.out.println("Avoiding obstacle. Attempts: " + attemptsToAvoid);
            AdaptationMetricsTracker.getInstance().markEvent(label + "_anomaly");

            if (attemptsToAvoid > 15) {
                AdaptationMetricsTracker.getInstance().markEvent(drone.getLabel() + "_reaction");
                LoggerController.getInstance().print("Too many attempts. Landing.");
                DroneBusinessObject.safeLanding(drone);
                DroneBusinessObject.landing(drone);
                DroneBusinessObject.landed(drone);
                DroneBusinessObject.shutDown(drone);

                LoggerController.getInstance().print("The drone is blocked.");
                attemptsToAvoid = 0;
            } else {
                avoidObstacle(drone);
            }
            AdaptationMetricsTracker.getInstance().markEvent(label + "_completion");
            QoSMetricsTracker.getInstance().incrementAdaptations(label);

            return null;
        } else {
            return proceed();
        }
    }

    void around(): applyEconomyMode() {
        Drone drone = (Drone) thisJoinPoint.getArgs()[0];
        if (drone.getWrapperId() == 9){

        }
    }

    before(): safeLanding() {
        Drone drone = (Drone) thisJoinPoint.getArgs()[0];
        int wrapper = drone.getWrapperId();

        if (wrapper == 9) {
            String label = drone.getLabel();
            double distance = drone.getDistanceDestiny();
            boolean isOnWater = drone.isOnWater();

            if (distance > 60 && isOnWater) {
                AdaptationMetricsTracker.getInstance().markEvent(label + "_anomaly");
                moveASide(thisJoinPoint);
                AdaptationMetricsTracker.getInstance().markEvent(label + "_completion");
                QoSMetricsTracker.getInstance().incrementAdaptations(label);
            }
        }
    }

    boolean around(): safeLanding() {
        Drone drone = (Drone) thisJoinPoint.getArgs()[0];
        double distance = drone.getDistanceDestiny();
        boolean strongRain = drone.isStrongRain();
        boolean strongWind = drone.isStrongWind();
        int wrapper = drone.getWrapperId();
        String label = drone.getLabel();

        if (wrapper == 9) {
            if ((strongRain ^ strongWind) && distance <= 60) {
                AdaptationMetricsTracker.getInstance().markEvent(label + "_anomaly");
                keepFlying(thisJoinPoint);
                QoSMetricsTracker.getInstance().incrementAdaptations(label);
                AdaptationMetricsTracker.getInstance().markEvent(label + "_completion");
                return false;
            }

            if (strongRain && strongWind && distance < 30) {
                AdaptationMetricsTracker.getInstance().markEvent(label + "_anomaly");
                keepFlying(thisJoinPoint);
                QoSMetricsTracker.getInstance().incrementAdaptations(label);
                AdaptationMetricsTracker.getInstance().markEvent(label + "_completion");
                return false;
            }
            return true;
        } else {
            return proceed();
        }
    }

    after(): checkAndPrintIfLostDrone(){
        Drone drone = (Drone) thisJoinPoint.getArgs()[0];
        if (drone.getWrapperId() == 9) {
            String label = ((Drone) thisJoinPoint.getArgs()[0]).getLabel();
            AdaptationMetricsTracker.getInstance().logMetrics(label);
            QoSMetricsTracker.getInstance().logQoS(label);
            RuntimeCostTracker.getInstance().logRuntimeCost(label);
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

    private void avoidObstacle(Drone drone) {
        LoggerController.getInstance().print("Drone[" + drone.getLabel() + "] Obstacle detected! Trying to avoid...");

        String currentDirection = drone.getAutoFlyDirectionCommand();
        String oppositeDirection = getOppositeDirection(currentDirection);
        boolean avoidMade = false;

        AdaptationMetricsTracker.getInstance().markEvent(drone.getLabel() + "_reaction");

        while(!avoidMade) {
            String[] orthogonals = getOrthogonalDirections(currentDirection);

            for (String ortho : orthogonals) {
                if (!drone.hasObstacleInDirection(ortho)) {
                    DroneBusinessObject.goTo(drone, ortho);

                    currentDirection = ortho;
                    drone.setAutoFlyDirectionCommand(ortho);

                    avoidMade = true;
                    break;
                }
            }

            if (!avoidMade) {
                DroneBusinessObject.goTo(drone, oppositeDirection);

                drone.setAutoFlyDirectionCommand(oppositeDirection);
                currentDirection = oppositeDirection;
            }
        }
    }


    private String[] getOrthogonalDirections(String direction) {
        if (direction == null) return new String[0];

        switch (direction) {
            case "/\\":
            case "\\/":
                return new String[] {"<-", "->"};
            case "<-":
            case "->":
                return new String[] {"/\\", "\\/"};
            default:
                return new String[0];
        }
    }

    private String getOppositeDirection(String direction) {
        if (direction == null) return null;

        switch (direction) {
            case "->":
                return "<-";
            case "<-":
                return "->";
            case "/\\":
                return "\\/";
            case "\\/":
                return "/\\";
            default:
                return null;
        }
    }

    private void keepFlying(JoinPoint thisJoinPoint) {
        Drone drone = (Drone) thisJoinPoint.getArgs()[0];
        System.out.println("Drone["+drone.getLabel()+"] "+"Keep Flying");
        AdaptationMetricsTracker.getInstance().markEvent(drone.getLabel() + "_reaction");
        LoggerController.getInstance().print("Drone["+drone.getLabel()+"] "+"Keep Flying");
    }

}
