/**
 * @description       : Service class called by Seating Tool LWC Apex Controller in order to execute business logic
 * @author            : Adrian Flores
 * @group             :
 * @last modified on  : 05-11-2023
 * @last modified by  : Anderson Morino
 **/
// BEGINNING - Ticket #41032 / #41033 / #41003 / #30715 / #41034 / #40880 / #40065 / #40818 / #40869 / #40868 / #41037 - Solved bugs and implemented some missing notification tasks from the Seating Tool backlog
// BEGINNING - Ticket #39117 / #40707 / #40408 / #40326 / #40064 / #40063 / #40054 / #40050 / #39502 / #39232 - Fixed bugs for notifications and seating process bugs
// BEGINNING - Ticket #40446 / #40408 / #40046 / #40045 / #40023 / #40022 / #39836 / #39117 - Fixed bugs for Split Trains
// BEGINNING - Ticket #32134 / #39498 / #40024 / #40025 / #40026 - Fixed bugs
// BEGINNING - Ticket #39453 / #40026 / #40010 / #39498 / #39117 / #37921 - Refactorings
// BEGINNING - Ticket #35471 - Service class to be called by LWC Apex Controller class
public with sharing class RM_SeatingToolService {
  /**
   * @description Return a list wrapped train leg/itineraries, where wrapper is: rail service name and its itinerary
   * @author Anderson Morino | 03-22-2023
   * @param trainItineraries
   * @return List<RM_SeatingToolWrappers.ROSRoutesServiceWrapper>
   **/
  public static List<RM_SeatingToolWrappers.ROSRoutesServiceWrapper> rosRoutesServices(
    List<RM_ROS_IntegrationWrapper.TRAIN_ITINERARY> trainItineraries
  ) {
    // we need to use a List of wrapped object to maintain the order of itineraies recieved from the JSON
    // if we used map instead, the keyset would be auto sorted
    List<RM_SeatingToolWrappers.ROSRoutesServiceWrapper> wrappedResponse = new List<RM_SeatingToolWrappers.ROSRoutesServiceWrapper>();

    if (trainItineraries != null) {
      Map<String, ROS_Kaptio_Legs_Map__mdt> railServicesMap = ROS_Kaptio_Legs_Map__mdt.getAll();

      for (RM_ROS_IntegrationWrapper.TRAIN_ITINERARY itinerary : trainItineraries) {
        for (String railServiceKey : railServicesMap.keySet()) {
          if (
            itinerary.Origin_Station_Code == railServicesMap.get(railServiceKey).ROS_Origin_Leg_Id__c &&
            itinerary.Destination_Station_Code == railServicesMap.get(railServiceKey).ROS_Destination_Leg_Id__c
          ) {
            wrappedResponse.add(new RM_SeatingToolWrappers.ROSRoutesServiceWrapper(railServicesMap.get(railServiceKey).MasterLabel, itinerary));
          }
        }
      }
    } else {
      throw new RM_SeatingToolException('Train itineraries cannot be null');
    }
    return wrappedResponse;
  }

  // BEGINNING - Ticket #30919 - Remove list out of index error added the below if condition
  /**
   * @description Get trains from ROS
   * @author Anderson Morino | 03-22-2023
   * @param departureDate
   * @return String
   **/
  public static String getROSTrains(String departureDate) {
    // BEGINNING - Tickets #30916 / #30958 - Split Trains logic implement
    String rosResponse = RM_ROS_Integration.getTrainsByDate(departureDate);

    if (!rosResponse.startsWith('There was an error in the ROS API Callout')) {
      RM_ROS_IntegrationWrapper response = (RM_ROS_IntegrationWrapper) JSON.deserialize(rosResponse, RM_ROS_IntegrationWrapper.class);
      String processedResponse = JSON.serialize(checkForSplitTrains(response));
      return processedResponse;
    }
    return rosResponse;
  }

  /**
   * @description:
   * This method check if the ROS response contains Split trains, if it does,
   * it merges those trains in a new single train, removes repeated itineraries,
   * and retain different itineraries in the new train.
   * @author Adrian Flores | 12-22-2022
   * @param response
   * @return RM_ROS_IntegrationWrapper
   **/
  private static RM_ROS_IntegrationWrapper checkForSplitTrains(RM_ROS_IntegrationWrapper response) {
    List<RM_ROS_IntegrationWrapper.TRAINS> trains = response.TRAINS;

    for (Integer i = 0; i < trains.size(); i++) {
      RM_ROS_IntegrationWrapper.TRAINS train1 = trains[i];
      if (!train1.TRAIN.TRAIN_ITINERARY.isEmpty()) {
        RM_ROS_IntegrationWrapper.TRAIN_ITINERARY firstLeg1 = train1.TRAIN.TRAIN_ITINERARY[0];
        RM_ROS_IntegrationWrapper.TRAIN_ITINERARY lastLeg1 = train1.TRAIN.TRAIN_ITINERARY[train1.TRAIN.TRAIN_ITINERARY.size() - 1];

        for (Integer j = i + 1; j < trains.size(); j++) {
          RM_ROS_IntegrationWrapper.TRAINS train2 = trains[j];
          if (!train2.TRAIN.TRAIN_ITINERARY.isEmpty()) {
            RM_ROS_IntegrationWrapper.TRAIN_ITINERARY firstLeg2 = train2.TRAIN.TRAIN_ITINERARY[0];
            RM_ROS_IntegrationWrapper.TRAIN_ITINERARY lastLeg2 = train2.TRAIN.TRAIN_ITINERARY[train2.TRAIN.TRAIN_ITINERARY.size() - 1];

            if ((firstLeg1.Origin_Station_Code == '0VA' && firstLeg1.Management_Leg_Name == firstLeg2.Management_Leg_Name)) {
              RM_ROS_IntegrationWrapper.TRAIN mergedTrain = new RM_ROS_IntegrationWrapper.TRAIN();
              String trainName2 = train2.TRAIN.Train_Name.substringAfterLast('-');
              mergedTrain.Train_Name = train1.TRAIN.Train_Name + '-' + trainName2;
              mergedTrain.Scheduled_Departure_Date = train1.TRAIN.Scheduled_Departure_Date;
              mergedTrain.Origin_Station_Code = train1.TRAIN.Origin_Station_Code;
              mergedTrain.TRAIN_ITINERARY = new List<RM_ROS_IntegrationWrapper.TRAIN_ITINERARY>();

              // Add the legs of train1 to the merged train, skipping duplicates
              for (RM_ROS_IntegrationWrapper.TRAIN_ITINERARY leg : train1.TRAIN.TRAIN_ITINERARY) {
                if (!legExistsInList(leg, mergedTrain.TRAIN_ITINERARY)) {
                  mergedTrain.TRAIN_ITINERARY.add(leg);
                }
              }

              // Add the legs of train2 to the merged train, skipping duplicates
              for (RM_ROS_IntegrationWrapper.TRAIN_ITINERARY leg : train2.TRAIN.TRAIN_ITINERARY) {
                if (!legExistsInList(leg, mergedTrain.TRAIN_ITINERARY)) {
                  mergedTrain.TRAIN_ITINERARY.add(leg);
                }
              }

              // Remove the original trains
              response.TRAINS.remove(i);
              response.TRAINS.remove(j - 1);

              // Add the merged train
              RM_ROS_IntegrationWrapper.TRAINS train2Add = new RM_ROS_IntegrationWrapper.TRAINS();
              train2Add.TRAIN = mergedTrain;
              response.TRAINS.add(train2Add);

              return response;
            } else if (lastLeg1.Destination_Station_Code == '0VA' && lastLeg1.Management_Leg_Name == lastLeg2.Management_Leg_Name) {
              RM_ROS_IntegrationWrapper.TRAIN mergedTrain = new RM_ROS_IntegrationWrapper.TRAIN();

              String trainName2 = train2.TRAIN.Train_Name.substringAfter('_').substringBeforeLast('-');
              String suffix = train1.TRAIN.Train_Name.substringBeforeLast('-') + '-' + trainName2;
              String preffix = train1.TRAIN.Train_Name.substringAfterLast('-');

              mergedTrain.Train_Name = suffix + '-' + preffix;

              mergedTrain.Scheduled_Departure_Date = train1.TRAIN.Scheduled_Departure_Date;
              mergedTrain.Origin_Station_Code = train1.TRAIN.Origin_Station_Code + '-' + train2.TRAIN.Origin_Station_Code;
              mergedTrain.TRAIN_ITINERARY = new List<RM_ROS_IntegrationWrapper.TRAIN_ITINERARY>();

              // Add the legs of train1 to the merged train, skipping duplicates
              for (RM_ROS_IntegrationWrapper.TRAIN_ITINERARY leg : train1.TRAIN.TRAIN_ITINERARY) {
                if (!legExistsInList(leg, mergedTrain.TRAIN_ITINERARY)) {
                  mergedTrain.TRAIN_ITINERARY.add(leg);
                }
              }

              // Remove the last leg from first split train to be added again in the right order
              mergedTrain.TRAIN_ITINERARY.remove(mergedTrain.TRAIN_ITINERARY.size() - 1);

              // Add the legs of train2 to the merged train, skipping duplicates
              for (RM_ROS_IntegrationWrapper.TRAIN_ITINERARY leg : train2.TRAIN.TRAIN_ITINERARY) {
                if (!legExistsInList(leg, mergedTrain.TRAIN_ITINERARY)) {
                  mergedTrain.TRAIN_ITINERARY.add(leg);
                }
              }

              // Remove the original trains
              response.TRAINS.remove(i);
              response.TRAINS.remove(j - 1);

              // Add the merged train
              RM_ROS_IntegrationWrapper.TRAINS train2Add = new RM_ROS_IntegrationWrapper.TRAINS();
              train2Add.TRAIN = mergedTrain;
              response.TRAINS.add(train2Add);

              return response;
            }
          }
        }
      }
    }

    return response;
  }
  // END - Ticket #30919

  /**
   * @description Method to check if it is a split train between two trains in the same departure date
   * @author Anderson Morino | 03-22-2023
   * @param leg
   * @param legs
   * @return Boolean
   **/
  private static Boolean legExistsInList(RM_ROS_IntegrationWrapper.TRAIN_ITINERARY leg, List<RM_ROS_IntegrationWrapper.TRAIN_ITINERARY> legs) {
    for (RM_ROS_IntegrationWrapper.TRAIN_ITINERARY l : legs) {
      if (leg.Management_Leg_Name == l.Management_Leg_Name) {
        return true;
      }
    }
    return false;
  }
  // END - Tickets #30916 / #30958

  // BEGINNING - Ticket #30921 - Refactorings
  /**
   * @description Returns data about the railcars
   * @author Anderson Morino | 03-22-2023
   * @param trainLeg
   * @return Map<Integer, RM_SeatingToolWrappers.RailcarWrapper>
   **/
  public static Map<Integer, RM_SeatingToolWrappers.RailcarWrapper> getRailcarsInfo(RM_ROS_IntegrationWrapper.TRAIN_ITINERARY trainLeg) {
    List<RM_SeatingToolWrappers.ROSRoutesServiceWrapper> routesItineraries = rosRoutesServices(
      new List<RM_ROS_IntegrationWrapper.TRAIN_ITINERARY>{ trainLeg }
    );

    Date routeDateFrom = Date.valueOf(routesItineraries[0].itinerary.Scheduled_Departure_Date);
    String serviceName = routesItineraries[0].masterLabel;

    List<RM_ROS_IntegrationWrapper.TRAIN_CONSTRUCT> trainConstructs = routesItineraries[0].itinerary.TRAIN_CONSTRUCT;
    Map<String, RM_SeatingToolWrappers.RailcarWrapper> railcarOrderById = new Map<String, RM_SeatingToolWrappers.RailcarWrapper>();

    for (RM_ROS_IntegrationWrapper.TRAIN_CONSTRUCT trainConstruct : trainConstructs) {
      railcarOrderById.put(
        trainConstruct.Rail_Car,
        new RM_SeatingToolWrappers.RailcarWrapper(trainConstruct.Rail_Car_Direction, trainConstruct.Rail_Car_Order)
      );
    }

    Map<Integer, RM_SeatingToolWrappers.RailcarWrapper> railcarInfoByOrder = new Map<Integer, RM_SeatingToolWrappers.RailcarWrapper>();

    for (Railcar__c railcar : [
      SELECT Id, Name, Physical_Seating_Capacity__c, Service_Class__c
      FROM Railcar__c
      WHERE Name IN :railcarOrderById.keySet()
    ]) {
      railcarInfoByOrder.put(
        railcarOrderById.get(railcar.Name).railcarOrder,
        new RM_SeatingToolWrappers.RailcarWrapper(
          serviceName,
          routeDateFrom,
          railcar.Name,
          Integer.valueOf(railcar.Physical_Seating_Capacity__c),
          railcar.Service_Class__c,
          railcarOrderById.get(railcar.Name).direction,
          new List<Integer>(),
          new Map<String, String>(),
          new List<Integer>()
        )
      );
    }

    for (Railcar_Seat__c railcarSeat : [
      SELECT Id, Railcar__c, Railcar__r.Name, Seat__c, Seat__r.Name, Inactive__c
      FROM Railcar_Seat__c
      WHERE Railcar__r.Name IN :railcarOrderById.keySet() AND Inactive__c = TRUE
    ]) {
      railcarInfoByOrder.get(railcarOrderById.get(railcarSeat.Railcar__r.Name).railcarOrder)
        .inactiveSeatsNumber.add(Integer.valueOf(railcarSeat.Seat__r.Name));
    }

    // Get PIUA for this management leg (service with departure date)
    for (
      KaptioTravel__PassengerItineraryUnitAssignment__c piua : [
        SELECT Id, RailCarNumber__c, RailCarOrdinalNumber__c, RailSeatNumber__c
        FROM KaptioTravel__PassengerItineraryUnitAssignment__c
        WHERE
          // BEGINNING - Ticket #32131 - Removed the filter to follow best practices and added to the if inside this for loop
          KaptioTravel__ItineraryItem__r.KaptioTravel__DateFrom__c = :routeDateFrom
          AND KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c = :serviceName
      ]
    ) {
      // BEGINNING - Ticket #31231 - Fixed error by checking if railcar collection has the PIUA allocation info
      if (piua.RailSeatNumber__c != null && railcarOrderById.containsKey(piua.RailCarNumber__c)) {
        railcarInfoByOrder.get(railcarOrderById.get(piua.RailCarNumber__c).railcarOrder)
          .occupiedSeatsNumber.add(Integer.valueOf(piua.RailSeatNumber__c));
        railcarInfoByOrder.get(railcarOrderById.get(piua.RailCarNumber__c).railcarOrder)
          .piuaIdsBySeatNumber.put(String.valueOf(piua.RailSeatNumber__c), String.valueOf(piua.Id));
      }
      // END - Ticket #31231
      // END - Ticket #32131
    }

    return railcarInfoByOrder;
  }

  // BEGINNING - Ticket #31237 - Method changed to adapt the process from Queueable to Batchable class
  /**
   * @description Unseat passengers
   * @author Anderson Morino | 03-22-2023
   * @param jsonTrain
   * @return List<Id>
   **/
  public static List<Id> unseatPassengers(String jsonTrain) {
    RM_ROS_IntegrationWrapper.TRAIN wrappedTrain = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(
      jsonTrain,
      RM_ROS_IntegrationWrapper.TRAIN.class
    );
    List<RM_SeatingToolWrappers.ROSRoutesServiceWrapper> routesItineraries = RM_SeatingToolService.rosRoutesServices(wrappedTrain.TRAIN_ITINERARY);

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();

    for (RM_SeatingToolWrappers.ROSRoutesServiceWrapper route : routesItineraries) {
      if (route.itinerary != null) {
        wrappedItineraries.add(
          new RM_SeatingToolWrappers.ManagementLegWrapper(
            route.itinerary.Management_Leg_Name,
            route.masterLabel,
            route.itinerary.Scheduled_Departure_Date,
            route.itinerary.TRAIN_CONSTRUCT
          )
        );
      }
    }
    // END - Ticket #31237

    List<Id> batchJobIdList = new List<Id>();

    Id unseatBatchJobId = Database.executeBatch(new RM_SeatingToolUnseatPIUABatch(wrappedItineraries), 100);
    batchJobIdList.add(unseatBatchJobId);

    return batchJobIdList;
  }
  // END - Ticket #31237

  // BEGINNING - Ticket #37921 / #31294 - Added list of routes and call the business method only if there are elegible bookings
  // BEGINNING - Ticket #38145 / #38487 / #38498 / #38790 - Added variables and logic for LAK seating process
  // BEGINNING - Ticket #39745 / #39544 / #39498 / #37922 / #37921 / #32134 / #31236 - Fixed bugs when seating bookings, improving the order of bookings and passengers by Room Id
  /**
   * @description Seat passengers
   * @author Anderson Morino | 03-22-2023
   * @param trainDetails
   * @return List<Id>
   **/
  public static List<Id> seatPassengers(String trainDetails) {
    List<RM_ROS_IntegrationWrapper.TRAINS> trainsList = new List<RM_ROS_IntegrationWrapper.TRAINS>();
    Map<Integer, List<RM_ROS_IntegrationWrapper.TRAIN_ITINERARY>> trainItinsByTrain = new Map<Integer, List<RM_ROS_IntegrationWrapper.TRAIN_ITINERARY>>();
    Integer trainIndex = 0;

    RM_ROS_IntegrationWrapper.TRAIN wrappedTrain = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(
      trainDetails,
      RM_ROS_IntegrationWrapper.TRAIN.class
    );

    List<RM_SeatingToolWrappers.ROSRoutesServiceWrapper> routesItineraries = rosRoutesServices(wrappedTrain.TRAIN_ITINERARY);

    List<String> routeList = new List<String>();

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();

    Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper> mapMobility_Railcar = new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>();

    for (RM_SeatingToolWrappers.ROSRoutesServiceWrapper route : routesItineraries) {
      if (route.itinerary != null) {
        wrappedItineraries.add(
          new RM_SeatingToolWrappers.ManagementLegWrapper(
            route.itinerary.Management_Leg_Name,
            route.masterLabel,
            route.itinerary.Scheduled_Departure_Date,
            route.itinerary.TRAIN_CONSTRUCT
          )
        );
      }

      if (!routeList.contains(route.masterLabel)) {
        routeList.add(route.masterLabel);
      }
    }

    Map<Integer, List<RM_ROS_IntegrationWrapper.TRAIN_CONSTRUCT>> trainConstructs = new Map<Integer, List<RM_ROS_IntegrationWrapper.TRAIN_CONSTRUCT>>();

    Map<Integer, String> lakeLouiseSLRailcarIdByRailcarOrder = new Map<Integer, String>();
    Map<Integer, String> lakeLouiseGLRailcarIdByRailcarOrder = new Map<Integer, String>();

    for (RM_SeatingToolWrappers.ManagementLegWrapper legName : wrappedItineraries) {
      trainConstructs.put(wrappedItineraries.indexOf(legName), legName.legConstruct);
      for (RM_ROS_IntegrationWrapper.TRAIN_CONSTRUCT construct : legName.legConstruct) {
        if (
          (legName.managementLegId.contains('KAM-LAK') || legName.managementLegId.contains('LAK-KAM')) &&
          construct.Rail_Car_Order <= legName.legConstruct[0].Rail_Car_Order + 9
        ) {
          if (
            !lakeLouiseSLRailcarIdByRailcarOrder.containsKey(construct.Rail_Car_Order) &&
            construct.Rail_Car.startsWith('2') &&
            !construct.Rail_Car.equals('2015') &&
            !construct.Rail_Car.equals('2016')
          ) {
            lakeLouiseSLRailcarIdByRailcarOrder.put(construct.Rail_Car_Order, construct.Rail_Car);
          } else if (!lakeLouiseGLRailcarIdByRailcarOrder.containsKey(construct.Rail_Car_Order) && construct.Rail_Car.startsWith('9')) {
            lakeLouiseGLRailcarIdByRailcarOrder.put(construct.Rail_Car_Order, construct.Rail_Car);
          }
        }
      }
    }

    // Create wrapper to handle rail car order and rail car ordinal
    Map<String, RM_SeatingToolWrappers.RailcarWrapper> railcarOrderByRailcarId = new Map<String, RM_SeatingToolWrappers.RailcarWrapper>();
    Map<String, RM_SeatingToolWrappers.RailcarWrapper> railcarOrderByRouteAndRailcarId = new Map<String, RM_SeatingToolWrappers.RailcarWrapper>();

    Map<Integer, RM_SeatingToolWrappers.RailcarWrapper> goldLeafRailcarIdByRailcarOrder = new Map<Integer, RM_SeatingToolWrappers.RailcarWrapper>();
    Map<Integer, RM_SeatingToolWrappers.RailcarWrapper> silverLeafPlusRailcarIdByRailcarOrder = new Map<Integer, RM_SeatingToolWrappers.RailcarWrapper>();
    Map<Integer, RM_SeatingToolWrappers.RailcarWrapper> silverLeafRailcarIdByRailcarOrder = new Map<Integer, RM_SeatingToolWrappers.RailcarWrapper>();

    List<String> goldLeafRailcarResponseOrderedList = new List<String>();
    List<String> silverLeafPlusRailcarResponseOrderedList = new List<String>();
    List<String> silverLeafRailcarResponseOrderedList = new List<String>();

    Map<Integer, List<String>> railcarListByLeg = new Map<Integer, List<String>>();

    for (Integer constructId : trainConstructs.keySet()) {
      Integer counter = 0;
      for (RM_ROS_IntegrationWrapper.TRAIN_CONSTRUCT construct : trainConstructs.get(constructId)) {
        railcarOrderByRailcarId.put(
          construct.Rail_Car,
          new RM_SeatingToolWrappers.RailcarWrapper(construct.Rail_Car_Order, construct.Rail_Car_Ordinal)
        );

        String constructKey = String.valueOf(constructId).length() == 1 ? '0' + String.valueOf(constructId) : String.valueOf(constructId);

        railcarOrderByRouteAndRailcarId.put(
          constructKey +
          '-' +
          construct.Rail_Car,
          new RM_SeatingToolWrappers.RailcarWrapper(construct.Rail_Car_Order, construct.Rail_Car_Ordinal, counter)
        );

        counter++;

        if (construct.Rail_Car.startsWith('9')) {
          goldLeafRailcarIdByRailcarOrder.put(construct.Rail_Car_Order, new RM_SeatingToolWrappers.RailcarWrapper(construct.Rail_Car, 'GL'));
        } else if (construct.Rail_Car.equals('2015') || construct.Rail_Car.equals('2016')) {
          silverLeafPlusRailcarIdByRailcarOrder.put(construct.Rail_Car_Order, new RM_SeatingToolWrappers.RailcarWrapper(construct.Rail_Car, 'SL+'));
        } else if (construct.Rail_Car.startsWith('2')) {
          silverLeafRailcarIdByRailcarOrder.put(construct.Rail_Car_Order, new RM_SeatingToolWrappers.RailcarWrapper(construct.Rail_Car, 'SL'));
        }

        if (!railcarListByLeg.containsKey(constructId)) {
          railcarListByLeg.put(constructId, new List<String>{ construct.Rail_Car });
        } else if (!railcarListByLeg.get(constructId).contains(construct.Rail_Car)) {
          railcarListByLeg.get(constructId).add(construct.Rail_Car);
        }
      }
    }

    Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper> lakeLouiseSLRailcarSeatMap = new Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper>();
    Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper> lakeLouiseGLRailcarSeatMap = new Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper>();
    Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper> circleJourneyRailcarSeatMap = new Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper>();
    Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper> silverLeafRailcarSeatMap = new Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper>();
    Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper> goldLeafRailcarSeatMap = new Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper>();
    // BEGINNING - Ticket #30915 - Created map to seat silverleaf plus customers
    Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper> silverLeafPlusRailcarSeatMap = new Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper>();
    // END - Ticket #30915

    Map<String, RM_SeatingToolWrappers.RailcarWrapper> availableSeatsByLAKSLRailcarId = new Map<String, RM_SeatingToolWrappers.RailcarWrapper>();
    Map<String, RM_SeatingToolWrappers.RailcarWrapper> availableSeatsByLAKGLRailcarId = new Map<String, RM_SeatingToolWrappers.RailcarWrapper>();
    Map<String, RM_SeatingToolWrappers.RailcarWrapper> availableSeatsByCJRailcarId = new Map<String, RM_SeatingToolWrappers.RailcarWrapper>();
    Map<String, RM_SeatingToolWrappers.RailcarWrapper> availableSeatsBySLRailcarId = new Map<String, RM_SeatingToolWrappers.RailcarWrapper>();
    Map<String, RM_SeatingToolWrappers.RailcarWrapper> availableSeatsByGLRailcarId = new Map<String, RM_SeatingToolWrappers.RailcarWrapper>();
    Map<String, RM_SeatingToolWrappers.RailcarWrapper> availableSeatsBySLPRailcarId = new Map<String, RM_SeatingToolWrappers.RailcarWrapper>();

    Map<Id, Railcar_Seat__c> railcarSeatByIdMap = new Map<Id, Railcar_Seat__c>();

    // BEGINNING - Ticket #31238 - Added more one filter in order to do not seat passengers in Less Desirable Seats
    // BEGINNING - Ticket #35471 - Added Railcar Series field
    List<Railcar_Seat__c> railcarSeatList = [
      SELECT
        Id,
        Name,
        Railcar__c,
        Railcar__r.Name,
        Seat__c,
        Seat__r.Name,
        Railcar__r.Available_Seats__c,
        Railcar__r.Available_Seating_Capacity__c,
        Railcar__r.Service_Class__c,
        Mobility_Approved__c,
        Seat_Letter__c,
        Railcar__r.Railcar_Series__c
      FROM Railcar_Seat__c
      WHERE Railcar__r.Name IN :railcarOrderByRailcarId.keySet() AND Inactive__c = FALSE AND Less_Desirable__c = FALSE
    ];
    // END - Ticket #35471
    // END - Ticket #31238

    for (RM_SeatingToolWrappers.ROSRoutesServiceWrapper route : routesItineraries) {
      for (Railcar_Seat__c railcarSeat : railcarSeatList) {
        // END - Ticket #35471
        if (!railcarSeatByIdMap.containsKey(railcarSeat.Id)) {
          railcarSeatByIdMap.put(railcarSeat.Id, railcarSeat);
        }

        if (
          railcarListByLeg.containsKey(routesItineraries.indexOf(route)) &&
          railcarListByLeg.get(routesItineraries.indexOf(route)).contains(railcarSeat.Railcar__r.Name)
        ) {
          if (
            !availableSeatsByLAKSLRailcarId.containsKey(route.masterLabel + '-' + railcarSeat.Railcar__r.Name) &&
            lakeLouiseSLRailcarIdByRailcarOrder.values().contains(railcarSeat.Railcar__r.Name)
          ) {
            if (routeList.contains('Lake Louise to Kamloops') || routeList.contains('Kamloops to Lake Louise')) {
              availableSeatsByLAKSLRailcarId.put(
                route.masterLabel +
                '-' +
                railcarSeat.Railcar__r.Name,
                new RM_SeatingToolWrappers.RailcarWrapper(Integer.valueOf(railcarSeat.Railcar__r.Available_Seats__c), new List<String>())
              );
            }
          }

          if (
            !availableSeatsByLAKGLRailcarId.containsKey(route.masterLabel + '-' + railcarSeat.Railcar__r.Name) &&
            lakeLouiseGLRailcarIdByRailcarOrder.values().contains(railcarSeat.Railcar__r.Name)
          ) {
            if (routeList.contains('Lake Louise to Kamloops')) {
              availableSeatsByLAKGLRailcarId.put(
                route.masterLabel +
                '-' +
                railcarSeat.Railcar__r.Name,
                new RM_SeatingToolWrappers.RailcarWrapper(36, new List<String>())
              );
            } else if (routeList.contains('Kamloops to Lake Louise')) {
              availableSeatsByLAKGLRailcarId.put(
                route.masterLabel +
                '-' +
                railcarSeat.Railcar__r.Name,
                new RM_SeatingToolWrappers.RailcarWrapper(Integer.valueOf(railcarSeat.Railcar__r.Available_Seats__c), new List<String>())
              );
            }
          }

          if (
            !availableSeatsByCJRailcarId.containsKey(route.masterLabel + '-' + railcarSeat.Railcar__r.Name) &&
            railcarSeat.Railcar__r.Railcar_Series__c != null &&
            railcarSeat.Railcar__r.Service_Class__c == 'GL' &&
            (railcarSeat.Railcar__r.Railcar_Series__c == '3.0' ||
            railcarSeat.Railcar__r.Railcar_Series__c == '2.0')
          ) {
            availableSeatsByCJRailcarId.put(
              route.masterLabel +
              '-' +
              railcarSeat.Railcar__r.Name,
              new RM_SeatingToolWrappers.RailcarWrapper(Integer.valueOf(railcarSeat.Railcar__r.Available_Seats__c), new List<String>())
            );
          }

          if (
            !availableSeatsBySLRailcarId.containsKey(route.masterLabel + '-' + railcarSeat.Railcar__r.Name) &&
            railcarSeat.Railcar__r.Service_Class__c == 'SL'
          ) {
            availableSeatsBySLRailcarId.put(
              route.masterLabel +
              '-' +
              railcarSeat.Railcar__r.Name,
              new RM_SeatingToolWrappers.RailcarWrapper(Integer.valueOf(railcarSeat.Railcar__r.Available_Seats__c), new List<String>())
            );
          } else if (
            !availableSeatsByGLRailcarId.containsKey(route.masterLabel + '-' + railcarSeat.Railcar__r.Name) &&
            railcarSeat.Railcar__r.Service_Class__c == 'GL'
          ) {
            availableSeatsByGLRailcarId.put(
              route.masterLabel +
              '-' +
              railcarSeat.Railcar__r.Name,
              new RM_SeatingToolWrappers.RailcarWrapper(Integer.valueOf(railcarSeat.Railcar__r.Available_Seats__c), new List<String>())
            );
          } else if (
            !availableSeatsBySLPRailcarId.containsKey(route.masterLabel + '-' + railcarSeat.Railcar__r.Name) &&
            railcarSeat.Railcar__r.Service_Class__c == 'SL+'
          ) {
            availableSeatsBySLPRailcarId.put(
              route.masterLabel +
              '-' +
              railcarSeat.Railcar__r.Name,
              new RM_SeatingToolWrappers.RailcarWrapper(Integer.valueOf(railcarSeat.Railcar__r.Available_Seats__c), new List<String>())
            );
          }
        }
      }
    }

    for (RM_SeatingToolWrappers.ManagementLegWrapper itinerary : wrappedItineraries) {
      for (Railcar_Seat__c railcarSeat : railcarSeatByIdMap.values()) {
        if (
          itinerary.legConstruct != null &&
          railcarListByLeg.containsKey(wrappedItineraries.indexOf(itinerary)) &&
          railcarListByLeg.get(wrappedItineraries.indexOf(itinerary)).contains(railcarSeat.Railcar__r.Name) &&
          railcarOrderByRouteAndRailcarId.containsKey(
            String.valueOf(wrappedItineraries.indexOf(itinerary)).length() == 1
              ? '0' + String.valueOf(wrappedItineraries.indexOf(itinerary) + '-' + railcarSeat.Railcar__r.Name)
              : String.valueOf(wrappedItineraries.indexOf(itinerary) + '-' + railcarSeat.Railcar__r.Name)
          )
        ) {
          String routeKey = String.valueOf(wrappedItineraries.indexOf(itinerary)).length() == 1
            ? '0' + String.valueOf(wrappedItineraries.indexOf(itinerary))
            : String.valueOf(wrappedItineraries.indexOf(itinerary));
          String railcarSeriesKey;

          if (railcarSeat.Railcar__r.Railcar_Series__c != null) {
            if (railcarSeat.Railcar__r.Railcar_Series__c == '3.0') {
              railcarSeriesKey = '000' + String.valueOf(railcarSeat.Railcar__r.Railcar_Series__c).removeEnd('.0');
            } else if (railcarSeat.Railcar__r.Railcar_Series__c == '2.0') {
              railcarSeriesKey = '00' + String.valueOf(railcarSeat.Railcar__r.Railcar_Series__c).removeEnd('.0');
            } else if (railcarSeat.Railcar__r.Railcar_Series__c == '1.0') {
              railcarSeriesKey = '0' + String.valueOf(railcarSeat.Railcar__r.Railcar_Series__c).removeEnd('.0');
            } else {
              railcarSeriesKey = '';
            }
          }
          String railcarOrderKey = String.valueOf(railcarOrderByRouteAndRailcarId.get(routeKey + '-' + railcarSeat.Railcar__r.Name).counter)
              .length() == 1
            ? '0' + String.valueOf(railcarOrderByRouteAndRailcarId.get(routeKey + '-' + railcarSeat.Railcar__r.Name).counter)
            : String.valueOf(railcarOrderByRouteAndRailcarId.get(routeKey + '-' + railcarSeat.Railcar__r.Name).counter);
          String railcarSeatKey = railcarSeat.Seat__r.Name.length() == 1 ? '0' + railcarSeat.Seat__r.Name : railcarSeat.Seat__r.Name;

          if (lakeLouiseSLRailcarIdByRailcarOrder.values().contains(railcarSeat.Railcar__r.Name)) {
            lakeLouiseSLRailcarSeatMap.put(
              routeKey +
              '-' +
              railcarOrderKey +
              '-' +
              railcarSeat.Railcar__r.Name +
              '-' +
              railcarSeatKey,
              new RM_SeatingToolWrappers.RailcarSeatWrapper(
                wrappedItineraries.indexOf(itinerary),
                itinerary.route,
                Date.valueOf(itinerary.departureDate),
                railcarSeat.Railcar__r.Name,
                railcarOrderByRouteAndRailcarId.get(routeKey + '-' + railcarSeat.Railcar__r.Name).railcarOrdinal,
                railcarSeat.Seat__r.Name,
                railcarSeat.Seat_Letter__c,
                Integer.valueOf(railcarSeat.Railcar__r.Available_Seating_Capacity__c),
                false,
                railcarSeat.Mobility_Approved__c,
                !lakeLouiseSLRailcarIdByRailcarOrder.isEmpty() &&
                  lakeLouiseSLRailcarIdByRailcarOrder.values().get(lakeLouiseSLRailcarIdByRailcarOrder.values().size() - 1) ==
                  railcarSeat.Railcar__r.Name
                  ? true
                  : false,
                // BEGINNING - Ticket #35471 - Added information about railcar series and each piece of this map key in order to use the aux map
                railcarSeat.Railcar__r.Railcar_Series__c,
                routeKey,
                railcarSeriesKey,
                railcarOrderKey,
                railcarSeatKey,
                // END - Ticket #35471
                null,
                0,
                null
              )
            );

            if (!mapMobility_Railcar.containsKey(itinerary.route + '-' + railcarSeat.Railcar__r.Name)) {
              mapMobility_Railcar.put(
                itinerary.route +
                '-' +
                railcarSeat.Railcar__r.Name,
                new RM_SeatingToolWrappers.MobilityEmailWrapper(0, new List<KaptioTravel__PassengerItineraryUnitAssignment__c>())
              );
            }
          } else if (lakeLouiseGLRailcarIdByRailcarOrder.values().contains(railcarSeat.Railcar__r.Name)) {
            lakeLouiseGLRailcarSeatMap.put(
              routeKey +
              '-' +
              railcarOrderKey +
              '-' +
              railcarSeat.Railcar__r.Name +
              '-' +
              railcarSeatKey,
              new RM_SeatingToolWrappers.RailcarSeatWrapper(
                wrappedItineraries.indexOf(itinerary),
                itinerary.route,
                Date.valueOf(itinerary.departureDate),
                railcarSeat.Railcar__r.Name,
                railcarOrderByRouteAndRailcarId.get(routeKey + '-' + railcarSeat.Railcar__r.Name).railcarOrdinal,
                railcarSeat.Seat__r.Name,
                railcarSeat.Seat_Letter__c,
                Integer.valueOf(railcarSeat.Railcar__r.Available_Seating_Capacity__c),
                false,
                railcarSeat.Mobility_Approved__c,
                !lakeLouiseGLRailcarIdByRailcarOrder.isEmpty() &&
                  lakeLouiseGLRailcarIdByRailcarOrder.values().get(lakeLouiseGLRailcarIdByRailcarOrder.values().size() - 1) ==
                  railcarSeat.Railcar__r.Name
                  ? true
                  : false,
                // BEGINNING - Ticket #35471 - Added information about railcar series and each piece of this map key in order to use the aux map
                railcarSeat.Railcar__r.Railcar_Series__c,
                routeKey,
                railcarSeriesKey,
                railcarOrderKey,
                railcarSeatKey,
                // END - Ticket #35471
                null,
                0,
                null
              )
            );

            if (!mapMobility_Railcar.containsKey(itinerary.route + '-' + railcarSeat.Railcar__r.Name)) {
              mapMobility_Railcar.put(
                itinerary.route +
                '-' +
                railcarSeat.Railcar__r.Name,
                new RM_SeatingToolWrappers.MobilityEmailWrapper(0, new List<KaptioTravel__PassengerItineraryUnitAssignment__c>())
              );
            }
          }

          if (railcarSeat.Railcar__r.Service_Class__c == 'SL') {
            silverLeafRailcarSeatMap.put(
              routeKey +
              '-' +
              railcarOrderKey +
              '-' +
              railcarSeat.Railcar__r.Name +
              '-' +
              railcarSeatKey,
              new RM_SeatingToolWrappers.RailcarSeatWrapper(
                wrappedItineraries.indexOf(itinerary),
                itinerary.route,
                Date.valueOf(itinerary.departureDate),
                railcarSeat.Railcar__r.Name,
                railcarOrderByRouteAndRailcarId.get(routeKey + '-' + railcarSeat.Railcar__r.Name).railcarOrdinal,
                railcarSeat.Seat__r.Name,
                railcarSeat.Seat_Letter__c,
                Integer.valueOf(railcarSeat.Railcar__r.Available_Seating_Capacity__c),
                false,
                railcarSeat.Mobility_Approved__c,
                !silverLeafRailcarIdByRailcarOrder.isEmpty() &&
                  silverLeafRailcarIdByRailcarOrder.values().get(silverLeafRailcarIdByRailcarOrder.values().size() - 1).railcarId ==
                  railcarSeat.Railcar__r.Name &&
                  silverLeafRailcarIdByRailcarOrder.values().get(silverLeafRailcarIdByRailcarOrder.values().size() - 1).serviceClass ==
                  railcarSeat.Railcar__r.Service_Class__c
                  ? true
                  : false,
                // BEGINNING - Ticket #35471 - Added information about railcar series and each piece of this map key in order to use the aux map
                railcarSeat.Railcar__r.Railcar_Series__c,
                routeKey,
                railcarSeriesKey,
                railcarOrderKey,
                railcarSeatKey,
                // END - Ticket #35471
                null,
                0,
                null
              )
            );

            if (!mapMobility_Railcar.containsKey(itinerary.route + '-' + railcarSeat.Railcar__r.Name)) {
              mapMobility_Railcar.put(
                itinerary.route +
                '-' +
                railcarSeat.Railcar__r.Name,
                new RM_SeatingToolWrappers.MobilityEmailWrapper(0, new List<KaptioTravel__PassengerItineraryUnitAssignment__c>())
              );
            }
          } else if (railcarSeat.Railcar__r.Service_Class__c == 'GL') {
            goldLeafRailcarSeatMap.put(
              routeKey +
              '-' +
              railcarOrderKey +
              '-' +
              railcarSeat.Railcar__r.Name +
              '-' +
              railcarSeatKey,
              new RM_SeatingToolWrappers.RailcarSeatWrapper(
                wrappedItineraries.indexOf(itinerary),
                itinerary.route,
                Date.valueOf(itinerary.departureDate),
                railcarSeat.Railcar__r.Name,
                railcarOrderByRouteAndRailcarId.get(routeKey + '-' + railcarSeat.Railcar__r.Name).railcarOrdinal,
                railcarSeat.Seat__r.Name,
                railcarSeat.Seat_Letter__c,
                Integer.valueOf(railcarSeat.Railcar__r.Available_Seating_Capacity__c),
                false,
                railcarSeat.Mobility_Approved__c,
                !goldLeafRailcarIdByRailcarOrder.isEmpty() &&
                  goldLeafRailcarIdByRailcarOrder.values().get(goldLeafRailcarIdByRailcarOrder.values().size() - 1).railcarId ==
                  railcarSeat.Railcar__r.Name &&
                  goldLeafRailcarIdByRailcarOrder.values().get(goldLeafRailcarIdByRailcarOrder.values().size() - 1).serviceClass ==
                  railcarSeat.Railcar__r.Service_Class__c
                  ? true
                  : false,
                // BEGINNING - Ticket #35471 - Added information about railcar series and each piece of this map key in order to use the aux map
                railcarSeat.Railcar__r.Railcar_Series__c,
                routeKey,
                railcarSeriesKey,
                railcarOrderKey,
                railcarSeatKey,
                // END - Ticket #35471
                null,
                0,
                null
              )
            );

            if (!mapMobility_Railcar.containsKey(itinerary.route + '-' + railcarSeat.Railcar__r.Name)) {
              mapMobility_Railcar.put(
                itinerary.route +
                '-' +
                railcarSeat.Railcar__r.Name,
                new RM_SeatingToolWrappers.MobilityEmailWrapper(0, new List<KaptioTravel__PassengerItineraryUnitAssignment__c>())
              );
            }

            // BEGINNING - Ticket #35471 - Put Railcar Seat information to the aux map for Circle Journey
            if (
              railcarSeat.Railcar__r.Railcar_Series__c != null &&
              (railcarSeat.Railcar__r.Railcar_Series__c == '3.0' ||
              railcarSeat.Railcar__r.Railcar_Series__c == '2.0')
            ) {
              circleJourneyRailcarSeatMap.put(
                routeKey +
                '-' +
                railcarSeriesKey +
                '-' +
                railcarOrderKey +
                '-' +
                railcarSeat.Railcar__r.Name +
                '-' +
                railcarSeatKey,
                new RM_SeatingToolWrappers.RailcarSeatWrapper(
                  wrappedItineraries.indexOf(itinerary),
                  itinerary.route,
                  Date.valueOf(itinerary.departureDate),
                  railcarSeat.Railcar__r.Name,
                  railcarOrderByRouteAndRailcarId.get(routeKey + '-' + railcarSeat.Railcar__r.Name).railcarOrdinal,
                  railcarSeat.Seat__r.Name,
                  railcarSeat.Seat_Letter__c,
                  Integer.valueOf(railcarSeat.Railcar__r.Available_Seating_Capacity__c),
                  false,
                  railcarSeat.Mobility_Approved__c,
                  !goldLeafRailcarIdByRailcarOrder.isEmpty() &&
                    goldLeafRailcarIdByRailcarOrder.values().get(goldLeafRailcarIdByRailcarOrder.values().size() - 1).railcarId ==
                    railcarSeat.Railcar__r.Name &&
                    goldLeafRailcarIdByRailcarOrder.values().get(goldLeafRailcarIdByRailcarOrder.values().size() - 1).serviceClass ==
                    railcarSeat.Railcar__r.Service_Class__c
                    ? true
                    : false,
                  railcarSeat.Railcar__r.Railcar_Series__c,
                  routeKey,
                  railcarSeriesKey,
                  railcarOrderKey,
                  railcarSeatKey,
                  null,
                  0,
                  null
                )
              );

              if (!mapMobility_Railcar.containsKey(itinerary.route + '-' + railcarSeat.Railcar__r.Name)) {
                mapMobility_Railcar.put(
                  itinerary.route +
                  '-' +
                  railcarSeat.Railcar__r.Name,
                  new RM_SeatingToolWrappers.MobilityEmailWrapper(0, new List<KaptioTravel__PassengerItineraryUnitAssignment__c>())
                );
              }
            }
            // END - Ticket #35471

            // BEGINNING - Ticket #30915 - check if the railcar seat is SilverLeaf Plus
          } else if (railcarSeat.Railcar__r.Service_Class__c == 'SL+') {
            silverLeafPlusRailcarSeatMap.put(
              routeKey +
              '-' +
              railcarOrderKey +
              '-' +
              railcarSeat.Railcar__r.Name +
              '-' +
              railcarSeatKey,
              new RM_SeatingToolWrappers.RailcarSeatWrapper(
                wrappedItineraries.indexOf(itinerary),
                itinerary.route,
                Date.valueOf(itinerary.departureDate),
                railcarSeat.Railcar__r.Name,
                railcarOrderByRouteAndRailcarId.get(routeKey + '-' + railcarSeat.Railcar__r.Name).railcarOrdinal,
                railcarSeat.Seat__r.Name,
                railcarSeat.Seat_Letter__c,
                Integer.valueOf(railcarSeat.Railcar__r.Available_Seating_Capacity__c),
                false,
                railcarSeat.Mobility_Approved__c,
                !silverLeafPlusRailcarIdByRailcarOrder.isEmpty() &&
                  silverLeafPlusRailcarIdByRailcarOrder.values().get(silverLeafPlusRailcarIdByRailcarOrder.values().size() - 1).railcarId ==
                  railcarSeat.Railcar__r.Name &&
                  silverLeafPlusRailcarIdByRailcarOrder.values().get(silverLeafPlusRailcarIdByRailcarOrder.values().size() - 1).serviceClass ==
                  railcarSeat.Railcar__r.Service_Class__c
                  ? true
                  : false,
                // BEGINNING - Ticket #35471 - Added information about railcar series and each piece of this map key in order to use the aux map
                railcarSeat.Railcar__r.Railcar_Series__c,
                routeKey,
                railcarSeriesKey,
                railcarOrderKey,
                railcarSeatKey,
                // END - Ticket #35471
                null,
                0,
                null
              )
            );

            if (!mapMobility_Railcar.containsKey(itinerary.route + '-' + railcarSeat.Railcar__r.Name)) {
              mapMobility_Railcar.put(
                itinerary.route +
                '-' +
                railcarSeat.Railcar__r.Name,
                new RM_SeatingToolWrappers.MobilityEmailWrapper(0, new List<KaptioTravel__PassengerItineraryUnitAssignment__c>())
              );
            }
          }
          // END - Ticket #30915
        }
      }
    }

    if (!mapMobility_Railcar.containsKey('No seated GL passengers')) {
      mapMobility_Railcar.put(
        'No seated GL passengers',
        new RM_SeatingToolWrappers.MobilityEmailWrapper(0, new List<KaptioTravel__PassengerItineraryUnitAssignment__c>())
      );
    }

    List<String> lakeLouiseSLMapKeySet = new List<String>(lakeLouiseSLRailcarSeatMap.keySet());
    lakeLouiseSLMapKeySet.sort();
    List<String> lakeLouiseGLMapKeySet = new List<String>(lakeLouiseGLRailcarSeatMap.keySet());
    lakeLouiseGLMapKeySet.sort();

    List<String> silverLeafMapKeySet = new List<String>(silverLeafRailcarSeatMap.keySet());
    silverLeafMapKeySet.sort();
    List<String> goldLeafMapKeySet = new List<String>(goldLeafRailcarSeatMap.keySet());
    goldLeafMapKeySet.sort();

    // BEGINNING - Ticket #35471 - Sorting aux maps
    List<String> circleJourneyMapKeySet = new List<String>(circleJourneyRailcarSeatMap.keySet());
    circleJourneyMapKeySet.sort();
    // END - Ticket #35471

    List<String> silverLeafPlusMapKeySet = new List<String>(silverLeafPlusRailcarSeatMap.keySet());
    silverLeafPlusMapKeySet.sort();

    List<Id> batchJobIdList = new List<Id>();

    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    // BEGINNING - Ticket #32131 - Fixed to check two combinations of scenarios: GoldLeaf and SilverLeaf Cars or SilverLeaf and SilverLeaf Plus Cars
    // BEGINNING - Ticket #31289 - Improved the validation to check if there is no SL/GL or SL/GL+ railcars
    if (silverLeafRailcarSeatMap.isEmpty() && goldLeafRailcarSeatMap.isEmpty() && silverLeafPlusRailcarSeatMap.isEmpty()) {
      throw new RM_SeatingToolException('No railcars to process');
      // END - Ticket #31289
      // END - Ticket #32131
    } else {
      RM_SeatingToolWrappers.SeatingToolBatchWrapper wrappedSeatingBatchLAKSL = RM_SeatingTool_Utils.seatingBatchWrapperBuilder(
        lakeLouiseSLMapKeySet,
        lakeLouiseSLRailcarSeatMap,
        new RM_SeatingToolWrappers.SeatingRuleWrapper(),
        availableSeatsByLAKSLRailcarId,
        false
      );

      RM_SeatingToolWrappers.SeatingToolBatchWrapper wrappedSeatingBatchLAKGL = RM_SeatingTool_Utils.seatingBatchWrapperBuilder(
        lakeLouiseGLMapKeySet,
        lakeLouiseGLRailcarSeatMap,
        new RM_SeatingToolWrappers.SeatingRuleWrapper(),
        availableSeatsByLAKGLRailcarId,
        false
      );

      RM_SeatingToolWrappers.SeatingToolBatchWrapper wrappedSeatingBatchCJ = RM_SeatingTool_Utils.seatingBatchWrapperBuilder(
        circleJourneyMapKeySet,
        circleJourneyRailcarSeatMap,
        new RM_SeatingToolWrappers.SeatingRuleWrapper(),
        availableSeatsByCJRailcarId,
        false
      );

      RM_SeatingToolWrappers.SeatingToolBatchWrapper wrappedSeatingBatchSL = RM_SeatingTool_Utils.seatingBatchWrapperBuilder(
        silverLeafMapKeySet,
        silverLeafRailcarSeatMap,
        new RM_SeatingToolWrappers.SeatingRuleWrapper(),
        availableSeatsBySLRailcarId,
        false
      );

      RM_SeatingToolWrappers.SeatingToolBatchWrapper wrappedSeatingBatchGL = RM_SeatingTool_Utils.seatingBatchWrapperBuilder(
        goldLeafMapKeySet,
        goldLeafRailcarSeatMap,
        new RM_SeatingToolWrappers.SeatingRuleWrapper(),
        availableSeatsByGLRailcarId,
        false
      );

      RM_SeatingToolWrappers.SeatingToolBatchWrapper wrappedSeatingBatchSLP = RM_SeatingTool_Utils.seatingBatchWrapperBuilder(
        silverLeafPlusMapKeySet,
        silverLeafPlusRailcarSeatMap,
        new RM_SeatingToolWrappers.SeatingRuleWrapper(),
        availableSeatsBySLPRailcarId,
        false
      );

      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper(
        wrappedSeatingBatchLAKSL,
        wrappedSeatingBatchLAKGL,
        wrappedSeatingBatchCJ,
        wrappedSeatingBatchSL,
        wrappedSeatingBatchGL,
        wrappedSeatingBatchSLP
      );

      Integer sizeOfPIUA2UpdateMap = 1;

      Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c> railcarIdByLAKGLBookingPIUAOver36 = new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>();

      List<KaptioTravel__Itinerary_Item__c> bookingList = new List<KaptioTravel__Itinerary_Item__c>();

      Id batchJobId = Database.executeBatch(
        new RM_SeatingTool_DataSorting_Batch(
          wrappedItineraries,
          wrappedServiceClassGroup,
          batchJobIdList,
          piua2UpdateMap,
          wrappedTrain,
          sizeOfPIUA2UpdateMap,
          mapMobility_Railcar,
          routeList,
          railcarIdByLAKGLBookingPIUAOver36,
          bookingList
        ),
        2000
      );

      batchJobIdList.add(batchJobId);
      if (Test.isRunningTest()) {
        system.abortJob(batchJobId);
      }
    }

    return batchJobIdList;
  }
  // END - Ticket #37921 / #31294
  // END - Ticket #38145 / #38487 / #38498 / #38790
  // END - Ticket #30921

  /**
   * @description get status execution of batch
   * @author Anderson Morino | 10-31-2022
   * @param jobId
   * @return AsyncApexJob
   **/
  public static AsyncApexJob getBatchJobStatus(Id jobId) {
    AsyncApexJob jobInfo = [SELECT Status, NumberOfErrors, JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id = :jobID];
    return jobInfo;
  }
}
// END - Ticket #39745 / #39544 / #39498 / #37922 / #37921 / #32134 / #31236
// END - Ticket #35471
// END - Ticket #39453 / #40026 / #40010 / #39498 / #39117 / #37921
// END - Ticket #32134 / #39498 / #40024 / #40025 / #40026
// END - Ticket #40446 / #40408 / #40046 / #40045 / #40023 / #40022 / #39836 / #39117
// END - Ticket #39117 / #40707 / #40408 / #40326 / #40064 / #40063 / #40054 / #40050 / #39502 / #39232
// END - Ticket #41032 / #41033 / #41003 / #30715 / #41034 / #40880 / #40065 / #40818 / #40869 / #40868 / #41037
