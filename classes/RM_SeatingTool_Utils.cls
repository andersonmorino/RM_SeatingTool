/**
 * @description       : Utils class reusable methods for Seating Tool
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
// BEGINNING - Ticket #35471 - Util class with reusable methods for Seating Tool
// BEGINNING - Ticket #38145 / #38487 / #38498 / #38790 - Added boolean variable to control LAK seating process
public with sharing class RM_SeatingTool_Utils {
  private final static String MOBILITY_CAPACITY_EXCEEDED_EMAIL_SUBJECT = System.Label.Mobility_Capacity_Exceeded_Email_Subject;

  public RM_SeatingTool_Utils() {
  }

  /**
   * @description Method to group wrapper variables for each ST process
   * @author Anderson Morino | 03-22-2023
   * @param wrappedSeatingBatchLAKSL
   * @param wrappedSeatingBatchLAKGL
   * @param wrappedSeatingBatchCJ
   * @param wrappedSeatingBatchSL
   * @param wrappedSeatingBatchGL
   * @param wrappedSeatingBatchSLP
   * @return RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper
   **/
  public static RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper seatingServiceClassWrapperBuilder(
    RM_SeatingToolWrappers.SeatingToolBatchWrapper wrappedSeatingBatchLAKSL,
    RM_SeatingToolWrappers.SeatingToolBatchWrapper wrappedSeatingBatchLAKGL,
    RM_SeatingToolWrappers.SeatingToolBatchWrapper wrappedSeatingBatchCJ,
    RM_SeatingToolWrappers.SeatingToolBatchWrapper wrappedSeatingBatchSL,
    RM_SeatingToolWrappers.SeatingToolBatchWrapper wrappedSeatingBatchGL,
    RM_SeatingToolWrappers.SeatingToolBatchWrapper wrappedSeatingBatchSLP
  ) {
    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper seatingServiceClassWrapper = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper(
      wrappedSeatingBatchLAKSL,
      wrappedSeatingBatchLAKGL,
      wrappedSeatingBatchCJ,
      wrappedSeatingBatchSL,
      wrappedSeatingBatchGL,
      wrappedSeatingBatchSLP
    );

    return seatingServiceClassWrapper;
  }

  /**
   * @description Method to group railcar variables
   * @author Anderson Morino | 03-22-2023
   * @param mapKeySet
   * @param railcarSeatMap
   * @param wrappedSeatingRule
   * @param availableSeatsByRailcarId
   * @param hasExecuted
   * @return RM_SeatingToolWrappers.SeatingToolBatchWrapper
   **/
  public static RM_SeatingToolWrappers.SeatingToolBatchWrapper seatingBatchWrapperBuilder(
    List<String> mapKeySet,
    Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper> railcarSeatMap,
    RM_SeatingToolWrappers.SeatingRuleWrapper wrappedSeatingRule,
    Map<String, RM_SeatingToolWrappers.RailcarWrapper> availableSeatsByRailcarId,
    Boolean hasExecuted
  ) {
    wrappedSeatingRule = seatingRulesWrapperBuilder(new RM_SeatingToolWrappers.SeatingRuleWrapper());

    RM_SeatingToolWrappers.SeatingToolBatchWrapper seatingBatchWrapper = new RM_SeatingToolWrappers.SeatingToolBatchWrapper(
      mapKeySet,
      railcarSeatMap,
      wrappedSeatingRule,
      availableSeatsByRailcarId,
      hasExecuted
    );

    return seatingBatchWrapper;
  }

  /**
   * @description Method to group all Service class variables
   * @author Anderson Morino | 03-22-2023
   * @param seatingRulesWrapper
   * @return RM_SeatingToolWrappers.SeatingRuleWrapper
   **/
  public static RM_SeatingToolWrappers.SeatingRuleWrapper seatingRulesWrapperBuilder(RM_SeatingToolWrappers.SeatingRuleWrapper seatingRulesWrapper) {
    Map<String, List<KaptioTravel__Itinerary_Item__c>> railServicesByBooking = new Map<String, List<KaptioTravel__Itinerary_Item__c>>();
    Map<String, KaptioTravel__Itinerary_Item__c> transferServicesByLocation = new Map<String, KaptioTravel__Itinerary_Item__c>();
    Map<String, List<KaptioTravel__Itinerary_Item__c>> recordsToProcess = new Map<String, List<KaptioTravel__Itinerary_Item__c>>();
    List<KaptioTravel__Itinerary_Item__c> bookingsToProcessList = new List<KaptioTravel__Itinerary_Item__c>();
    Set<String> serviceDogLinkedItinerariesSet = new Set<String>();
    Set<String> fullyBoundLinkedItinerariesSet = new Set<String>();
    List<KaptioTravel__PassengerItineraryUnitAssignment__c> bookingServiceDogPIUAList = new List<KaptioTravel__PassengerItineraryUnitAssignment__c>();
    List<KaptioTravel__PassengerItineraryUnitAssignment__c> bookingFullyBoundPIUAList = new List<KaptioTravel__PassengerItineraryUnitAssignment__c>();
    Set<String> serviceDogPassengerSet = new Set<String>();
    Set<String> fullyBoundPassengerSet = new Set<String>();
    List<KaptioTravel__Itinerary_Item__c> remainingMobilityGroupBookingsToProcessList = new List<KaptioTravel__Itinerary_Item__c>();
    List<KaptioTravel__Itinerary_Item__c> remainingMobilityIndividualBookingsToProcessList = new List<KaptioTravel__Itinerary_Item__c>();
    List<KaptioTravel__Itinerary_Item__c> remainingCouplesBookingsToProcessList = new List<KaptioTravel__Itinerary_Item__c>();
    List<KaptioTravel__Itinerary_Item__c> remainingOddsBookingsToProcessList = new List<KaptioTravel__Itinerary_Item__c>();
    List<KaptioTravel__Itinerary_Item__c> remainingLinkedItiBookingsToProcessList = new List<KaptioTravel__Itinerary_Item__c>();
    List<KaptioTravel__Itinerary_Item__c> remainingOthersBookingsToProcessList = new List<KaptioTravel__Itinerary_Item__c>();
    List<KaptioTravel__Itinerary_Item__c> mobilityGroupBookingsToProcessList = new List<KaptioTravel__Itinerary_Item__c>();
    List<KaptioTravel__Itinerary_Item__c> mobilityIndividualBookingsToProcessList = new List<KaptioTravel__Itinerary_Item__c>();
    List<KaptioTravel__Itinerary_Item__c> couplesBookingsToProcessList = new List<KaptioTravel__Itinerary_Item__c>();
    List<KaptioTravel__Itinerary_Item__c> oddsBookingsToProcessList = new List<KaptioTravel__Itinerary_Item__c>();
    List<KaptioTravel__Itinerary_Item__c> linkedItiBookingsToProcessList = new List<KaptioTravel__Itinerary_Item__c>();
    List<KaptioTravel__Itinerary_Item__c> othersBookingsToProcessList = new List<KaptioTravel__Itinerary_Item__c>();
    Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingCouplesPIUAListByItiItem = new Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>>();
    Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingOddsPIUAListByItiItem = new Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>>();
    Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingLinkedItiPIUAListByItiItem = new Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>>();
    Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingMobilityPIUAListByItiItem = new Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>>();
    Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingMobilityPIUAGroupListByItiItem = new Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>>();
    Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingOthersPIUAListByItiItem = new Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>>();
    RM_SeatingToolBatchHelper batchHelper = RM_SeatingToolBatchHelper.getInstance();
    Set<Id> itinerarySet = new Set<Id>();
    Set<Id> linkedItinerarySet = new Set<Id>();
    Set<Id> linkedMobilityItinerarySet = new Set<Id>();

    seatingRulesWrapper = new RM_SeatingToolWrappers.SeatingRuleWrapper(
      railServicesByBooking,
      transferServicesByLocation,
      recordsToProcess,
      bookingsToProcessList,
      serviceDogLinkedItinerariesSet,
      fullyBoundLinkedItinerariesSet,
      bookingServiceDogPIUAList,
      bookingFullyBoundPIUAList,
      serviceDogPassengerSet,
      fullyBoundPassengerSet,
      remainingMobilityGroupBookingsToProcessList,
      remainingMobilityIndividualBookingsToProcessList,
      remainingCouplesBookingsToProcessList,
      remainingOddsBookingsToProcessList,
      remainingLinkedItiBookingsToProcessList,
      remainingOthersBookingsToProcessList,
      mobilityGroupBookingsToProcessList,
      mobilityIndividualBookingsToProcessList,
      couplesBookingsToProcessList,
      oddsBookingsToProcessList,
      linkedItiBookingsToProcessList,
      othersBookingsToProcessList,
      bookingCouplesPIUAListByItiItem,
      bookingOddsPIUAListByItiItem,
      bookingLinkedItiPIUAListByItiItem,
      bookingMobilityPIUAListByItiItem,
      bookingMobilityPIUAGroupListByItiItem,
      bookingOthersPIUAListByItiItem,
      batchHelper,
      itinerarySet,
      linkedItinerarySet,
      linkedMobilityItinerarySet
    );

    return seatingRulesWrapper;
  }

  /**
   * @description Send email to Prods Ops Team if exceeded capacity for mobility customers on trains
   * @author Anderson Morino | 03-22-2023
   * @param piuaSpecialMobility2Notify
   * @param mobilityPassengerSet
   **/
  public static void sendProdOpsTeamEmail(
    List<KaptioTravel__PassengerItineraryUnitAssignment__c> piuaSpecialMobility2Notify,
    Set<String> mobilityPassengerSet
  ) {
    if (piuaSpecialMobility2Notify.isEmpty()) {
      return;
    }

    List<Seating_Tool_Product_Ops_Team_Email__mdt> prodOpsTeamEmailList = Seating_Tool_Product_Ops_Team_Email__mdt.getAll().values();
    List<String> emailAddrList = new List<String>();
    String htmlBody = '';

    for (Seating_Tool_Product_Ops_Team_Email__mdt pote : prodOpsTeamEmailList) {
      if (!emailAddrList.contains(pote.Email__c)) {
        emailAddrList.add(pote.Email__c);
      }
    }

    htmlBody = 'We have exceeded capacity for mobility customers on trains: ';
    htmlBody += '<br><table border="1">';
    htmlBody += '<tr> <th><b>Train</b></th> <th><b>Railcar</b></th> <th><b>Date</b></th> <th><b>Passenger</b></th> <th><b>Booking Number</b></th> <th><b>Mobility Requirement (PGI)</b></th> </tr>';

    for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : piuaSpecialMobility2Notify) {
      if (!mobilityPassengerSet.contains(String.valueOf(piua.KaptioTravel__Passenger__c))) {
        String piuapassengerName = String.valueOf(piua.KaptioTravel__Passenger__r.passenger_full_name__c);
        String piuaMobilityNeed = piua.KaptioTravel__Passenger__r.MobilityGeneral__c == null
          ? ''
          : piua.KaptioTravel__Passenger__r.MobilityGeneral__c;
        String railcarNumber = piua.RailCarNumber__c == null ? 'Not Seated' : piua.RailCarNumber__c;
        htmlBody +=
          '<tr> <td>' +
          piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
          '</td> <td>' +
          railcarNumber +
          '</td> <td>' +
          piua.Rail_Date__c +
          '</td> <td>' +
          piuaPassengerName +
          '</td> <td>' +
          piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.KaptioTravel__BookingNumber__c +
          '</td> <td>' +
          piuaMobilityNeed +
          '</td> </tr>';

        mobilityPassengerSet.add(piua.KaptioTravel__Passenger__c);
      }
    }
    htmlBody += '</table><br>';

    if (htmlBody != '') {
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      mail.setToAddresses(emailAddrList);
      mail.setSubject(MOBILITY_CAPACITY_EXCEEDED_EMAIL_SUBJECT);
      mail.setBccSender(false);
      mail.setHtmlBody(htmlBody);
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    }
  }

  /**
   * @description Send an email to Prods Ops Team for each Gold Leaf booking or linked booking which has over 36 Lake Louise guests that have been seated
   * @author Anderson Morino | 05-05-2023
   * @param railcarIdByLAKGLBookingPIUAOver36
   * @param trainInfo
   **/
  public static void sendLAKGLOver36ProdOpsTeamEmail(
    Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c> railcarIdByLAKGLBookingPIUAOver36,
    RM_ROS_IntegrationWrapper.TRAIN trainInfo
  ) {
    if (railcarIdByLAKGLBookingPIUAOver36.isEmpty()) {
      return;
    }

    List<Seating_Tool_Product_Ops_Team_Email__mdt> prodOpsTeamEmailList = Seating_Tool_Product_Ops_Team_Email__mdt.getAll().values();
    List<String> emailAddrList = new List<String>();
    List<String> htmlBodyList = new List<String>();

    for (Seating_Tool_Product_Ops_Team_Email__mdt pote : prodOpsTeamEmailList) {
      if (!emailAddrList.contains(pote.Email__c)) {
        emailAddrList.add(pote.Email__c);
      }
    }

    Set<String> emailBookings = new Set<String>();

    for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : railcarIdByLAKGLBookingPIUAOver36.values()) {
      String bookingPIUAKey = piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c == null
        ? piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.KaptioTravel__BookingNumber__c
        : piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__r.Name;

      if (!emailBookings.contains(bookingPIUAKey)) {
        String htmlBody = 'A large group with more than standard capacity for Lake Louise has been seated.';
        htmlBody += '<br>';
        htmlBody += 'Date: <b>' + trainInfo.Scheduled_Departure_Date + '</b>';
        htmlBody += '<br>';
        htmlBody += 'Train: <b>' + trainInfo.Train_Name + '</b>';
        htmlBody += '<br>';
        htmlBody += 'Rail Car: <b>' + piua.RailCarNumber__c + '</b>';
        htmlBody += '<br>';
        htmlBody += 'Itinerary: <b>' + bookingPIUAKey + '</b>';

        emailBookings.add(bookingPIUAKey);

        if (!htmlBodyList.contains(htmlBody)) {
          htmlBodyList.add(htmlBody);
        }
      }
    }

    List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();

    for (String body : htmlBodyList) {
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      mail.setToAddresses(emailAddrList);
      mail.setSubject('Train Seated with more than standard capacity for Lake Louise ' + trainInfo.Train_Name);
      mail.setBccSender(false);
      mail.setHtmlBody(body);

      if (!mailList.contains(mail)) {
        mailList.add(mail);
      }
    }

    Messaging.sendEmail(mailList);
  }

  /**
   * @description return map of contiguous railcar seats size
   * @author Anderson Morino | 01-19-2023
   * @param railcarSeatMap
   * @param mapKeySet
   * @param isMobilityRule
   * @return Map<String, RM_SeatingToolWrappers.RailcarWrapper>
   **/
  public static Map<String, RM_SeatingToolWrappers.RailcarWrapper> getContiguousRailcarSeatsSize(
    Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper> railcarSeatMap,
    List<String> mapKeySet,
    Boolean isMobilityRule,
    Boolean isSilver
  ) {
    List<RM_SeatingToolWrappers.RailcarSeatWrapper> wrappedRailcarSeatList = new List<RM_SeatingToolWrappers.RailcarSeatWrapper>();

    String currentKey = null;
    List<RM_SeatingToolWrappers.RailcarSeatWrapper> currentWrappedRailcarSeatList = new List<RM_SeatingToolWrappers.RailcarSeatWrapper>();
    List<RM_SeatingToolWrappers.RailcarSeatWrapper> currentWrappedRailcarMobilitySeatList = new List<RM_SeatingToolWrappers.RailcarSeatWrapper>();
    Map<String, List<RM_SeatingToolWrappers.RailcarSeatWrapper>> railcarSeatInfoListByKey = new Map<String, List<RM_SeatingToolWrappers.RailcarSeatWrapper>>();
    Map<String, List<RM_SeatingToolWrappers.RailcarSeatWrapper>> railcarMobilitySeatInfoListByKey = new Map<String, List<RM_SeatingToolWrappers.RailcarSeatWrapper>>();
    Integer counter = 0;

    // iterate through the built list
    for (Integer i = 0; i < mapKeySet.size(); i++) {
      if (!railcarSeatMap.get(mapKeySet[i]).occupied) {
        /**
         * if it's the first iteration OR
         * the current wrapped railcar seat is not contiguous from the previous one OR
         * the current railcar seat is contiguous but the current seat railcar is not equals the previous one, put a new key and initialize a new list
         **/
        if (
          currentKey == null ||
          (Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) -
          Integer.valueOf(currentWrappedRailcarSeatList[currentWrappedRailcarSeatList.size() - 1].railcarSeatId)) !=
          (isMobilityRule && isSilver ? -1 : 1) ||
          ((Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) -
          Integer.valueOf(currentWrappedRailcarSeatList[currentWrappedRailcarSeatList.size() - 1].railcarSeatId)) ==
          (isMobilityRule && isSilver ? -1 : 1) &&
          railcarSeatMap.get(mapKeySet[i]).railcarId != currentWrappedRailcarSeatList[currentWrappedRailcarSeatList.size() - 1].railcarId) ||
          (((!isMobilityRule && isSilver) || (isMobilityRule && !isSilver) || (!isMobilityRule && !isSilver)) &&
          Math.mod(Integer.valueOf(currentWrappedRailcarSeatList[0].railcarSeatId), 4) == 0) ||
          (isMobilityRule &&
          isSilver &&
          Math.mod(Integer.valueOf(currentWrappedRailcarSeatList[0].railcarSeatId) + 1, 2) == 0 &&
          Math.mod(Integer.valueOf(currentWrappedRailcarSeatList[0].railcarSeatId) + 1, 4) != 0) ||
          (((!isMobilityRule && isSilver) ||
          (isMobilityRule && !isSilver) ||
          (!isMobilityRule && !isSilver)) &&
          Math.mod(Integer.valueOf(currentWrappedRailcarSeatList[0].railcarSeatId) + 1, 4) == 0 &&
          Math.mod(Integer.valueOf(currentWrappedRailcarSeatList[currentWrappedRailcarSeatList.size() - 1].railcarSeatId), 4) == 0) ||
          (isMobilityRule &&
          railcarSeatMap.get(mapKeySet[i]).mobilityApproved &&
          !currentWrappedRailcarSeatList[currentWrappedRailcarSeatList.size() - 1].mobilityApproved)
        ) {
          /**
           * if current railcar is not equals the previous one then reset counter
           **/
          if (
            !currentWrappedRailcarSeatList.isEmpty() &&
            railcarSeatMap.get(mapKeySet[i]).railcarId != currentWrappedRailcarSeatList[currentWrappedRailcarSeatList.size() - 1].railcarId
          ) {
            counter = 0;
          }

          // the current key to be put into the map has a concatenated string with the "{routeKey}-{railcarOrderKey}-{railcar contiguous seats group index}"
          currentKey =
            railcarSeatMap.get(mapKeySet[i]).routeKey +
            '-' +
            railcarSeatMap.get(mapKeySet[i]).railcarOrderKey +
            '-' +
            (String.valueOf(counter).length() == 1 ? '0' + String.valueOf(counter) : String.valueOf(counter));

          // initialize the list
          currentWrappedRailcarSeatList = new List<RM_SeatingToolWrappers.RailcarSeatWrapper>();
          currentWrappedRailcarMobilitySeatList = new List<RM_SeatingToolWrappers.RailcarSeatWrapper>();
          // put the current key and the new list into the map
          railcarSeatInfoListByKey.put(currentKey, currentWrappedRailcarSeatList);
          railcarMobilitySeatInfoListByKey.put(currentKey, currentWrappedRailcarMobilitySeatList);

          // increment the counter
          counter++;
        }
        // keep adding each wrapped railcar seat to the list while railcar is the same and seat is contiguous
        currentWrappedRailcarSeatList.add(railcarSeatMap.get(mapKeySet[i]));

        if (railcarSeatMap.get(mapKeySet[i]).mobilityApproved) {
          currentWrappedRailcarMobilitySeatList.add(railcarSeatMap.get(mapKeySet[i]));
        }

        // update the contiguous seat group with the new key
        railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey = currentKey;
      }
    }

    Map<String, RM_SeatingToolWrappers.RailcarWrapper> contiguousSeatsSizeMap = new Map<String, RM_SeatingToolWrappers.RailcarWrapper>();

    // build the map with all keys with their sizes
    for (String key : railcarSeatInfoListByKey.keySet()) {
      // BEGINNING - Ticket #39090 - small change to the contiguous size map
      contiguousSeatsSizeMap.put(
        key,
        new RM_SeatingToolWrappers.RailcarWrapper(
          new List<String>(),
          railcarSeatInfoListByKey.get(key).size(),
          railcarSeatInfoListByKey.get(key)[0].railcarSeatLetter,
          railcarMobilitySeatInfoListByKey.get(key).size(),
          railcarSeatInfoListByKey.get(key)[0].railcarId
        )
      );
      // END - Ticket #39090
    }

    // return the map with all keys with their sizes
    return contiguousSeatsSizeMap;
  }
}
// END - Ticket #38145 / #38487 / #38498 / #38790
// END - Ticket #35471
// END - Ticket #39453 / #40026 / #40010 / #39498 / #39117 / #37921
// END - Ticket #32134 / #39498 / #40024 / #40025 / #40026
// END - Ticket #40446 / #40408 / #40046 / #40045 / #40023 / #40022 / #39836 / #39117
// END - Ticket #39117 / #40707 / #40408 / #40326 / #40064 / #40063 / #40054 / #40050 / #39502 / #39232
// END - Ticket #41032 / #41033 / #41003 / #30715 / #41034 / #40880 / #40065 / #40818 / #40869 / #40868 / #41037
