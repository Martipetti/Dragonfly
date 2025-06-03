package controller;

import javafx.scene.input.KeyEvent;
import model.entity.Obstacle;
import view.CellView;
import view.SelectableView;
import view.obstacle.ObstacleView;

import java.util.HashMap;
import java.util.Map;

public class ObstacleController {
    private Map<String, ObstacleView> obstacleViewMap = new HashMap<>();
    private Map<String, Obstacle>  obstacleMap = new HashMap<>();
    private static ObstacleController instance;

    private ObstacleController() {

    }

    public static ObstacleController getInstance(){
        if(instance == null){

            instance = new ObstacleController();
        }

        return instance;
    }

    public Obstacle createObstacle(String uniqueID, String labelObstacle, CellView currentCellView){

        ObstacleView obstacleView  = new ObstacleView(uniqueID, labelObstacle,currentCellView);


        obstacleViewMap.put(uniqueID, obstacleView);


        Obstacle obstacle = new Obstacle(uniqueID, labelObstacle, currentCellView.getRowPosition(), currentCellView.getCollunmPosition());

        obstacle.addListener(obstacleView);

        obstacleMap.put(uniqueID, obstacle);

        obstacle.setSelected(true);

        return obstacle;
    }



    public ObstacleView getObstacleViewFrom(String identifierObstacle) {

        return obstacleViewMap.get(identifierObstacle);
    }

    public Obstacle getObstacleFrom(String identifierObstacle) {
        return obstacleMap.get(identifierObstacle);
    }

    public void consumeReset() {

    }

    public void consumeClickEvent(SelectableView selectedEntityView ) {
        if(selectedEntityView instanceof ObstacleView){
            Obstacle obstacle =  getObstacleFrom(selectedEntityView.getUniqueID());
            obstacle.setSelected(true);
        }
    }

    public void consumeOnKeyPressed(SelectableView selectedEntityView, KeyEvent keyEvent) {
        if(!(selectedEntityView instanceof ObstacleView)){
            return;
        }

    }


    public void consumeRunEnviroment() {

    }

    public Map<String, ObstacleView> getObstacleViewMap() {
        return obstacleViewMap;
    }

    public void setObstacleViewMap(Map<String, ObstacleView> obstacleViewMap) {
        this.obstacleViewMap = obstacleViewMap;
    }

    public Map<String, Obstacle> getObstacleMap() {
        return obstacleMap;
    }

    public void setObstacleMap(Map<String, Obstacle> obstacleMap) {
        this.obstacleMap = obstacleMap;
    }

    public void consumeCleanEnvironment() {
        obstacleMap.clear();
        obstacleViewMap.clear();
        Obstacle.restartCount();
    }


    public void cleanSelections() {
        for(Obstacle obstacle : obstacleMap.values()){
            obstacle.setSelected(false);
        }
    }

    public void deleteObstacle(Obstacle obstacle) {
        obstacleMap.remove(obstacle.getUniqueID());
        ObstacleView obstacleView = obstacleViewMap.remove(obstacle.getUniqueID());
        obstacleView.getCurrentCellView().getChildren().remove(obstacleView);
    }
}
