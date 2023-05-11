/**
 * @description       : Batch to seat bookings with only one mobility guest
 * @author            : Anderson Morino
 * @group             :
 * @last modified on  : 05-11-2023
 * @last modified by  : Anderson Morino
 **/
// BEGINNING - Ticket #41032 / #41033 / #41003 / #30715 / #41034 / #40880 / #40065 / #40818 / #40869 / #40868 / #41037 - Solved bugs and implemented some missing notification tasks from the Seating Tool backlog
// BEGINNING - Ticket #39117 / #40707 / #40408 / #40326 / #40064 / #40063 / #40054 / #40050 / #39502 / #39232 - Fixed bugs for notifications and seating process bugs
// BEGINNING - Ticket #40446 / #40408 / #40046 / #40045 / #40023 / #40022 / #39836 / #39117 - Fixed bugs for Split Trains
// BEGINNING - Ticket #32134 / #39498 / #40024 / #40025 / #40026 - Fixed bugs
// BEGINNING - Ticket #39453 / #40026 / #40010 / #39498 / #39117 / #37921 - Refactorings
// BEGINNING - Ticket #31241 - Batch to seat bookings with only one mobility guest
// BEGINNING - Ticket #37921 / #31294 - Added list of routes and call the business method only if there are elegible bookings
// BEGINNING - Ticket #39745 / #39544 / #39498 / #37922 / #37921 / #32134 / #31236 - Fixed bugs when seating bookings, improving the order of bookings and passengers by Room Id
global class RM_SeatingTool_MobilityIndividual_Batch implements Database.Batchable<sObject>, Database.Stateful {
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

  public RM_SeatingTool_MobilityIndividual_Batch(
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
    for (
      KaptioTravel__Itinerary_Item__c bookingWithPassengers : wrappedSeatingBatch.wrappedSeatingRule.remainingMobilityIndividualBookingsToProcessList
    ) {
      if (bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c == null) {
        for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : bookingWithPassengers.KaptioTravel__PassengerItineraryUnitAssignments__r) {
          if (piua.KaptioTravel__Passenger__r.Mobility_Needs__c) {
            if (
              !wrappedSeatingBatch.wrappedSeatingRule.mobilityIndividualBookingsToProcessList.contains(bookingWithPassengers) &&
              !wrappedSeatingBatch.wrappedSeatingRule.bookingMobilityPIUAListByItiItem.containsKey(bookingWithPassengers.Id)
            ) {
              wrappedSeatingBatch.wrappedSeatingRule.mobilityIndividualBookingsToProcessList.add(bookingWithPassengers);

              wrappedSeatingBatch.wrappedSeatingRule.bookingMobilityPIUAListByItiItem.put(
                bookingWithPassengers.Id,
                bookingWithPassengers.KaptioTravel__PassengerItineraryUnitAssignments__r
              );
            }
          }
        }
      }
    }

    wrappedSeatingBatch.wrappedSeatingRule.batchHelper.createFakeMobilityBookingsWithPIUA(
      wrappedItineraries,
      wrappedSeatingBatch.wrappedSeatingRule.mobilityIndividualBookingsToProcessList,
      wrappedSeatingBatch.wrappedSeatingRule.bookingMobilityPIUAListByItiItem,
      routeList,
      piua2UpdateMap.size(),
      false
    );

    return wrappedSeatingBatch.wrappedSeatingRule.mobilityIndividualBookingsToProcessList;
  }

  global void execute(Database.BatchableContext BC, List<KaptioTravel__Itinerary_Item__c> scope) {
    if (!scope.isEmpty()) {
      // seat groups of only a mobility piua on mobility seats and others piua in the same booking together
      wrappedSeatingBatch.wrappedSeatingRule.batchHelper.processMobilityPIUA(
        wrappedSeatingBatch.wrappedSeatingRule.bookingMobilityPIUAListByItiItem,
        wrappedSeatingBatch.mapKeySet,
        wrappedSeatingBatch.railcarSeatMap,
        wrappedSeatingBatch.availableSeatsByRailcarId,
        wrappedSeatingBatch.wrappedSeatingRule.batchHelper,
        piua2UpdateMap,
        wrappedItineraries,
        scope,
        wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.hasExecuted,
        wrappedServiceClassGroup.wrappedSeatingBatchCJ.hasExecuted,
        wrappedServiceClassGroup.wrappedSeatingBatchGL.hasExecuted,
        piua2UpdateMap.size(),
        wrappedSeatingBatch.wrappedSeatingRule.itinerarySet,
        routeList,
        false,
        mapMobility_Railcar,
        railcarIdByLAKGLBookingPIUAOver36
      );
    }
  }

  global void finish(Database.BatchableContext BC) {
    Id linkedMobilityIndividualBatchJobId = Database.executeBatch(
      new RM_SeatingTool_LinkedMobIndividual_Batch(
        wrappedItineraries,
        wrappedServiceClassGroup,
        wrappedSeatingBatch,
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

    batchJobIdList.add(linkedMobilityIndividualBatchJobId);
    if (Test.isRunningTest()) {
      system.abortJob(linkedMobilityIndividualBatchJobId);
    }
  }
}
// END - Ticket #39745 / #39544 / #39498 / #37922 / #37921 / #32134 / #31236
// END - Ticket #37921 / #31294
// END - Ticket #31241
// END - Ticket #39453 / #40026 / #40010 / #39498 / #39117 / #37921
// END - Ticket #32134 / #39498 / #40024 / #40025 / #40026
// END - Ticket #40446 / #40408 / #40046 / #40045 / #40023 / #40022 / #39836 / #39117
// END - Ticket #39117 / #40707 / #40408 / #40326 / #40064 / #40063 / #40054 / #40050 / #39502 / #39232
// END - Ticket #41032 / #41033 / #41003 / #30715 / #41034 / #40880 / #40065 / #40818 / #40869 / #40868 / #41037
