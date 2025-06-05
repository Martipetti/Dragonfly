package model.entity;

import java.util.ArrayList;
import java.util.List;

public class Obstacle {
    public static int COUNT_OBSTACLE = 1;
    private final String uniqueID;
    int rowPosition, columnPosition;
    private Boolean selected = false;
    private List<Obstacle.Listener> listeners = new ArrayList<>();
    private String label;

    public Obstacle(String uniqueID, String label, int rowPosition, int columnPosition) {
        this.uniqueID = uniqueID;
        this.rowPosition = rowPosition;
        this.columnPosition = columnPosition;
        this.label = label;
        COUNT_OBSTACLE++;
    }

    public String getLabel() {
        return label;
    }

    public interface Listener{
        public void onChange(Obstacle obstacle, String methodName, Object oldValue, Object newValue);
    }

    public static void restartCount() {
        COUNT_OBSTACLE = 1;
    }

    public int getRowPosition() {
        return rowPosition;
    }

    public void setRowPosition(int rowPosition) {
        this.rowPosition = rowPosition;
    }

    public int getColumnPosition() {
        return columnPosition;
    }

    public void setColumnPosition(int columnPosition) {
        this.columnPosition = columnPosition;
    }

    public String getUniqueID() {
        return uniqueID;
    }

    public Boolean getSelected() {
        return selected;
    }

    public void setSelected(Boolean selected) {
        boolean oldValue = this.selected;
        boolean newValue = selected;

        this.selected = selected;

        notifiesListeners(Thread.currentThread().getStackTrace()[1].getMethodName(),oldValue, newValue);
    }

    public List<Obstacle.Listener> getListeners() {
        return listeners;
    }

    public void setListeners(List<Obstacle.Listener> listeners) {
        this.listeners = listeners;
    }

    public void addListener(Obstacle.Listener listener) {
        this.listeners.add(listener);
    }
    private void notifiesListeners(String attributeName, Object oldValue, Object newValue){

        synchronized (this){
            for (Obstacle.Listener listener : listeners){
                listener.onChange(this, attributeName, oldValue, newValue);
            }
        }
    }
}
