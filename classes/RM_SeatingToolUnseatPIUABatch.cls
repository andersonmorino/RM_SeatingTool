/**
 * @description       : Batch to unseat all passengers from a specific departure date
 * @author            : Anderson Morino
 * @group             :
 * @last modified on  : 04-10-2023
 * @last modified by  : Caio Remberg
 **/
// BEGINNING - Ticket #40446 / #40408 / #40046 / #40045 / #40023 / #40022 / #39836 / #39117 - Fixed bugs for Split Trains
// BEGINNING - Ticket #32134 / #39498 / #40024 / #40025 / #40026 - Fixed bugs
// BEGINNING - Ticket #35471 - Batch to unseat all PIUA records from a specific departure date
public with sharing class RM_SeatingToolUnseatPIUABatch implements Database.Batchable<sObject>, Database.Stateful {
  private List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries;
  // BEGINNING - Ticket #30921 - Refactorings

  private List<KaptioTravel__PassengerItineraryUnitAssignment__c> bookingPIUAs = new List<KaptioTravel__PassengerItineraryUnitAssignment__c>();
  private List<KaptioTravel__PassengerItineraryUnitAssignment__c> scope = new List<KaptioTravel__PassengerItineraryUnitAssignment__c>();

  public RM_SeatingToolUnseatPIUABatch(List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries) {
    this.wrappedItineraries = wrappedItineraries;
  }

  public Iterable<sObject> start(Database.BatchableContext BC) {
    for (
      KaptioTravel__PassengerItineraryUnitAssignment__c piua : (List<KaptioTravel__PassengerItineraryUnitAssignment__c>) Database.query(
        RM_SeatingToolBatchHelper.getPIUARecords(wrappedItineraries)
      )
    ) {
      if (!scope.contains(piua)) {
        scope.add(piua);
      }
    }

    for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : scope) {
      if (piua.RailCarNumber__c != null || piua.RailCarOrdinalNumber__c != null || piua.RailSeatNumber__c != null) {
        piua.RailCarNumber__c = null;
        piua.RailCarOrdinalNumber__c = null;
        piua.RailSeatNumber__c = null;

        bookingPIUAs.add(piua);
      }
    }

    return bookingPIUAs;
  }

  public void execute(Database.BatchableContext info, List<sObject> scope) {
    List<KaptioTravel__PassengerItineraryUnitAssignment__c> piua2Update = (List<KaptioTravel__PassengerItineraryUnitAssignment__c>) scope;

    try {
      if (!piua2Update.isEmpty()) {
        RM_SF2INK_Utils.isSeatingBatch = true;
        update piua2Update;
        RM_SF2INK_Utils.isSeatingBatch = false;
      }
    } catch (Exception ex) {
      // Implement logic to notify user for exceptions - AKA Exception Log Task
      throw new RM_SeatingToolException(ex);
    }
  }
  // END - Ticket #30921

  public void finish(Database.BatchableContext info) {
  }
}
// END - Ticket #35471
// END - Ticket #32134 / #39498 / #40024 / #40025 / #40026
// END - Ticket #40446 / #40408 / #40046 / #40045 / #40023 / #40022 / #39836 / #39117