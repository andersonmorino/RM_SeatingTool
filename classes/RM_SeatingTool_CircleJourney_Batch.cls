/**
 * @description       : Batch to start circle journey business rules execution
 * @author            : Anderson Morino
 * @group             :
 * @last modified on  : 05-11-2023
 * @last modified by  : Anderson Morino
 **/
// BEGINNING - Ticket #41032 / #41033 / #41003 / #30715 / #41034 / #40880 / #40065 / #40818 / #40869 / #40868 / #41037 - Solved bugs and implemented some missing notification tasks from the Seating Tool backlog
// BEGINNING - Ticket #39117 / #40707 / #40408 / #40326 / #40064 / #40063 / #40054 / #40050 / #39502 / #39232 - Fixed bugs for notifications and seating process bugs
// BEGINNING - Ticket #39453 / #40026 / #40010 / #39498 / #39117 / #37921 - Refactorings
// BEGINNING - Ticket #35471 - Batch to start circle journey business rules execution
// BEGINNING - Ticket #39745 / #39544 / #39498 / #37922 / #37921 / #32134 / #31236 - Fixed bugs when seating bookings, improving the order of bookings and passengers by Room Id
global class RM_SeatingTool_CircleJourney_Batch implements Database.Batchable<sObject>, Database.Stateful {
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

  public RM_SeatingTool_CircleJourney_Batch(
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
    return wrappedServiceClassGroup.wrappedSeatingBatchCJ.wrappedSeatingRule.bookingsToProcessList;
  }

  global void execute(Database.BatchableContext BC, List<KaptioTravel__Itinerary_Item__c> scope) {
  }

  global void finish(Database.BatchableContext BC) {
    Id emailNotificationBatchJobId = Database.executeBatch(
      new RM_SeatingTool_EmailNotification_Batch(
        wrappedItineraries,
        wrappedServiceClassGroup,
        wrappedServiceClassGroup.wrappedSeatingBatchCJ,
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

    batchJobIdList.add(emailNotificationBatchJobId);
  }
}
// END - Ticket #39745 / #39544 / #39498 / #37922 / #37921 / #32134 / #31236
// END - Ticket #35471
// END - Ticket #39453 / #40026 / #40010 / #39498 / #39117 / #37921
// END - Ticket #39117 / #40707 / #40408 / #40326 / #40064 / #40063 / #40054 / #40050 / #39502 / #39232
// END - Ticket #41032 / #41033 / #41003 / #30715 / #41034 / #40880 / #40065 / #40818 / #40869 / #40868 / #41037
