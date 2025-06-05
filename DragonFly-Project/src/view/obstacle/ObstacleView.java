package view.obstacle;

import javafx.scene.Group;
import javafx.scene.Node;
import javafx.scene.control.Label;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.paint.Color;
import javafx.scene.text.TextAlignment;
import model.entity.Obstacle;
import util.SelectHelper;
import view.CellView;
import view.SelectableView;

public class ObstacleView extends Group implements SelectableView, Obstacle.Listener {
    private String uniqueID;
    private String obstacleLabel;
    private CellView currentCellView;
    private SelectHelper selectHelper = new SelectHelper(SelectHelper.DEFAULT_COLOR);

    public ObstacleView(String uniqueID, String obstacleLabel, CellView cellViewSelected) {
        this.obstacleLabel = obstacleLabel;
        this.uniqueID = uniqueID;
        this.currentCellView = cellViewSelected;

        Label label = new Label();
        label.setText(obstacleLabel);
        label.setTextFill(Color.RED);
        label.setTextAlignment(TextAlignment.CENTER);

        ImageView imageView = new ImageView();
        Image image = new Image("/view/res/tree.png");
        imageView.setImage(image);

        this.getChildren().addAll(imageView, label);

        cellViewSelected.getChildren().add(this);
    }

    @Override
    public void onChange(Obstacle obstacle, String methodName, Object oldValue, Object newValue) {
        if(uniqueID != obstacle.getUniqueID()){
            return;
        }

        if(methodName.equals("setSelected")
                &&!(Boolean) oldValue && (Boolean) newValue){
            applyStyleSelected();
            return;
        }

        if(methodName.equals("setSelected")
                && (Boolean) oldValue && !(Boolean) newValue){
            removeStyleSelected();
            return;
        }
    }

    @Override
    public Node getNode() {
        return this;
    }

    @Override
    public CellView getCurrentCellView() {
        return currentCellView;
    }

    @Override
    public String getUniqueID() {
        return uniqueID;
    }

    @Override
    public void removeStyleSelected() {
        if(getChildren().contains(selectHelper)){
            getChildren().remove(selectHelper);
        }
    }

    @Override
    public void applyStyleSelected() {
        if(!getChildren().contains(selectHelper)){
            getChildren().add(selectHelper);
        }

    }

    public String getObstacleLabel() {
        return obstacleLabel;
    }

}
