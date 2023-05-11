/**
 * @description       : Batch to seat bookings with a single PIUA
 * @author            : Anderson Morino
 * @group             :
 * @last modified on  : 05-11-2023
 * @last modified by  : Anderson Morino
 **/
// BEGINNING - Ticket #41032 / #41033 / #41003 / #30715 / #41034 / #40880 / #40065 / #40818 / #40869 / #40868 / #41037 - Solved bugs and implemented some missing notification tasks from the Seating Tool backlog
// BEGINNING - Ticket #39117 / #40707 / #40408 / #40326 / #40064 / #40063 / #40054 / #40050 / #39502 / #39232 - Fixed bugs for notifications and seating process bugs
// BEGINNING - Ticket #32134 / #39498 / #40024 / #40025 / #40026 - Fixed bugs
// BEGINNING - Ticket #39453 / #40026 / #40010 / #39498 / #39117 / #37921 - Refactorings
// BEGINNING - Ticket #35471 - Batch to seat bookings with a single PIUA
// BEGINNING - Ticket #38145 / #38487 / #38498 / #38790 - Added boolean variable to control LAK seating process
// BEGINNING - Ticket #37921 / #31294 - Added list of routes and call the business method only if there are elegible bookings
// BEGINNING - Ticket #39745 / #39544 / #39498 / #37922 / #37921 / #32134 / #31236 - Fixed bugs when seating bookings, improving the order of bookings and passengers by Room Id
global class RM_SeatingTool_Others_Batch implements Database.Batchable<sObject>, Database.Stateful {
  private List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries;
  private RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup;
  private RM_SeatingToolWrappers.SeatingToolBatchWrapper wrappedSeatingBatch;
  private List<Id> batchJobIdList;
  private Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap;
  private RM_ROS_IntegrationWrapper.TRAIN trainInfo;
  private Integer sizeOfPIUA2UpdateMap;
  private Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper> mapMobility_Railcar;
  private List<String> routeList;
  private Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c> railcarIdByLAKGLBookingPIUAOver36;
  private List<KaptioTravel__Itinerary_Item__c> bookingList;

  public RM_SeatingTool_Others_Batch(
    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries,
    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup,
    RM_SeatingToolWrappers.SeatingToolBatchWrapper wrappedSeatingBatch,
    List<Id> batchJobIdList,
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap,
    RM_ROS_IntegrationWrapper.TRAIN trainInfo,
    Integer sizeOfPIUA2UpdateMap,
    Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper> mapMobility_Railcar,
    List<String> routeList,
    Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c> railcarIdByLAKGLBookingPIUAOver36,
    List<KaptioTravel__Itinerary_Item__c> bookingList
  ) {
    this.wrappedItineraries = wrappedItineraries;
    this.wrappedServiceClassGroup = wrappedServiceClassGroup;
    this.wrappedSeatingBatch = wrappedSeatingBatch;
    this.batchJobIdList = batchJobIdList;
    this.piua2UpdateMap = piua2UpdateMap;
    this.trainInfo = trainInfo;
    this.sizeOfPIUA2UpdateMap = sizeOfPIUA2UpdateMap;
    this.mapMobility_Railcar = mapMobility_Railcar;
    this.routeList = routeList;
    this.railcarIdByLAKGLBookingPIUAOver36 = railcarIdByLAKGLBookingPIUAOver36;
    this.bookingList = bookingList;
  }

  global Iterable<sObject> start(Database.BatchableContext BC) {
    for (KaptioTravel__Itinerary_Item__c bookingWithPassengers : wrappedSeatingBatch.wrappedSeatingRule.remainingOthersBookingsToProcessList) {
      wrappedSeatingBatch.wrappedSeatingRule.othersBookingsToProcessList.add(bookingWithPassengers);

      wrappedSeatingBatch.wrappedSeatingRule.bookingOthersPIUAListByItiItem.put(
        bookingWithPassengers.Id,
        bookingWithPassengers.KaptioTravel__PassengerItineraryUnitAssignments__r
      );
    }

    for (KaptioTravel__Itinerary_Item__c bookingWithPassengers : wrappedSeatingBatch.wrappedSeatingRule.othersBookingsToProcessList) {
      for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : bookingWithPassengers.KaptioTravel__PassengerItineraryUnitAssignments__r) {
        if (
          piua.KaptioTravel__Passenger__c == null &&
          wrappedSeatingBatch.wrappedSeatingRule.bookingOthersPIUAListByItiItem.containsKey(bookingWithPassengers.Id)
        ) {
          wrappedSeatingBatch.wrappedSeatingRule.bookingOthersPIUAListByItiItem.get(bookingWithPassengers.Id)
            .remove(wrappedSeatingBatch.wrappedSeatingRule.bookingOthersPIUAListByItiItem.get(bookingWithPassengers.Id).indexOf(piua));

          if (wrappedSeatingBatch.wrappedSeatingRule.bookingOthersPIUAListByItiItem.get(bookingWithPassengers.Id).isEmpty()) {
            wrappedSeatingBatch.wrappedSeatingRule.bookingOthersPIUAListByItiItem.remove(bookingWithPassengers.Id);
          }
        }
      }
    }

    return wrappedSeatingBatch.wrappedSeatingRule.othersBookingsToProcessList;
  }

  global void execute(Database.BatchableContext BC, List<KaptioTravel__Itinerary_Item__c> scope) {
    if (!scope.isEmpty()) {
      Map<String, RM_SeatingToolWrappers.RailcarWrapper> contiguousSeatsSizeMap = RM_SeatingTool_Utils.getContiguousRailcarSeatsSize(
        wrappedSeatingBatch.railcarSeatMap,
        wrappedSeatingBatch.mapKeySet,
        false,
        false
      );

      // seat all remaining bookings without business rules
      wrappedSeatingBatch.wrappedSeatingRule.batchHelper.processOtherPIUA(
        wrappedSeatingBatch.wrappedSeatingRule.bookingOthersPIUAListByItiItem,
        wrappedSeatingBatch.mapKeySet,
        wrappedSeatingBatch.railcarSeatMap,
        contiguousSeatsSizeMap,
        wrappedSeatingBatch.availableSeatsByRailcarId,
        piua2UpdateMap,
        wrappedItineraries,
        scope,
        wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.hasExecuted,
        piua2UpdateMap.size(),
        wrappedSeatingBatch.wrappedSeatingRule.itinerarySet,
        routeList,
        railcarIdByLAKGLBookingPIUAOver36
      );
    }
  }

  global void finish(Database.BatchableContext BC) {
    if (!wrappedServiceClassGroup.wrappedSeatingBatchLAKSL.hasExecuted) {
      wrappedServiceClassGroup.wrappedSeatingBatchLAKSL.hasExecuted = true;
    } else if (!wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.hasExecuted) {
      wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.hasExecuted = true;
    } else if (!wrappedServiceClassGroup.wrappedSeatingBatchCJ.hasExecuted) {
      wrappedServiceClassGroup.wrappedSeatingBatchCJ.hasExecuted = true;
    } else if (!wrappedServiceClassGroup.wrappedSeatingBatchSL.hasExecuted) {
      wrappedServiceClassGroup.wrappedSeatingBatchSL.hasExecuted = true;
    } else if (!wrappedServiceClassGroup.wrappedSeatingBatchGL.hasExecuted) {
      wrappedServiceClassGroup.wrappedSeatingBatchGL.hasExecuted = true;
    } else if (!wrappedServiceClassGroup.wrappedSeatingBatchSLP.hasExecuted) {
      wrappedServiceClassGroup.wrappedSeatingBatchSLP.hasExecuted = true;
    }

    if (
      wrappedServiceClassGroup.wrappedSeatingBatchLAKSL.hasExecuted &&
      wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.hasExecuted &&
      wrappedServiceClassGroup.wrappedSeatingBatchCJ.hasExecuted &&
      wrappedServiceClassGroup.wrappedSeatingBatchSL.hasExecuted &&
      wrappedServiceClassGroup.wrappedSeatingBatchGL.hasExecuted &&
      wrappedServiceClassGroup.wrappedSeatingBatchSLP.hasExecuted
    ) {
      // BEGINNING - Ticket #39090 - Notify for visually impaired guests
      List<KaptioTravel__PassengerItineraryUnitAssignment__c> bookingVisuallyImpairedPIUAList = new List<KaptioTravel__PassengerItineraryUnitAssignment__c>();
      Set<String> visuallyImpairedPassengerSet = new Set<String>();

      for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : piua2UpdateMap.values()) {
        if (piua.KaptioTravel__Passenger__r.MobilityGeneral__c != null) {
          List<String> mobility = piua.KaptioTravel__Passenger__r.MobilityGeneral__c.split(';');
          if (mobility.contains('Visually Impaired')) {
            bookingVisuallyImpairedPIUAList.add(piua);
          }
        }
      }

      try {
        if (!bookingVisuallyImpairedPIUAList.isEmpty()) {
          wrappedSeatingBatch.wrappedSeatingRule.batchHelper.sendProdOpsTeamEmail(
            bookingVisuallyImpairedPIUAList,
            visuallyImpairedPassengerSet,
            'Guest with visually impaired',
            'with Visually Impaired'
          );
        }
        // END - Ticket #39090

        if (!piua2UpdateMap.isEmpty()) {
          for (Id piuaId : piua2UpdateMap.keySet()) {
            if (piua2UpdateMap.get(piuaId).isClone()) {
              piua2UpdateMap.remove(piuaId);
            }
          }

          Id piua2UpdateBatchJobId = Database.executeBatch(new RM_SeatingTool_PIUA2Update_Batch(piua2UpdateMap.values()), 100);

          batchJobIdList.add(piua2UpdateBatchJobId);
        }

        List<KaptioTravel__PassengerItineraryUnitAssignment__c> piuaSpecialMobility2Notify = new List<KaptioTravel__PassengerItineraryUnitAssignment__c>();
        Set<String> mobilityPassengerSet = new Set<String>();

        List<String> routeRailcarIdList = new List<String>();
        routeRailcarIdList.addAll(mapMobility_Railcar.keySet());

        for (Integer i = 0; i < routeRailcarIdList.size(); i++) {
          if (mapMobility_Railcar.containsKey(routeRailcarIdList[i]) && !mapMobility_Railcar.get(routeRailcarIdList[i]).mobilityPIUAList.isEmpty()) {
            piuaSpecialMobility2Notify.addAll(mapMobility_Railcar.get(routeRailcarIdList[i]).mobilityPIUAList);
          }
        }

        if (!piuaSpecialMobility2Notify.isEmpty()) {
          RM_SeatingTool_Utils.sendProdOpsTeamEmail(piuaSpecialMobility2Notify, mobilityPassengerSet);
        }

        if (!railcarIdByLAKGLBookingPIUAOver36.isEmpty()) {
          RM_SeatingTool_Utils.sendLAKGLOver36ProdOpsTeamEmail(railcarIdByLAKGLBookingPIUAOver36, trainInfo);
        }
      } catch (Exception ex) {
        // Implement logic to notify user for exceptions - AKA Exception Log Task
        throw new RM_SeatingToolException(ex);
      }
    } else {
      Id batchJobId = Database.executeBatch(
        new RM_SeatingTool_DataSorting_Batch(
          wrappedItineraries,
          wrappedServiceClassGroup,
          batchJobIdList,
          piua2UpdateMap,
          trainInfo,
          piua2UpdateMap.size(),
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
  }
}
// END - Ticket #39745 / #39544 / #39498 / #37922 / #37921 / #32134 / #31236
// END - Ticket #37921 / #31294
// END - Ticket #38145 / #38487 / #38498 / #38790
// END - Ticket #35471
// END - Ticket #39453 / #40026 / #40010 / #39498 / #39117 / #37921
// END - Ticket #32134 / #39498 / #40024 / #40025 / #40026
// END - Ticket #39117 / #40707 / #40408 / #40326 / #40064 / #40063 / #40054 / #40050 / #39502 / #39232
// END - Ticket #41032 / #41033 / #41003 / #30715 / #41034 / #40880 / #40065 / #40818 / #40869 / #40868 / #41037
