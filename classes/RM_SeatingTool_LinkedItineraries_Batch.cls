/**
 * @description       : Batch to seat linked bookings except with 2 PIUA records
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
// BEGINNING - Ticket #37882 - Batch to seat linked bookings except with 2 PIUA records
// BEGINNING - Ticket #37921 / #31294 - Added list of routes and call the business method only if there are elegible bookings
// BEGINNING - Ticket #39745 / #39544 / #39498 / #37922 / #37921 / #32134 / #31236 - Fixed bugs when seating bookings, improving the order of bookings and passengers by Room Id
global class RM_SeatingTool_LinkedItineraries_Batch implements Database.Batchable<sObject>, Database.Stateful {
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

  public RM_SeatingTool_LinkedItineraries_Batch(
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
    // iterate bookings with passengers in order to add each linked itinerary Id that does not is linked to a booking with special mobility condition
    for (KaptioTravel__Itinerary_Item__c bookingWithPassengers : wrappedSeatingBatch.wrappedSeatingRule.remainingLinkedItiBookingsToProcessList) {
      if (
        bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c != null &&
        bookingWithPassengers.KaptioTravel__Itinerary__r.Passengers_with_service_animal__c == 0 &&
        bookingWithPassengers.KaptioTravel__Itinerary__r.Fully_Bound_Mobility_Passengers__c == 0 &&
        !wrappedSeatingBatch.wrappedSeatingRule.serviceDogLinkedItinerariesSet.contains(
          bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c
        ) &&
        !wrappedSeatingBatch.wrappedSeatingRule.fullyBoundLinkedItinerariesSet.contains(
          bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c
        )
      ) {
        if (!wrappedSeatingBatch.wrappedSeatingRule.linkedItiBookingsToProcessList.contains(bookingWithPassengers)) {
          wrappedSeatingBatch.wrappedSeatingRule.linkedItiBookingsToProcessList.add(bookingWithPassengers);
        }

        for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : bookingWithPassengers.KaptioTravel__PassengerItineraryUnitAssignments__r) {
          if (piua.KaptioTravel__Passenger__c != null) {
            if (
              !wrappedSeatingBatch.wrappedSeatingRule.bookingLinkedItiPIUAListByItiItem.containsKey(
                bookingWithPassengers.KaptioTravel__ExternalItemName__c +
                '-' +
                bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c
              )
            ) {
              wrappedSeatingBatch.wrappedSeatingRule.bookingLinkedItiPIUAListByItiItem.put(
                bookingWithPassengers.KaptioTravel__ExternalItemName__c +
                '-' +
                bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c,
                new List<KaptioTravel__PassengerItineraryUnitAssignment__c>{ piua }
              );
            } else if (
              !wrappedSeatingBatch.wrappedSeatingRule.bookingLinkedItiPIUAListByItiItem.get(
                  bookingWithPassengers.KaptioTravel__ExternalItemName__c +
                  '-' +
                  bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c
                )
                .contains(piua)
            ) {
              wrappedSeatingBatch.wrappedSeatingRule.bookingLinkedItiPIUAListByItiItem.get(
                  bookingWithPassengers.KaptioTravel__ExternalItemName__c +
                  '-' +
                  bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c
                )
                .add(piua);
            }
          }
        }
      }
    }

    wrappedSeatingBatch.wrappedSeatingRule.batchHelper.createFakeLinkedBookingsWithPIUA(
      wrappedItineraries,
      wrappedSeatingBatch.wrappedSeatingRule.linkedItiBookingsToProcessList,
      wrappedSeatingBatch.wrappedSeatingRule.bookingLinkedItiPIUAListByItiItem,
      routeList,
      piua2UpdateMap.size()
    );

    return wrappedSeatingBatch.wrappedSeatingRule.linkedItiBookingsToProcessList;
  }

  global void execute(Database.BatchableContext BC, List<KaptioTravel__Itinerary_Item__c> scope) {
    List<KaptioTravel__Itinerary_Item__c> linkedScope = new List<KaptioTravel__Itinerary_Item__c>();

    for (KaptioTravel__Itinerary_Item__c linkedItiItem : scope) {
      if (
        !linkedScope.contains(linkedItiItem) &&
        wrappedSeatingBatch.wrappedSeatingRule.bookingLinkedItiPIUAListByItiItem.containsKey(
          linkedItiItem.KaptioTravel__ExternalItemName__c +
          '-' +
          linkedItiItem.KaptioTravel__Itinerary__r.LinkedItinerary__c
        )
      ) {
        linkedScope.add(linkedItiItem);
      }
    }

    if (!linkedScope.isEmpty()) {
      Map<String, RM_SeatingToolWrappers.RailcarWrapper> contiguousSeatsSizeMap = RM_SeatingTool_Utils.getContiguousRailcarSeatsSize(
        wrappedSeatingBatch.railcarSeatMap,
        wrappedSeatingBatch.mapKeySet,
        false,
        false
      );

      // seat other linked itineraries
      wrappedSeatingBatch.wrappedSeatingRule.batchHelper.processLinkedItineraries(
        wrappedSeatingBatch.wrappedSeatingRule.bookingLinkedItiPIUAListByItiItem,
        wrappedSeatingBatch.mapKeySet,
        wrappedSeatingBatch.railcarSeatMap,
        contiguousSeatsSizeMap,
        wrappedSeatingBatch.availableSeatsByRailcarId,
        piua2UpdateMap,
        wrappedItineraries,
        linkedScope,
        wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.hasExecuted,
        piua2UpdateMap.size(),
        wrappedSeatingBatch.wrappedSeatingRule.linkedItinerarySet,
        routeList,
        railcarIdByLAKGLBookingPIUAOver36
      );
    }
  }

  global void finish(Database.BatchableContext BC) {
    for (KaptioTravel__Itinerary_Item__c bookingWithPassengers : wrappedSeatingBatch.wrappedSeatingRule.remainingLinkedItiBookingsToProcessList) {
      if (
        bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c != null &&
        bookingWithPassengers.KaptioTravel__Itinerary__r.Passengers_with_service_animal__c == 0 &&
        bookingWithPassengers.KaptioTravel__Itinerary__r.Fully_Bound_Mobility_Passengers__c == 0 &&
        !wrappedSeatingBatch.wrappedSeatingRule.serviceDogLinkedItinerariesSet.contains(
          bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c
        ) &&
        !wrappedSeatingBatch.wrappedSeatingRule.fullyBoundLinkedItinerariesSet.contains(
          bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c
        )
      ) {
        continue;
      } else {
        wrappedSeatingBatch.wrappedSeatingRule.remainingOthersBookingsToProcessList.add(bookingWithPassengers);
      }
    }
    Id othersBatchJobId = Database.executeBatch(
      new RM_SeatingTool_Others_Batch(
        // BEGINNING - Ticket #35471 - Added aux maps and controller boolean variable
        wrappedItineraries,
        wrappedServiceClassGroup,
        wrappedSeatingBatch,
        batchJobIdList,
        piua2UpdateMap,
        // END - Ticket #35471
        trainInfo,
        piua2UpdateMap.size(),
        mapMobility_Railcar,
        routeList,
        railcarIdByLAKGLBookingPIUAOver36,
        bookingList
      ),
      2000
    );

    batchJobIdList.add(othersBatchJobId);
    if (Test.isRunningTest()) {
      system.abortJob(othersBatchJobId);
    }
  }
}
// END - Ticket #39745 / #39544 / #39498 / #37922 / #37921 / #32134 / #31236
// END - Ticket #37921 / #31294
// END - Ticket #37882
// END - Ticket #39453 / #40026 / #40010 / #39498 / #39117 / #37921
// END - Ticket #32134 / #39498 / #40024 / #40025 / #40026
// END - Ticket #40446 / #40408 / #40046 / #40045 / #40023 / #40022 / #39836 / #39117
// END - Ticket #39117 / #40707 / #40408 / #40326 / #40064 / #40063 / #40054 / #40050 / #39502 / #39232
// END - Ticket #41032 / #41033 / #41003 / #30715 / #41034 / #40880 / #40065 / #40818 / #40869 / #40868 / #41037
