/**
 * @description       : Holds all wrappers used by the Seating Tool application
 * @author            : Adrian Flores
 * @group             :
 * @last modified on  : 05-03-2023
 * @last modified by  : Anderson Morino
 **/
// BEGINNING - Ticket #39117 / #40707 / #40408 / #40326 / #40064 / #40063 / #40054 / #40050 / #39502 / #39232 - Fixed bugs for notifications and seating process bugs
// BEGINNING - Ticket #32134 / #39498 / #40024 / #40025 / #40026 - Fixed bugs
// BEGINNING - Ticket #39453 - Added getters and setters
// BEGINNING - Ticket #35471 - Wrapper class
public with sharing class RM_SeatingToolWrappers {
  /**
   * Wrapper that holds Itinerary information.
   */
  public class ManagementLegWrapper {
    // This will hold the management leg name, since is a unique value
    public String managementLegId { get; set; }
    public String route { get; set; }
    public String departureDate { get; set; }
    public List<RM_ROS_IntegrationWrapper.TRAIN_CONSTRUCT> legConstruct { get; set; }

    public ManagementLegWrapper(
      String managementLegId,
      String route,
      String departureDate,
      List<RM_ROS_IntegrationWrapper.TRAIN_CONSTRUCT> legConstruct
    ) {
      this.managementLegId = managementLegId;
      this.route = route;
      this.departureDate = departureDate;
      this.legConstruct = legConstruct;
    }
  }

  /**
   * @description Provide meaningful info about this wrapper
   * @author Adrian Flores | 08-19-2022
   * @return List<String>
   **/
  public class ROSRoutesServiceWrapper {
    public String masterLabel { get; set; }
    public RM_ROS_IntegrationWrapper.TRAIN_ITINERARY itinerary { get; set; }

    public ROSRoutesServiceWrapper(String masterLabel, RM_ROS_IntegrationWrapper.TRAIN_ITINERARY itinerary) {
      this.masterLabel = masterLabel;
      this.itinerary = itinerary;
    }
  }

  // BEGINNING - Ticket #37921 / #31294 - Created wrapper class in order to sort PIUA by itinerary or linked itinerary
  // BEGINNING - Ticket #38145 / #38487 / #38498 / #38790 - Created variables for LAK seating process
  public class RailcarWrapper {
    @AuraEnabled
    public String route { get; set; }
    @AuraEnabled
    public Date departureDate { get; set; }
    @AuraEnabled
    public String railcarId { get; set; }
    @AuraEnabled
    public Integer seatsCapacity { get; set; }
    @AuraEnabled
    public String serviceClass { get; set; }
    @AuraEnabled
    public String direction { get; set; }
    @AuraEnabled
    public Integer railcarOrder { get; set; }
    @AuraEnabled
    public List<Integer> occupiedSeatsNumber { get; set; }
    @AuraEnabled
    public Map<String, String> piuaIdsBySeatNumber { get; set; }
    @AuraEnabled
    public List<Integer> inactiveSeatsNumber { get; set; }
    @AuraEnabled
    public String railcarSeatId { get; set; }
    @AuraEnabled
    public String railcarOrdinal { get; set; }
    @AuraEnabled
    public Boolean occupied { get; set; }
    @AuraEnabled
    public Railcar_Seat__c railcarSeat { get; set; }
    @AuraEnabled
    public Decimal availableSeatsCapacity { get; set; }
    @AuraEnabled
    public List<String> itiItemIds { get; set; }
    @AuraEnabled
    public Integer sizeOfSeats { get; set; }
    @AuraEnabled
    public Integer counter { get; set; }
    @AuraEnabled
    public String railcarSeatLetter { get; set; }
    @AuraEnabled
    public Integer sizeOfMobilitySeats { get; set; }

    public RailcarWrapper(Integer railcarOrder, String railcarOrdinal) {
      this.railcarOrder = railcarOrder;
      this.railcarOrdinal = railcarOrdinal;
    }

    public RailcarWrapper(Integer railcarOrder, String railcarOrdinal, Integer counter) {
      this.railcarOrder = railcarOrder;
      this.railcarOrdinal = railcarOrdinal;
      this.counter = counter;
    }

    public RailcarWrapper(String railcarId, String serviceClass) {
      this.railcarId = railcarId;
      this.serviceClass = serviceClass;
    }

    public RailcarWrapper(String direction, Integer railcarOrder) {
      this.direction = direction;
      this.railcarOrder = railcarOrder;
    }

    // BEGINNING - Ticket #30921 - Refactorings
    public RailcarWrapper(Integer seatsCapacity, List<String> itiItemIds) {
      this.seatsCapacity = seatsCapacity;
      this.itiItemIds = itiItemIds;
    }

    public RailcarWrapper(List<String> itiItemIds, Integer sizeOfSeats) {
      this.itiItemIds = itiItemIds;
      this.sizeOfSeats = sizeOfSeats;
    }

    public RailcarWrapper(List<String> itiItemIds, Integer sizeOfSeats, String railcarSeatLetter, Integer sizeOfMobilitySeats, String railcarId) {
      this.itiItemIds = itiItemIds;
      this.sizeOfSeats = sizeOfSeats;
      this.railcarSeatLetter = railcarSeatLetter;
      this.sizeOfMobilitySeats = sizeOfMobilitySeats;
      this.railcarId = railcarId;
    }

    public RailcarWrapper(
      String route,
      Date departureDate,
      String railcarId,
      Integer seatsCapacity,
      String serviceClass,
      String direction,
      List<Integer> occupiedSeatsNumber,
      Map<String, String> piuaIdsBySeatNumber,
      List<Integer> inactiveSeatsNumber
    ) {
      this.route = route;
      this.departureDate = departureDate;
      this.railcarId = railcarId;
      this.seatsCapacity = seatsCapacity;
      this.serviceClass = serviceClass;
      this.direction = direction;
      this.occupiedSeatsNumber = occupiedSeatsNumber;
      this.piuaIdsBySeatNumber = piuaIdsBySeatNumber;
      this.inactiveSeatsNumber = inactiveSeatsNumber;
    }
  }

  public class RailcarSeatWrapper {
    public Integer routeOrder { get; set; }
    public String route { get; set; }
    public Date departureDate { get; set; }
    public String railcarId { get; set; }
    public String railcarOrdinal { get; set; }
    public String railcarSeatId { get; set; }
    public String railcarSeatLetter { get; set; }
    public Integer railcarAvailableSeats { get; set; }
    public Boolean occupied { get; set; }
    public Boolean mobilityApproved { get; set; }
    public Boolean isLastRailcar { get; set; }
    // BEGINNING - Ticket #35471 - Batch to seat bookings with no business rules
    public String railcarSeries { get; set; }
    public String routeKey { get; set; }
    public String railcarSeriesKey { get; set; }
    public String railcarOrderKey { get; set; }
    public String railcarSeatKey { get; set; }
    // END - Ticket #35471
    public String railcarContiguousSeatsListKey { get; set; }
    public Integer mobilityCounter { get; set; }
    public KaptioTravel__PassengerItineraryUnitAssignment__c assignedPIUA { get; set; }

    public RailcarSeatWrapper(
      Integer routeOrder,
      String route,
      Date departureDate,
      String railcarId,
      String railcarOrdinal,
      String railcarSeatId,
      String railcarSeatLetter,
      Integer railcarAvailableSeats,
      Boolean occupied,
      Boolean mobilityApproved,
      Boolean isLastRailcar,
      // BEGINNING - Ticket #35471 - Batch to seat bookings with no business rules
      String railcarSeries,
      String routeKey,
      String railcarSeriesKey,
      String railcarOrderKey,
      String railcarSeatKey,
      // END - Ticket #35471
      String availableRailcarSeatsListKey,
      Integer mobilityCounter,
      KaptioTravel__PassengerItineraryUnitAssignment__c assignedPIUA
    ) {
      this.routeOrder = routeOrder;
      this.route = route;
      this.departureDate = departureDate;
      this.railcarId = railcarId;
      this.railcarOrdinal = railcarOrdinal;
      this.railcarSeatId = railcarSeatId;
      this.railcarSeatLetter = railcarSeatLetter;
      this.railcarAvailableSeats = railcarAvailableSeats;
      this.occupied = occupied;
      this.mobilityApproved = mobilityApproved;
      this.isLastRailcar = isLastRailcar;
      // BEGINNING - Ticket #35471 - Batch to seat bookings with no business rules
      this.railcarSeries = railcarSeries;
      this.routeKey = routeKey;
      this.railcarSeriesKey = railcarSeriesKey;
      this.railcarOrderKey = railcarOrderKey;
      this.railcarSeatKey = railcarSeatKey;
      // END - Ticket #35471
      this.railcarContiguousSeatsListKey = railcarContiguousSeatsListKey;
      this.mobilityCounter = mobilityCounter;
      this.assignedPIUA = assignedPIUA;
    }

    public RailcarSeatWrapper(String railcarId, String railcarOrdinal, String railcarSeatId) {
      this.railcarId = railcarId;
      this.railcarOrdinal = railcarOrdinal;
      this.railcarSeatId = railcarSeatId;
    }
  }

  public class SeatingRuleWrapper {
    public SeatingRuleWrapper() {
    }

    public Map<String, List<KaptioTravel__Itinerary_Item__c>> railServicesByBooking { get; set; }
    public Map<String, KaptioTravel__Itinerary_Item__c> transferServicesByLocation { get; set; }
    public Map<String, List<KaptioTravel__Itinerary_Item__c>> recordsToProcess { get; set; }
    public List<KaptioTravel__Itinerary_Item__c> bookingsToProcessList { get; set; }
    public Set<String> serviceDogLinkedItinerariesSet { get; set; }
    public Set<String> fullyBoundLinkedItinerariesSet { get; set; }
    public List<KaptioTravel__PassengerItineraryUnitAssignment__c> bookingServiceDogPIUAList { get; set; }
    public List<KaptioTravel__PassengerItineraryUnitAssignment__c> bookingFullyBoundPIUAList { get; set; }
    public Set<String> serviceDogPassengerSet { get; set; }
    public Set<String> fullyBoundPassengerSet { get; set; }
    public List<KaptioTravel__Itinerary_Item__c> remainingMobilityGroupBookingsToProcessList { get; set; }
    public List<KaptioTravel__Itinerary_Item__c> remainingMobilityIndividualBookingsToProcessList { get; set; }
    public List<KaptioTravel__Itinerary_Item__c> remainingCouplesBookingsToProcessList { get; set; }
    public List<KaptioTravel__Itinerary_Item__c> remainingOddsBookingsToProcessList { get; set; }
    public List<KaptioTravel__Itinerary_Item__c> remainingLinkedItiBookingsToProcessList { get; set; }
    public List<KaptioTravel__Itinerary_Item__c> remainingOthersBookingsToProcessList { get; set; }
    public List<KaptioTravel__Itinerary_Item__c> mobilityGroupBookingsToProcessList { get; set; }
    public List<KaptioTravel__Itinerary_Item__c> mobilityIndividualBookingsToProcessList { get; set; }
    public List<KaptioTravel__Itinerary_Item__c> couplesBookingsToProcessList { get; set; }
    public List<KaptioTravel__Itinerary_Item__c> oddsBookingsToProcessList { get; set; }
    public List<KaptioTravel__Itinerary_Item__c> linkedItiBookingsToProcessList { get; set; }
    public List<KaptioTravel__Itinerary_Item__c> othersBookingsToProcessList { get; set; }
    public Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingCouplesPIUAListByItiItem { get; set; }
    public Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingOddsPIUAListByItiItem { get; set; }
    public Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingLinkedItiPIUAListByItiItem { get; set; }
    public Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingMobilityPIUAListByItiItem { get; set; }
    public Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingMobilityPIUAGroupListByItiItem { get; set; }
    public Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingOthersPIUAListByItiItem { get; set; }
    public RM_SeatingToolBatchHelper batchHelper;
    public Set<Id> itinerarySet;
    public Set<Id> linkedItinerarySet;
    public Set<Id> linkedMobilityItinerarySet;

    public SeatingRuleWrapper(
      Map<String, List<KaptioTravel__Itinerary_Item__c>> railServicesByBooking,
      Map<String, KaptioTravel__Itinerary_Item__c> transferServicesByLocation,
      Map<String, List<KaptioTravel__Itinerary_Item__c>> recordsToProcess,
      List<KaptioTravel__Itinerary_Item__c> bookingsToProcessList,
      Set<String> serviceDogLinkedItinerariesSet,
      Set<String> fullyBoundLinkedItinerariesSet,
      List<KaptioTravel__PassengerItineraryUnitAssignment__c> bookingServiceDogPIUAList,
      List<KaptioTravel__PassengerItineraryUnitAssignment__c> bookingFullyBoundPIUAList,
      Set<String> serviceDogPassengerSet,
      Set<String> fullyBoundPassengerSet,
      List<KaptioTravel__Itinerary_Item__c> remainingMobilityGroupBookingsToProcessList,
      List<KaptioTravel__Itinerary_Item__c> remainingMobilityIndividualBookingsToProcessList,
      List<KaptioTravel__Itinerary_Item__c> remainingCouplesBookingsToProcessList,
      List<KaptioTravel__Itinerary_Item__c> remainingOddsBookingsToProcessList,
      List<KaptioTravel__Itinerary_Item__c> remainingLinkedItiBookingsToProcessList,
      List<KaptioTravel__Itinerary_Item__c> remainingOthersBookingsToProcessList,
      List<KaptioTravel__Itinerary_Item__c> mobilityGroupBookingsToProcessList,
      List<KaptioTravel__Itinerary_Item__c> mobilityIndividualBookingsToProcessList,
      List<KaptioTravel__Itinerary_Item__c> couplesBookingsToProcessList,
      List<KaptioTravel__Itinerary_Item__c> oddsBookingsToProcessList,
      List<KaptioTravel__Itinerary_Item__c> linkedItiBookingsToProcessList,
      List<KaptioTravel__Itinerary_Item__c> othersBookingsToProcessList,
      Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingCouplesPIUAListByItiItem,
      Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingOddsPIUAListByItiItem,
      Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingLinkedItiPIUAListByItiItem,
      Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingMobilityPIUAListByItiItem,
      Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingMobilityPIUAGroupListByItiItem,
      Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingOthersPIUAListByItiItem,
      RM_SeatingToolBatchHelper batchHelper,
      Set<Id> itinerarySet,
      Set<Id> linkedItinerarySet,
      Set<Id> linkedMobilityItinerarySet
    ) {
      this.railServicesByBooking = railServicesByBooking;
      this.transferServicesByLocation = transferServicesByLocation;
      this.recordsToProcess = recordsToProcess;
      this.bookingsToProcessList = bookingsToProcessList;
      this.serviceDogLinkedItinerariesSet = serviceDogLinkedItinerariesSet;
      this.fullyBoundLinkedItinerariesSet = fullyBoundLinkedItinerariesSet;
      this.bookingServiceDogPIUAList = bookingServiceDogPIUAList;
      this.bookingFullyBoundPIUAList = bookingFullyBoundPIUAList;
      this.serviceDogPassengerSet = serviceDogPassengerSet;
      this.fullyBoundPassengerSet = fullyBoundPassengerSet;
      this.remainingMobilityGroupBookingsToProcessList = remainingMobilityGroupBookingsToProcessList;
      this.remainingMobilityIndividualBookingsToProcessList = remainingMobilityIndividualBookingsToProcessList;
      this.remainingCouplesBookingsToProcessList = remainingCouplesBookingsToProcessList;
      this.remainingOddsBookingsToProcessList = remainingOddsBookingsToProcessList;
      this.remainingLinkedItiBookingsToProcessList = remainingLinkedItiBookingsToProcessList;
      this.remainingOthersBookingsToProcessList = remainingOthersBookingsToProcessList;
      this.mobilityGroupBookingsToProcessList = mobilityGroupBookingsToProcessList;
      this.mobilityIndividualBookingsToProcessList = mobilityIndividualBookingsToProcessList;
      this.couplesBookingsToProcessList = couplesBookingsToProcessList;
      this.oddsBookingsToProcessList = oddsBookingsToProcessList;
      this.linkedItiBookingsToProcessList = linkedItiBookingsToProcessList;
      this.othersBookingsToProcessList = othersBookingsToProcessList;
      this.bookingCouplesPIUAListByItiItem = bookingCouplesPIUAListByItiItem;
      this.bookingOddsPIUAListByItiItem = bookingOddsPIUAListByItiItem;
      this.bookingLinkedItiPIUAListByItiItem = bookingLinkedItiPIUAListByItiItem;
      this.bookingMobilityPIUAListByItiItem = bookingMobilityPIUAListByItiItem;
      this.bookingMobilityPIUAGroupListByItiItem = bookingMobilityPIUAGroupListByItiItem;
      this.bookingOthersPIUAListByItiItem = bookingOthersPIUAListByItiItem;
      this.batchHelper = batchHelper;
      this.itinerarySet = itinerarySet;
      this.linkedItinerarySet = linkedItinerarySet;
      this.linkedMobilityItinerarySet = linkedMobilityItinerarySet;
    }
  }

  public class SeatingToolBatchWrapper {
    public SeatingToolBatchWrapper() {
    }

    public List<String> mapKeySet { get; set; }
    public Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper> railcarSeatMap { get; set; }
    public RM_SeatingToolWrappers.SeatingRuleWrapper wrappedSeatingRule { get; set; }
    public Map<String, RM_SeatingToolWrappers.RailcarWrapper> availableSeatsByRailcarId { get; set; }
    public Boolean hasExecuted { get; set; }

    public SeatingToolBatchWrapper(
      List<String> mapKeySet,
      Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper> railcarSeatMap,
      RM_SeatingToolWrappers.SeatingRuleWrapper wrappedSeatingRule,
      Map<String, RM_SeatingToolWrappers.RailcarWrapper> availableSeatsByRailcarId,
      Boolean hasExecuted
    ) {
      this.mapKeySet = mapKeySet;
      this.railcarSeatMap = railcarSeatMap;
      this.wrappedSeatingRule = wrappedSeatingRule;
      this.availableSeatsByRailcarId = availableSeatsByRailcarId;
      this.hasExecuted = hasExecuted;
    }
  }

  public class SeatingToolServiceClassGroupWrapper {
    public SeatingToolServiceClassGroupWrapper() {
    }

    public RM_SeatingToolWrappers.SeatingToolBatchWrapper wrappedSeatingBatchLAKSL { get; set; }
    public RM_SeatingToolWrappers.SeatingToolBatchWrapper wrappedSeatingBatchLAKGL { get; set; }
    public RM_SeatingToolWrappers.SeatingToolBatchWrapper wrappedSeatingBatchCJ { get; set; }
    public RM_SeatingToolWrappers.SeatingToolBatchWrapper wrappedSeatingBatchSL { get; set; }
    public RM_SeatingToolWrappers.SeatingToolBatchWrapper wrappedSeatingBatchGL { get; set; }
    public RM_SeatingToolWrappers.SeatingToolBatchWrapper wrappedSeatingBatchSLP { get; set; }

    public SeatingToolServiceClassGroupWrapper(
      RM_SeatingToolWrappers.SeatingToolBatchWrapper wrappedSeatingBatchLAKSL,
      RM_SeatingToolWrappers.SeatingToolBatchWrapper wrappedSeatingBatchLAKGL,
      RM_SeatingToolWrappers.SeatingToolBatchWrapper wrappedSeatingBatchCJ,
      RM_SeatingToolWrappers.SeatingToolBatchWrapper wrappedSeatingBatchSL,
      RM_SeatingToolWrappers.SeatingToolBatchWrapper wrappedSeatingBatchGL,
      RM_SeatingToolWrappers.SeatingToolBatchWrapper wrappedSeatingBatchSLP
    ) {
      this.wrappedSeatingBatchLAKSL = wrappedSeatingBatchLAKSL;
      this.wrappedSeatingBatchLAKGL = wrappedSeatingBatchLAKGL;
      this.wrappedSeatingBatchCJ = wrappedSeatingBatchCJ;
      this.wrappedSeatingBatchSL = wrappedSeatingBatchSL;
      this.wrappedSeatingBatchGL = wrappedSeatingBatchGL;
      this.wrappedSeatingBatchSLP = wrappedSeatingBatchSLP;
    }
  }

  public class MobilityEmailWrapper {
    public MobilityEmailWrapper() {
    }

    public Integer mobilityCounter { get; set; }
    public List<KaptioTravel__PassengerItineraryUnitAssignment__c> mobilityPIUAList { get; set; }

    public MobilityEmailWrapper(Integer mobilityCounter, List<KaptioTravel__PassengerItineraryUnitAssignment__c> mobilityPIUAList) {
      this.mobilityCounter = mobilityCounter;
      this.mobilityPIUAList = mobilityPIUAList;
    }
  }
  // END - Ticket #30921
  // END - Ticket #37921 / #31294
  // END - Ticket #38145 / #38487 / #38498 / #38790
}
// END - Ticket #35471
// END - Ticket #39453
// END - Ticket #32134 / #39498 / #40024 / #40025 / #40026
// END - Ticket #39117 / #40707 / #40408 / #40326 / #40064 / #40063 / #40054 / #40050 / #39502 / #39232