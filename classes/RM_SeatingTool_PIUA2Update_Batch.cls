/**
 * @description       : Batch to only update the whole PIUA map list values from all business rules batches
 * @author            : Anderson Morino
 * @group             :
 * @last modified on  : 03-22-2023
 * @last modified by  : Anderson Morino
 **/
// BEGINNING - Ticket #39453 / #40026 / #40010 / #39498 / #39117 / #37921 - Refactorings
// BEGINNING - Ticket #35471 - Batch to only update the whole PIUA map list values from all business rules batches
global class RM_SeatingTool_PIUA2Update_Batch implements Database.Batchable<sObject>, Database.Stateful {
  private List<KaptioTravel__PassengerItineraryUnitAssignment__c> scope;

  public RM_SeatingTool_PIUA2Update_Batch(List<KaptioTravel__PassengerItineraryUnitAssignment__c> scope) {
    this.scope = scope;
  }

  global Iterable<sObject> start(Database.BatchableContext BC) {
    return scope;
  }

  global void execute(Database.BatchableContext BC, List<KaptioTravel__PassengerItineraryUnitAssignment__c> scope) {
    try {
      if (!scope.isEmpty()) {
        RM_SF2INK_Utils.isSeatingBatch = true;
        update scope;
        RM_SF2INK_Utils.isSeatingBatch = false;
      }
    } catch (Exception ex) {
      // Implement logic to notify user for exceptions - AKA Exception Log Task
      throw new RM_SeatingToolException(ex);
    }
  }

  global void finish(Database.BatchableContext BC) {
  }
}
// END - Ticket #35471
// END - Ticket #39453 / #40026 / #40010 / #39498 / #39117 / #37921