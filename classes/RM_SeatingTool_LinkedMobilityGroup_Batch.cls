/**
 * @description       : Batch to seat linked bookings with more than a mobility guest
 * @author            : Anderson Morino
 * @group             :
 * @last modified on  : 05-11-2023
 * @last modified by  : Anderson Morino
 **/
// BEGINNING - Ticket #41032 / #41033 / #41003 / #30715 / #41034 / #40880 / #40065 / #40818 / #40869 / #40868 / #41037 - Solved bugs and implemented some missing notification tasks from the Seating Tool backlog
// BEGINNING - Ticket #39117 / #40707 / #40408 / #40326 / #40064 / #40063 / #40054 / #40050 / #39502 / #39232 - Fixed bugs for notifications and seating process bugs
global class RM_SeatingTool_LinkedMobilityGroup_Batch implements Database.Batchable<sObject>, Database.Stateful {
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

  private Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingLinkedMobilityPIUAGroupListByItiItem = new Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>>();
  private List<KaptioTravel__Itinerary_Item__c> linkedMobilityGroupBookingsToProcessList = new List<KaptioTravel__Itinerary_Item__c>();

  public RM_SeatingTool_LinkedMobilityGroup_Batch(
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
    for (KaptioTravel__Itinerary_Item__c bookingWithPassengers : wrappedSeatingBatch.wrappedSeatingRule.remainingMobilityGroupBookingsToProcessList) {
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
        Integer counter = 0;

        for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : bookingWithPassengers.KaptioTravel__PassengerItineraryUnitAssignments__r) {
          if (piua.KaptioTravel__Passenger__r.Mobility_Needs__c) {
            counter++;
          }

          if (
            counter > 1 &&
            bookingWithPassengers.KaptioTravel__PassengerItineraryUnitAssignments__r.indexOf(piua) ==
            (bookingWithPassengers.KaptioTravel__PassengerItineraryUnitAssignments__r.size() - 1)
          ) {
            if (!linkedMobilityGroupBookingsToProcessList.contains(bookingWithPassengers)) {
              linkedMobilityGroupBookingsToProcessList.add(bookingWithPassengers);
            }
          }
        }

        if (counter > 1) {
          for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : bookingWithPassengers.KaptioTravel__PassengerItineraryUnitAssignments__r) {
            if (
              !bookingLinkedMobilityPIUAGroupListByItiItem.containsKey(
                bookingWithPassengers.KaptioTravel__ExternalItemName__c +
                '-' +
                bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c
              )
            ) {
              bookingLinkedMobilityPIUAGroupListByItiItem.put(
                bookingWithPassengers.KaptioTravel__ExternalItemName__c +
                '-' +
                bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c,
                new List<KaptioTravel__PassengerItineraryUnitAssignment__c>{ piua }
              );
            } else if (
              !bookingLinkedMobilityPIUAGroupListByItiItem.get(
                  bookingWithPassengers.KaptioTravel__ExternalItemName__c +
                  '-' +
                  bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c
                )
                .contains(piua)
            ) {
              bookingLinkedMobilityPIUAGroupListByItiItem.get(
                  bookingWithPassengers.KaptioTravel__ExternalItemName__c +
                  '-' +
                  bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c
                )
                .add(piua);
            }

            if (
              !wrappedSeatingBatch.wrappedSeatingRule.linkedMobilityItinerarySet.contains(
                bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c
              )
            ) {
              wrappedSeatingBatch.wrappedSeatingRule.linkedMobilityItinerarySet.add(
                bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c
              );
            }
          }
        }
      }
    }

    for (KaptioTravel__Itinerary_Item__c bookingWithPassengers : wrappedSeatingBatch.wrappedSeatingRule.remainingMobilityGroupBookingsToProcessList) {
      if (
        wrappedSeatingBatch.wrappedSeatingRule.linkedMobilityItinerarySet.contains(
          bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c
        )
      ) {
        if (!linkedMobilityGroupBookingsToProcessList.contains(bookingWithPassengers)) {
          linkedMobilityGroupBookingsToProcessList.add(bookingWithPassengers);
        }

        for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : bookingWithPassengers.KaptioTravel__PassengerItineraryUnitAssignments__r) {
          if (
            !bookingLinkedMobilityPIUAGroupListByItiItem.containsKey(
              bookingWithPassengers.KaptioTravel__ExternalItemName__c +
              '-' +
              bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c
            )
          ) {
            bookingLinkedMobilityPIUAGroupListByItiItem.put(
              bookingWithPassengers.KaptioTravel__ExternalItemName__c +
              '-' +
              bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c,
              new List<KaptioTravel__PassengerItineraryUnitAssignment__c>{ piua }
            );
          } else if (
            !bookingLinkedMobilityPIUAGroupListByItiItem.get(
                bookingWithPassengers.KaptioTravel__ExternalItemName__c +
                '-' +
                bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c
              )
              .contains(piua)
          ) {
            bookingLinkedMobilityPIUAGroupListByItiItem.get(
                bookingWithPassengers.KaptioTravel__ExternalItemName__c +
                '-' +
                bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c
              )
              .add(piua);
          }
        }
      }
    }

    wrappedSeatingBatch.wrappedSeatingRule.batchHelper.createFakeMobilityBookingsWithPIUA(
      wrappedItineraries,
      linkedMobilityGroupBookingsToProcessList,
      bookingLinkedMobilityPIUAGroupListByItiItem,
      routeList,
      piua2UpdateMap.size(),
      true
    );

    return linkedMobilityGroupBookingsToProcessList;
  }

  global void execute(Database.BatchableContext BC, List<KaptioTravel__Itinerary_Item__c> scope) {
    if (!scope.isEmpty()) {
      wrappedSeatingBatch.wrappedSeatingRule.batchHelper.processMobilityPIUAGroup(
        bookingLinkedMobilityPIUAGroupListByItiItem,
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
        wrappedSeatingBatch.wrappedSeatingRule.linkedItinerarySet,
        routeList,
        true,
        mapMobility_Railcar,
        railcarIdByLAKGLBookingPIUAOver36
      );
    }
  }

  global void finish(Database.BatchableContext BC) {
    for (KaptioTravel__Itinerary_Item__c bookingWithPassengers : wrappedSeatingBatch.wrappedSeatingRule.remainingMobilityGroupBookingsToProcessList) {
      Integer counter = 0;

      for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : bookingWithPassengers.KaptioTravel__PassengerItineraryUnitAssignments__r) {
        if (piua.KaptioTravel__Passenger__r.Mobility_Needs__c) {
          counter++;
        }

        if (
          counter <= 1 &&
          bookingWithPassengers.KaptioTravel__PassengerItineraryUnitAssignments__r.indexOf(piua) ==
          (bookingWithPassengers.KaptioTravel__PassengerItineraryUnitAssignments__r.size() - 1) &&
          !wrappedSeatingBatch.wrappedSeatingRule.remainingMobilityIndividualBookingsToProcessList.contains(bookingWithPassengers)
        ) {
          wrappedSeatingBatch.wrappedSeatingRule.remainingMobilityIndividualBookingsToProcessList.add(bookingWithPassengers);
        }
      }
    }

    Id mobilityIndividualBatchJobId = Database.executeBatch(
      new RM_SeatingTool_MobilityIndividual_Batch(
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
    batchJobIdList.add(mobilityIndividualBatchJobId);
    if (Test.isRunningTest()) {
      system.abortJob(mobilityIndividualBatchJobId);
    }
  }
}
// END - Ticket #39117 / #40707 / #40408 / #40326 / #40064 / #40063 / #40054 / #40050 / #39502 / #39232
// END - Ticket #41032 / #41033 / #41003 / #30715 / #41034 / #40880 / #40065 / #40818 / #40869 / #40868 / #41037
