package view;


import controller.CellController;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.input.KeyCode;
import javafx.scene.layout.*;
import model.Cell;

import java.util.List;

public class EnvironmentView {


    private GridPane gridpane = new GridPane();
    private AnchorPane envivonmentAnchorPane;
    private KeyCode keySelected;
    private ImageView windImageView = new ImageView(new Image("/view/res/wind.png"));
    private ImageView rainImageView = new ImageView(new Image("/view/res/rain.png"));
    private  CellController cellController = CellController.getInstance();

    public EnvironmentView(Cell cell, AnchorPane envivonmentAnchorPane) {
        //new EnvironmentView(cell, envivonmentAnchorPane);
        cellController.init(this);
        gridpane.setFocusTraversable(true);
    }

    public void notifyclearEnverionment() {
        cellController.clearEnverioment();
    }


    public EnvironmentView(int countRow, int countColunm, AnchorPane environmentAnchorPane) {
        gridpane.setLayoutY(35);

        for(int i = 0; i < countColunm; i++) {
            ColumnConstraints column = new ColumnConstraints(30);
            gridpane.getColumnConstraints().add(column);
        }

        for (int i = 0; i < countRow; i++) {
            RowConstraints row = new RowConstraints(30);
            gridpane.getRowConstraints().add(row);
        }

        for (int i = 0 ; i < countRow ; i++) {
            for (int j = 0; j < countColunm; j++) {
                createCell(i, j);
            }
        }


        gridpane.setGridLinesVisible(true);
        this.envivonmentAnchorPane = environmentAnchorPane;
        environmentAnchorPane.getChildren().addAll(gridpane);


    }

    private void createCell(int rowIndex, int collunmIndex) {

       CellView cellView = cellController.createCell(rowIndex, collunmIndex);

       gridpane.add(cellView,collunmIndex, rowIndex);

    }

    public List<CellView> getCellViews() {
        return CellController.getInstance().getCellViewList();
    }

    public CellView getCellViewSelected() {
        return cellController.getCellViewSelected();
    }

    public GridPane getGridpane() {
        return gridpane;
    }

    public KeyCode getKeySelected() {
        return keySelected;
    }

   /* public CellView getCellFrom(int i, int j){
        for(CellView cellView : getCellViews()){
            if(cellView.getInitialRowPosition() == i && cellView.getInitialCollunmPosition() == j){
                return cellView;
            }
        }
        return null;
    }
*/
    public void applyStrongWind() {
        if(!envivonmentAnchorPane.getChildren().contains(windImageView)){
            envivonmentAnchorPane.getChildren().add(windImageView);
        }

    }

    public void removeStrongWind() {
        if(envivonmentAnchorPane.getChildren().contains(windImageView)){
            envivonmentAnchorPane.getChildren().remove(windImageView);
        }
    }

    public void applyStrongRain() {
        if(!envivonmentAnchorPane.getChildren().contains(rainImageView)) {
            rainImageView.setX(35);
            envivonmentAnchorPane.getChildren().add(rainImageView);
        }
    }

    public void removeStrongRain() {
        if(envivonmentAnchorPane.getChildren().contains(rainImageView)){
            envivonmentAnchorPane.getChildren().remove(rainImageView);
        }
    }
}
