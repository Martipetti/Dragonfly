
package wrappers;

import controller.DroneController;
import controller.EnvironmentController;
import controller.LoggerController;
import javafx.scene.input.KeyCode;
import metrics.AdaptationMetricsTracker;
import metrics.QoSMetricsTracker;
import metrics.RuntimeCostTracker;
import model.entity.drone.Drone;
import model.entity.drone.DroneBusinessObject;
import org.aspectj.lang.JoinPoint;
import view.CellView;
import view.drone.DroneView;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;

public aspect Wrapper2 {

    pointcut safeLanding(): call (* model.entity.drone.DroneBusinessObject.safeLanding(*));
    pointcut returnToHome() : call (void model.entity.drone.DroneBusinessObject.returnToHome(*));
    pointcut applyEconomyMode() : call (void model.entity.drone.DroneBusinessObject.applyEconomyMode(*));
    pointcut goDestinyAutomatic() : call (void controller.DroneAutomaticController.goDestinyAutomatic(*));
    pointcut checkAndPrintIfLostDrone(): call (* model.entity.drone.DroneBusinessObject.checkAndPrintIfLostDrone(*));

    static private Set<Drone> isGlideSet = new HashSet<>();
    static private int attemptsToAvoid = 0;

    before(): goDestinyAutomatic() {
        Drone drone = (Drone) thisJoinPoint.getArgs()[0];

        if (drone.hasObstaclesInFront() && drone.getWrapperId() == 2) {
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
                String label = drone.getLabel();

                System.out.println("anomaly");
                AdaptationMetricsTracker.getInstance().markEvent(label + "_anomaly");

                avoidObstacle(thisJoinPoint);

                System.out.println("completion");
                AdaptationMetricsTracker.getInstance().markEvent(label + "_completion");
                QoSMetricsTracker.getInstance().incrementAdaptations(label);
            }
        }
    }


    //estou testando isso aqui só para automático, pode ser que no manual eu tenho que lidar com mais threads
    before(): safeLanding()
            &&
            if(
            (((Drone)thisJoinPoint.getArgs()[0]).getWrapperId() == 2)
            &&
            (((Drone)thisJoinPoint.getArgs()[0]).getDistanceDestiny() > 60)
            &&
            (((Drone)thisJoinPoint.getArgs()[0]).isOnWater())
            ){
        moveASide(thisJoinPoint);
    }

    //60 representa 2 bloquinhos de distancia
    boolean around(): safeLanding()
            &&
            if(
            (((Drone)thisJoinPoint.getArgs()[0]).getWrapperId() == 2)
            &&
            (((Drone)thisJoinPoint.getArgs()[0]).isStrongWind())
            &&
            (((Drone)thisJoinPoint.getArgs()[0]).isStrongRain())
            &&
            (((Drone)thisJoinPoint.getArgs()[0]).getDistanceDestiny() <=60)
            ){
        keepFlying(thisJoinPoint);
        return false;
    }

    void around(): returnToHome()
            &&
            if(
            (((Drone)thisJoinPoint.getArgs()[0]).getWrapperId() == 2)
            &&
            (((Drone)thisJoinPoint.getArgs()[0]).getCurrentBattery() > 10)
            &&
            (((Drone)thisJoinPoint.getArgs()[0]).getDistanceDestiny() < ((Drone)thisJoinPoint.getArgs()[0]).getDistanceSource())
            ){
        glide(thisJoinPoint);
    }


    void around(): goDestinyAutomatic()
            &&
            if(
            (((Drone)thisJoinPoint.getArgs()[0]).getWrapperId() == 2)
            &&
            (isGlideSet.contains((Drone)thisJoinPoint.getArgs()[0]))
            &&
            (((Drone)thisJoinPoint.getArgs()[0]).isBadConnection())
            ){

        // around goDestinyAutomatic while is glide

        Drone drone = (Drone) thisJoinPoint.getArgs()[0];
        isGlideSet.remove(drone);

    }

    void around(): applyEconomyMode()
            &&
            if
            (
            (((Drone)thisJoinPoint.getArgs()[0]).getWrapperId() == 2)
            ){
        // around applyEconomyMode
    }

    after(): checkAndPrintIfLostDrone(){
        Drone drone = (Drone) thisJoinPoint.getArgs()[0];
        if (drone.getWrapperId() == 2) {
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
        System.out.println("closerLandCellView: " + closerLandCellView.getRowPosition() + "," + closerLandCellView.getCollunmPosition());

        System.out.println("Drone["+drone.getLabel()+"] "+"Move Aside");
        LoggerController.getInstance().print("Drone["+drone.getLabel()+"] "+"Move Aside");

        while (drone.isOnWater()) {
            String goDirection = DroneBusinessObject.closeDirection(droneView.getCurrentCellView(), closerLandCellView);
            // drone.setEconomyMode(false);
            DroneBusinessObject.goTo(drone, goDirection);
        }
    }

    private void avoidObstacle(JoinPoint thisJoinPoint) {
        Drone drone = (Drone) thisJoinPoint.getArgs()[0];

        LoggerController.getInstance().print("Drone[" + drone.getLabel() + "] Obstacle detected! Trying to avoid...");

        String[] directions = {"<-", "->", "/\\", "\\/"};
        String currentDirection = drone.getAutoFlyDirectionCommand();
        String oppositeDirection = getOppositeDirection(currentDirection);

        boolean avoidMade = false;

        System.out.println("reaction");
        AdaptationMetricsTracker.getInstance().markEvent(drone.getLabel() + "_reaction");
        for (String direction : directions) {
            if (direction.equals(oppositeDirection)) continue;

            if (!drone.hasObstacleInDirection(direction)) {
                DroneBusinessObject.goTo(drone, direction);
                avoidMade = true;

                break;
            }
        }

        if (!avoidMade) {
            DroneBusinessObject.goTo(drone, oppositeDirection);

            String[] orthogonals = getOrthogonalDirections(oppositeDirection);

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

    after(): checkAndPrintIfLostDrone(){
        Drone drone = (Drone) thisJoinPoint.getArgs()[0];
        if (drone.getWrapperId() == 1) {
            String label = ((Drone) thisJoinPoint.getArgs()[0]).getLabel();
            AdaptationMetricsTracker.getInstance().logMetrics(label);
            QoSMetricsTracker.getInstance().logQoS(label);
            RuntimeCostTracker.getInstance().logRuntimeCost(label);
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
        //drone.setEconomyMode(false);
        System.out.println("Drone["+drone.getLabel()+"] "+"Keep Flying");
        LoggerController.getInstance().print("Drone["+drone.getLabel()+"] "+"Keep Flying");
    }


    private void glide(JoinPoint thisJoinPoint) {
        Drone drone = (Drone) thisJoinPoint.getArgs()[0];
        System.out.println("Drone["+drone.getLabel()+"] "+"Glide");
        LoggerController.getInstance().print("Drone["+drone.getLabel()+"] "+"Glide");
        isGlideSet.add(drone);

    }


}