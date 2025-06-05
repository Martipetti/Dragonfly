package wrappers;

import controller.DroneController;
import controller.EnvironmentController;
import controller.LoggerController;
import metrics.AdaptationMetricsTracker;
import metrics.QoSMetricsTracker;
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

    before(): goDestinyAutomatic() {
        Drone drone = (Drone) thisJoinPoint.getArgs()[0];

        if (drone.hasObstaclesInFront()) {
            attemptsToAvoid++;
            System.out.println("Avoiding obstacle. Attempts: " + attemptsToAvoid);

            if (attemptsToAvoid > 10) {
                LoggerController.getInstance().print("Too many attempts. Landing.");
                DroneBusinessObject.safeLanding(drone);
                DroneBusinessObject.landing(drone);
                DroneBusinessObject.landed(drone);
                DroneBusinessObject.shutDown(drone);

                LoggerController.getInstance().print("The drone is blocked.");
                attemptsToAvoid = 0;
            } else {
                avoidObstacle(thisJoinPoint);
            }

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
        }
        return true;
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

    private void avoidObstacle(JoinPoint thisJoinPoint) {
        Drone drone = (Drone) thisJoinPoint.getArgs()[0];

        LoggerController.getInstance().print("Drone[" + drone.getLabel() + "] Obstacle detected! Trying to avoid...");

        String[] directions = {"<-", "->", "/\\", "\\/"};
        String currentDirection = drone.getAutoFlyDirectionCommand();
        String oppositeDirection = getOppositeDirection(currentDirection);

        System.out.println("currentDirection: " + currentDirection);
        System.out.println("oppositeDirection: " + oppositeDirection);

        boolean avoidMade = false;

        System.out.println("Direction: " + directions[0] + ", HasObstacle: " + drone.hasObstacleInDirection(directions[0]));
        System.out.println("Direction: " + directions[1] + ", HasObstacle: " + drone.hasObstacleInDirection(directions[1]));
        System.out.println("Direction: " + directions[2] + ", HasObstacle: " + drone.hasObstacleInDirection(directions[2]));
        System.out.println("Direction: " + directions[3] + ", HasObstacle: " + drone.hasObstacleInDirection(directions[3]));

        for (String direction : directions) {
            if (direction.equals(oppositeDirection)) continue;

            if (!drone.hasObstacleInDirection(direction)) {
                DroneBusinessObject.goTo(drone, direction);
                avoidMade = true;

                System.out.println("Choose: " + direction);
                break;
            }
        }

        if (!avoidMade) {
            System.out.println("Not opposite is not possibile");
            DroneBusinessObject.goTo(drone, oppositeDirection);

            String[] orthogonals = getOrthogonalDirections(oppositeDirection);
            System.out.println("Orthogonals: " + orthogonals[0] + ", " + orthogonals[1]);

            System.out.println("Orthogonal: " + orthogonals[0] + ", HasObstacle: " + drone.hasObstacleInDirection(orthogonals[0]));
            System.out.println("Orthogonal: " + orthogonals[1] + ", HasObstacle: " + drone.hasObstacleInDirection(orthogonals[1]));

            for (String ortho : orthogonals) {
                if (!drone.hasObstacleInDirection(ortho)) {
                    DroneBusinessObject.goTo(drone, ortho);

                    break;
                }
            }
        } else {
            attemptsToAvoid = 0;
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
