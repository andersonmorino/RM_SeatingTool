/**
 * @description       : Wrapper class to build ROS response
 * @author            : Adrian Flores
 * @group             :
 * @last modified on  : 05-11-2023
 * @last modified by  : Anderson Morino
 **/
// BEGINNING - Ticket #41032 / #41033 / #41003 / #30715 / #41034 / #40880 / #40065 / #40818 / #40869 / #40868 / #41037 - Solved bugs and implemented some missing notification tasks from the Seating Tool backlog
// BEGINNING - Ticket #40010 - Documented class
// BEGINNING - Ticket #30715 - Refactorings
public without sharing class RM_ROS_IntegrationWrapper {
  /**
   * Wrapper of JSON response
   */
  public class TRAINS {
    public TRAIN TRAIN { get; set; }

    public TRAINS() {
    }

    public TRAINS(TRAIN TRAIN) {
      this.TRAIN = TRAIN;
    }
  }

  /**
   * Trains variable for getting multiple trains in ROS JSON response
   */
  public List<TRAINS> TRAINS;

  /**
   * This class represents the railcar construction, how is built
   */
  public class TRAIN_CONSTRUCT {
    public String Rail_Car { get; set; }
    public String Rail_Car_Ordinal { get; set; }
    public Integer Rail_Car_Order { get; set; }
    public String Rail_Car_Is_Active { get; set; }
    public String Rail_Car_Direction { get; set; }

    public TRAIN_CONSTRUCT() {
    }

    public TRAIN_CONSTRUCT(String Rail_Car, String Rail_Car_Ordinal, Integer Rail_Car_Order, String Rail_Car_Is_Active, String Rail_Car_Direction) {
      this.Rail_Car = Rail_Car;
      this.Rail_Car_Ordinal = Rail_Car_Ordinal;
      this.Rail_Car_Order = Rail_Car_Order;
      this.Rail_Car_Is_Active = Rail_Car_Is_Active;
      this.Rail_Car_Direction = Rail_Car_Direction;
    }
  }

  /**
   * This class represents a Leg
   */
  public class TRAIN_ITINERARY {
    public String Management_Leg_Name { get; set; }
    public String Origin_Station_Code { get; set; }
    public String Destination_Station_Code { get; set; }
    public String Scheduled_Arrival_Date { get; set; }
    public String Scheduled_Departure_Date { get; set; }
    public String Scheduled_Arrival_Time { get; set; }
    public String Scheduled_Departure_Time { get; set; }
    public List<TRAIN_CONSTRUCT> TRAIN_CONSTRUCT { get; set; }

    public TRAIN_ITINERARY() {
    }

    public TRAIN_ITINERARY(
      String Management_Leg_Name,
      String Origin_Station_Code,
      String Destination_Station_Code,
      String Scheduled_Arrival_Date,
      String Scheduled_Departure_Date,
      String Scheduled_Arrival_Time,
      String Scheduled_Departure_Time,
      List<TRAIN_CONSTRUCT> TRAIN_CONSTRUCT
    ) {
      this.Management_Leg_Name = Management_Leg_Name;
      this.Origin_Station_Code = Origin_Station_Code;
      this.Destination_Station_Code = Destination_Station_Code;
      this.Scheduled_Arrival_Date = Scheduled_Arrival_Date;
      this.Scheduled_Departure_Date = Scheduled_Departure_Date;
      this.Scheduled_Arrival_Time = Scheduled_Arrival_Time;
      this.Scheduled_Departure_Time = Scheduled_Departure_Time;
      this.TRAIN_CONSTRUCT = TRAIN_CONSTRUCT;
    }
  }

  /**
   * Train structure
   */
  public class TRAIN {
    public String Train_Name { get; set; }
    public String Scheduled_Departure_Date { get; set; }
    public String Origin_Station_Code { get; set; }
    public List<TRAIN_ITINERARY> TRAIN_ITINERARY { get; set; }

    public TRAIN() {
    }

    public TRAIN(String Train_Name, String Scheduled_Departure_Date, String Origin_Station_Code, List<TRAIN_ITINERARY> TRAIN_ITINERARY) {
      this.Train_Name = Train_Name;
      this.Scheduled_Departure_Date = Scheduled_Departure_Date;
      this.Origin_Station_Code = Origin_Station_Code;
      this.TRAIN_ITINERARY = TRAIN_ITINERARY;
    }
  }

  /**
   * @description Parse ROS response
   * @author Anderson Morino | 03-22-2023
   * @param json
   * @return RM_ROS_IntegrationWrapper
   **/
  public static RM_ROS_IntegrationWrapper parseResponse(String json) {
    return (RM_ROS_IntegrationWrapper) System.Json.deserialize(json, RM_ROS_IntegrationWrapper.class);
  }
}
// END - Ticket #30715
// END - Ticket #40010
// END - Ticket #41032 / #41033 / #41003 / #30715 / #41034 / #40880 / #40065 / #40818 / #40869 / #40868 / #41037
