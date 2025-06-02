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

public aspect Wrapper1 {

    pointcut safeLanding(): call (* model.entity.drone.DroneBusinessObject.safeLanding(*));
    pointcut applyEconomyMode(): call (* model.entity.drone.DroneBusinessObject.applyEconomyMode(*));

    //estou testando isso aqui só para automático, pode ser que no manual eu tenho que lidar com mais threads
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
        AdaptationMetricsTracker.getInstance().updateFailureAvoided(label);
        AdaptationMetricsTracker.getInstance().logMetrics(label);
    }


   boolean around(): safeLanding()
   && if
   (
   (((Drone)thisJoinPoint.getArgs()[0]).getWrapperId() == 1)
   &&
   (((Drone)thisJoinPoint.getArgs()[0]).getDistanceDestiny() <=60)
   &&
   (((Drone)thisJoinPoint.getArgs()[0]).isStrongWind())
   &&
   (((Drone)thisJoinPoint.getArgs()[0]).isStrongRain())
   ){
        keepFlying(thisJoinPoint);
        return false;
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
        LoggerController.getInstance().print("Drone["+drone.getLabel()+"] "+"Keep Flying");
    }



}
