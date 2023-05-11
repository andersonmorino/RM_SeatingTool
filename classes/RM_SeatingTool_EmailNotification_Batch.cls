/**
 * @description       : Batch to send a notification for each passenger with a special mobility condition without seating the booking
 * @author            : Anderson Morino
 * @group             :
 * @last modified on  : 05-11-2023
 * @last modified by  : Anderson Morino
 **/
// BEGINNING - Ticket #41032 / #41033 / #41003 / #30715 / #41034 / #40880 / #40065 / #40818 / #40869 / #40868 / #41037 - Solved bugs and implemented some missing notification tasks from the Seating Tool backlog
// BEGINNING - Ticket #39117 / #40707 / #40408 / #40326 / #40064 / #40063 / #40054 / #40050 / #39502 / #39232 - Fixed bugs for notifications and seating process bugs
// BEGINNING - Ticket #39453 / #40026 / #40010 / #39498 / #39117 / #37921 - Refactorings
// BEGINNING - Ticket #35471 - Batch to send a notification for each passenger with a special mobility condition without seating the booking
// BEGINNING - Ticket #37921 / #31294 - Added list of routes and call the business method only if there are elegible bookings
// BEGINNING - Ticket #39745 / #39544 / #39498 / #37922 / #37921 / #32134 / #31236 - Fixed bugs when seating bookings, improving the order of bookings and passengers by Room Id
global class RM_SeatingTool_EmailNotification_Batch implements Database.Batchable<sObject>, Database.Stateful {
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

  public RM_SeatingTool_EmailNotification_Batch(
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
    for (KaptioTravel__Itinerary_Item__c bookingWithPassengers : wrappedSeatingBatch.wrappedSeatingRule.bookingsToProcessList) {
      if (
        bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c != null &&
        bookingWithPassengers.KaptioTravel__Itinerary__r.Passengers_with_service_animal__c > 0
      ) {
        wrappedSeatingBatch.wrappedSeatingRule.serviceDogLinkedItinerariesSet.add(
          bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c
        );
      }

      if (
        bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c != null &&
        bookingWithPassengers.KaptioTravel__Itinerary__r.Fully_Bound_Mobility_Passengers__c > 0
      ) {
        wrappedSeatingBatch.wrappedSeatingRule.fullyBoundLinkedItinerariesSet.add(
          bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c
        );
      }
    }

    List<KaptioTravel__Itinerary_Item__c> specialMobilityBookings = new List<KaptioTravel__Itinerary_Item__c>();

    for (KaptioTravel__Itinerary_Item__c bookingWithPassengers : wrappedSeatingBatch.wrappedSeatingRule.bookingsToProcessList) {
      if (
        ((bookingWithPassengers.KaptioTravel__Itinerary__r.Passengers_with_service_animal__c > 0 ||
        bookingWithPassengers.KaptioTravel__Itinerary__r.Fully_Bound_Mobility_Passengers__c > 0) &&
        bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c == null) ||
        (!wrappedSeatingBatch.wrappedSeatingRule.serviceDogLinkedItinerariesSet.isEmpty() &&
        wrappedSeatingBatch.wrappedSeatingRule.serviceDogLinkedItinerariesSet.contains(
          bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c
        )) ||
        (!wrappedSeatingBatch.wrappedSeatingRule.fullyBoundLinkedItinerariesSet.isEmpty() &&
        wrappedSeatingBatch.wrappedSeatingRule.fullyBoundLinkedItinerariesSet.contains(
          bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c
        ))
      ) {
        if (!specialMobilityBookings.contains(bookingWithPassengers)) {
          specialMobilityBookings.add(bookingWithPassengers);
        }

        if (
          (bookingWithPassengers.KaptioTravel__Itinerary__r.Passengers_with_service_animal__c > 0 &&
          bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c == null) ||
          (!wrappedSeatingBatch.wrappedSeatingRule.serviceDogLinkedItinerariesSet.isEmpty() &&
          wrappedSeatingBatch.wrappedSeatingRule.serviceDogLinkedItinerariesSet.contains(
            bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c
          ))
        ) {
          wrappedSeatingBatch.wrappedSeatingRule.bookingServiceDogPIUAList.addAll(
            bookingWithPassengers.KaptioTravel__PassengerItineraryUnitAssignments__r
          );
        }

        if (
          (bookingWithPassengers.KaptioTravel__Itinerary__r.Fully_Bound_Mobility_Passengers__c > 0 &&
          bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c == null) ||
          (!wrappedSeatingBatch.wrappedSeatingRule.fullyBoundLinkedItinerariesSet.isEmpty() &&
          wrappedSeatingBatch.wrappedSeatingRule.fullyBoundLinkedItinerariesSet.contains(
            bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c
          ))
        ) {
          wrappedSeatingBatch.wrappedSeatingRule.bookingFullyBoundPIUAList.addAll(
            bookingWithPassengers.KaptioTravel__PassengerItineraryUnitAssignments__r
          );
        }
      }
    }

    return specialMobilityBookings;
  }

  global void execute(Database.BatchableContext BC, List<KaptioTravel__Itinerary_Item__c> scope) {
    List<KaptioTravel__PassengerItineraryUnitAssignment__c> piua2Notify = new List<KaptioTravel__PassengerItineraryUnitAssignment__c>();

    piua2Notify.addAll(wrappedSeatingBatch.wrappedSeatingRule.bookingServiceDogPIUAList);
    piua2Notify.addAll(wrappedSeatingBatch.wrappedSeatingRule.bookingFullyBoundPIUAList);

    List<KaptioTravel__PassengerItineraryUnitAssignment__c> piuaServiceDog2Notify = new List<KaptioTravel__PassengerItineraryUnitAssignment__c>();
    List<KaptioTravel__PassengerItineraryUnitAssignment__c> piuaFullyBound2Notify = new List<KaptioTravel__PassengerItineraryUnitAssignment__c>();

    // add only piua with a service dog and as fully bound wheelchair from bookings to their respective lists
    for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : piua2Notify) {
      if (!piuaServiceDog2Notify.contains(piua) && piua.KaptioTravel__Passenger__c != null && piua.KaptioTravel__Passenger__r.Service_animal__c) {
        piuaServiceDog2Notify.add(piua);
      }

      if (!piuaFullyBound2Notify.contains(piua) && piua.KaptioTravel__Passenger__c != null && piua.KaptioTravel__Passenger__r.Mobility_Bound__c) {
        piuaFullyBound2Notify.add(piua);
      }
    }

    try {
      // send an email notification for each passenger as fully bound wheelchair to Product Ops Team
      if (!piuaServiceDog2Notify.isEmpty()) {
        wrappedSeatingBatch.wrappedSeatingRule.batchHelper.sendProdOpsTeamEmail(
          piuaServiceDog2Notify,
          wrappedSeatingBatch.wrappedSeatingRule.serviceDogPassengerSet,
          'Guest with a Service Dog',
          'with a Service Dog'
        );
      }

      // send an email notification for each passenger with service dog to Product Ops Team
      if (!piuaFullyBound2Notify.isEmpty()) {
        wrappedSeatingBatch.wrappedSeatingRule.batchHelper.sendProdOpsTeamEmail(
          piuaFullyBound2Notify,
          wrappedSeatingBatch.wrappedSeatingRule.fullyBoundPassengerSet,
          'Guest as Fully Bound Wheelchair',
          'as Fully Bound Wheelchair'
        );
      }
    } catch (Exception ex) {
      // Implement logic to notify user for exceptions - AKA Exception Log Task
      throw new RM_SeatingToolException(ex);
    }
  }

  global void finish(Database.BatchableContext BC) {
    for (KaptioTravel__Itinerary_Item__c bookingWithPassengers : wrappedSeatingBatch.wrappedSeatingRule.bookingsToProcessList) {
      if (
        ((bookingWithPassengers.KaptioTravel__Itinerary__r.Passengers_with_service_animal__c > 0 ||
        bookingWithPassengers.KaptioTravel__Itinerary__r.Fully_Bound_Mobility_Passengers__c > 0) &&
        bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c == null) ||
        (!wrappedSeatingBatch.wrappedSeatingRule.serviceDogLinkedItinerariesSet.isEmpty() &&
        wrappedSeatingBatch.wrappedSeatingRule.serviceDogLinkedItinerariesSet.contains(
          bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c
        )) ||
        (!wrappedSeatingBatch.wrappedSeatingRule.fullyBoundLinkedItinerariesSet.isEmpty() &&
        wrappedSeatingBatch.wrappedSeatingRule.fullyBoundLinkedItinerariesSet.contains(
          bookingWithPassengers.KaptioTravel__Itinerary__r.LinkedItinerary__c
        ))
      ) {
        continue;
      } else {
        wrappedSeatingBatch.wrappedSeatingRule.remainingMobilityGroupBookingsToProcessList.add(bookingWithPassengers);
      }
    }

    // BEGINNING - Ticket #35471 - Added aux maps and controller boolean variable

    Id mobilityGroupBatchJobId = Database.executeBatch(
      new RM_SeatingTool_MobilityGroup_Batch(
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
    // END - Ticket #35471
    batchJobIdList.add(mobilityGroupBatchJobId);
    if (Test.isRunningTest()) {
      system.abortJob(mobilityGroupBatchJobId);
    }
  }
}
// END - Ticket #39745 / #39544 / #39498 / #37922 / #37921 / #32134 / #31236
// END - Ticket #37921 / #31294
// END - Ticket #35471
// END - Ticket #39453 / #40026 / #40010 / #39498 / #39117 / #37921
// END - Ticket #39117 / #40707 / #40408 / #40326 / #40064 / #40063 / #40054 / #40050 / #39502 / #39232
// END - Ticket #41032 / #41033 / #41003 / #30715 / #41034 / #40880 / #40065 / #40818 / #40869 / #40868 / #41037
