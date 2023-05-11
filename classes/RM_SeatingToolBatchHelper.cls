/**
 * @description       : Class with business rules methods
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
public with sharing class RM_SeatingToolBatchHelper {
  /**
   * Singleton pattern
   */
  // private static instance of the class
  private static RM_SeatingToolBatchHelper instance = null;

  // private constructor to avoid creating an instance

  private RM_SeatingToolBatchHelper() {
  }

  public static RM_SeatingToolBatchHelper getInstance() {
    if (instance == null) {
      instance = new RM_SeatingToolBatchHelper();
    }
    return instance;
  }

  /**
   * @description Gets query string of bookings with PIUA records from a specific train date and service level
   * @author Anderson Morino | 12-22-2022
   * @param wrappedItineraries
   * @return String
   **/
  // BEGINNING - Ticket #37921 / #31294 - Created methods to generate fake records cloning PIUA records from database in order to have them for all train legs
  // BEGINNING - Ticket #38145 / #38487 / #38498 / #38790 - Added condition in all business rules in order to check limit of passengers for first 10 contiguous railcars for SL/GL
  // BEGINNING - Ticket #39745 / #39544 / #39498 / #37922 / #37921 / #32134 / #31236 - Fixed bugs when seating bookings, improving the order of bookings and passengers by Room Id
  public static String getBookingsWithPIUA(List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries) {
    String routesAndDates = ' AND (';

    for (RM_SeatingToolWrappers.ManagementLegWrapper itinerary : wrappedItineraries) {
      Date departureDate = Date.valueOf(itinerary.departureDate);
      routesAndDates +=
        '(KaptioTravel__DateFrom__c = ' +
        String.valueOf(departureDate) +
        ' AND KaptioTravel__ExternalItemName__c = ' +
        '\'' +
        itinerary.route +
        '\'' +
        ')';

      routesAndDates += (wrappedItineraries.indexOf(itinerary) != wrappedItineraries.size() - 1) ? ' OR ' : ')';
    }

    // BEGINNING - Ticket #35471 - Converted query to String in order to make it dynamically
    String query =
      'SELECT' +
      ' Id,' +
      ' KaptioTravel__Itinerary__c,' +
      ' KaptioTravel__Itinerary__r.KaptioTravel__BookingNumber__c,' +
      ' KaptioTravel__Itinerary__r.LinkedItinerary__c,' +
      ' KaptioTravel__Itinerary__r.LinkedItinerary__r.Name,' +
      ' KaptioTravel__Itinerary__r.Passengers_with_service_animal__c,' +
      ' KaptioTravel__Itinerary__r.Fully_Bound_Mobility_Passengers__c,' +
      ' KaptioTravel__DateFrom__c,' +
      ' KaptioTravel__Item__r.KaptioTravel__Location__r.Name,' +
      ' KaptioTravel__ExternalItemName__c,' +
      ' KaptioTravel__Price_Category__r.Name,' +
      ' KaptioTravel__Itinerary__r.CircleJourney__c,' +
      ' (SELECT' +
      ' Id,' +
      ' KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c,' +
      ' KaptioTravel__Passenger__c,' +
      ' KaptioTravel__Passenger__r.passenger_full_name__c,' +
      ' KaptioTravel__Passenger__r.MobilityGeneral__c,' +
      ' KaptioTravel__Passenger__r.MobilityRequirements__c,' +
      ' KaptioTravel__Passenger__r.Mobility_Needs__c,' +
      ' KaptioTravel__Passenger__r.Service_animal__c,' +
      ' KaptioTravel__Passenger__r.Mobility_Bound__c,' +
      ' KaptioTravel__Passenger__r.KaptioTravel__FirstName__c,' +
      ' KaptioTravel__Passenger__r.KaptioTravel__LastName__c,' +
      ' KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c,' +
      ' KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c,' +
      ' KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c,' +
      ' KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__r.Name,' +
      ' KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.KaptioTravel__BookingNumber__c,' +
      ' KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.Passengers_with_service_animal__c,' +
      ' KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.CircleJourney__c,' +
      ' KaptioTravel__ItineraryItem__r.KaptioTravel__Price_Category__r.Name,' +
      ' Passenger_Name__c,' +
      ' RailCarNumber__c,' +
      ' RailCarOrdinalNumber__c,' +
      ' RailSeatNumber__c,' +
      ' Rail_Date__c' +
      ' FROM KaptioTravel__PassengerItineraryUnitAssignments__r' +
      ' WHERE' +
      ' KaptioTravel__Passenger__c != null' +
      ' ORDER BY KaptioTravel__Passenger__r.Mobility_Needs__c DESC, KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c ASC, KaptioTravel__Passenger__c ASC)' +
      ' FROM KaptioTravel__Itinerary_Item__c' +
      ' WHERE' +
      ' KaptioTravel__Item__r.RecordType.IsActive = TRUE' +
      ' AND KaptioTravel__Item__r.RecordType.DeveloperName = \'Rail\'' +
      ' AND KaptioTravel__Mode__c = \'Active\'' +
      ' AND KaptioTravel__Itinerary__r.KaptioTravel__Status__c IN (\'Booked\', \'Confirmed\')' +
      routesAndDates;

    return query;
    // END - Ticket #35471
  }

  /**
   * @description Gets ordered itineraries data by transfer service
   * @author Anderson Morino | 01-12-2023
   * @param scope
   * @param wrappedSeatingRule
   * @param itiItemPriceCategories
   * @return List<KaptioTravel__Itinerary_Item__c>
   **/

  // BEGINNING - Ticket #35471 - Gets ordered itineraries data by transfer service
  public static List<KaptioTravel__Itinerary_Item__c> getItinerariesByTransferSort(
    List<KaptioTravel__Itinerary_Item__c> scope,
    RM_SeatingToolWrappers.SeatingRuleWrapper wrappedSeatingRule,
    String itiItemPriceCategories
  ) {
    // List<String> itiItemPriceCategoryList = new List<String>();

    // if (itiItemPriceCategories.contains(',')) {
    //   itiItemPriceCategoryList = itiItemPriceCategories.split(',');
    // }

    // // Populate collection of variables to fetch itineraries transfer items info
    // for (KaptioTravel__Itinerary_Item__c itiItem : scope) {
    //   if (
    //     (!itiItemPriceCategoryList.isEmpty() && itiItemPriceCategoryList.contains(itiItem.KaptioTravel__Price_Category__r.Name)) ||
    //     itiItem.KaptioTravel__Price_Category__r.Name == itiItemPriceCategories
    //   ) {
    //     if (!wrappedSeatingRule.railServicesByBooking.containsKey(itiItem.KaptioTravel__Itinerary__r.KaptioTravel__BookingNumber__c)) {
    //       wrappedSeatingRule.railServicesByBooking.put(
    //         itiItem.KaptioTravel__Itinerary__r.KaptioTravel__BookingNumber__c,
    //         new List<KaptioTravel__Itinerary_Item__c>{ itiItem }
    //       );
    //     } else {
    //       wrappedSeatingRule.railServicesByBooking.get(itiItem.KaptioTravel__Itinerary__r.KaptioTravel__BookingNumber__c).add(itiItem);
    //     }
    //   }
    // }

    // wrappedSeatingRule.transferServicesByLocation.putAll(
    //   RM_SeatingToolBatchHelper.getItinerariesTransfersInfo(wrappedSeatingRule.railServicesByBooking.keySet())
    // );

    // for (String transferInfoKey : wrappedSeatingRule.transferServicesByLocation.keySet()) {
    //   String transferBookingNumber = transferInfoKey.substringBefore('-');
    //   String transferKeyword = transferInfoKey.substringAfter('-');

    //   if (wrappedSeatingRule.railServicesByBooking.get(transferBookingNumber) != null) {
    //     for (KaptioTravel__Itinerary_Item__c railServiceWithPIUAs : wrappedSeatingRule.railServicesByBooking.get(transferBookingNumber)) {
    //       if (transferKeyword == railServiceWithPIUAs.KaptioTravel__Item__r.KaptioTravel__Location__r.Name) {
    //         KaptioTravel__Itinerary_Item__c transferService = wrappedSeatingRule.transferServicesByLocation.get(transferInfoKey);

    //         if (!wrappedSeatingRule.recordsToProcess.containsKey(transferService.KaptioTravel__PickUpLocation__c)) {
    //           wrappedSeatingRule.recordsToProcess.put(
    //             transferService.KaptioTravel__PickUpLocation__c,
    //             new List<KaptioTravel__Itinerary_Item__c>{ railServiceWithPIUAs }
    //           );
    //         } else {
    //           wrappedSeatingRule.recordsToProcess.get(transferService.KaptioTravel__PickUpLocation__c).add(railServiceWithPIUAs);
    //         }
    //         wrappedSeatingRule.railServicesByBooking.remove(transferBookingNumber);
    //       } else if (transferKeyword == railServiceWithPIUAs.KaptioTravel__ExternalItemName__c) {
    //         KaptioTravel__Itinerary_Item__c transferService = wrappedSeatingRule.transferServicesByLocation.get(transferInfoKey);

    //         if (!wrappedSeatingRule.recordsToProcess.containsKey(transferService.KaptioTravel__DropOffLocation__c)) {
    //           wrappedSeatingRule.recordsToProcess.put(
    //             transferService.KaptioTravel__DropOffLocation__c,
    //             new List<KaptioTravel__Itinerary_Item__c>{ railServiceWithPIUAs }
    //           );
    //         } else {
    //           wrappedSeatingRule.recordsToProcess.get(transferService.KaptioTravel__DropOffLocation__c).add(railServiceWithPIUAs);
    //         }
    //         wrappedSeatingRule.railServicesByBooking.remove(transferBookingNumber);
    //       } else {
    //         if (!wrappedSeatingRule.recordsToProcess.containsKey('No transfer information')) {
    //           wrappedSeatingRule.recordsToProcess.put('No transfer information', new List<KaptioTravel__Itinerary_Item__c>{ railServiceWithPIUAs });
    //         } else {
    //           wrappedSeatingRule.recordsToProcess.get('No transfer information').add(railServiceWithPIUAs);
    //         }
    //         wrappedSeatingRule.railServicesByBooking.remove(transferBookingNumber);
    //       }
    //     }
    //   }
    // }

    // for (String railServiceKey : wrappedSeatingRule.railServicesByBooking.keySet()) {
    //   for (KaptioTravel__Itinerary_Item__c railServiceWithPIUAs : wrappedSeatingRule.railServicesByBooking.get(railServiceKey)) {
    //     if (!wrappedSeatingRule.recordsToProcess.containsKey('Other locations')) {
    //       wrappedSeatingRule.recordsToProcess.put('Other locations', new List<KaptioTravel__Itinerary_Item__c>{ railServiceWithPIUAs });
    //     } else {
    //       wrappedSeatingRule.recordsToProcess.get('Other locations').add(railServiceWithPIUAs);
    //     }
    //   }
    // }

    // for (String recordToProcess : wrappedSeatingRule.recordsToProcess.keySet()) {
    //   wrappedSeatingRule.bookingsToProcessList.addAll(wrappedSeatingRule.recordsToProcess.get(recordToProcess));
    // }

    wrappedSeatingRule.bookingsToProcessList = scope;

    return wrappedSeatingRule.bookingsToProcessList;
  }
  // END - Ticket #35471

  /**
   * @description Gets PIUA records from a specific train date
   * @author Anderson Morino | 12-22-2022
   * @param routeServiceNames
   * @param railServicesDates
   * @param bookingNumbers
   * @return Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>
   **/
  public static String getPIUARecords(List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries) {
    String routesAndDates = ' AND (';

    String testChecker = Test.isrunningTest() ? ' LIMIT 100' : '';

    for (RM_SeatingToolWrappers.ManagementLegWrapper itinerary : wrappedItineraries) {
      Date departureDate = Date.valueOf(itinerary.departureDate);
      routesAndDates +=
        '(KaptioTravel__ItineraryItem__r.KaptioTravel__DateFrom__c = ' +
        String.valueOf(departureDate) +
        ' AND KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c = ' +
        '\'' +
        itinerary.route +
        '\'' +
        ')';

      routesAndDates += (wrappedItineraries.indexOf(itinerary) != wrappedItineraries.size() - 1) ? ' OR ' : ')';
    }

    String query =
      'SELECT' +
      ' Id,' +
      ' RailCarNumber__c,' +
      ' RailCarOrdinalNumber__c,' +
      ' RailSeatNumber__c' +
      ' FROM KaptioTravel__PassengerItineraryUnitAssignment__c' +
      ' WHERE' +
      ' KaptioTravel__ItineraryItem__r.KaptioTravel__Item__r.RecordType.IsActive = TRUE' +
      ' AND KaptioTravel__ItineraryItem__r.KaptioTravel__Item__r.RecordType.DeveloperName = \'Rail\'' +
      routesAndDates +
      testChecker;

    return query;
  }

  /**
   * @description Gets transfer services from rail services bookings
   * @author Adrian Flores | 11-11-2022
   * @param railServicesByBookings
   * @return Map<String, KaptioTravel__Itinerary_Item__c>
   **/
  public static Map<String, KaptioTravel__Itinerary_Item__c> getItinerariesTransfersInfo(Set<String> railServicesByBookings) {
    Map<String, Seating_Tool_Transfer_Location__mdt> transferLocations = Seating_Tool_Transfer_Location__mdt.getAll();

    Set<String> locations = new Set<String>();

    for (Seating_Tool_Transfer_Location__mdt location : transferLocations.values()) {
      locations.add(location.MasterLabel);
    }

    // the map to return
    Map<String, KaptioTravel__Itinerary_Item__c> transferServicesByLocation = new Map<String, KaptioTravel__Itinerary_Item__c>();

    for (
      KaptioTravel__Itinerary_Item__c transferService : [
        SELECT
          KaptioTravel__Itinerary__r.KaptioTravel__BookingNumber__c,
          KaptioTravel__Item__r.KaptioTravel__Location__r.Name,
          KaptioTravel__Item__r.KaptioTravel__TransferType__c,
          KaptioTravel__PickUpLocation__c,
          KaptioTravel__DropOffLocation__c
        FROM KaptioTravel__Itinerary_Item__c
        WHERE
          KaptioTravel__Itinerary__r.KaptioTravel__BookingNumber__c IN :railServicesByBookings
          AND KaptioTravel__Item__r.KaptioTravel__Location__r.Name IN :locations
          // BEGINNING - Ticket #32131 - Changed the record type filter to follow best practices
          AND KaptioTravel__Item__r.RecordType.DeveloperName = 'Transfer'
        // END - Ticket #32131
      ]
    ) {
      String transferKey;
      if (
        transferService.KaptioTravel__Item__r.KaptioTravel__TransferType__c.contains('Hotel to Station') &&
        !String.isBlank(transferService.KaptioTravel__PickUpLocation__c)
      ) {
        transferKey =
          transferService.KaptioTravel__Itinerary__r.KaptioTravel__BookingNumber__c +
          '-' +
          transferService.KaptioTravel__Item__r.KaptioTravel__Location__r.Name;
        transferServicesByLocation.put(transferKey, transferService);
      } else if (
        transferService.KaptioTravel__Item__r.KaptioTravel__TransferType__c.contains('Station to Hotel') &&
        transferService.KaptioTravel__DropOffLocation__c != null &&
        transferService.KaptioTravel__PickUpLocation__c != null
      ) {
        transferKey =
          transferService.KaptioTravel__Itinerary__r.KaptioTravel__BookingNumber__c +
          '-' +
          transferService.KaptioTravel__PickUpLocation__c;
        transferServicesByLocation.put(transferKey, transferService);
      }
    }

    return transferServicesByLocation;
  }

  // BEGINNING - Tickets #31246 / #31251 / #33315 - send email notification to Product Ops Team about special mobility condition
  /**
   * @description Send email notification to Product Ops Team about special mobility condition
   * @author Anderson Morino | 12-21-2022
   * @param piuaSpecialMobility2Notify
   * @param mobilityPassengerSet
   * @param subject
   * @param mobilityCondition
   **/
  public void sendProdOpsTeamEmail(
    List<KaptioTravel__PassengerItineraryUnitAssignment__c> piuaSpecialMobility2Notify,
    Set<String> mobilityPassengerSet,
    String subject,
    String mobilityCondition
  ) {
    List<Seating_Tool_Product_Ops_Team_Email__mdt> prodOpsTeamEmailList = Seating_Tool_Product_Ops_Team_Email__mdt.getAll().values();
    List<String> emailAddrList = new List<String>();
    String htmlBody = '';
    List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();

    for (Seating_Tool_Product_Ops_Team_Email__mdt pote : prodOpsTeamEmailList) {
      if (!emailAddrList.contains(pote.Email__c)) {
        emailAddrList.add(pote.Email__c);
      }
    }

    for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : piuaSpecialMobility2Notify) {
      // Check if the notification has been sent already for this passenger
      if (!mobilityPassengerSet.contains(piua.KaptioTravel__Passenger__c)) {
        if (mobilityCondition == 'with Visually Impaired') {
          htmlBody =
            'A guest in <b>' +
            piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.KaptioTravel__BookingNumber__c +
            '</b>, <b>' +
            piua.KaptioTravel__Passenger__r.KaptioTravel__LastName__c +
            ',' +
            piua.KaptioTravel__Passenger__r.KaptioTravel__FirstName__c +
            '</b> has been identified <b>' +
            mobilityCondition +
            '.';
        } else {
          htmlBody =
            'A guest in <b>' +
            piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.KaptioTravel__BookingNumber__c +
            '</b>, <b>' +
            piua.KaptioTravel__Passenger__r.KaptioTravel__LastName__c +
            ',' +
            piua.KaptioTravel__Passenger__r.KaptioTravel__FirstName__c +
            '</b> has been identified <b>' +
            mobilityCondition +
            '. The booking has not been seated.';
        }

        // add passenger Id to avoid duplicate email notification to the same passenger
        mobilityPassengerSet.add(piua.KaptioTravel__Passenger__c);

        // We instantiate our single email message object
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Assign the TO address to our mail object
        mail.setToAddresses(emailAddrList);

        // Set the subject line for your email address.
        mail.setSubject(subject);

        // You can set this to true if you want to BCC yourself on the email
        mail.setBccSender(false);

        // Specify any html body
        mail.setHtmlBody(htmlBody);

        // Add emails to the list
        lstMails.add(mail);
      }
    }

    // Send emails
    Messaging.sendEmail(lstMails);
  }
  // END - Tickets #31246 / #31251 /#33315

  // BEGINNING - Tickets #30718 - send email notification to Product Ops Team about special mobility condition
  /**
   * @description Send email notification to Product Ops Team about no bookings
   * @author Anusha Nelluri | 03-22-2023
   * @param train
   * @param Subject
   **/
  public void sendNoBookingsEmail(RM_ROS_IntegrationWrapper.TRAIN train, String Subject) {
    List<Seating_Tool_Product_Ops_Team_Email__mdt> prodOpsTeamEmailList = Seating_Tool_Product_Ops_Team_Email__mdt.getAll().values();
    List<String> emailAddrList = new List<String>();

    for (Seating_Tool_Product_Ops_Team_Email__mdt pote : prodOpsTeamEmailList) {
      if (!emailAddrList.contains(pote.Email__c)) {
        emailAddrList.add(pote.Email__c);
      }
    }

    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

    mail.setToAddresses(emailAddrList);

    mail.setSubject(subject);

    mail.setBccSender(false);

    String htmlBody =
      'An error occurred during Seating Tool process, no one has been seated: There are no bookings for <b>' +
      train.Train_Name +
      '</b>, ' +
      'on <b>' +
      train.Scheduled_Departure_Date +
      '</b>.';

    mail.setHtmlBody(htmlBody);

    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
  }
  // END - Ticket #30718

  // BEGINNING - Ticket #37921 - Added collection to all business methods in order to keep the same seat for all legs once that passengers is first seated
  /**
   * BEGINNING - Ticket #37923 - Added collection to all business methods in order to keep the same seat for all legs once that passengers is first seated
   * and other collection with available contiguous seat groups to seat bookings with the size less or equals than it
   **/
  // BEGINNING - Ticket #37921 / #31294 - Added logic to business methods and new methods to create fake/clone records to make as all legs have the respective PIUA record, but not seating those because it's not a database record
  // BEGINNING - Ticket #35471 - Added aux railcar seat parameters to this method and logic to sync occupied seats from both railcar seat maps
  // BEGINNING - Ticket #31236 - Fixed bug by assigning only the current PIUA in to the current seat which the loop is currently iterating
  // BEGINNING - Ticket #37881 - Fixed bug by assigning only the current PIUA in to the current seat which the loop is currently iterating
  /**
   * @description Seats piua records with bookings that has odd number of passengers and no linked itineraries
   * @author Anderson Morino | 03-22-2023
   * @param bookingPIUAListByItiItem
   * @param mapKeySet
   * @param railcarSeatMap
   * @param contiguousSeatsSizeMap
   * @param availableSeatsByRailcarId
   * @param piua2UpdateMap
   * @param wrappedItineraries
   * @param itiItemList
   * @param hasExecutedLAKGL
   * @param sizeOfPIUA2UpdateMap
   * @param itinerarySet
   * @param routeList
   * @return Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>
   **/
  public Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> processCouples(
    Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingPIUAListByItiItem,
    List<String> mapKeySet,
    Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper> railcarSeatMap,
    Map<String, RM_SeatingToolWrappers.RailcarWrapper> contiguousSeatsSizeMap,
    Map<String, RM_SeatingToolWrappers.RailcarWrapper> availableSeatsByRailcarId,
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap,
    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries,
    List<KaptioTravel__Itinerary_Item__c> itiItemList,
    Boolean hasExecutedLAKGL,
    Integer sizeOfPIUA2UpdateMap,
    Set<Id> itinerarySet,
    List<String> routeList,
    Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c> railcarIdByLAKGLBookingPIUAOver36
  ) {
    // BEGINNING - Ticket #30976 - map to keep the same seat number for all management legs
    Map<Id, RM_SeatingToolWrappers.RailcarSeatWrapper> railcarSeatInfoBySeatedPassengerId = new Map<Id, RM_SeatingToolWrappers.RailcarSeatWrapper>();
    // END - Ticket #30976

    Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c> piuaByKeyMap = createFakeBookingsWithPIUA(
      wrappedItineraries,
      itiItemList,
      bookingPIUAListByItiItem,
      routeList,
      piua2UpdateMap.size()
    );

    List<String> keyMapList = new List<String>(piuaByKeyMap.keySet());
    keyMapList.sort();

    for (Integer i = 0; i < keyMapList.size(); i++) {
      KaptioTravel__PassengerItineraryUnitAssignment__c piua = piuaByKeyMap.get(keyMapList[i]);

      if (bookingPIUAListByItiItem.containsKey(piua.KaptioTravel__ItineraryItem__c)) {
        bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).clear();
      }
    }

    for (Integer i = 0; i < keyMapList.size(); i++) {
      KaptioTravel__PassengerItineraryUnitAssignment__c piua = piuaByKeyMap.get(keyMapList[i]);

      if (
        bookingPIUAListByItiItem.containsKey(piua.KaptioTravel__ItineraryItem__c) &&
        !bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).contains(piua)
      ) {
        bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).add(piua);
      }
    }

    Map<String, KaptioTravel__Itinerary_Item__c> itiItemByKey = new Map<String, KaptioTravel__Itinerary_Item__c>();

    for (KaptioTravel__Itinerary_Item__c itiItem : itiItemList) {
      if (!itiItemByKey.containsKey(itiItem.KaptioTravel__Itinerary__c + '-' + itiItem.KaptioTravel__ExternalItemName__c)) {
        itiItemByKey.put(itiItem.KaptioTravel__Itinerary__c + '-' + itiItem.KaptioTravel__ExternalItemName__c, itiItem);
      }
    }

    List<String> sortedItiItemList = new List<String>(itiItemByKey.keySet());
    sortedItiItemList.sort();

    Map<String, List<String>> externalItemNameListByBooking = new Map<String, List<String>>();

    Iterator<String> itiItemKeySetIterator = sortedItiItemList.iterator();
    String nextItiItemMapKey = itiItemKeySetIterator.next();

    for (Integer k = 0; k < sortedItiItemList.size(); k++) {
      if (itiItemKeySetIterator.hasNext()) {
        nextItiItemMapKey = itiItemKeySetIterator.next();
      }

      if (
        (itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c != 'Kamloops to Vancouver' &&
        itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c != 'Vancouver to Kamloops') ||
        ((itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c == 'Vancouver to Kamloops' ||
        itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c == 'Kamloops to Vancouver') &&
        ((k > 0 &&
        itiItemByKey.get(nextItiItemMapKey).KaptioTravel__Itinerary__c != itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__c &&
        itiItemByKey.get(sortedItiItemList[k - 1]).KaptioTravel__Itinerary__c != itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__c) ||
        (k == 0 &&
        itiItemByKey.get(nextItiItemMapKey).KaptioTravel__Itinerary__c != itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__c) ||
        (itiItemByKey.size() == 1) ||
        (k == (sortedItiItemList.size() - 1) &&
        itiItemByKey.get(sortedItiItemList[k - 1]).KaptioTravel__Itinerary__c != itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__c)))
      ) {
        for (Integer i = 0; i < mapKeySet.size(); i++) {
          if (itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c == railcarSeatMap.get(mapKeySet[i]).route) {
            if (!externalItemNameListByBooking.containsKey(itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__c)) {
              externalItemNameListByBooking.put(
                itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__c,
                new List<String>{ railcarSeatMap.get(mapKeySet[i]).railcarId }
              );
            } else if (
              !externalItemNameListByBooking.get(itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__c)
                .contains(railcarSeatMap.get(mapKeySet[i]).railcarId)
            ) {
              externalItemNameListByBooking.get(itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__c)
                .add(railcarSeatMap.get(mapKeySet[i]).railcarId);
            }
          }
        }
      }
    }

    for (Integer j = 0; j < keyMapList.size(); j++) {
      KaptioTravel__PassengerItineraryUnitAssignment__c piua = piuaByKeyMap.get(keyMapList[j]);
      String room = piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c == null
        ? '00'
        : String.valueOf(piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c).length() == 1
            ? '0' + String.valueOf(piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c)
            : String.valueOf(piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c);
      Iterator<String> mapKeySetIterator = mapKeySet.iterator();
      String nextMapKey = mapKeySetIterator.next();
      if (piua.RailSeatNumber__c == null) {
        // Iterate railcarseats
        for (Integer i = 0; i < mapKeySet.size(); i++) {
          if (mapKeySetIterator.hasNext()) {
            nextMapKey = mapKeySetIterator.next();
          }

          if (
            !railcarSeatMap.get(mapKeySet[i]).occupied &&
            piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c == railcarSeatMap.get(mapKeySet[i]).route &&
            bookingPIUAListByItiItem.containsKey(piua.KaptioTravel__ItineraryItem__c) &&
            (bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size() <=
            availableSeatsByRailcarId.get(
                piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                '-' +
                railcarSeatMap.get(mapKeySet[i]).railcarId
              )
              .seatsCapacity ||
            (isLAKGLOver36Guests(
              routeList,
              piua,
              piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
              '-' +
              railcarSeatMap.get(mapKeySet[i]).railcarId,
              hasExecutedLAKGL,
              bookingPIUAListByItiItem,
              String.valueOf(piua.KaptioTravel__ItineraryItem__c),
              availableSeatsByRailcarId
            ))) &&
            contiguousSeatsSizeMap.containsKey(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey) &&
            bookingPIUAListByItiItem.containsKey(piua.KaptioTravel__ItineraryItem__c + '-' + room) &&
            bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size() <=
            contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey).sizeOfSeats &&
            externalItemNameListByBooking.containsKey(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c) &&
            externalItemNameListByBooking.get(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c)
              .contains(railcarSeatMap.get(mapKeySet[i]).railcarId)
          ) {
            // BEGINNING - Ticket #30976 - check if the map doesn't contain the passenger
            if (
              ((!railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c) &&
              bookingPIUAListByItiItem.containsKey(piua.KaptioTravel__ItineraryItem__c + '-' + room)) &&
              ((Math.mod(bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c + '-' + room).size(), 2) == 0 &&
              ((Math.mod(bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c + '-' + room).indexOf(piua), 2) == 0 &&
              mapKeySetIterator.hasNext() &&
              Integer.valueOf(railcarSeatMap.get(nextMapKey).railcarId) == Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarId) &&
              Integer.valueOf(railcarSeatMap.get(nextMapKey).railcarSeatId) == Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1 &&
              !railcarSeatMap.get(nextMapKey).occupied &&
              ((Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1, 2) == 0 &&
              Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1, 4) != 0) ||
              ((Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1, 4) == 0) &&
              (bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c + '-' + room).size() == 2 ||
              bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size() == 2 ||
              bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c + '-' + room).indexOf(piua) == 2)))) ||
              (Math.mod(bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c + '-' + room).indexOf(piua), 2) == 1 &&
              (i - 1) >= 0 &&
              railcarSeatMap.get(mapKeySet[i - 1]).assignedPIUA.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c ==
              piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c &&
              Integer.valueOf(railcarSeatMap.get(mapKeySet[i - 1]).railcarId) == Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarId) &&
              Integer.valueOf(railcarSeatMap.get(mapKeySet[i - 1]).railcarSeatId) ==
              Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) - 1 &&
              railcarSeatMap.get(mapKeySet[i - 1]).occupied &&
              railcarSeatMap.get(mapKeySet[i - 1]).assignedPIUA.KaptioTravel__ItineraryItem__c == piua.KaptioTravel__ItineraryItem__c &&
              ((Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId), 2) == 0 &&
              Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId), 4) != 0) ||
              ((Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId), 4) == 0) &&
              (bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c + '-' + room).size() == 2 ||
              bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size() == 2 ||
              bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c + '-' + room).indexOf(piua) == 3)))))) ||
              (bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c + '-' + room).size() == 3 &&
              ((bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c + '-' + room).indexOf(piua) == 0 &&
              mapKeySetIterator.hasNext() &&
              Integer.valueOf(railcarSeatMap.get(nextMapKey).railcarId) == Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarId) &&
              Integer.valueOf(railcarSeatMap.get(nextMapKey).railcarSeatId) == Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1 &&
              !railcarSeatMap.get(nextMapKey).occupied &&
              ((Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1, 2) == 0 &&
              Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1, 4) != 0) ||
              ((Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId), 2) == 0 &&
              Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId), 4) != 0) &&
              bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size() == 3))) ||
              (bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c + '-' + room).indexOf(piua) > 0 &&
              (i - 1) >= 0 &&
              railcarSeatMap.get(mapKeySet[i - 1]).assignedPIUA.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c ==
              piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c &&
              Integer.valueOf(railcarSeatMap.get(mapKeySet[i - 1]).railcarId) == Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarId) &&
              Integer.valueOf(railcarSeatMap.get(mapKeySet[i - 1]).railcarSeatId) ==
              Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) - 1 &&
              railcarSeatMap.get(mapKeySet[i - 1]).occupied &&
              railcarSeatMap.get(mapKeySet[i - 1]).assignedPIUA.KaptioTravel__ItineraryItem__c == piua.KaptioTravel__ItineraryItem__c))) ||
              (bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c + '-' + room).size() == 1 &&
              ((bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).indexOf(piua) == 0 &&
              mapKeySetIterator.hasNext() &&
              Integer.valueOf(railcarSeatMap.get(nextMapKey).railcarId) == Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarId) &&
              Integer.valueOf(railcarSeatMap.get(nextMapKey).railcarSeatId) == Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1 &&
              !railcarSeatMap.get(nextMapKey).occupied &&
              ((((Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1, 2) == 0 &&
              Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1, 4) != 0) ||
              (Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1, 4) == 0)) &&
              Math.mod(bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size(), 2) == 0 &&
              Math.mod(bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size(), 4) != 0) ||
              ((Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1, 2) == 0 &&
              Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1, 4) != 0) &&
              Math.mod(bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size(), 4) == 0))) ||
              (bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).indexOf(piua) > 0 &&
              (i - 1) >= 0 &&
              Integer.valueOf(railcarSeatMap.get(mapKeySet[i - 1]).railcarId) == Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarId) &&
              Integer.valueOf(railcarSeatMap.get(mapKeySet[i - 1]).railcarSeatId) ==
              Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) - 1 &&
              railcarSeatMap.get(mapKeySet[i - 1]).occupied &&
              railcarSeatMap.get(mapKeySet[i - 1]).assignedPIUA.KaptioTravel__ItineraryItem__c == piua.KaptioTravel__ItineraryItem__c))))) ||
              (railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c) &&
              railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarSeatId ==
              railcarSeatMap.get(mapKeySet[i]).railcarSeatId &&
              railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarId == railcarSeatMap.get(mapKeySet[i]).railcarId)
            ) {
              piua.RailCarNumber__c = !railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c)
                ? railcarSeatMap.get(mapKeySet[i]).railcarId
                : railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarId;
              piua.RailCarOrdinalNumber__c = !railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c)
                ? railcarSeatMap.get(mapKeySet[i]).railcarOrdinal
                : railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarOrdinal;
              piua.RailSeatNumber__c = !railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c)
                ? railcarSeatMap.get(mapKeySet[i]).railcarSeatId
                : railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarSeatId;
              piua2UpdateMap.put(piua.Id, piua);

              railcarSeatMap.get(mapKeySet[i]).occupied = true;
              railcarSeatMap.get(mapKeySet[i]).assignedPIUA = piua;
              if (!itinerarySet.contains(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c)) {
                itinerarySet.add(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c);
              }

              if (
                piua.Id ==
                bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c)
                  .get(bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size() - 1)
                  .Id
              ) {
                contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey)
                  .sizeOfSeats -= bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size();

                if (
                  !contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey)
                    .itiItemIds.contains(piua.KaptioTravel__ItineraryItem__c)
                ) {
                  contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey)
                    .itiItemIds.add(piua.KaptioTravel__ItineraryItem__c);
                }

                contiguousSeatsSizeMap = RM_SeatingTool_Utils.getContiguousRailcarSeatsSize(railcarSeatMap, mapKeySet, false, false);
              }

              if (
                piua.Id ==
                bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c)
                  .get(bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size() - 1)
                  .Id
              ) {
                availableSeatsByRailcarId.get(
                    piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                    '-' +
                    railcarSeatMap.get(mapKeySet[i]).railcarId
                  )
                  .seatsCapacity -= bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size();
                if (
                  !availableSeatsByRailcarId.get(
                      piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                      '-' +
                      railcarSeatMap.get(mapKeySet[i]).railcarId
                    )
                    .itiItemIds.contains(piua.KaptioTravel__ItineraryItem__c)
                ) {
                  availableSeatsByRailcarId.get(
                      piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                      '-' +
                      railcarSeatMap.get(mapKeySet[i]).railcarId
                    )
                    .itiItemIds.add(piua.KaptioTravel__ItineraryItem__c);
                }
              }

              // BEGINNING - Ticket #30976 - put the passenger as key and its seat assignment information
              // BEGINNING - Ticket #32131 - Changed from getting updated piua values to get values from the map
              if (!railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c)) {
                railcarSeatInfoBySeatedPassengerId.put(
                  piua.KaptioTravel__Passenger__c,
                  new RM_SeatingToolWrappers.RailcarSeatWrapper(
                    railcarSeatMap.get(mapKeySet[i]).railcarId,
                    railcarSeatMap.get(mapKeySet[i]).railcarOrdinal,
                    railcarSeatMap.get(mapKeySet[i]).railcarSeatId
                  )
                );
              }
              // END - Ticket #32131
              // END - Ticket #30976

              if (
                isLAKGLOver36Guests(
                  routeList,
                  piua,
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                  '-' +
                  railcarSeatMap.get(mapKeySet[i]).railcarId,
                  hasExecutedLAKGL,
                  bookingPIUAListByItiItem,
                  String.valueOf(piua.KaptioTravel__ItineraryItem__c),
                  availableSeatsByRailcarId
                ) && !railcarIdByLAKGLBookingPIUAOver36.containsKey(piua.Id)
              ) {
                railcarIdByLAKGLBookingPIUAOver36.put(piua.Id, piua);
              }

              break;
            }
          }
        }
      }
    }

    return piua2UpdateMap;
  }
  // END - Ticket #37881
  // END - Ticket #31236
  // END - Ticket #35471

  // BEGINNING - Ticket #31250 - seats piua records with bookings that has a odd number of passengers and no linked itineraries
  // BEGINNING - Ticket #35471 - Added aux railcar seat parameters to this method and logic to sync occupied seats from both railcar seat maps
  /**
   * @description Seats piua records with bookings that has a odd number of passengers and no linked itineraries
   * @author Anderson Morino | 03-22-2023
   * @param bookingPIUAListByItiItem
   * @param mapKeySet
   * @param railcarSeatMap
   * @param contiguousSeatsSizeMap
   * @param availableSeatsByRailcarId
   * @param piua2UpdateMap
   * @param wrappedItineraries
   * @param itiItemList
   * @param hasExecutedLAKGL
   * @param sizeOfPIUA2UpdateMap
   * @param itinerarySet
   * @param routeList
   * @return Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>
   **/
  public Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> processOddsNumber(
    Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingPIUAListByItiItem,
    List<String> mapKeySet,
    Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper> railcarSeatMap,
    Map<String, RM_SeatingToolWrappers.RailcarWrapper> contiguousSeatsSizeMap,
    Map<String, RM_SeatingToolWrappers.RailcarWrapper> availableSeatsByRailcarId,
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap,
    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries,
    List<KaptioTravel__Itinerary_Item__c> itiItemList,
    Boolean hasExecutedLAKGL,
    Integer sizeOfPIUA2UpdateMap,
    Set<Id> itinerarySet,
    List<String> routeList,
    Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c> railcarIdByLAKGLBookingPIUAOver36
  ) {
    Map<Id, RM_SeatingToolWrappers.RailcarSeatWrapper> railcarSeatInfoBySeatedPassengerId = new Map<Id, RM_SeatingToolWrappers.RailcarSeatWrapper>();

    Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c> piuaByKeyMap = createFakeBookingsWithPIUA(
      wrappedItineraries,
      itiItemList,
      bookingPIUAListByItiItem,
      routeList,
      piua2UpdateMap.size()
    );

    List<String> keyMapList = new List<String>(piuaByKeyMap.keySet());
    keyMapList.sort();

    for (Integer i = 0; i < keyMapList.size(); i++) {
      KaptioTravel__PassengerItineraryUnitAssignment__c piua = piuaByKeyMap.get(keyMapList[i]);

      if (bookingPIUAListByItiItem.containsKey(piua.KaptioTravel__ItineraryItem__c)) {
        bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).clear();
      }
    }

    for (Integer i = 0; i < keyMapList.size(); i++) {
      KaptioTravel__PassengerItineraryUnitAssignment__c piua = piuaByKeyMap.get(keyMapList[i]);

      if (
        bookingPIUAListByItiItem.containsKey(piua.KaptioTravel__ItineraryItem__c) &&
        !bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).contains(piua)
      ) {
        bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).add(piua);
      }
    }

    Map<String, KaptioTravel__Itinerary_Item__c> itiItemByKey = new Map<String, KaptioTravel__Itinerary_Item__c>();

    for (KaptioTravel__Itinerary_Item__c itiItem : itiItemList) {
      if (!itiItemByKey.containsKey(itiItem.KaptioTravel__Itinerary__c + '-' + itiItem.KaptioTravel__ExternalItemName__c)) {
        itiItemByKey.put(itiItem.KaptioTravel__Itinerary__c + '-' + itiItem.KaptioTravel__ExternalItemName__c, itiItem);
      }
    }

    List<String> sortedItiItemList = new List<String>(itiItemByKey.keySet());
    sortedItiItemList.sort();

    Map<String, List<String>> externalItemNameListByBooking = new Map<String, List<String>>();

    Iterator<String> itiItemKeySetIterator = sortedItiItemList.iterator();
    String nextItiItemMapKey = itiItemKeySetIterator.next();

    for (Integer k = 0; k < sortedItiItemList.size(); k++) {
      if (itiItemKeySetIterator.hasNext()) {
        nextItiItemMapKey = itiItemKeySetIterator.next();
      }

      if (
        (itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c != 'Kamloops to Vancouver' &&
        itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c != 'Vancouver to Kamloops') ||
        ((itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c == 'Vancouver to Kamloops' ||
        itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c == 'Kamloops to Vancouver') &&
        ((k > 0 &&
        itiItemByKey.get(nextItiItemMapKey).KaptioTravel__Itinerary__c != itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__c &&
        itiItemByKey.get(sortedItiItemList[k - 1]).KaptioTravel__Itinerary__c != itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__c) ||
        (k == 0 &&
        itiItemByKey.get(nextItiItemMapKey).KaptioTravel__Itinerary__c != itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__c) ||
        (itiItemByKey.size() == 1) ||
        (k == (sortedItiItemList.size() - 1) &&
        itiItemByKey.get(sortedItiItemList[k - 1]).KaptioTravel__Itinerary__c != itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__c)))
      ) {
        for (Integer i = 0; i < mapKeySet.size(); i++) {
          if (itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c == railcarSeatMap.get(mapKeySet[i]).route) {
            if (!externalItemNameListByBooking.containsKey(itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__c)) {
              externalItemNameListByBooking.put(
                itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__c,
                new List<String>{ railcarSeatMap.get(mapKeySet[i]).railcarId }
              );
            } else if (
              !externalItemNameListByBooking.get(itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__c)
                .contains(railcarSeatMap.get(mapKeySet[i]).railcarId)
            ) {
              externalItemNameListByBooking.get(itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__c)
                .add(railcarSeatMap.get(mapKeySet[i]).railcarId);
            }
          }
        }
      }
    }

    for (Integer j = 0; j < keyMapList.size(); j++) {
      KaptioTravel__PassengerItineraryUnitAssignment__c piua = piuaByKeyMap.get(keyMapList[j]);
      String room = piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c == null
        ? '00'
        : String.valueOf(piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c).length() == 1
            ? '0' + String.valueOf(piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c)
            : String.valueOf(piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c);
      Iterator<String> mapKeySetIterator = mapKeySet.iterator();
      String nextMapKey = mapKeySetIterator.next();
      if (piua.RailSeatNumber__c == null) {
        // Iterate railcarseats
        for (Integer i = 0; i < mapKeySet.size(); i++) {
          if (mapKeySetIterator.hasNext()) {
            nextMapKey = mapKeySetIterator.next();
          }

          if (
            !railcarSeatMap.get(mapKeySet[i]).occupied &&
            piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c == railcarSeatMap.get(mapKeySet[i]).route &&
            bookingPIUAListByItiItem.containsKey(piua.KaptioTravel__ItineraryItem__c) &&
            (bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size() <=
            availableSeatsByRailcarId.get(
                piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                '-' +
                railcarSeatMap.get(mapKeySet[i]).railcarId
              )
              .seatsCapacity ||
            (isLAKGLOver36Guests(
              routeList,
              piua,
              piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
              '-' +
              railcarSeatMap.get(mapKeySet[i]).railcarId,
              hasExecutedLAKGL,
              bookingPIUAListByItiItem,
              String.valueOf(piua.KaptioTravel__ItineraryItem__c),
              availableSeatsByRailcarId
            ))) &&
            contiguousSeatsSizeMap.containsKey(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey) &&
            bookingPIUAListByItiItem.containsKey(piua.KaptioTravel__ItineraryItem__c + '-' + room) &&
            bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size() <=
            ((bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).indexOf(piua) == 0 &&
              contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey).railcarSeatLetter == 'B' &&
              bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size() > 3 &&
              Math.mod((bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size() - 3), 4) != 0)
              ? (contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey).sizeOfSeats - 3)
              : (bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).indexOf(piua) == 0 &&
                  contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey).railcarSeatLetter == 'C' &&
                  bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size() > 2 &&
                  Math.mod((bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size() - 2), 4) != 0)
                  ? (contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey).sizeOfSeats - 2)
                  : (bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).indexOf(piua) == 0 &&
                      contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey).railcarSeatLetter == 'D' &&
                      bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size() > 1)
                      ? (contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey).sizeOfSeats - 1)
                      : contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey).sizeOfSeats) &&
            externalItemNameListByBooking.containsKey(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c) &&
            externalItemNameListByBooking.get(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c)
              .contains(railcarSeatMap.get(mapKeySet[i]).railcarId)
          ) {
            // BEGINNING - Ticket #30976 - check if the map doesn't contain the passenger
            if (
              ((!railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c) &&
              bookingPIUAListByItiItem.containsKey(piua.KaptioTravel__ItineraryItem__c + '-' + room)) &&
              ((Math.mod(bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c + '-' + room).size(), 2) == 0 &&
              ((Math.mod(bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c + '-' + room).indexOf(piua), 2) == 0 &&
              mapKeySetIterator.hasNext() &&
              Integer.valueOf(railcarSeatMap.get(nextMapKey).railcarId) == Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarId) &&
              Integer.valueOf(railcarSeatMap.get(nextMapKey).railcarSeatId) == Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1 &&
              !railcarSeatMap.get(nextMapKey).occupied &&
              ((Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1, 2) == 0 &&
              Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1, 4) != 0) ||
              ((Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1, 4) == 0) &&
              (bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c + '-' + room).size() == 2 ||
              bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c + '-' + room).indexOf(piua) == 2)))) ||
              (Math.mod(bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c + '-' + room).indexOf(piua), 2) == 1 &&
              (i - 1) >= 0 &&
              railcarSeatMap.get(mapKeySet[i - 1]).assignedPIUA.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c ==
              piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c &&
              Integer.valueOf(railcarSeatMap.get(mapKeySet[i - 1]).railcarId) == Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarId) &&
              Integer.valueOf(railcarSeatMap.get(mapKeySet[i - 1]).railcarSeatId) ==
              Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) - 1 &&
              railcarSeatMap.get(mapKeySet[i - 1]).occupied &&
              railcarSeatMap.get(mapKeySet[i - 1]).assignedPIUA.KaptioTravel__ItineraryItem__c == piua.KaptioTravel__ItineraryItem__c &&
              ((Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId), 2) == 0 &&
              Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId), 4) != 0) ||
              ((Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId), 4) == 0) &&
              (bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c + '-' + room).size() == 2 ||
              bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c + '-' + room).indexOf(piua) == 3)))))) ||
              (bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c + '-' + room).size() == 3 &&
              ((bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c + '-' + room).indexOf(piua) == 0 &&
              mapKeySetIterator.hasNext() &&
              Integer.valueOf(railcarSeatMap.get(nextMapKey).railcarId) == Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarId) &&
              Integer.valueOf(railcarSeatMap.get(nextMapKey).railcarSeatId) == Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1 &&
              !railcarSeatMap.get(nextMapKey).occupied &&
              ((Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1, 2) == 0 &&
              Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1, 4) != 0) ||
              ((Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId), 2) == 0 &&
              Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId), 4) != 0) &&
              bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size() == 3))) ||
              (bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c + '-' + room).indexOf(piua) > 0 &&
              (i - 1) >= 0 &&
              railcarSeatMap.get(mapKeySet[i - 1]).assignedPIUA.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c ==
              piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c &&
              Integer.valueOf(railcarSeatMap.get(mapKeySet[i - 1]).railcarId) == Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarId) &&
              Integer.valueOf(railcarSeatMap.get(mapKeySet[i - 1]).railcarSeatId) ==
              Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) - 1 &&
              railcarSeatMap.get(mapKeySet[i - 1]).occupied &&
              railcarSeatMap.get(mapKeySet[i - 1]).assignedPIUA.KaptioTravel__ItineraryItem__c == piua.KaptioTravel__ItineraryItem__c))) ||
              (bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c + '-' + room).size() == 1 &&
              ((bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).indexOf(piua) == 0 &&
              mapKeySetIterator.hasNext() &&
              Integer.valueOf(railcarSeatMap.get(nextMapKey).railcarId) == Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarId) &&
              Integer.valueOf(railcarSeatMap.get(nextMapKey).railcarSeatId) == Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1 &&
              !railcarSeatMap.get(nextMapKey).occupied &&
              (Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId), 2) == 0 &&
              Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId), 4) != 0)) ||
              (bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).indexOf(piua) > 0 &&
              ((mapKeySetIterator.hasNext() &&
              Integer.valueOf(railcarSeatMap.get(nextMapKey).railcarId) == Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarId) &&
              Integer.valueOf(railcarSeatMap.get(nextMapKey).railcarSeatId) == Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1 &&
              railcarSeatMap.get(nextMapKey).assignedPIUA.KaptioTravel__ItineraryItem__c == piua.KaptioTravel__ItineraryItem__c) ||
              ((i - 1) >= 0 &&
              Integer.valueOf(railcarSeatMap.get(mapKeySet[i - 1]).railcarId) == Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarId) &&
              Integer.valueOf(railcarSeatMap.get(mapKeySet[i - 1]).railcarSeatId) ==
              Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) - 1 &&
              railcarSeatMap.get(mapKeySet[i - 1]).occupied &&
              railcarSeatMap.get(mapKeySet[i - 1]).assignedPIUA.KaptioTravel__ItineraryItem__c == piua.KaptioTravel__ItineraryItem__c))))))) ||
              (railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c) &&
              railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarSeatId ==
              railcarSeatMap.get(mapKeySet[i]).railcarSeatId &&
              railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarId == railcarSeatMap.get(mapKeySet[i]).railcarId)
            ) {
              piua.RailCarNumber__c = !railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c)
                ? railcarSeatMap.get(mapKeySet[i]).railcarId
                : railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarId;
              piua.RailCarOrdinalNumber__c = !railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c)
                ? railcarSeatMap.get(mapKeySet[i]).railcarOrdinal
                : railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarOrdinal;
              piua.RailSeatNumber__c = !railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c)
                ? railcarSeatMap.get(mapKeySet[i]).railcarSeatId
                : railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarSeatId;
              piua2UpdateMap.put(piua.Id, piua);

              railcarSeatMap.get(mapKeySet[i]).occupied = true;
              railcarSeatMap.get(mapKeySet[i]).assignedPIUA = piua;
              if (!itinerarySet.contains(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c)) {
                itinerarySet.add(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c);
              }

              if (
                piua.Id ==
                bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c)
                  .get(bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size() - 1)
                  .Id
              ) {
                contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey)
                  .sizeOfSeats -= bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size();

                if (
                  !contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey)
                    .itiItemIds.contains(piua.KaptioTravel__ItineraryItem__c)
                ) {
                  contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey)
                    .itiItemIds.add(piua.KaptioTravel__ItineraryItem__c);
                }

                contiguousSeatsSizeMap = RM_SeatingTool_Utils.getContiguousRailcarSeatsSize(railcarSeatMap, mapKeySet, false, false);
              }

              if (
                piua.Id ==
                bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c)
                  .get(bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size() - 1)
                  .Id
              ) {
                availableSeatsByRailcarId.get(
                    piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                    '-' +
                    railcarSeatMap.get(mapKeySet[i]).railcarId
                  )
                  .seatsCapacity -= bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size();
                if (
                  !availableSeatsByRailcarId.get(
                      piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                      '-' +
                      railcarSeatMap.get(mapKeySet[i]).railcarId
                    )
                    .itiItemIds.contains(piua.KaptioTravel__ItineraryItem__c)
                ) {
                  availableSeatsByRailcarId.get(
                      piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                      '-' +
                      railcarSeatMap.get(mapKeySet[i]).railcarId
                    )
                    .itiItemIds.add(piua.KaptioTravel__ItineraryItem__c);
                }
              }

              // BEGINNING - Ticket #30976 - put the passenger as key and its seat assignment information
              // BEGINNING - Ticket #32131 - Changed from getting updated piua values to get values from the map
              if (!railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c)) {
                railcarSeatInfoBySeatedPassengerId.put(
                  piua.KaptioTravel__Passenger__c,
                  new RM_SeatingToolWrappers.RailcarSeatWrapper(
                    railcarSeatMap.get(mapKeySet[i]).railcarId,
                    railcarSeatMap.get(mapKeySet[i]).railcarOrdinal,
                    railcarSeatMap.get(mapKeySet[i]).railcarSeatId
                  )
                );
              }
              // END - Ticket #32131
              // END - Ticket #30976

              if (
                isLAKGLOver36Guests(
                  routeList,
                  piua,
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                  '-' +
                  railcarSeatMap.get(mapKeySet[i]).railcarId,
                  hasExecutedLAKGL,
                  bookingPIUAListByItiItem,
                  String.valueOf(piua.KaptioTravel__ItineraryItem__c),
                  availableSeatsByRailcarId
                ) && !railcarIdByLAKGLBookingPIUAOver36.containsKey(piua.Id)
              ) {
                railcarIdByLAKGLBookingPIUAOver36.put(piua.Id, piua);
              }

              break;
            }
          }
        }
      }
    }

    return piua2UpdateMap;
  }
  // END - Ticket #35471
  // END - Ticket #31250

  // BEGINNING - Ticket #35471 - Added aux railcar seat parameters to this method and logic to sync occupied seats from both railcar seat maps
  // BEGINNING - Ticket #37882 - Added collection with available contiguous seat groups to seat linked bookings with the size less or equals than it
  // BEGINNING - Ticket #33366 - Fixed bug to keep linked bookings seated together
  /**
   * @description Seats piua records with linked itineraries AKA bookings
   * @author Anderson Morino | 03-22-2023
   * @param bookingPIUAListByItiItem
   * @param mapKeySet
   * @param railcarSeatMap
   * @param contiguousSeatsSizeMap
   * @param availableSeatsByRailcarId
   * @param piua2UpdateMap
   * @param wrappedItineraries
   * @param itiItemList
   * @param hasExecutedLAKGL
   * @param sizeOfPIUA2UpdateMap
   * @param linkedItinerarySet
   * @param routeList
   * @return Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>
   **/
  public Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> processLinkedItineraries(
    Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingPIUAListByItiItem,
    List<String> mapKeySet,
    Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper> railcarSeatMap,
    Map<String, RM_SeatingToolWrappers.RailcarWrapper> contiguousSeatsSizeMap,
    Map<String, RM_SeatingToolWrappers.RailcarWrapper> availableSeatsByRailcarId,
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap,
    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries,
    List<KaptioTravel__Itinerary_Item__c> itiItemList,
    Boolean hasExecutedLAKGL,
    Integer sizeOfPIUA2UpdateMap,
    Set<Id> linkedItinerarySet,
    List<String> routeList,
    Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c> railcarIdByLAKGLBookingPIUAOver36
  ) {
    // BEGINNING - Ticket #30976 - map to keep the same seat number for all management legs
    Map<Id, RM_SeatingToolWrappers.RailcarSeatWrapper> railcarSeatInfoBySeatedPassengerId = new Map<Id, RM_SeatingToolWrappers.RailcarSeatWrapper>();
    // END - Ticket #30976

    Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c> piuaByKeyMap = sortPIUAList(bookingPIUAListByItiItem, routeList, true);

    List<String> keyMapList = new List<String>(piuaByKeyMap.keySet());
    keyMapList.sort();

    for (Integer i = 0; i < keyMapList.size(); i++) {
      KaptioTravel__PassengerItineraryUnitAssignment__c piua = piuaByKeyMap.get(keyMapList[i]);

      if (
        bookingPIUAListByItiItem.containsKey(
          piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
          '-' +
          piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
        )
      ) {
        bookingPIUAListByItiItem.get(
            piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
            '-' +
            piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
          )
          .clear();
      }
    }

    for (Integer i = 0; i < keyMapList.size(); i++) {
      KaptioTravel__PassengerItineraryUnitAssignment__c piua = piuaByKeyMap.get(keyMapList[i]);

      if (
        bookingPIUAListByItiItem.containsKey(
          piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
          '-' +
          piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
        ) &&
        !bookingPIUAListByItiItem.get(
            piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
            '-' +
            piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
          )
          .contains(piua)
      ) {
        bookingPIUAListByItiItem.get(
            piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
            '-' +
            piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
          )
          .add(piua);
      }
    }

    Map<String, KaptioTravel__Itinerary_Item__c> itiItemByKey = new Map<String, KaptioTravel__Itinerary_Item__c>();

    for (KaptioTravel__Itinerary_Item__c itiItem : itiItemList) {
      if (!itiItemByKey.containsKey(itiItem.KaptioTravel__Itinerary__r.LinkedItinerary__c + '-' + itiItem.KaptioTravel__ExternalItemName__c)) {
        itiItemByKey.put(itiItem.KaptioTravel__Itinerary__r.LinkedItinerary__c + '-' + itiItem.KaptioTravel__ExternalItemName__c, itiItem);
      }
    }

    List<String> sortedItiItemList = new List<String>(itiItemByKey.keySet());
    sortedItiItemList.sort();

    Map<String, List<String>> externalItemNameListByBooking = new Map<String, List<String>>();

    Iterator<String> itiItemKeySetIterator = sortedItiItemList.iterator();
    String nextItiItemMapKey = itiItemKeySetIterator.next();

    for (Integer k = 0; k < sortedItiItemList.size(); k++) {
      if (itiItemKeySetIterator.hasNext()) {
        nextItiItemMapKey = itiItemKeySetIterator.next();
      }

      if (
        (itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c != 'Kamloops to Vancouver' &&
        itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c != 'Vancouver to Kamloops') ||
        ((itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c == 'Vancouver to Kamloops' ||
        itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c == 'Kamloops to Vancouver') &&
        ((k > 0 &&
        itiItemByKey.get(nextItiItemMapKey).KaptioTravel__Itinerary__r.LinkedItinerary__c !=
        itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__r.LinkedItinerary__c &&
        itiItemByKey.get(sortedItiItemList[k - 1]).KaptioTravel__Itinerary__r.LinkedItinerary__c !=
        itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__r.LinkedItinerary__c) ||
        (k == 0 &&
        itiItemByKey.get(nextItiItemMapKey).KaptioTravel__Itinerary__r.LinkedItinerary__c !=
        itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__r.LinkedItinerary__c) ||
        (itiItemByKey.size() == 1) ||
        (k == (sortedItiItemList.size() - 1) &&
        itiItemByKey.get(sortedItiItemList[k - 1]).KaptioTravel__Itinerary__r.LinkedItinerary__c !=
        itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__r.LinkedItinerary__c)))
      ) {
        for (Integer i = 0; i < mapKeySet.size(); i++) {
          if (itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c == railcarSeatMap.get(mapKeySet[i]).route) {
            if (!externalItemNameListByBooking.containsKey(itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__r.LinkedItinerary__c)) {
              externalItemNameListByBooking.put(
                itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__r.LinkedItinerary__c,
                new List<String>{ railcarSeatMap.get(mapKeySet[i]).railcarId }
              );
            } else if (
              !externalItemNameListByBooking.get(itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__r.LinkedItinerary__c)
                .contains(railcarSeatMap.get(mapKeySet[i]).railcarId)
            ) {
              externalItemNameListByBooking.get(itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__r.LinkedItinerary__c)
                .add(railcarSeatMap.get(mapKeySet[i]).railcarId);
            }
          }
        }
      }
    }

    for (Integer j = 0; j < keyMapList.size(); j++) {
      KaptioTravel__PassengerItineraryUnitAssignment__c piua = piuaByKeyMap.get(keyMapList[j]);
      Iterator<String> mapKeySetIterator = mapKeySet.iterator();
      String nextMapKey = mapKeySetIterator.next();
      if (piua.RailSeatNumber__c == null) {
        // Iterate railcarseats
        for (Integer i = 0; i < mapKeySet.size(); i++) {
          if (mapKeySetIterator.hasNext()) {
            nextMapKey = mapKeySetIterator.next();
          }

          if (
            !railcarSeatMap.get(mapKeySet[i]).occupied &&
            piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c == railcarSeatMap.get(mapKeySet[i]).route &&
            bookingPIUAListByItiItem.containsKey(
              piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
              '-' +
              piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
            ) &&
            (bookingPIUAListByItiItem.get(
                piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                '-' +
                piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
              )
              .size() <=
            availableSeatsByRailcarId.get(
                piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                '-' +
                railcarSeatMap.get(mapKeySet[i]).railcarId
              )
              .seatsCapacity ||
            (isLAKGLOver36Guests(
              routeList,
              piua,
              piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
              '-' +
              railcarSeatMap.get(mapKeySet[i]).railcarId,
              hasExecutedLAKGL,
              bookingPIUAListByItiItem,
              piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
              '-' +
              String.valueOf(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c),
              availableSeatsByRailcarId
            ))) &&
            contiguousSeatsSizeMap.containsKey(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey) &&
            bookingPIUAListByItiItem.get(
                piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                '-' +
                piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
              )
              .size() <=
            ((bookingPIUAListByItiItem.get(
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                  '-' +
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                )
                .indexOf(piua) == 0 &&
              contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey).railcarSeatLetter == 'B' &&
              bookingPIUAListByItiItem.get(
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                  '-' +
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                )
                .size() > 3 &&
              Math.mod(
                (bookingPIUAListByItiItem.get(
                    piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                    '-' +
                    piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                  )
                  .size() - 3),
                4
              ) != 0)
              ? (contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey).sizeOfSeats - 3)
              : (bookingPIUAListByItiItem.get(
                      piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                      '-' +
                      piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                    )
                    .indexOf(piua) == 0 &&
                  contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey).railcarSeatLetter == 'C' &&
                  bookingPIUAListByItiItem.get(
                      piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                      '-' +
                      piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                    )
                    .size() > 2 &&
                  Math.mod(
                    (bookingPIUAListByItiItem.get(
                        piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                        '-' +
                        piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                      )
                      .size() - 2),
                    4
                  ) != 0)
                  ? (contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey).sizeOfSeats - 2)
                  : (bookingPIUAListByItiItem.get(
                          piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                          '-' +
                          piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                        )
                        .indexOf(piua) == 0 &&
                      contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey).railcarSeatLetter == 'D' &&
                      bookingPIUAListByItiItem.get(
                          piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                          '-' +
                          piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                        )
                        .size() > 1)
                      ? (contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey).sizeOfSeats - 1)
                      : contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey).sizeOfSeats) &&
            externalItemNameListByBooking.containsKey(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c) &&
            externalItemNameListByBooking.get(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c)
              .contains(railcarSeatMap.get(mapKeySet[i]).railcarId)
          ) {
            if (
              (!railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c) &&
              ((bookingPIUAListByItiItem.get(
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                  '-' +
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                )
                .indexOf(piua) == 0 &&
              mapKeySetIterator.hasNext() &&
              Integer.valueOf(railcarSeatMap.get(nextMapKey).railcarId) == Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarId) &&
              Integer.valueOf(railcarSeatMap.get(nextMapKey).railcarSeatId) == Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1 &&
              !railcarSeatMap.get(nextMapKey).occupied &&
              ((Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1, 2) == 0 &&
              Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1, 4) != 0) ||
              (bookingPIUAListByItiItem.get(
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                  '-' +
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                )
                .size() >= 4 ||
              bookingPIUAListByItiItem.get(
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                  '-' +
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                )
                .size() == 1) ||
              ((Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId), 2) == 0 &&
              Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId), 4) != 0) &&
              bookingPIUAListByItiItem.get(
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                  '-' +
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                )
                .size() == 3) ||
              (Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1, 4) == 0 &&
              bookingPIUAListByItiItem.get(
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                  '-' +
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                )
                .size() == 2))) ||
              (bookingPIUAListByItiItem.get(
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                  '-' +
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                )
                .indexOf(piua) > 0 &&
              (i - 1) >= 0 &&
              Integer.valueOf(railcarSeatMap.get(mapKeySet[i - 1]).railcarId) == Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarId) &&
              Integer.valueOf(railcarSeatMap.get(mapKeySet[i - 1]).railcarSeatId) ==
              Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) - 1 &&
              railcarSeatMap.get(mapKeySet[i - 1]).occupied &&
              railcarSeatMap.get(mapKeySet[i - 1]).assignedPIUA.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c ==
              piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c &&
              ((((Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId), 2) == 0 &&
              Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId), 4) != 0) ||
              (Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId), 4) == 0)) &&
              bookingPIUAListByItiItem.get(
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                  '-' +
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                )
                .size() == 2) ||
              (((Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId), 2) == 0 &&
              Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId), 4) != 0) ||
              (Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1, 4) == 0) ||
              (Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId), 4) == 0)) &&
              bookingPIUAListByItiItem.get(
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                  '-' +
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                )
                .size() == 3) ||
              (bookingPIUAListByItiItem.get(
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                  '-' +
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                )
                .size() >= 4))))) ||
              (railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c) &&
              railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarSeatId ==
              railcarSeatMap.get(mapKeySet[i]).railcarSeatId &&
              railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarId == railcarSeatMap.get(mapKeySet[i]).railcarId)
            ) {
              piua.RailCarNumber__c = !railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c)
                ? railcarSeatMap.get(mapKeySet[i]).railcarId
                : railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarId;
              piua.RailCarOrdinalNumber__c = !railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c)
                ? railcarSeatMap.get(mapKeySet[i]).railcarOrdinal
                : railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarOrdinal;
              piua.RailSeatNumber__c = !railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c)
                ? railcarSeatMap.get(mapKeySet[i]).railcarSeatId
                : railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarSeatId;
              piua2UpdateMap.put(piua.Id, piua);

              railcarSeatMap.get(mapKeySet[i]).occupied = true;
              railcarSeatMap.get(mapKeySet[i]).assignedPIUA = piua;
              if (!linkedItinerarySet.contains(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c)) {
                linkedItinerarySet.add(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c);
              }

              if (
                piua.Id ==
                bookingPIUAListByItiItem.get(
                    piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                    '-' +
                    piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                  )
                  .get(
                    bookingPIUAListByItiItem.get(
                        piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                        '-' +
                        piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                      )
                      .size() - 1
                  )
                  .Id
              ) {
                contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey)
                  .sizeOfSeats -= bookingPIUAListByItiItem.get(
                    piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                    '-' +
                    piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                  )
                  .size();

                if (
                  !contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey)
                    .itiItemIds.contains(
                      piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                      '-' +
                      piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                    )
                ) {
                  contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey)
                    .itiItemIds.add(
                      piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                      '-' +
                      piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                    );
                }

                contiguousSeatsSizeMap = RM_SeatingTool_Utils.getContiguousRailcarSeatsSize(railcarSeatMap, mapKeySet, false, false);
              }

              if (
                piua.Id ==
                bookingPIUAListByItiItem.get(
                    piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                    '-' +
                    piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                  )
                  .get(
                    bookingPIUAListByItiItem.get(
                        piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                        '-' +
                        piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                      )
                      .size() - 1
                  )
                  .Id
              ) {
                availableSeatsByRailcarId.get(
                    piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                    '-' +
                    railcarSeatMap.get(mapKeySet[i]).railcarId
                  )
                  .seatsCapacity -= bookingPIUAListByItiItem.get(
                    piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                    '-' +
                    piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                  )
                  .size();
                if (
                  !availableSeatsByRailcarId.get(
                      piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                      '-' +
                      railcarSeatMap.get(mapKeySet[i]).railcarId
                    )
                    .itiItemIds.contains(
                      piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                      '-' +
                      piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                    )
                ) {
                  availableSeatsByRailcarId.get(
                      piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                      '-' +
                      railcarSeatMap.get(mapKeySet[i]).railcarId
                    )
                    .itiItemIds.add(
                      piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                      '-' +
                      piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                    );
                }
              }

              // BEGINNING - Ticket #30976 - put the passenger as key and its seat assignment information
              // BEGINNING - Ticket #32131 - Changed from getting updated piua values to get values from the map
              if (!railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c)) {
                railcarSeatInfoBySeatedPassengerId.put(
                  piua.KaptioTravel__Passenger__c,
                  new RM_SeatingToolWrappers.RailcarSeatWrapper(
                    railcarSeatMap.get(mapKeySet[i]).railcarId,
                    railcarSeatMap.get(mapKeySet[i]).railcarOrdinal,
                    railcarSeatMap.get(mapKeySet[i]).railcarSeatId
                  )
                );
              }
              // END - Ticket #32131
              // END - Ticket #30976

              if (
                isLAKGLOver36Guests(
                  routeList,
                  piua,
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                  '-' +
                  railcarSeatMap.get(mapKeySet[i]).railcarId,
                  hasExecutedLAKGL,
                  bookingPIUAListByItiItem,
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                  '-' +
                  String.valueOf(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c),
                  availableSeatsByRailcarId
                ) && !railcarIdByLAKGLBookingPIUAOver36.containsKey(piua.Id)
              ) {
                railcarIdByLAKGLBookingPIUAOver36.put(piua.Id, piua);
              }

              break;
            }
          }
        }
      }
    }
    return piua2UpdateMap;
  }
  // END - Ticket #37882
  // END - Ticket #35471

  // BEGINNING - Ticket #35471 - Added aux railcar seat parameters to this method and logic to sync occupied seats from both railcar seat maps
  /**
   * @description Seats bookings with more than a mobility guest
   * @author Anderson Morino | 03-22-2023
   * @param bookingPIUAListByItiItem
   * @param mapKeySet
   * @param railcarSeatMap
   * @param availableSeatsByRailcarId
   * @param batchHelper
   * @param piua2UpdateMap
   * @param wrappedItineraries
   * @param itiItemList
   * @param hasExecutedLAKGL
   * @param hasExecutedCJ
   * @param hasExecutedGL
   * @param sizeOfPIUA2UpdateMap
   * @param itinerarySet
   * @param routeList
   * @param isLinked
   * @return Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>
   **/
  public Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> processMobilityPIUAGroup(
    Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingPIUAListByItiItem,
    List<String> mapKeySet,
    Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper> railcarSeatMap,
    Map<String, RM_SeatingToolWrappers.RailcarWrapper> availableSeatsByRailcarId,
    RM_SeatingToolBatchHelper batchHelper,
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap,
    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries,
    List<KaptioTravel__Itinerary_Item__c> itiItemList,
    Boolean hasExecutedLAKGL,
    Boolean hasExecutedCJ,
    Boolean hasExecutedGL,
    Integer sizeOfPIUA2UpdateMap,
    Set<Id> itinerarySet,
    List<String> routeList,
    Boolean isLinked,
    Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper> mapMobility_Railcar,
    Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c> railcarIdByLAKGLBookingPIUAOver36
  ) {
    Boolean isSilver = false;

    if (
      !itiItemList.isEmpty() &&
      (itiItemList[0].KaptioTravel__Price_Category__r.Name == 'SilverLeaf Adult' ||
      itiItemList[0].KaptioTravel__Price_Category__r.Name == 'SilverLeaf Plus Adult')
    ) {
      isSilver = true;
    }

    Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper> silverRailcarSeatMap;
    List<String> silverMapKeySet;

    List<String> bkpMapKeySet;
    Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper> bkpRailcarSeatMap;

    if (isSilver) {
      bkpMapKeySet = new List<String>(mapKeySet);
      bkpRailcarSeatMap = new Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper>(railcarSeatMap);

      silverRailcarSeatMap = new Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper>();
      String zeros = '';

      Iterator<String> mapKeySetIterator = mapKeySet.iterator();
      String nextMapKey = '';

      if (mapKeySetIterator.hasNext()) {
        nextMapKey = mapKeySetIterator.next();
      }

      for (Integer i = 0; i < mapKeySet.size(); i++) {
        silverRailcarSeatMap.put(
          railcarSeatMap.get(mapKeySet[i]).routeKey +
          '-' +
          railcarSeatMap.get(mapKeySet[i]).railcarOrderKey +
          '-' +
          railcarSeatMap.get(mapKeySet[i]).railcarId +
          '-' +
          zeros +
          railcarSeatMap.get(mapKeySet[i]).railcarSeatKey,
          railcarSeatMap.get(mapKeySet[i])
        );

        if (mapKeySetIterator.hasNext()) {
          nextMapKey = mapKeySetIterator.next();
        }

        zeros = railcarSeatMap.get(nextMapKey).railcarId == railcarSeatMap.get(mapKeySet[i]).railcarId ? '0' + zeros : '';
      }

      silverMapKeySet = new List<String>(silverRailcarSeatMap.keySet());
      silverMapKeySet.sort();

      railcarSeatMap = silverRailcarSeatMap;
      mapKeySet = silverMapKeySet;
    }

    Map<String, RM_SeatingToolWrappers.RailcarWrapper> contiguousSeatsSizeMap = RM_SeatingTool_Utils.getContiguousRailcarSeatsSize(
      railcarSeatMap,
      mapKeySet,
      true,
      isSilver
    );

    // BEGINNING - Ticket #30976 - map to keep the same seat number for all management legs
    Map<Id, RM_SeatingToolWrappers.RailcarSeatWrapper> railcarSeatInfoBySeatedPassengerId = new Map<Id, RM_SeatingToolWrappers.RailcarSeatWrapper>();
    // END - Ticket #30976

    Map<String, List<String>> railcarIdListByTrainLeg = new Map<String, List<String>>();

    for (Integer i = 0; i < mapKeySet.size(); i++) {
      if (!railcarIdListByTrainLeg.containsKey(railcarSeatMap.get(mapKeySet[i]).route)) {
        railcarIdListByTrainLeg.put(railcarSeatMap.get(mapKeySet[i]).route, new List<String>{ railcarSeatMap.get(mapKeySet[i]).railcarId });
      } else if (!railcarIdListByTrainLeg.get(railcarSeatMap.get(mapKeySet[i]).route).contains(railcarSeatMap.get(mapKeySet[i]).railcarId)) {
        railcarIdListByTrainLeg.get(railcarSeatMap.get(mapKeySet[i]).route).add(railcarSeatMap.get(mapKeySet[i]).railcarId);
      }
    }

    for (String trainLeg : railcarIdListByTrainLeg.keySet()) {
      railcarIdListByTrainLeg.get(trainLeg).remove(railcarIdListByTrainLeg.get(trainLeg).size() - 1);
    }

    Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c> piuaByKeyMap = sortPIUAList(bookingPIUAListByItiItem, routeList, isLinked);

    List<String> keyMapList = new List<String>(piuaByKeyMap.keySet());
    keyMapList.sort();

    for (Integer i = 0; i < keyMapList.size(); i++) {
      KaptioTravel__PassengerItineraryUnitAssignment__c piua = piuaByKeyMap.get(keyMapList[i]);

      String bookingPIUAKey = !isLinked
        ? String.valueOf(piua.KaptioTravel__ItineraryItem__c)
        : piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
          '-' +
          String.valueOf(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c);

      if (bookingPIUAListByItiItem.containsKey(bookingPIUAKey)) {
        bookingPIUAListByItiItem.get(bookingPIUAKey).clear();
      }
    }

    Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingPIUAListByItiItemRoom = new Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>>();

    for (Integer i = 0; i < keyMapList.size(); i++) {
      KaptioTravel__PassengerItineraryUnitAssignment__c piua = piuaByKeyMap.get(keyMapList[i]);

      String bookingPIUAKey = !isLinked
        ? String.valueOf(piua.KaptioTravel__ItineraryItem__c)
        : piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
          '-' +
          String.valueOf(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c);

      if (bookingPIUAListByItiItem.containsKey(bookingPIUAKey) && !bookingPIUAListByItiItem.get(bookingPIUAKey).contains(piua)) {
        bookingPIUAListByItiItem.get(bookingPIUAKey).add(piua);
      }

      String room = piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c == null
        ? '00'
        : String.valueOf(piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c).length() == 1
            ? '0' + String.valueOf(piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c)
            : String.valueOf(piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c);

      if (!isLinked) {
        if (!bookingPIUAListByItiItemRoom.containsKey(bookingPIUAKey + '-' + room)) {
          bookingPIUAListByItiItemRoom.put(bookingPIUAKey + '-' + room, new List<KaptioTravel__PassengerItineraryUnitAssignment__c>{ piua });
        } else if (!bookingPIUAListByItiItemRoom.get(bookingPIUAKey + '-' + room).contains(piua)) {
          bookingPIUAListByItiItemRoom.get(bookingPIUAKey + '-' + room).add(piua);
        }
      }
    }

    Map<String, KaptioTravel__Itinerary_Item__c> itiItemByKey = new Map<String, KaptioTravel__Itinerary_Item__c>();

    for (KaptioTravel__Itinerary_Item__c itiItem : itiItemList) {
      String bookingPIUAKey = !isLinked
        ? String.valueOf(itiItem.KaptioTravel__Itinerary__c)
        : String.valueOf(itiItem.KaptioTravel__Itinerary__r.LinkedItinerary__c);

      if (!itiItemByKey.containsKey(bookingPIUAKey + '-' + itiItem.KaptioTravel__ExternalItemName__c)) {
        itiItemByKey.put(bookingPIUAKey + '-' + itiItem.KaptioTravel__ExternalItemName__c, itiItem);
      }
    }

    List<String> sortedItiItemList = new List<String>(itiItemByKey.keySet());
    sortedItiItemList.sort();

    Map<String, List<String>> externalItemNameListByBooking = new Map<String, List<String>>();

    Iterator<String> itiItemKeySetIterator = sortedItiItemList.iterator();
    String nextItiItemMapKey = itiItemKeySetIterator.next();

    for (Integer k = 0; k < sortedItiItemList.size(); k++) {
      if (itiItemKeySetIterator.hasNext()) {
        nextItiItemMapKey = itiItemKeySetIterator.next();
      }

      String bookingPIUAKey = !isLinked
        ? String.valueOf(itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__c)
        : String.valueOf(itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__r.LinkedItinerary__c);

      if (
        (itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c != 'Kamloops to Vancouver' &&
        itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c != 'Vancouver to Kamloops') ||
        ((itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c == 'Vancouver to Kamloops' ||
        itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c == 'Kamloops to Vancouver') &&
        ((k > 0 &&
        (!isLinked
          ? String.valueOf(itiItemByKey.get(nextItiItemMapKey).KaptioTravel__Itinerary__c)
          : String.valueOf(itiItemByKey.get(nextItiItemMapKey).KaptioTravel__Itinerary__r.LinkedItinerary__c)) != bookingPIUAKey &&
        (!isLinked
          ? String.valueOf(itiItemByKey.get(sortedItiItemList[k - 1]).KaptioTravel__Itinerary__c)
          : String.valueOf(itiItemByKey.get(sortedItiItemList[k - 1]).KaptioTravel__Itinerary__r.LinkedItinerary__c)) != bookingPIUAKey) ||
        (k == 0 &&
        (!isLinked
          ? String.valueOf(itiItemByKey.get(nextItiItemMapKey).KaptioTravel__Itinerary__c)
          : String.valueOf(itiItemByKey.get(nextItiItemMapKey).KaptioTravel__Itinerary__r.LinkedItinerary__c)) != bookingPIUAKey) ||
        (itiItemByKey.size() == 1) ||
        (k == (sortedItiItemList.size() - 1) &&
        (!isLinked
          ? String.valueOf(itiItemByKey.get(sortedItiItemList[k - 1]).KaptioTravel__Itinerary__c)
          : String.valueOf(itiItemByKey.get(sortedItiItemList[k - 1]).KaptioTravel__Itinerary__r.LinkedItinerary__c)) != bookingPIUAKey)))
      ) {
        for (Integer i = 0; i < mapKeySet.size(); i++) {
          if (itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c == railcarSeatMap.get(mapKeySet[i]).route) {
            if (!externalItemNameListByBooking.containsKey(bookingPIUAKey)) {
              externalItemNameListByBooking.put(bookingPIUAKey, new List<String>{ railcarSeatMap.get(mapKeySet[i]).railcarId });
            } else if (!externalItemNameListByBooking.get(bookingPIUAKey).contains(railcarSeatMap.get(mapKeySet[i]).railcarId)) {
              externalItemNameListByBooking.get(bookingPIUAKey).add(railcarSeatMap.get(mapKeySet[i]).railcarId);
            }
          }
        }
      }
    }

    Map<String, Integer> bookingMobilityPIUASize = new Map<String, Integer>();
    Map<String, Integer> bookingMobilityRoomPIUASize = new Map<String, Integer>();
    Map<String, List<Integer>> roomIdListByBooking = new Map<String, List<Integer>>();

    for (String booking : bookingPIUAListByItiItem.keySet()) {
      Integer mobilitySizeCounter = 0;
      Integer mobilityRoomSizeCounter = 0;
      for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : bookingPIUAListByItiItem.get(booking)) {
        String bookingPIUAKey = !isLinked
          ? String.valueOf(piua.KaptioTravel__ItineraryItem__c)
          : piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
            '-' +
            String.valueOf(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c);

        Integer roomId = piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c == null
          ? 0
          : Integer.valueOf(piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c);

        if (
          !isLinked &&
          !piua.KaptioTravel__Passenger__r.Mobility_Needs__c &&
          roomIdListByBooking.containsKey(bookingPIUAKey) &&
          roomIdListByBooking.get(bookingPIUAKey).contains(roomId)
        ) {
          mobilityRoomSizeCounter++;
        }

        if (piua.KaptioTravel__Passenger__r.Mobility_Needs__c) {
          mobilitySizeCounter++;
          mobilityRoomSizeCounter++;

          if (!isLinked) {
            if (!roomIdListByBooking.containsKey(bookingPIUAKey)) {
              roomIdListByBooking.put(bookingPIUAKey, new List<Integer>{ roomId });
            } else if (!roomIdListByBooking.get(bookingPIUAKey).contains(roomId)) {
              roomIdListByBooking.get(bookingPIUAKey).add(roomId);
            }
          }
        }

        if (piua.Id == bookingPIUAListByItiItem.get(bookingPIUAKey).get(bookingPIUAListByItiItem.get(bookingPIUAKey).size() - 1).Id) {
          bookingMobilityPIUASize.put(bookingPIUAKey, mobilitySizeCounter);
          bookingMobilityRoomPIUASize.put(bookingPIUAKey, mobilityRoomSizeCounter);
        }
      }
    }

    Integer mobilityCounter = 0;

    for (Integer j = 0; j < keyMapList.size(); j++) {
      KaptioTravel__PassengerItineraryUnitAssignment__c piua = piuaByKeyMap.get(keyMapList[j]);

      String bookingPIUAKey = !isLinked
        ? String.valueOf(piua.KaptioTravel__ItineraryItem__c)
        : piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
          '-' +
          String.valueOf(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c);

      String itinerarySetId = !isLinked
        ? String.valueOf(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c)
        : String.valueOf(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c);

      String piuaItineraryId = !isLinked
        ? String.valueOf(piua.KaptioTravel__ItineraryItem__c)
        : String.valueOf(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c);

      Iterator<String> mapKeySetIterator = mapKeySet.iterator();
      String nextMapKey = '';

      if (mapKeySetIterator.hasNext()) {
        nextMapKey = mapKeySetIterator.next();
      }

      if (piua.RailSeatNumber__c == null) {
        // Iterate railcarseats
        for (Integer i = 0; i < mapKeySet.size(); i++) {
          if (mapKeySetIterator.hasNext()) {
            nextMapKey = mapKeySetIterator.next();
          }

          if (
            !railcarSeatMap.get(mapKeySet[i]).occupied &&
            piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c == railcarSeatMap.get(mapKeySet[i]).route &&
            bookingPIUAListByItiItem.containsKey(bookingPIUAKey) &&
            (bookingPIUAListByItiItem.get(bookingPIUAKey).size() <=
            availableSeatsByRailcarId.get(
                piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                '-' +
                railcarSeatMap.get(mapKeySet[i]).railcarId
              )
              .seatsCapacity ||
            (isLAKGLOver36Guests(
              routeList,
              piua,
              piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
              '-' +
              railcarSeatMap.get(mapKeySet[i]).railcarId,
              hasExecutedLAKGL,
              bookingPIUAListByItiItem,
              bookingPIUAKey,
              availableSeatsByRailcarId
            ))) &&
            contiguousSeatsSizeMap.containsKey(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey) &&
            bookingPIUAListByItiItem.get(bookingPIUAKey).size() <=
            contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey).sizeOfSeats &&
            externalItemNameListByBooking.containsKey(itinerarySetId) &&
            externalItemNameListByBooking.get(itinerarySetId).contains(railcarSeatMap.get(mapKeySet[i]).railcarId) &&
            mapMobility_Railcar.containsKey(
              piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
              '-' +
              railcarSeatMap.get(mapKeySet[i]).railcarId
            ) &&
            bookingMobilityRoomPIUASize.containsKey(bookingPIUAKey) &&
            bookingMobilityRoomPIUASize.get(bookingPIUAKey) <=
            contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey).sizeOfMobilitySeats &&
            ((!isSilver &&
            railcarIdListByTrainLeg.containsKey(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c) &&
            ((!railcarIdListByTrainLeg.get(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c)
              .contains(railcarSeatMap.get(mapKeySet[i]).railcarId)) ||
            (railcarIdListByTrainLeg.get(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c)
              .contains(railcarSeatMap.get(mapKeySet[i]).railcarId) &&
            ((mapMobility_Railcar.get(
                piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                '-' +
                railcarSeatMap.get(mapKeySet[i]).railcarId
              )
              .mobilityCounter < 3) ||
            (bookingMobilityPIUASize.containsKey(bookingPIUAKey) &&
            bookingMobilityPIUASize.get(bookingPIUAKey) > 3 &&
            mapMobility_Railcar.get(
                piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                '-' +
                railcarSeatMap.get(mapKeySet[i]).railcarId
              )
              .mobilityCounter == 0))))) || (isSilver))
          ) {
            if (
              (!railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c) &&
              ((bookingPIUAListByItiItem.get(bookingPIUAKey).indexOf(piua) == 0 &&
              ((!isSilver) ||
              (isSilver &&
              ((Math.mod(bookingPIUAListByItiItem.get(bookingPIUAKey).size(), 2) == 0) ||
              (Math.mod(bookingPIUAListByItiItem.get(bookingPIUAKey).size(), 2) == 1 &&
              ((Math.mod(bookingPIUAListByItiItem.get(bookingPIUAKey).size() + 1, 2) == 0 &&
              Math.mod(bookingPIUAListByItiItem.get(bookingPIUAKey).size() + 1, 4) != 0 &&
              Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1, 2) == 0 &&
              Math.mod(Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1, 4) != 0) ||
              !(Math.mod(bookingPIUAListByItiItem.get(bookingPIUAKey).size() + 1, 2) == 0 &&
              Math.mod(bookingPIUAListByItiItem.get(bookingPIUAKey).size() + 1, 4) != 0)))))) &&
              railcarSeatMap.get(mapKeySet[i]).mobilityApproved &&
              piua.KaptioTravel__Passenger__r.Mobility_Needs__c &&
              mapKeySetIterator.hasNext() &&
              Integer.valueOf(railcarSeatMap.get(nextMapKey).railcarId) == Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarId) &&
              Integer.valueOf(railcarSeatMap.get(nextMapKey).railcarSeatId) ==
              (!isSilver
                ? Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1
                : Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) - 1) &&
              !railcarSeatMap.get(nextMapKey).occupied) ||
              (bookingPIUAListByItiItem.get(bookingPIUAKey).indexOf(piua) > 0 &&
              ((railcarSeatMap.get(mapKeySet[i]).mobilityApproved) ||
              (!railcarSeatMap.get(mapKeySet[i]).mobilityApproved && !piua.KaptioTravel__Passenger__r.Mobility_Needs__c)) &&
              (i - 1) >= 0 &&
              Integer.valueOf(railcarSeatMap.get(mapKeySet[i - 1]).railcarId) == Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarId) &&
              Integer.valueOf(railcarSeatMap.get(mapKeySet[i - 1]).railcarSeatId) ==
              (!isSilver
                ? Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) - 1
                : Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1) &&
              railcarSeatMap.get(mapKeySet[i - 1]).occupied &&
              (!isLinked
                ? String.valueOf(railcarSeatMap.get(mapKeySet[i - 1]).assignedPIUA.KaptioTravel__ItineraryItem__c)
                : String.valueOf(
                    railcarSeatMap.get(mapKeySet[i - 1]).assignedPIUA.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                  )) == piuaItineraryId))) ||
              (railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c) &&
              railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarSeatId ==
              railcarSeatMap.get(mapKeySet[i]).railcarSeatId &&
              railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarId == railcarSeatMap.get(mapKeySet[i]).railcarId)
            ) {
              if (piua.KaptioTravel__Passenger__r.Mobility_Needs__c) {
                mobilityCounter++;
              }

              if (
                isSilver &&
                mapMobility_Railcar.get(
                    piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                    '-' +
                    railcarSeatMap.get(mapKeySet[i]).railcarId
                  )
                  .mobilityCounter > 3
              ) {
                mapMobility_Railcar.get(
                    piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                    '-' +
                    railcarSeatMap.get(mapKeySet[i]).railcarId
                  )
                  .mobilityPIUAList.add(piua);
              }

              if (piua.Id == bookingPIUAListByItiItem.get(bookingPIUAKey).get(bookingPIUAListByItiItem.get(bookingPIUAKey).size() - 1).Id) {
                mapMobility_Railcar.get(
                    piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                    '-' +
                    railcarSeatMap.get(mapKeySet[i]).railcarId
                  )
                  .mobilityCounter += mobilityCounter;
                mobilityCounter = 0;
              }

              piua.RailCarNumber__c = !railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c)
                ? railcarSeatMap.get(mapKeySet[i]).railcarId
                : railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarId;
              piua.RailCarOrdinalNumber__c = !railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c)
                ? railcarSeatMap.get(mapKeySet[i]).railcarOrdinal
                : railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarOrdinal;
              piua.RailSeatNumber__c = !railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c)
                ? railcarSeatMap.get(mapKeySet[i]).railcarSeatId
                : railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarSeatId;
              piua2UpdateMap.put(piua.Id, piua);

              railcarSeatMap.get(mapKeySet[i]).occupied = true;
              railcarSeatMap.get(mapKeySet[i]).assignedPIUA = piua;

              if (!itinerarySet.contains(itinerarySetId)) {
                itinerarySet.add(itinerarySetId);
              }

              if (piua.Id == bookingPIUAListByItiItem.get(bookingPIUAKey).get(bookingPIUAListByItiItem.get(bookingPIUAKey).size() - 1).Id) {
                contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey)
                  .sizeOfSeats -= bookingPIUAListByItiItem.get(bookingPIUAKey).size();

                if (
                  !contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey)
                    .itiItemIds.contains(piua.KaptioTravel__ItineraryItem__c)
                ) {
                  contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey)
                    .itiItemIds.add(piua.KaptioTravel__ItineraryItem__c);
                }

                contiguousSeatsSizeMap = RM_SeatingTool_Utils.getContiguousRailcarSeatsSize(railcarSeatMap, mapKeySet, true, isSilver);
              }

              if (piua.Id == bookingPIUAListByItiItem.get(bookingPIUAKey).get(bookingPIUAListByItiItem.get(bookingPIUAKey).size() - 1).Id) {
                availableSeatsByRailcarId.get(
                    piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                    '-' +
                    railcarSeatMap.get(mapKeySet[i]).railcarId
                  )
                  .seatsCapacity -= bookingPIUAListByItiItem.get(bookingPIUAKey).size();
                if (
                  !availableSeatsByRailcarId.get(
                      piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                      '-' +
                      railcarSeatMap.get(mapKeySet[i]).railcarId
                    )
                    .itiItemIds.contains(bookingPIUAKey)
                ) {
                  availableSeatsByRailcarId.get(
                      piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                      '-' +
                      railcarSeatMap.get(mapKeySet[i]).railcarId
                    )
                    .itiItemIds.add(bookingPIUAKey);
                }
              }

              if (!railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c)) {
                railcarSeatInfoBySeatedPassengerId.put(
                  piua.KaptioTravel__Passenger__c,
                  new RM_SeatingToolWrappers.RailcarSeatWrapper(
                    railcarSeatMap.get(mapKeySet[i]).railcarId,
                    railcarSeatMap.get(mapKeySet[i]).railcarOrdinal,
                    railcarSeatMap.get(mapKeySet[i]).railcarSeatId
                  )
                );
              }

              if (isSilver) {
                String railcarSeatKey = railcarSeatMap.get(mapKeySet[i]).railcarSeatId.length() == 1
                  ? '0' + railcarSeatMap.get(mapKeySet[i]).railcarSeatId
                  : railcarSeatMap.get(mapKeySet[i]).railcarSeatId;

                String railcarSeatMapKey =
                  railcarSeatMap.get(mapKeySet[i]).routeKey +
                  '-' +
                  railcarSeatMap.get(mapKeySet[i]).railcarOrderKey +
                  '-' +
                  railcarSeatMap.get(mapKeySet[i]).railcarId +
                  '-' +
                  railcarSeatKey;

                if (bkpRailcarSeatMap.containsKey(railcarSeatMapKey)) {
                  bkpRailcarSeatMap.get(railcarSeatMapKey).occupied = true;
                  bkpRailcarSeatMap.get(railcarSeatMapKey).assignedPIUA = piua;
                }
              }

              if (
                isLAKGLOver36Guests(
                  routeList,
                  piua,
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                  '-' +
                  railcarSeatMap.get(mapKeySet[i]).railcarId,
                  hasExecutedLAKGL,
                  bookingPIUAListByItiItem,
                  bookingPIUAKey,
                  availableSeatsByRailcarId
                ) && !railcarIdByLAKGLBookingPIUAOver36.containsKey(piua.Id)
              ) {
                railcarIdByLAKGLBookingPIUAOver36.put(piua.Id, piua);
              }

              break;
            }
          }
        }
      }
    }

    if (isSilver) {
      railcarSeatMap = bkpRailcarSeatMap;
      mapKeySet = bkpMapKeySet;
    }

    if (!isSilver && hasExecutedLAKGL && hasExecutedCJ && !hasExecutedGL) {
      for (Integer j = 0; j < keyMapList.size(); j++) {
        KaptioTravel__PassengerItineraryUnitAssignment__c piua = piuaByKeyMap.get(keyMapList[j]);

        if (!piua2UpdateMap.containsKey(piua.Id)) {
          mapMobility_Railcar.get('No seated GL passengers').mobilityPIUAList.add(piua);
        }
      }
    }

    return piua2UpdateMap;
  }
  // END - Ticket #35471
  // END - Ticket #31242

  // BEGINNING - Ticket #31242 - seats bookings with only a mobility guest
  // BEGINNING - Ticket #30715 - exceeded capacity for mobility customers - Adrian Flores
  // BEGINNING - Ticket #35471 - Added aux railcar seat parameters to this method and logic to sync occupied seats from both railcar seat maps
  // BEGINNING - Ticket #31241 - Check for GL and if the number of Mobility Pax counter is at its limit
  /**
   * @description Seats bookings with only a mobility guest
   * @author Anderson Morino | 03-22-2023
   * @param bookingPIUAListByItiItem
   * @param mapKeySet
   * @param railcarSeatMap
   * @param availableSeatsByRailcarId
   * @param batchHelper
   * @param piua2UpdateMap
   * @param wrappedItineraries
   * @param itiItemList
   * @param hasExecutedLAKGL
   * @param hasExecutedCJ
   * @param hasExecutedGL
   * @param sizeOfPIUA2UpdateMap
   * @param itinerarySet
   * @param routeList
   * @return Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>
   **/
  public Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> processMobilityPIUA(
    Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingPIUAListByItiItem,
    List<String> mapKeySet,
    Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper> railcarSeatMap,
    Map<String, RM_SeatingToolWrappers.RailcarWrapper> availableSeatsByRailcarId,
    RM_SeatingToolBatchHelper batchHelper,
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap,
    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries,
    List<KaptioTravel__Itinerary_Item__c> itiItemList,
    Boolean hasExecutedLAKGL,
    Boolean hasExecutedCJ,
    Boolean hasExecutedGL,
    Integer sizeOfPIUA2UpdateMap,
    Set<Id> itinerarySet,
    List<String> routeList,
    Boolean isLinked,
    Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper> mapMobility_Railcar,
    Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c> railcarIdByLAKGLBookingPIUAOver36
  ) {
    Boolean isSilver = false;

    if (
      !itiItemList.isEmpty() &&
      (itiItemList[0].KaptioTravel__Price_Category__r.Name == 'SilverLeaf Adult' ||
      itiItemList[0].KaptioTravel__Price_Category__r.Name == 'SilverLeaf Plus Adult')
    ) {
      isSilver = true;
    }

    Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper> silverRailcarSeatMap;
    List<String> silverMapKeySet;

    List<String> bkpMapKeySet;
    Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper> bkpRailcarSeatMap;

    if (isSilver) {
      bkpMapKeySet = new List<String>(mapKeySet);
      bkpRailcarSeatMap = new Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper>(railcarSeatMap);

      silverRailcarSeatMap = new Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper>();
      String zeros = '';

      Iterator<String> mapKeySetIterator = mapKeySet.iterator();
      String nextMapKey = '';

      if (mapKeySetIterator.hasNext()) {
        nextMapKey = mapKeySetIterator.next();
      }

      for (Integer i = 0; i < mapKeySet.size(); i++) {
        silverRailcarSeatMap.put(
          railcarSeatMap.get(mapKeySet[i]).routeKey +
          '-' +
          railcarSeatMap.get(mapKeySet[i]).railcarOrderKey +
          '-' +
          railcarSeatMap.get(mapKeySet[i]).railcarId +
          '-' +
          zeros +
          railcarSeatMap.get(mapKeySet[i]).railcarSeatKey,
          railcarSeatMap.get(mapKeySet[i])
        );

        if (mapKeySetIterator.hasNext()) {
          nextMapKey = mapKeySetIterator.next();
        }

        zeros = railcarSeatMap.get(nextMapKey).railcarId == railcarSeatMap.get(mapKeySet[i]).railcarId ? '0' + zeros : '';
      }

      silverMapKeySet = new List<String>(silverRailcarSeatMap.keySet());
      silverMapKeySet.sort();

      railcarSeatMap = silverRailcarSeatMap;
      mapKeySet = silverMapKeySet;
    }

    Map<String, RM_SeatingToolWrappers.RailcarWrapper> contiguousSeatsSizeMap = RM_SeatingTool_Utils.getContiguousRailcarSeatsSize(
      railcarSeatMap,
      mapKeySet,
      true,
      isSilver
    );

    // Replicate the assigned seat for passenger, for the following legs
    Map<Id, RM_SeatingToolWrappers.RailcarSeatWrapper> railcarSeatInfoBySeatedPassengerId = new Map<Id, RM_SeatingToolWrappers.RailcarSeatWrapper>();

    Map<String, List<String>> railcarIdListByTrainLeg = new Map<String, List<String>>();

    for (Integer i = 0; i < mapKeySet.size(); i++) {
      if (!railcarIdListByTrainLeg.containsKey(railcarSeatMap.get(mapKeySet[i]).route)) {
        railcarIdListByTrainLeg.put(railcarSeatMap.get(mapKeySet[i]).route, new List<String>{ railcarSeatMap.get(mapKeySet[i]).railcarId });
      } else if (!railcarIdListByTrainLeg.get(railcarSeatMap.get(mapKeySet[i]).route).contains(railcarSeatMap.get(mapKeySet[i]).railcarId)) {
        railcarIdListByTrainLeg.get(railcarSeatMap.get(mapKeySet[i]).route).add(railcarSeatMap.get(mapKeySet[i]).railcarId);
      }
    }

    for (String trainLeg : railcarIdListByTrainLeg.keySet()) {
      railcarIdListByTrainLeg.get(trainLeg).remove(railcarIdListByTrainLeg.get(trainLeg).size() - 1);
    }

    List<KaptioTravel__PassengerItineraryUnitAssignment__c> piuaSpecialMobility2Notify = new List<KaptioTravel__PassengerItineraryUnitAssignment__c>();

    Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c> piuaByKeyMap = sortPIUAList(bookingPIUAListByItiItem, routeList, isLinked);

    List<String> keyMapList = new List<String>(piuaByKeyMap.keySet());
    keyMapList.sort();

    for (Integer i = 0; i < keyMapList.size(); i++) {
      KaptioTravel__PassengerItineraryUnitAssignment__c piua = piuaByKeyMap.get(keyMapList[i]);

      String bookingPIUAKey = !isLinked
        ? String.valueOf(piua.KaptioTravel__ItineraryItem__c)
        : piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
          '-' +
          String.valueOf(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c);

      if (bookingPIUAListByItiItem.containsKey(bookingPIUAKey)) {
        bookingPIUAListByItiItem.get(bookingPIUAKey).clear();
      }
    }

    for (Integer i = 0; i < keyMapList.size(); i++) {
      KaptioTravel__PassengerItineraryUnitAssignment__c piua = piuaByKeyMap.get(keyMapList[i]);

      String bookingPIUAKey = !isLinked
        ? String.valueOf(piua.KaptioTravel__ItineraryItem__c)
        : piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
          '-' +
          String.valueOf(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c);

      if (bookingPIUAListByItiItem.containsKey(bookingPIUAKey) && !bookingPIUAListByItiItem.get(bookingPIUAKey).contains(piua)) {
        bookingPIUAListByItiItem.get(bookingPIUAKey).add(piua);
      }
    }

    Map<String, KaptioTravel__Itinerary_Item__c> itiItemByKey = new Map<String, KaptioTravel__Itinerary_Item__c>();

    for (KaptioTravel__Itinerary_Item__c itiItem : itiItemList) {
      String bookingPIUAKey = !isLinked ? String.valueOf(itiItem.Id) : String.valueOf(itiItem.KaptioTravel__Itinerary__r.LinkedItinerary__c);

      if (!itiItemByKey.containsKey(bookingPIUAKey + '-' + itiItem.KaptioTravel__ExternalItemName__c)) {
        itiItemByKey.put(bookingPIUAKey + '-' + itiItem.KaptioTravel__ExternalItemName__c, itiItem);
      }
    }

    List<String> sortedItiItemList = new List<String>(itiItemByKey.keySet());
    sortedItiItemList.sort();

    Map<String, List<String>> externalItemNameListByBooking = new Map<String, List<String>>();

    Iterator<String> itiItemKeySetIterator = sortedItiItemList.iterator();
    String nextItiItemMapKey = itiItemKeySetIterator.next();

    for (Integer k = 0; k < sortedItiItemList.size(); k++) {
      if (itiItemKeySetIterator.hasNext()) {
        nextItiItemMapKey = itiItemKeySetIterator.next();
      }

      String bookingPIUAKey = !isLinked
        ? String.valueOf(itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__c)
        : String.valueOf(itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__r.LinkedItinerary__c);

      if (
        (itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c != 'Kamloops to Vancouver' &&
        itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c != 'Vancouver to Kamloops') ||
        ((itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c == 'Vancouver to Kamloops' ||
        itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c == 'Kamloops to Vancouver') &&
        ((k > 0 &&
        (!isLinked
          ? String.valueOf(itiItemByKey.get(nextItiItemMapKey).KaptioTravel__Itinerary__c)
          : String.valueOf(itiItemByKey.get(nextItiItemMapKey).KaptioTravel__Itinerary__r.LinkedItinerary__c)) != bookingPIUAKey &&
        (!isLinked
          ? String.valueOf(itiItemByKey.get(sortedItiItemList[k - 1]).KaptioTravel__Itinerary__c)
          : String.valueOf(itiItemByKey.get(sortedItiItemList[k - 1]).KaptioTravel__Itinerary__r.LinkedItinerary__c)) != bookingPIUAKey) ||
        (k == 0 &&
        (!isLinked
          ? String.valueOf(itiItemByKey.get(nextItiItemMapKey).KaptioTravel__Itinerary__c)
          : String.valueOf(itiItemByKey.get(nextItiItemMapKey).KaptioTravel__Itinerary__r.LinkedItinerary__c)) != bookingPIUAKey) ||
        (itiItemByKey.size() == 1) ||
        (k == (sortedItiItemList.size() - 1) &&
        (!isLinked
          ? String.valueOf(itiItemByKey.get(sortedItiItemList[k - 1]).KaptioTravel__Itinerary__c)
          : String.valueOf(itiItemByKey.get(sortedItiItemList[k - 1]).KaptioTravel__Itinerary__r.LinkedItinerary__c)) != bookingPIUAKey)))
      ) {
        for (Integer i = 0; i < mapKeySet.size(); i++) {
          if (itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c == railcarSeatMap.get(mapKeySet[i]).route) {
            if (!externalItemNameListByBooking.containsKey(bookingPIUAKey)) {
              externalItemNameListByBooking.put(bookingPIUAKey, new List<String>{ railcarSeatMap.get(mapKeySet[i]).railcarId });
            } else if (!externalItemNameListByBooking.get(bookingPIUAKey).contains(railcarSeatMap.get(mapKeySet[i]).railcarId)) {
              externalItemNameListByBooking.get(bookingPIUAKey).add(railcarSeatMap.get(mapKeySet[i]).railcarId);
            }
          }
        }
      }
    }

    Integer mobilityCounter = 0;

    for (Integer j = 0; j < keyMapList.size(); j++) {
      KaptioTravel__PassengerItineraryUnitAssignment__c piua = piuaByKeyMap.get(keyMapList[j]);

      String bookingPIUAKey = !isLinked
        ? String.valueOf(piua.KaptioTravel__ItineraryItem__c)
        : piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
          '-' +
          String.valueOf(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c);

      String itinerarySetId = !isLinked
        ? String.valueOf(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c)
        : String.valueOf(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c);

      String piuaItineraryId = !isLinked
        ? String.valueOf(piua.KaptioTravel__ItineraryItem__c)
        : String.valueOf(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c);

      Iterator<String> mapKeySetIterator = mapKeySet.iterator();
      String nextMapKey = '';

      if (mapKeySetIterator.hasNext()) {
        nextMapKey = mapKeySetIterator.next();
      }

      if (piua.RailSeatNumber__c == null) {
        // Iterate railcarseats
        for (Integer i = 0; i < mapKeySet.size(); i++) {
          if (mapKeySetIterator.hasNext()) {
            nextMapKey = mapKeySetIterator.next();
          }

          if (
            !railcarSeatMap.get(mapKeySet[i]).occupied &&
            piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c == railcarSeatMap.get(mapKeySet[i]).route &&
            bookingPIUAListByItiItem.containsKey(bookingPIUAKey) &&
            (bookingPIUAListByItiItem.get(bookingPIUAKey).size() <=
            availableSeatsByRailcarId.get(
                piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                '-' +
                railcarSeatMap.get(mapKeySet[i]).railcarId
              )
              .seatsCapacity ||
            (isLAKGLOver36Guests(
              routeList,
              piua,
              piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
              '-' +
              railcarSeatMap.get(mapKeySet[i]).railcarId,
              hasExecutedLAKGL,
              bookingPIUAListByItiItem,
              bookingPIUAKey,
              availableSeatsByRailcarId
            ))) &&
            contiguousSeatsSizeMap.containsKey(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey) &&
            bookingPIUAListByItiItem.get(bookingPIUAKey).size() <=
            contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey).sizeOfSeats &&
            externalItemNameListByBooking.containsKey(itinerarySetId) &&
            externalItemNameListByBooking.get(itinerarySetId).contains(railcarSeatMap.get(mapKeySet[i]).railcarId) &&
            mapMobility_Railcar.containsKey(
              piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
              '-' +
              railcarSeatMap.get(mapKeySet[i]).railcarId
            ) &&
            ((!isSilver &&
            railcarIdListByTrainLeg.containsKey(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c) &&
            ((!railcarIdListByTrainLeg.get(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c)
              .contains(railcarSeatMap.get(mapKeySet[i]).railcarId)) ||
            (railcarIdListByTrainLeg.get(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c)
              .contains(railcarSeatMap.get(mapKeySet[i]).railcarId) &&
            mapMobility_Railcar.get(
                piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                '-' +
                railcarSeatMap.get(mapKeySet[i]).railcarId
              )
              .mobilityCounter < 3))) || (isSilver))
          ) {
            if (
              (!railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c) &&
              ((bookingPIUAListByItiItem.get(bookingPIUAKey).indexOf(piua) == 0 &&
              railcarSeatMap.get(mapKeySet[i]).mobilityApproved &&
              piua.KaptioTravel__Passenger__r.Mobility_Needs__c &&
              mapKeySetIterator.hasNext() &&
              Integer.valueOf(railcarSeatMap.get(nextMapKey).railcarId) == Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarId) &&
              Integer.valueOf(railcarSeatMap.get(nextMapKey).railcarSeatId) ==
              (!isSilver
                ? Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1
                : Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) - 1) &&
              !railcarSeatMap.get(nextMapKey).occupied) ||
              (bookingPIUAListByItiItem.get(bookingPIUAKey).indexOf(piua) > 0 &&
              (i - 1) >= 0 &&
              Integer.valueOf(railcarSeatMap.get(mapKeySet[i - 1]).railcarId) == Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarId) &&
              Integer.valueOf(railcarSeatMap.get(mapKeySet[i - 1]).railcarSeatId) ==
              (!isSilver
                ? Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) - 1
                : Integer.valueOf(railcarSeatMap.get(mapKeySet[i]).railcarSeatId) + 1) &&
              railcarSeatMap.get(mapKeySet[i - 1]).occupied &&
              (!isLinked
                ? String.valueOf(railcarSeatMap.get(mapKeySet[i - 1]).assignedPIUA.KaptioTravel__ItineraryItem__c)
                : String.valueOf(
                    railcarSeatMap.get(mapKeySet[i - 1]).assignedPIUA.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c
                  )) == piuaItineraryId))) ||
              (railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c) &&
              railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarSeatId ==
              railcarSeatMap.get(mapKeySet[i]).railcarSeatId &&
              railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarId == railcarSeatMap.get(mapKeySet[i]).railcarId)
            ) {
              if (piua.KaptioTravel__Passenger__r.Mobility_Needs__c) {
                mobilityCounter++;
              }

              if (
                isSilver &&
                mapMobility_Railcar.get(
                    piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                    '-' +
                    railcarSeatMap.get(mapKeySet[i]).railcarId
                  )
                  .mobilityCounter > 3
              ) {
                mapMobility_Railcar.get(
                    piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                    '-' +
                    railcarSeatMap.get(mapKeySet[i]).railcarId
                  )
                  .mobilityPIUAList.add(piua);
              }

              if (piua.Id == bookingPIUAListByItiItem.get(bookingPIUAKey).get(bookingPIUAListByItiItem.get(bookingPIUAKey).size() - 1).Id) {
                mapMobility_Railcar.get(
                    piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                    '-' +
                    railcarSeatMap.get(mapKeySet[i]).railcarId
                  )
                  .mobilityCounter += mobilityCounter;
                mobilityCounter = 0;
              }

              piua.RailCarNumber__c = !railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c)
                ? railcarSeatMap.get(mapKeySet[i]).railcarId
                : railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarId;
              piua.RailCarOrdinalNumber__c = !railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c)
                ? railcarSeatMap.get(mapKeySet[i]).railcarOrdinal
                : railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarOrdinal;
              piua.RailSeatNumber__c = !railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c)
                ? railcarSeatMap.get(mapKeySet[i]).railcarSeatId
                : railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarSeatId;
              piua2UpdateMap.put(piua.Id, piua);

              railcarSeatMap.get(mapKeySet[i]).occupied = true;
              railcarSeatMap.get(mapKeySet[i]).assignedPIUA = piua;

              if (!itinerarySet.contains(itinerarySetId)) {
                itinerarySet.add(itinerarySetId);
              }

              if (piua.Id == bookingPIUAListByItiItem.get(bookingPIUAKey).get(bookingPIUAListByItiItem.get(bookingPIUAKey).size() - 1).Id) {
                contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey)
                  .sizeOfSeats -= bookingPIUAListByItiItem.get(bookingPIUAKey).size();

                if (!contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey).itiItemIds.contains(bookingPIUAKey)) {
                  contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey).itiItemIds.add(bookingPIUAKey);
                }

                contiguousSeatsSizeMap = RM_SeatingTool_Utils.getContiguousRailcarSeatsSize(railcarSeatMap, mapKeySet, true, isSilver);
              }

              if (piua.Id == bookingPIUAListByItiItem.get(bookingPIUAKey).get(bookingPIUAListByItiItem.get(bookingPIUAKey).size() - 1).Id) {
                availableSeatsByRailcarId.get(
                    piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                    '-' +
                    railcarSeatMap.get(mapKeySet[i]).railcarId
                  )
                  .seatsCapacity -= bookingPIUAListByItiItem.get(bookingPIUAKey).size();
                if (
                  !availableSeatsByRailcarId.get(
                      piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                      '-' +
                      railcarSeatMap.get(mapKeySet[i]).railcarId
                    )
                    .itiItemIds.contains(bookingPIUAKey)
                ) {
                  availableSeatsByRailcarId.get(
                      piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                      '-' +
                      railcarSeatMap.get(mapKeySet[i]).railcarId
                    )
                    .itiItemIds.add(bookingPIUAKey);
                }
              }

              // BEGINNING - Ticket #32131 - Changed from getting updated piua values to get values from the map
              if (!railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c)) {
                railcarSeatInfoBySeatedPassengerId.put(
                  piua.KaptioTravel__Passenger__c,
                  new RM_SeatingToolWrappers.RailcarSeatWrapper(
                    railcarSeatMap.get(mapKeySet[i]).railcarId,
                    railcarSeatMap.get(mapKeySet[i]).railcarOrdinal,
                    railcarSeatMap.get(mapKeySet[i]).railcarSeatId
                  )
                );
              }

              if (isSilver) {
                String railcarSeatKey = railcarSeatMap.get(mapKeySet[i]).railcarSeatId.length() == 1
                  ? '0' + railcarSeatMap.get(mapKeySet[i]).railcarSeatId
                  : railcarSeatMap.get(mapKeySet[i]).railcarSeatId;

                String railcarSeatMapKey =
                  railcarSeatMap.get(mapKeySet[i]).routeKey +
                  '-' +
                  railcarSeatMap.get(mapKeySet[i]).railcarOrderKey +
                  '-' +
                  railcarSeatMap.get(mapKeySet[i]).railcarId +
                  '-' +
                  railcarSeatKey;

                if (bkpRailcarSeatMap.containsKey(railcarSeatMapKey)) {
                  bkpRailcarSeatMap.get(railcarSeatMapKey).occupied = true;
                  bkpRailcarSeatMap.get(railcarSeatMapKey).assignedPIUA = piua;
                }
              }

              if (
                isLAKGLOver36Guests(
                  routeList,
                  piua,
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                  '-' +
                  railcarSeatMap.get(mapKeySet[i]).railcarId,
                  hasExecutedLAKGL,
                  bookingPIUAListByItiItem,
                  bookingPIUAKey,
                  availableSeatsByRailcarId
                ) && !railcarIdByLAKGLBookingPIUAOver36.containsKey(piua.Id)
              ) {
                railcarIdByLAKGLBookingPIUAOver36.put(piua.Id, piua);
              }

              break;
              // END - Ticket #32131
            }
          }
        }
      }
    }

    if (isSilver) {
      railcarSeatMap = bkpRailcarSeatMap;
      mapKeySet = bkpMapKeySet;
    }

    if (!isSilver && hasExecutedLAKGL && hasExecutedCJ && !hasExecutedGL) {
      for (Integer j = 0; j < keyMapList.size(); j++) {
        KaptioTravel__PassengerItineraryUnitAssignment__c piua = piuaByKeyMap.get(keyMapList[j]);

        if (!piua2UpdateMap.containsKey(piua.Id)) {
          mapMobility_Railcar.get('No seated GL passengers').mobilityPIUAList.add(piua);
        }
      }
    }

    return piua2UpdateMap;
  }
  // END - Ticket #31241
  // END - Ticket #35471
  // END - Ticket #31242
  // END - Ticket #30715

  // BEGINNING - Ticket #35471 - Added aux railcar seat parameters to this method and logic to sync occupied seats from both railcar seat maps
  /**
   * @description Seats piua records with no business rules
   * @author Anderson Morino | 03-22-2023
   * @param bookingPIUAListByItiItem
   * @param mapKeySet
   * @param railcarSeatMap
   * @param contiguousSeatsSizeMap
   * @param availableSeatsByRailcarId
   * @param piua2UpdateMap
   * @param wrappedItineraries
   * @param itiItemList
   * @param hasExecutedLAKGL
   * @param sizeOfPIUA2UpdateMap
   * @param itinerarySet
   * @return Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>
   **/
  public Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> processOtherPIUA(
    Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingPIUAListByItiItem,
    List<String> mapKeySet,
    Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper> railcarSeatMap,
    Map<String, RM_SeatingToolWrappers.RailcarWrapper> contiguousSeatsSizeMap,
    Map<String, RM_SeatingToolWrappers.RailcarWrapper> availableSeatsByRailcarId,
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap,
    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries,
    List<KaptioTravel__Itinerary_Item__c> itiItemList,
    Boolean hasExecutedLAKGL,
    Integer sizeOfPIUA2UpdateMap,
    Set<Id> itinerarySet,
    List<String> routeList,
    Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c> railcarIdByLAKGLBookingPIUAOver36
  ) {
    // BEGINNING - Ticket #30976 - map to keep the same seat number for all management legs
    Map<Id, RM_SeatingToolWrappers.RailcarSeatWrapper> railcarSeatInfoBySeatedPassengerId = new Map<Id, RM_SeatingToolWrappers.RailcarSeatWrapper>();
    // END - Ticket #30976

    Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c> piuaByKeyMap = createFakeOtherBookingsWithPIUA(
      wrappedItineraries,
      itiItemList,
      bookingPIUAListByItiItem,
      routeList,
      piua2UpdateMap.size()
    );

    List<String> keyMapList = new List<String>(piuaByKeyMap.keySet());
    keyMapList.sort();

    for (Integer i = 0; i < keyMapList.size(); i++) {
      KaptioTravel__PassengerItineraryUnitAssignment__c piua = piuaByKeyMap.get(keyMapList[i]);

      if (bookingPIUAListByItiItem.containsKey(piua.KaptioTravel__ItineraryItem__c)) {
        bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).clear();
      }
    }

    for (Integer i = 0; i < keyMapList.size(); i++) {
      KaptioTravel__PassengerItineraryUnitAssignment__c piua = piuaByKeyMap.get(keyMapList[i]);

      if (
        bookingPIUAListByItiItem.containsKey(piua.KaptioTravel__ItineraryItem__c) &&
        !bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).contains(piua)
      ) {
        bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).add(piua);
      }
    }

    Map<String, KaptioTravel__Itinerary_Item__c> itiItemByKey = new Map<String, KaptioTravel__Itinerary_Item__c>();

    for (KaptioTravel__Itinerary_Item__c itiItem : itiItemList) {
      if (!itiItemByKey.containsKey(itiItem.KaptioTravel__Itinerary__c + '-' + itiItem.KaptioTravel__ExternalItemName__c)) {
        itiItemByKey.put(itiItem.KaptioTravel__Itinerary__c + '-' + itiItem.KaptioTravel__ExternalItemName__c, itiItem);
      }
    }

    List<String> sortedItiItemList = new List<String>(itiItemByKey.keySet());
    sortedItiItemList.sort();

    Map<String, List<String>> externalItemNameListByBooking = new Map<String, List<String>>();

    Iterator<String> itiItemKeySetIterator = sortedItiItemList.iterator();
    String nextItiItemMapKey = itiItemKeySetIterator.next();

    for (Integer k = 0; k < sortedItiItemList.size(); k++) {
      if (itiItemKeySetIterator.hasNext()) {
        nextItiItemMapKey = itiItemKeySetIterator.next();
      }

      if (
        (itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c != 'Kamloops to Vancouver' &&
        itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c != 'Vancouver to Kamloops') ||
        ((itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c == 'Vancouver to Kamloops' ||
        itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c == 'Kamloops to Vancouver') &&
        ((k > 0 &&
        itiItemByKey.get(nextItiItemMapKey).KaptioTravel__Itinerary__c != itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__c &&
        itiItemByKey.get(sortedItiItemList[k - 1]).KaptioTravel__Itinerary__c != itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__c) ||
        (k == 0 &&
        itiItemByKey.get(nextItiItemMapKey).KaptioTravel__Itinerary__c != itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__c) ||
        (itiItemByKey.size() == 1) ||
        (k == (sortedItiItemList.size() - 1) &&
        itiItemByKey.get(sortedItiItemList[k - 1]).KaptioTravel__Itinerary__c != itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__c)))
      ) {
        for (Integer i = 0; i < mapKeySet.size(); i++) {
          if (itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__ExternalItemName__c == railcarSeatMap.get(mapKeySet[i]).route) {
            if (!externalItemNameListByBooking.containsKey(itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__c)) {
              externalItemNameListByBooking.put(
                itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__c,
                new List<String>{ railcarSeatMap.get(mapKeySet[i]).railcarId }
              );
            } else if (
              !externalItemNameListByBooking.get(itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__c)
                .contains(railcarSeatMap.get(mapKeySet[i]).railcarId)
            ) {
              externalItemNameListByBooking.get(itiItemByKey.get(sortedItiItemList[k]).KaptioTravel__Itinerary__c)
                .add(railcarSeatMap.get(mapKeySet[i]).railcarId);
            }
          }
        }
      }
    }

    for (Integer j = 0; j < piuaByKeyMap.size(); j++) {
      KaptioTravel__PassengerItineraryUnitAssignment__c piua = piuaByKeyMap.get(keyMapList[j]);
      Iterator<String> mapKeySetIterator = mapKeySet.iterator();
      String nextMapKey = mapKeySetIterator.next();
      if (piua.RailSeatNumber__c == null) {
        // Iterate railcarseats
        for (Integer i = 0; i < mapKeySet.size(); i++) {
          if (mapKeySetIterator.hasNext()) {
            nextMapKey = mapKeySetIterator.next();
          }

          if (
            !railcarSeatMap.get(mapKeySet[i]).occupied &&
            piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c == railcarSeatMap.get(mapKeySet[i]).route &&
            bookingPIUAListByItiItem.containsKey(piua.KaptioTravel__ItineraryItem__c) &&
            (bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size() <=
            availableSeatsByRailcarId.get(
                piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                '-' +
                railcarSeatMap.get(mapKeySet[i]).railcarId
              )
              .seatsCapacity ||
            (isLAKGLOver36Guests(
              routeList,
              piua,
              piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
              '-' +
              railcarSeatMap.get(mapKeySet[i]).railcarId,
              hasExecutedLAKGL,
              bookingPIUAListByItiItem,
              String.valueOf(piua.KaptioTravel__ItineraryItem__c),
              availableSeatsByRailcarId
            ))) &&
            contiguousSeatsSizeMap.containsKey(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey) &&
            bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size() <=
            contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey).sizeOfSeats &&
            externalItemNameListByBooking.containsKey(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c) &&
            externalItemNameListByBooking.get(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c)
              .contains(railcarSeatMap.get(mapKeySet[i]).railcarId)
          ) {
            if (
              (!railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c)) ||
              (railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c) &&
              railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarSeatId ==
              railcarSeatMap.get(mapKeySet[i]).railcarSeatId &&
              railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarId == railcarSeatMap.get(mapKeySet[i]).railcarId)
            ) {
              piua.RailCarNumber__c = !railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c)
                ? railcarSeatMap.get(mapKeySet[i]).railcarId
                : railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarId;
              piua.RailCarOrdinalNumber__c = !railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c)
                ? railcarSeatMap.get(mapKeySet[i]).railcarOrdinal
                : railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarOrdinal;
              piua.RailSeatNumber__c = !railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c)
                ? railcarSeatMap.get(mapKeySet[i]).railcarSeatId
                : railcarSeatInfoBySeatedPassengerId.get(piua.KaptioTravel__Passenger__c).railcarSeatId;
              piua2UpdateMap.put(piua.Id, piua);

              railcarSeatMap.get(mapKeySet[i]).occupied = true;
              railcarSeatMap.get(mapKeySet[i]).assignedPIUA = piua;
              if (!itinerarySet.contains(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c)) {
                itinerarySet.add(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c);
              }

              if (
                piua.Id ==
                bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c)
                  .get(bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size() - 1)
                  .Id
              ) {
                contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey)
                  .sizeOfSeats -= bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size();

                if (
                  !contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey)
                    .itiItemIds.contains(piua.KaptioTravel__ItineraryItem__c)
                ) {
                  contiguousSeatsSizeMap.get(railcarSeatMap.get(mapKeySet[i]).railcarContiguousSeatsListKey)
                    .itiItemIds.add(piua.KaptioTravel__ItineraryItem__c);
                }

                contiguousSeatsSizeMap = RM_SeatingTool_Utils.getContiguousRailcarSeatsSize(railcarSeatMap, mapKeySet, false, false);
              }

              if (
                piua.Id ==
                bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c)
                  .get(bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size() - 1)
                  .Id
              ) {
                availableSeatsByRailcarId.get(
                    piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                    '-' +
                    railcarSeatMap.get(mapKeySet[i]).railcarId
                  )
                  .seatsCapacity -= bookingPIUAListByItiItem.get(piua.KaptioTravel__ItineraryItem__c).size();
                if (
                  !availableSeatsByRailcarId.get(
                      piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                      '-' +
                      railcarSeatMap.get(mapKeySet[i]).railcarId
                    )
                    .itiItemIds.contains(piua.KaptioTravel__ItineraryItem__c)
                ) {
                  availableSeatsByRailcarId.get(
                      piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                      '-' +
                      railcarSeatMap.get(mapKeySet[i]).railcarId
                    )
                    .itiItemIds.add(piua.KaptioTravel__ItineraryItem__c);
                }
              }

              // BEGINNING - Ticket #32131 - Changed from getting updated piua values to get values from the map
              if (!railcarSeatInfoBySeatedPassengerId.containsKey(piua.KaptioTravel__Passenger__c)) {
                railcarSeatInfoBySeatedPassengerId.put(
                  piua.KaptioTravel__Passenger__c,
                  new RM_SeatingToolWrappers.RailcarSeatWrapper(
                    railcarSeatMap.get(mapKeySet[i]).railcarId,
                    railcarSeatMap.get(mapKeySet[i]).railcarOrdinal,
                    railcarSeatMap.get(mapKeySet[i]).railcarSeatId
                  )
                );
              }

              if (
                isLAKGLOver36Guests(
                  routeList,
                  piua,
                  piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
                  '-' +
                  railcarSeatMap.get(mapKeySet[i]).railcarId,
                  hasExecutedLAKGL,
                  bookingPIUAListByItiItem,
                  String.valueOf(piua.KaptioTravel__ItineraryItem__c),
                  availableSeatsByRailcarId
                ) && !railcarIdByLAKGLBookingPIUAOver36.containsKey(piua.Id)
              ) {
                railcarIdByLAKGLBookingPIUAOver36.put(piua.Id, piua);
              }

              break;
              // END - Ticket #32131
            }
          }
        }
      }
    }

    return piua2UpdateMap;
  }
  // END - Ticket #35471
  // END - Ticket #37921
  // END - Ticket #37923

  // BEGINNING - Ticket #30919 - START

  /**
   * @description Send email notification to Product Ops Team if no ROS response is received
   * @author Anderson Morino | 03-22-2023
   * @param scheduledDepartureDate
   * @param errorMessage
   **/
  @AuraEnabled
  public static void sendNoROSApiEmail(String scheduledDepartureDate, String errorMessage) {
    List<Seating_Tool_Product_Ops_Team_Email__mdt> prodOpsTeamEmailList = Seating_Tool_Product_Ops_Team_Email__mdt.getAll().values();
    List<String> emailAddrList = new List<String>();
    String htmlBody = '';
    List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();

    for (Seating_Tool_Product_Ops_Team_Email__mdt pote : prodOpsTeamEmailList) {
      if (!emailAddrList.contains(pote.Email__c)) {
        emailAddrList.add(pote.Email__c);
      }
    }

    // We instantiate our single email message object
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

    // Assign the TO address to our mail object
    mail.setToAddresses(emailAddrList);

    // Set the subject line for your email address.
    mail.setSubject('There is an error in ROS API.');

    // You can set this to true if you want to BCC yourself on the email
    mail.setBccSender(false);

    // Specify any html body
    htmlBody =
      'In attempt to connect Seating Tool with ROS API, the following error ' +
      errorMessage +
      ' has occurred<b>' +
      '</b>, on <b>' +
      scheduledDepartureDate +
      '</b>.';
    mail.setHtmlBody(htmlBody);

    // Add emails to the list
    lstMails.add(mail);

    // Send emails
    Messaging.sendEmail(lstMails);
  }
  // END - Ticket #30919

  /**
   * @description Generate a fake record Id of any SObject based on the PIUA2UpdateMap size
   * @author Anderson Morino | 03-22-2023
   * @param sot
   * @param sizeOfPIUA2UpdateMap
   * @return String
   **/
  public String getFakeId(Schema.SObjectType sot, Integer sizeOfPIUA2UpdateMap) {
    String result = String.valueOf(sizeOfPIUA2UpdateMap);
    return sot.getDescribe().getKeyPrefix() + '0'.repeat(12 - result.length()) + result;
  }

  /**
   * @description Create Itinerary Items and their respective PIUA records for general business seating rules
   * @author Anderson Morino | 03-22-2023
   * @param wrappedItineraries
   * @param itiItemList
   * @param bookingPIUAListByItiItem
   * @param routeList
   * @param sizeOfPIUA2UpdateMap
   * @return Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>
   **/
  public Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c> createFakeBookingsWithPIUA(
    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries,
    List<KaptioTravel__Itinerary_Item__c> itiItemList,
    Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingPIUAListByItiItem,
    List<String> routeList,
    Integer sizeOfPIUA2UpdateMap
  ) {
    Map<String, List<KaptioTravel__Itinerary_Item__c>> itiItemListByItiRoute = new Map<String, List<KaptioTravel__Itinerary_Item__c>>();
    Map<String, List<String>> itiItemListByRoute = new Map<String, List<String>>();
    Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c> piuaByBookingItiItemPax = new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    if (
      (routeList.contains('Vancouver to Kamloops') &&
      routeList.contains('Kamloops to Lake Louise') &&
      routeList.contains('Lake Louise to Banff') &&
      routeList.contains('Kamloops to Jasper')) ||
      (routeList.contains('Banff to Lake Louise') &&
      routeList.contains('Lake Louise to Kamloops') &&
      routeList.contains('Jasper to Kamloops') &&
      routeList.contains('Kamloops to Vancouver'))
    ) {
      for (RM_SeatingToolWrappers.ManagementLegWrapper itinerary : wrappedItineraries) {
        for (KaptioTravel__Itinerary_Item__c itiItem : itiItemList) {
          if (itinerary.route == itiItem.KaptioTravel__ExternalItemName__c) {
            if (!itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c)) {
              itiItemListByItiRoute.put(itiItem.KaptioTravel__Itinerary__c, new List<KaptioTravel__Itinerary_Item__c>{ itiItem });
            } else {
              itiItemListByItiRoute.get(itiItem.KaptioTravel__Itinerary__c).add(itiItem);
            }

            if (!itiItemListByRoute.containsKey(itiItem.KaptioTravel__Itinerary__c)) {
              itiItemListByRoute.put(itiItem.KaptioTravel__Itinerary__c, new List<String>{ itiItem.KaptioTravel__ExternalItemName__c });
            } else if (!itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains(itiItem.KaptioTravel__ExternalItemName__c)) {
              itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).add(itiItem.KaptioTravel__ExternalItemName__c);
            }
          }
        }
      }

      for (RM_SeatingToolWrappers.ManagementLegWrapper itinerary : wrappedItineraries) {
        for (KaptioTravel__Itinerary_Item__c itiItem : itiItemList) {
          if (
            !itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c + '-' + itinerary.route) &&
            itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c) &&
            !itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains(itinerary.route) &&
            (((itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Kamloops to Jasper') ||
            itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Jasper to Kamloops')) &&
            (!itinerary.route.contains('Kamloops to Lake Louise') &&
            !itinerary.route.contains('Lake Louise to Banff') &&
            !itinerary.route.contains('Lake Louise to Kamloops') &&
            !itinerary.route.contains('Banff to Lake Louise'))) ||
            ((itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Kamloops to Lake Louise') ||
            itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Lake Louise to Banff') ||
            itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Lake Louise to Kamloops') ||
            itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Banff to Lake Louise')) &&
            (!itinerary.route.contains('Kamloops to Jasper') && !itinerary.route.contains('Jasper to Kamloops'))) ||
            ((itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Vancouver to Kamloops') ||
            itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Kamloops to Vancouver')) &&
            (!itinerary.route.contains('Kamloops to Lake Louise') &&
            !itinerary.route.contains('Lake Louise to Banff') &&
            !itinerary.route.contains('Kamloops to Jasper') &&
            !itinerary.route.contains('Lake Louise to Kamloops') &&
            !itinerary.route.contains('Banff to Lake Louise'))))
          ) {
            KaptioTravel__Itinerary_Item__c itiItemClone = itiItem.clone(false, false, false, false);
            itiItemClone.Id = getFakeId(KaptioTravel__Itinerary_Item__c.sObjectType, sizeOfPIUA2UpdateMap);
            sizeOfPIUA2UpdateMap++;
            itiItemClone.KaptioTravel__ExternalItemName__c = itinerary.route;
            itiItemListByItiRoute.put(
              itiItem.KaptioTravel__Itinerary__c +
              '-' +
              itinerary.route,
              new List<KaptioTravel__Itinerary_Item__c>{ itiItemClone }
            );
          }
        }
      }

      for (String route : itiItemListByItiRoute.keySet()) {
        for (KaptioTravel__Itinerary_Item__c itiItem : itiItemListByItiRoute.get(route)) {
          if (itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c + '-' + route.substringAfter('-')) && route.contains('-')) {
            for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : itiItem.KaptioTravel__PassengerItineraryUnitAssignments__r) {
              if (
                piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c == itiItem.KaptioTravel__Itinerary__c &&
                piua.KaptioTravel__ItineraryItem__c == itiItem.getCloneSourceId()
              ) {
                KaptioTravel__PassengerItineraryUnitAssignment__c piuaClone = piua.clone(false, false, false, false);
                piuaClone.Id = getFakeId(KaptioTravel__PassengerItineraryUnitAssignment__c.sObjectType, sizeOfPIUA2UpdateMap);
                sizeOfPIUA2UpdateMap++;

                piuaClone.KaptioTravel__ItineraryItem__c = itiItem.Id;
                piuaClone.KaptioTravel__ItineraryItem__r = itiItem;

                String room = piuaClone.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c == null
                  ? '00'
                  : String.valueOf(piuaClone.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c).length() == 1
                      ? '0' + String.valueOf(piuaClone.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c)
                      : String.valueOf(piuaClone.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c);

                if (!bookingPIUAListByItiItem.containsKey(itiItem.Id)) {
                  bookingPIUAListByItiItem.put(itiItem.Id, new List<KaptioTravel__PassengerItineraryUnitAssignment__c>{ piuaClone });
                } else if (!bookingPIUAListByItiItem.get(itiItem.Id).contains(piuaClone)) {
                  bookingPIUAListByItiItem.get(itiItem.Id).add(piuaClone);
                }

                if (!bookingPIUAListByItiItem.containsKey(itiItem.Id + '-' + room)) {
                  bookingPIUAListByItiItem.put(itiItem.Id + '-' + room, new List<KaptioTravel__PassengerItineraryUnitAssignment__c>{ piuaClone });
                } else if (!bookingPIUAListByItiItem.get(itiItem.Id + '-' + room).contains(piuaClone)) {
                  bookingPIUAListByItiItem.get(itiItem.Id + '-' + room).add(piuaClone);
                }
              }
            }
          }
        }
      }
    } else {
      for (RM_SeatingToolWrappers.ManagementLegWrapper itinerary : wrappedItineraries) {
        for (KaptioTravel__Itinerary_Item__c itiItem : itiItemList) {
          if (itinerary.route == itiItem.KaptioTravel__ExternalItemName__c) {
            if (!itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c)) {
              itiItemListByItiRoute.put(itiItem.KaptioTravel__Itinerary__c, new List<KaptioTravel__Itinerary_Item__c>{ itiItem });
            } else {
              itiItemListByItiRoute.get(itiItem.KaptioTravel__Itinerary__c).add(itiItem);
            }

            if (!itiItemListByRoute.containsKey(itiItem.KaptioTravel__Itinerary__c)) {
              itiItemListByRoute.put(itiItem.KaptioTravel__Itinerary__c, new List<String>{ itiItem.KaptioTravel__ExternalItemName__c });
            } else if (!itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains(itiItem.KaptioTravel__ExternalItemName__c)) {
              itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).add(itiItem.KaptioTravel__ExternalItemName__c);
            }
          }
        }
      }

      for (RM_SeatingToolWrappers.ManagementLegWrapper itinerary : wrappedItineraries) {
        for (KaptioTravel__Itinerary_Item__c itiItem : itiItemList) {
          if (
            !itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c + '-' + itinerary.route) &&
            itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c) &&
            !itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains(itinerary.route)
          ) {
            KaptioTravel__Itinerary_Item__c itiItemClone = itiItem.clone(false, false, false, false);
            itiItemClone.Id = getFakeId(KaptioTravel__Itinerary_Item__c.sObjectType, sizeOfPIUA2UpdateMap);
            sizeOfPIUA2UpdateMap++;
            itiItemClone.KaptioTravel__ExternalItemName__c = itinerary.route;
            itiItemListByItiRoute.put(
              itiItem.KaptioTravel__Itinerary__c +
              '-' +
              itinerary.route,
              new List<KaptioTravel__Itinerary_Item__c>{ itiItemClone }
            );
          }
        }
      }

      for (String route : itiItemListByItiRoute.keySet()) {
        for (KaptioTravel__Itinerary_Item__c itiItem : itiItemListByItiRoute.get(route)) {
          if (itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c + '-' + route.substringAfter('-')) && route.contains('-')) {
            for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : itiItem.KaptioTravel__PassengerItineraryUnitAssignments__r) {
              if (
                piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c == itiItem.KaptioTravel__Itinerary__c &&
                piua.KaptioTravel__ItineraryItem__c == itiItem.getCloneSourceId()
              ) {
                KaptioTravel__PassengerItineraryUnitAssignment__c piuaClone = piua.clone(false, false, false, false);
                piuaClone.Id = getFakeId(KaptioTravel__PassengerItineraryUnitAssignment__c.sObjectType, sizeOfPIUA2UpdateMap);
                sizeOfPIUA2UpdateMap++;

                piuaClone.KaptioTravel__ItineraryItem__c = itiItem.Id;
                piuaClone.KaptioTravel__ItineraryItem__r = itiItem;

                String room = piuaClone.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c == null
                  ? '00'
                  : String.valueOf(piuaClone.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c).length() == 1
                      ? '0' + String.valueOf(piuaClone.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c)
                      : String.valueOf(piuaClone.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c);

                if (!bookingPIUAListByItiItem.containsKey(itiItem.Id)) {
                  bookingPIUAListByItiItem.put(itiItem.Id, new List<KaptioTravel__PassengerItineraryUnitAssignment__c>{ piuaClone });
                } else if (!bookingPIUAListByItiItem.get(itiItem.Id).contains(piuaClone)) {
                  bookingPIUAListByItiItem.get(itiItem.Id).add(piuaClone);
                }

                if (!bookingPIUAListByItiItem.containsKey(itiItem.Id + '-' + room)) {
                  bookingPIUAListByItiItem.put(itiItem.Id + '-' + room, new List<KaptioTravel__PassengerItineraryUnitAssignment__c>{ piuaClone });
                } else if (!bookingPIUAListByItiItem.get(itiItem.Id + '-' + room).contains(piuaClone)) {
                  bookingPIUAListByItiItem.get(itiItem.Id + '-' + room).add(piuaClone);
                }
              }
            }
          }
        }
      }
    }

    for (String itiItem : bookingPIUAListByItiItem.keySet()) {
      if (itiItem.contains('-')) {
        for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : bookingPIUAListByItiItem.get(itiItem)) {
          String routeKey = String.valueOf(routeList.indexOf(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c)).length() == 1
            ? '0' + String.valueOf(routeList.indexOf(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c))
            : String.valueOf(routeList.indexOf(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c));

          String room = piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c == null
            ? '00'
            : String.valueOf(piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c).length() == 1
                ? '0' + String.valueOf(piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c)
                : String.valueOf(piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c);

          String bookingSize = bookingPIUAListByItiItem.get(itiItem).size() == 4
            ? '0000' + String.valueOf(bookingPIUAListByItiItem.get(itiItem).size())
            : bookingPIUAListByItiItem.get(itiItem).size() == 3
                ? '000' + String.valueOf(bookingPIUAListByItiItem.get(itiItem).size())
                : bookingPIUAListByItiItem.get(itiItem).size() == 2
                    ? '00' + String.valueOf(bookingPIUAListByItiItem.get(itiItem).size())
                    : bookingPIUAListByItiItem.get(itiItem).size() == 1 ? '0' + String.valueOf(bookingPIUAListByItiItem.get(itiItem).size()) : '';

          if (
            !piuaByBookingItiItemPax.containsKey(
              piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c +
              '-' +
              routeKey +
              '-' +
              bookingSize +
              '-' +
              room +
              '-' +
              piua.KaptioTravel__Passenger__c
            )
          ) {
            piuaByBookingItiItemPax.put(
              piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c +
              '-' +
              routeKey +
              '-' +
              bookingSize +
              '-' +
              room +
              '-' +
              piua.KaptioTravel__Passenger__c,
              piua
            );
          }
        }
      }
    }

    return piuaByBookingItiItemPax;
  }

  /**
   * @description Create Itinerary Items and their respective PIUA records for linked itineraries rules
   * @author Anderson Morino | 03-22-2023
   * @param wrappedItineraries
   * @param itiItemList
   * @param bookingPIUAListByItiItem
   * @param routeList
   * @param sizeOfPIUA2UpdateMap
   **/
  public void createFakeLinkedBookingsWithPIUA(
    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries,
    List<KaptioTravel__Itinerary_Item__c> itiItemList,
    Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingPIUAListByItiItem,
    List<String> routeList,
    Integer sizeOfPIUA2UpdateMap
  ) {
    // maps itineraryId - to List of Itinerary Items
    Map<String, List<KaptioTravel__Itinerary_Item__c>> itiItemListByItiRoute = new Map<String, List<KaptioTravel__Itinerary_Item__c>>();
    // maps itineraryId - to route name
    Map<String, List<String>> itiItemListByRoute = new Map<String, List<String>>();

    if (
      (routeList.contains('Vancouver to Kamloops') &&
      routeList.contains('Kamloops to Lake Louise') &&
      routeList.contains('Lake Louise to Banff') &&
      routeList.contains('Kamloops to Jasper')) ||
      (routeList.contains('Banff to Lake Louise') &&
      routeList.contains('Lake Louise to Kamloops') &&
      routeList.contains('Jasper to Kamloops') &&
      routeList.contains('Kamloops to Vancouver'))
    ) {
      for (RM_SeatingToolWrappers.ManagementLegWrapper itinerary : wrappedItineraries) {
        for (KaptioTravel__Itinerary_Item__c itiItem : itiItemList) {
          if (itinerary.route == itiItem.KaptioTravel__ExternalItemName__c) {
            if (!itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c)) {
              itiItemListByItiRoute.put(itiItem.KaptioTravel__Itinerary__c, new List<KaptioTravel__Itinerary_Item__c>{ itiItem });
            } else if (!itiItemListByItiRoute.get(itiItem.KaptioTravel__Itinerary__c).contains(itiItem)) {
              itiItemListByItiRoute.get(itiItem.KaptioTravel__Itinerary__c).add(itiItem);
            }
            if (!itiItemListByRoute.containsKey(itiItem.KaptioTravel__Itinerary__c)) {
              itiItemListByRoute.put(itiItem.KaptioTravel__Itinerary__c, new List<String>{ itiItem.KaptioTravel__ExternalItemName__c });
            } else if (!itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains(itiItem.KaptioTravel__ExternalItemName__c)) {
              itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).add(itiItem.KaptioTravel__ExternalItemName__c);
            }
          }
        }
      }

      for (RM_SeatingToolWrappers.ManagementLegWrapper itinerary : wrappedItineraries) {
        for (KaptioTravel__Itinerary_Item__c itiItem : itiItemList) {
          if (
            !itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c + '-' + itinerary.route) &&
            itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c) &&
            !itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains(itinerary.route) &&
            (((itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Kamloops to Jasper') ||
            itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Jasper to Kamloops')) &&
            (!itinerary.route.contains('Kamloops to Lake Louise') &&
            !itinerary.route.contains('Lake Louise to Banff') &&
            !itinerary.route.contains('Lake Louise to Kamloops') &&
            !itinerary.route.contains('Banff to Lake Louise'))) ||
            ((itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Kamloops to Lake Louise') ||
            itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Lake Louise to Banff') ||
            itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Lake Louise to Kamloops') ||
            itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Banff to Lake Louise')) &&
            (!itinerary.route.contains('Kamloops to Jasper') && !itinerary.route.contains('Jasper to Kamloops'))) ||
            ((itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Vancouver to Kamloops') ||
            itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Kamloops to Vancouver')) &&
            (!itinerary.route.contains('Kamloops to Lake Louise') &&
            !itinerary.route.contains('Lake Louise to Banff') &&
            !itinerary.route.contains('Kamloops to Jasper') &&
            !itinerary.route.contains('Lake Louise to Kamloops') &&
            !itinerary.route.contains('Banff to Lake Louise'))))
          ) {
            KaptioTravel__Itinerary_Item__c itiItemClone = itiItem.clone(false, false, false, false);
            itiItemClone.Id = getFakeId(KaptioTravel__Itinerary_Item__c.sObjectType, sizeOfPIUA2UpdateMap);
            sizeOfPIUA2UpdateMap++;
            itiItemClone.KaptioTravel__ExternalItemName__c = itinerary.route;
            itiItemListByItiRoute.put(
              itiItem.KaptioTravel__Itinerary__c +
              '-' +
              itinerary.route,
              new List<KaptioTravel__Itinerary_Item__c>{ itiItemClone }
            );
          }
        }
      }

      for (String route : itiItemListByItiRoute.keySet()) {
        for (KaptioTravel__Itinerary_Item__c itiItem : itiItemListByItiRoute.get(route)) {
          if (itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c + '-' + route.substringAfter('-')) && route.contains('-')) {
            for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : itiItem.KaptioTravel__PassengerItineraryUnitAssignments__r) {
              if (
                piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c == itiItem.KaptioTravel__Itinerary__c &&
                piua.KaptioTravel__ItineraryItem__c == itiItem.getCloneSourceId()
              ) {
                KaptioTravel__PassengerItineraryUnitAssignment__c piuaClone = piua.clone(false, false, false, false);
                piuaClone.Id = getFakeId(KaptioTravel__PassengerItineraryUnitAssignment__c.sObjectType, sizeOfPIUA2UpdateMap);
                sizeOfPIUA2UpdateMap++;

                piuaClone.KaptioTravel__ItineraryItem__c = itiItem.Id;
                piuaClone.KaptioTravel__ItineraryItem__r = itiItem;

                if (!bookingPIUAListByItiItem.containsKey(route.substringAfter('-') + '-' + itiItem.KaptioTravel__Itinerary__r.LinkedItinerary__c)) {
                  bookingPIUAListByItiItem.put(
                    route.substringAfter('-') +
                    '-' +
                    itiItem.KaptioTravel__Itinerary__r.LinkedItinerary__c,
                    new List<KaptioTravel__PassengerItineraryUnitAssignment__c>{ piuaClone }
                  );
                } else if (
                  !bookingPIUAListByItiItem.get(route.substringAfter('-') + '-' + itiItem.KaptioTravel__Itinerary__r.LinkedItinerary__c)
                    .contains(piuaClone)
                ) {
                  bookingPIUAListByItiItem.get(route.substringAfter('-') + '-' + itiItem.KaptioTravel__Itinerary__r.LinkedItinerary__c)
                    .add(piuaClone);
                }
              }
            }
          }
        }
      }
    } else {
      for (RM_SeatingToolWrappers.ManagementLegWrapper itinerary : wrappedItineraries) {
        for (KaptioTravel__Itinerary_Item__c itiItem : itiItemList) {
          if (itinerary.route == itiItem.KaptioTravel__ExternalItemName__c) {
            if (!itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c)) {
              itiItemListByItiRoute.put(itiItem.KaptioTravel__Itinerary__c, new List<KaptioTravel__Itinerary_Item__c>{ itiItem });
            } else if (!itiItemListByItiRoute.get(itiItem.KaptioTravel__Itinerary__c).contains(itiItem)) {
              itiItemListByItiRoute.get(itiItem.KaptioTravel__Itinerary__c).add(itiItem);
            }

            if (!itiItemListByRoute.containsKey(itiItem.KaptioTravel__Itinerary__c)) {
              itiItemListByRoute.put(itiItem.KaptioTravel__Itinerary__c, new List<String>{ itiItem.KaptioTravel__ExternalItemName__c });
            } else if (!itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains(itiItem.KaptioTravel__ExternalItemName__c)) {
              itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).add(itiItem.KaptioTravel__ExternalItemName__c);
            }
          }
        }
      }

      for (RM_SeatingToolWrappers.ManagementLegWrapper itinerary : wrappedItineraries) {
        for (KaptioTravel__Itinerary_Item__c itiItem : itiItemList) {
          if (
            !itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c + '-' + itinerary.route) &&
            itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c) &&
            !itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains(itinerary.route)
          ) {
            KaptioTravel__Itinerary_Item__c itiItemClone = itiItem.clone(false, false, false, false);
            itiItemClone.Id = getFakeId(KaptioTravel__Itinerary_Item__c.sObjectType, sizeOfPIUA2UpdateMap);
            sizeOfPIUA2UpdateMap++;
            itiItemClone.KaptioTravel__ExternalItemName__c = itinerary.route;
            itiItemListByItiRoute.put(
              itiItem.KaptioTravel__Itinerary__c +
              '-' +
              itinerary.route,
              new List<KaptioTravel__Itinerary_Item__c>{ itiItemClone }
            );
          }
        }
      }

      for (String route : itiItemListByItiRoute.keySet()) {
        for (KaptioTravel__Itinerary_Item__c itiItem : itiItemListByItiRoute.get(route)) {
          if (itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c + '-' + route.substringAfter('-')) && route.contains('-')) {
            for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : itiItem.KaptioTravel__PassengerItineraryUnitAssignments__r) {
              if (
                piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c == itiItem.KaptioTravel__Itinerary__c &&
                piua.KaptioTravel__ItineraryItem__c == itiItem.getCloneSourceId()
              ) {
                KaptioTravel__PassengerItineraryUnitAssignment__c piuaClone = piua.clone(false, false, false, false);
                piuaClone.Id = getFakeId(KaptioTravel__PassengerItineraryUnitAssignment__c.sObjectType, sizeOfPIUA2UpdateMap);
                sizeOfPIUA2UpdateMap++;

                piuaClone.KaptioTravel__ItineraryItem__c = itiItem.Id;
                piuaClone.KaptioTravel__ItineraryItem__r = itiItem;

                if (!bookingPIUAListByItiItem.containsKey(route.substringAfter('-') + '-' + itiItem.KaptioTravel__Itinerary__r.LinkedItinerary__c)) {
                  bookingPIUAListByItiItem.put(
                    route.substringAfter('-') +
                    '-' +
                    itiItem.KaptioTravel__Itinerary__r.LinkedItinerary__c,
                    new List<KaptioTravel__PassengerItineraryUnitAssignment__c>{ piuaClone }
                  );
                } else if (
                  !bookingPIUAListByItiItem.get(route.substringAfter('-') + '-' + itiItem.KaptioTravel__Itinerary__r.LinkedItinerary__c)
                    .contains(piuaClone)
                ) {
                  bookingPIUAListByItiItem.get(route.substringAfter('-') + '-' + itiItem.KaptioTravel__Itinerary__r.LinkedItinerary__c)
                    .add(piuaClone);
                }
              }
            }
          }
        }
      }
    }
  }
  // END - Ticket #37921 / #31294
  // END - Ticket #38145 / #38487 / #38498 / #38790

  /**
   * @description Create Itinerary Items and their respective PIUA records for mobility rules
   * @author Anderson Morino | 03-22-2023
   * @param wrappedItineraries
   * @param itiItemList
   * @param bookingPIUAListByItiItem
   * @param routeList
   * @param sizeOfPIUA2UpdateMap
   * @param isLinked
   **/
  public void createFakeMobilityBookingsWithPIUA(
    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries,
    List<KaptioTravel__Itinerary_Item__c> itiItemList,
    Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingPIUAListByItiItem,
    List<String> routeList,
    Integer sizeOfPIUA2UpdateMap,
    Boolean isLinked
  ) {
    Map<String, List<KaptioTravel__Itinerary_Item__c>> itiItemListByItiRoute = new Map<String, List<KaptioTravel__Itinerary_Item__c>>();
    Map<String, List<String>> itiItemListByRoute = new Map<String, List<String>>();
    Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c> piuaByBookingItiItemPax = new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    if (
      (routeList.contains('Vancouver to Kamloops') &&
      routeList.contains('Kamloops to Lake Louise') &&
      routeList.contains('Lake Louise to Banff') &&
      routeList.contains('Kamloops to Jasper')) ||
      (routeList.contains('Banff to Lake Louise') &&
      routeList.contains('Lake Louise to Kamloops') &&
      routeList.contains('Jasper to Kamloops') &&
      routeList.contains('Kamloops to Vancouver'))
    ) {
      for (RM_SeatingToolWrappers.ManagementLegWrapper itinerary : wrappedItineraries) {
        for (KaptioTravel__Itinerary_Item__c itiItem : itiItemList) {
          if (itinerary.route == itiItem.KaptioTravel__ExternalItemName__c) {
            if (!itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c)) {
              itiItemListByItiRoute.put(itiItem.KaptioTravel__Itinerary__c, new List<KaptioTravel__Itinerary_Item__c>{ itiItem });
            } else if (!itiItemListByItiRoute.get(itiItem.KaptioTravel__Itinerary__c).contains(itiItem)) {
              itiItemListByItiRoute.get(itiItem.KaptioTravel__Itinerary__c).add(itiItem);
            }

            if (!itiItemListByRoute.containsKey(itiItem.KaptioTravel__Itinerary__c)) {
              itiItemListByRoute.put(itiItem.KaptioTravel__Itinerary__c, new List<String>{ itiItem.KaptioTravel__ExternalItemName__c });
            } else if (!itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains(itiItem.KaptioTravel__ExternalItemName__c)) {
              itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).add(itiItem.KaptioTravel__ExternalItemName__c);
            }
          }
        }
      }

      for (RM_SeatingToolWrappers.ManagementLegWrapper itinerary : wrappedItineraries) {
        for (KaptioTravel__Itinerary_Item__c itiItem : itiItemList) {
          if (
            !itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c + '-' + itinerary.route) &&
            itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c) &&
            !itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains(itinerary.route) &&
            (((itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Kamloops to Jasper') ||
            itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Jasper to Kamloops')) &&
            (!itinerary.route.contains('Kamloops to Lake Louise') &&
            !itinerary.route.contains('Lake Louise to Banff') &&
            !itinerary.route.contains('Lake Louise to Kamloops') &&
            !itinerary.route.contains('Banff to Lake Louise'))) ||
            ((itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Kamloops to Lake Louise') ||
            itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Lake Louise to Banff') ||
            itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Lake Louise to Kamloops') ||
            itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Banff to Lake Louise')) &&
            (!itinerary.route.contains('Kamloops to Jasper') && !itinerary.route.contains('Jasper to Kamloops'))) ||
            ((itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Vancouver to Kamloops') ||
            itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Kamloops to Vancouver')) &&
            (!itinerary.route.contains('Kamloops to Lake Louise') &&
            !itinerary.route.contains('Lake Louise to Banff') &&
            !itinerary.route.contains('Kamloops to Jasper') &&
            !itinerary.route.contains('Lake Louise to Kamloops') &&
            !itinerary.route.contains('Banff to Lake Louise'))))
          ) {
            KaptioTravel__Itinerary_Item__c itiItemClone = itiItem.clone(false, false, false, false);
            itiItemClone.Id = getFakeId(KaptioTravel__Itinerary_Item__c.sObjectType, sizeOfPIUA2UpdateMap);
            sizeOfPIUA2UpdateMap++;
            itiItemClone.KaptioTravel__ExternalItemName__c = itinerary.route;
            itiItemListByItiRoute.put(
              itiItem.KaptioTravel__Itinerary__c +
              '-' +
              itinerary.route,
              new List<KaptioTravel__Itinerary_Item__c>{ itiItemClone }
            );
          }
        }
      }

      for (String route : itiItemListByItiRoute.keySet()) {
        for (KaptioTravel__Itinerary_Item__c itiItem : itiItemListByItiRoute.get(route)) {
          if (itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c + '-' + route.substringAfter('-')) && route.contains('-')) {
            String bookingPIUAKey = !isLinked
              ? String.valueOf(itiItem.Id)
              : route.substringAfter('-') + '-' + String.valueOf(itiItem.KaptioTravel__Itinerary__r.LinkedItinerary__c);
            for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : itiItem.KaptioTravel__PassengerItineraryUnitAssignments__r) {
              if (
                piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c == itiItem.KaptioTravel__Itinerary__c &&
                piua.KaptioTravel__ItineraryItem__c == itiItem.getCloneSourceId()
              ) {
                KaptioTravel__PassengerItineraryUnitAssignment__c piuaClone = piua.clone(false, false, false, false);
                piuaClone.Id = getFakeId(KaptioTravel__PassengerItineraryUnitAssignment__c.sObjectType, sizeOfPIUA2UpdateMap);
                sizeOfPIUA2UpdateMap++;

                piuaClone.KaptioTravel__ItineraryItem__c = itiItem.Id;
                piuaClone.KaptioTravel__ItineraryItem__r = itiItem;

                if (!bookingPIUAListByItiItem.containsKey(bookingPIUAKey)) {
                  bookingPIUAListByItiItem.put(bookingPIUAKey, new List<KaptioTravel__PassengerItineraryUnitAssignment__c>{ piuaClone });
                } else if (!bookingPIUAListByItiItem.get(bookingPIUAKey).contains(piuaClone)) {
                  bookingPIUAListByItiItem.get(bookingPIUAKey).add(piuaClone);
                }
              }
            }
          }
        }
      }
    } else {
      for (RM_SeatingToolWrappers.ManagementLegWrapper itinerary : wrappedItineraries) {
        for (KaptioTravel__Itinerary_Item__c itiItem : itiItemList) {
          if (itinerary.route == itiItem.KaptioTravel__ExternalItemName__c) {
            if (!itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c)) {
              itiItemListByItiRoute.put(itiItem.KaptioTravel__Itinerary__c, new List<KaptioTravel__Itinerary_Item__c>{ itiItem });
            } else if (!itiItemListByItiRoute.get(itiItem.KaptioTravel__Itinerary__c).contains(itiItem)) {
              itiItemListByItiRoute.get(itiItem.KaptioTravel__Itinerary__c).add(itiItem);
            }

            if (!itiItemListByRoute.containsKey(itiItem.KaptioTravel__Itinerary__c)) {
              itiItemListByRoute.put(itiItem.KaptioTravel__Itinerary__c, new List<String>{ itiItem.KaptioTravel__ExternalItemName__c });
            } else if (!itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains(itiItem.KaptioTravel__ExternalItemName__c)) {
              itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).add(itiItem.KaptioTravel__ExternalItemName__c);
            }
          }
        }
      }

      for (RM_SeatingToolWrappers.ManagementLegWrapper itinerary : wrappedItineraries) {
        for (KaptioTravel__Itinerary_Item__c itiItem : itiItemList) {
          if (
            !itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c + '-' + itinerary.route) &&
            itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c) &&
            !itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains(itinerary.route)
          ) {
            KaptioTravel__Itinerary_Item__c itiItemClone = itiItem.clone(false, false, false, false);
            itiItemClone.Id = getFakeId(KaptioTravel__Itinerary_Item__c.sObjectType, sizeOfPIUA2UpdateMap);
            sizeOfPIUA2UpdateMap++;
            itiItemClone.KaptioTravel__ExternalItemName__c = itinerary.route;
            itiItemListByItiRoute.put(
              itiItem.KaptioTravel__Itinerary__c +
              '-' +
              itinerary.route,
              new List<KaptioTravel__Itinerary_Item__c>{ itiItemClone }
            );
          }
        }
      }

      for (String route : itiItemListByItiRoute.keySet()) {
        for (KaptioTravel__Itinerary_Item__c itiItem : itiItemListByItiRoute.get(route)) {
          String bookingPIUAKey = !isLinked
            ? String.valueOf(itiItem.Id)
            : route.substringAfter('-') + '-' + String.valueOf(itiItem.KaptioTravel__Itinerary__r.LinkedItinerary__c);

          if (itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c + '-' + route.substringAfter('-')) && route.contains('-')) {
            for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : itiItem.KaptioTravel__PassengerItineraryUnitAssignments__r) {
              if (
                piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c == itiItem.KaptioTravel__Itinerary__c &&
                piua.KaptioTravel__ItineraryItem__c == itiItem.getCloneSourceId()
              ) {
                KaptioTravel__PassengerItineraryUnitAssignment__c piuaClone = piua.clone(false, false, false, false);
                piuaClone.Id = getFakeId(KaptioTravel__PassengerItineraryUnitAssignment__c.sObjectType, sizeOfPIUA2UpdateMap);
                sizeOfPIUA2UpdateMap++;

                piuaClone.KaptioTravel__ItineraryItem__c = itiItem.Id;
                piuaClone.KaptioTravel__ItineraryItem__r = itiItem;

                if (!bookingPIUAListByItiItem.containsKey(bookingPIUAKey)) {
                  bookingPIUAListByItiItem.put(bookingPIUAKey, new List<KaptioTravel__PassengerItineraryUnitAssignment__c>{ piuaClone });
                } else if (!bookingPIUAListByItiItem.get(bookingPIUAKey).contains(piuaClone)) {
                  bookingPIUAListByItiItem.get(bookingPIUAKey).add(piuaClone);
                }
              }
            }
          }
        }
      }
    }
  }
  // END - Ticket #33366
  // END - Ticket #39745 / #39544 / #39498 / #37922 / #37921 / #32134 / #31236

  /**
   * @description Create Itinerary Items and their respective PIUA records for remaining bookings with only one passenger
   * @author Anderson Morino | 03-22-2023
   * @param wrappedItineraries
   * @param itiItemList
   * @param bookingPIUAListByItiItem
   * @param routeList
   * @param sizeOfPIUA2UpdateMap
   * @return Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>
   **/
  public Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c> createFakeOtherBookingsWithPIUA(
    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries,
    List<KaptioTravel__Itinerary_Item__c> itiItemList,
    Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingPIUAListByItiItem,
    List<String> routeList,
    Integer sizeOfPIUA2UpdateMap
  ) {
    Map<String, List<KaptioTravel__Itinerary_Item__c>> itiItemListByItiRoute = new Map<String, List<KaptioTravel__Itinerary_Item__c>>();
    Map<String, List<String>> itiItemListByRoute = new Map<String, List<String>>();
    Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c> piuaByBookingItiItemPax = new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    if (
      (routeList.contains('Vancouver to Kamloops') &&
      routeList.contains('Kamloops to Lake Louise') &&
      routeList.contains('Lake Louise to Banff') &&
      routeList.contains('Kamloops to Jasper')) ||
      (routeList.contains('Banff to Lake Louise') &&
      routeList.contains('Lake Louise to Kamloops') &&
      routeList.contains('Jasper to Kamloops') &&
      routeList.contains('Kamloops to Vancouver'))
    ) {
      for (RM_SeatingToolWrappers.ManagementLegWrapper itinerary : wrappedItineraries) {
        for (KaptioTravel__Itinerary_Item__c itiItem : itiItemList) {
          if (itinerary.route == itiItem.KaptioTravel__ExternalItemName__c) {
            if (!itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c)) {
              itiItemListByItiRoute.put(itiItem.KaptioTravel__Itinerary__c, new List<KaptioTravel__Itinerary_Item__c>{ itiItem });
            } else {
              itiItemListByItiRoute.get(itiItem.KaptioTravel__Itinerary__c).add(itiItem);
            }

            if (!itiItemListByRoute.containsKey(itiItem.KaptioTravel__Itinerary__c)) {
              itiItemListByRoute.put(itiItem.KaptioTravel__Itinerary__c, new List<String>{ itiItem.KaptioTravel__ExternalItemName__c });
            } else if (!itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains(itiItem.KaptioTravel__ExternalItemName__c)) {
              itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).add(itiItem.KaptioTravel__ExternalItemName__c);
            }
          }
        }
      }

      for (RM_SeatingToolWrappers.ManagementLegWrapper itinerary : wrappedItineraries) {
        for (KaptioTravel__Itinerary_Item__c itiItem : itiItemList) {
          if (
            !itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c + '-' + itinerary.route) &&
            itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c) &&
            !itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains(itinerary.route) &&
            (((itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Kamloops to Jasper') ||
            itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Jasper to Kamloops')) &&
            (!itinerary.route.contains('Kamloops to Lake Louise') &&
            !itinerary.route.contains('Lake Louise to Banff') &&
            !itinerary.route.contains('Lake Louise to Kamloops') &&
            !itinerary.route.contains('Banff to Lake Louise'))) ||
            ((itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Kamloops to Lake Louise') ||
            itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Lake Louise to Banff') ||
            itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Lake Louise to Kamloops') ||
            itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Banff to Lake Louise')) &&
            (!itinerary.route.contains('Kamloops to Jasper') && !itinerary.route.contains('Jasper to Kamloops'))) ||
            ((itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Vancouver to Kamloops') ||
            itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains('Kamloops to Vancouver')) &&
            (!itinerary.route.contains('Kamloops to Lake Louise') &&
            !itinerary.route.contains('Lake Louise to Banff') &&
            !itinerary.route.contains('Kamloops to Jasper') &&
            !itinerary.route.contains('Lake Louise to Kamloops') &&
            !itinerary.route.contains('Banff to Lake Louise'))))
          ) {
            KaptioTravel__Itinerary_Item__c itiItemClone = itiItem.clone(false, false, false, false);
            itiItemClone.Id = getFakeId(KaptioTravel__Itinerary_Item__c.sObjectType, sizeOfPIUA2UpdateMap);
            sizeOfPIUA2UpdateMap++;
            itiItemClone.KaptioTravel__ExternalItemName__c = itinerary.route;
            itiItemListByItiRoute.put(
              itiItem.KaptioTravel__Itinerary__c +
              '-' +
              itinerary.route,
              new List<KaptioTravel__Itinerary_Item__c>{ itiItemClone }
            );
          }
        }
      }

      for (String route : itiItemListByItiRoute.keySet()) {
        for (KaptioTravel__Itinerary_Item__c itiItem : itiItemListByItiRoute.get(route)) {
          if (itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c + '-' + route.substringAfter('-')) && route.contains('-')) {
            for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : itiItem.KaptioTravel__PassengerItineraryUnitAssignments__r) {
              if (
                piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c == itiItem.KaptioTravel__Itinerary__c &&
                piua.KaptioTravel__ItineraryItem__c == itiItem.getCloneSourceId()
              ) {
                KaptioTravel__PassengerItineraryUnitAssignment__c piuaClone = piua.clone(false, false, false, false);
                piuaClone.Id = getFakeId(KaptioTravel__PassengerItineraryUnitAssignment__c.sObjectType, sizeOfPIUA2UpdateMap);
                sizeOfPIUA2UpdateMap++;

                piuaClone.KaptioTravel__ItineraryItem__c = itiItem.Id;
                piuaClone.KaptioTravel__ItineraryItem__r = itiItem;

                String room = piuaClone.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c == null
                  ? '00'
                  : String.valueOf(piuaClone.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c).length() == 1
                      ? '0' + String.valueOf(piuaClone.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c)
                      : String.valueOf(piuaClone.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c);

                if (!bookingPIUAListByItiItem.containsKey(itiItem.Id)) {
                  bookingPIUAListByItiItem.put(itiItem.Id, new List<KaptioTravel__PassengerItineraryUnitAssignment__c>{ piuaClone });
                } else if (!bookingPIUAListByItiItem.get(itiItem.Id).contains(piuaClone)) {
                  bookingPIUAListByItiItem.get(itiItem.Id).add(piuaClone);
                }

                if (!bookingPIUAListByItiItem.containsKey(itiItem.Id + '-' + room)) {
                  bookingPIUAListByItiItem.put(itiItem.Id + '-' + room, new List<KaptioTravel__PassengerItineraryUnitAssignment__c>{ piuaClone });
                } else if (!bookingPIUAListByItiItem.get(itiItem.Id + '-' + room).contains(piuaClone)) {
                  bookingPIUAListByItiItem.get(itiItem.Id + '-' + room).add(piuaClone);
                }
              }
            }
          }
        }
      }
    } else {
      for (RM_SeatingToolWrappers.ManagementLegWrapper itinerary : wrappedItineraries) {
        for (KaptioTravel__Itinerary_Item__c itiItem : itiItemList) {
          if (itinerary.route == itiItem.KaptioTravel__ExternalItemName__c) {
            if (!itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c)) {
              itiItemListByItiRoute.put(itiItem.KaptioTravel__Itinerary__c, new List<KaptioTravel__Itinerary_Item__c>{ itiItem });
            } else {
              itiItemListByItiRoute.get(itiItem.KaptioTravel__Itinerary__c).add(itiItem);
            }

            if (!itiItemListByRoute.containsKey(itiItem.KaptioTravel__Itinerary__c)) {
              itiItemListByRoute.put(itiItem.KaptioTravel__Itinerary__c, new List<String>{ itiItem.KaptioTravel__ExternalItemName__c });
            } else if (!itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains(itiItem.KaptioTravel__ExternalItemName__c)) {
              itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).add(itiItem.KaptioTravel__ExternalItemName__c);
            }
          }
        }
      }

      for (RM_SeatingToolWrappers.ManagementLegWrapper itinerary : wrappedItineraries) {
        for (KaptioTravel__Itinerary_Item__c itiItem : itiItemList) {
          if (
            !itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c + '-' + itinerary.route) &&
            itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c) &&
            !itiItemListByRoute.get(itiItem.KaptioTravel__Itinerary__c).contains(itinerary.route)
          ) {
            KaptioTravel__Itinerary_Item__c itiItemClone = itiItem.clone(false, false, false, false);
            itiItemClone.Id = getFakeId(KaptioTravel__Itinerary_Item__c.sObjectType, sizeOfPIUA2UpdateMap);
            sizeOfPIUA2UpdateMap++;
            itiItemClone.KaptioTravel__ExternalItemName__c = itinerary.route;
            itiItemListByItiRoute.put(
              itiItem.KaptioTravel__Itinerary__c +
              '-' +
              itinerary.route,
              new List<KaptioTravel__Itinerary_Item__c>{ itiItemClone }
            );
          }
        }
      }

      for (String route : itiItemListByItiRoute.keySet()) {
        for (KaptioTravel__Itinerary_Item__c itiItem : itiItemListByItiRoute.get(route)) {
          if (itiItemListByItiRoute.containsKey(itiItem.KaptioTravel__Itinerary__c + '-' + route.substringAfter('-')) && route.contains('-')) {
            for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : itiItem.KaptioTravel__PassengerItineraryUnitAssignments__r) {
              if (
                piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c == itiItem.KaptioTravel__Itinerary__c &&
                piua.KaptioTravel__ItineraryItem__c == itiItem.getCloneSourceId()
              ) {
                KaptioTravel__PassengerItineraryUnitAssignment__c piuaClone = piua.clone(false, false, false, false);
                piuaClone.Id = getFakeId(KaptioTravel__PassengerItineraryUnitAssignment__c.sObjectType, sizeOfPIUA2UpdateMap);
                sizeOfPIUA2UpdateMap++;

                piuaClone.KaptioTravel__ItineraryItem__c = itiItem.Id;
                piuaClone.KaptioTravel__ItineraryItem__r = itiItem;

                String room = piuaClone.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c == null
                  ? '00'
                  : String.valueOf(piuaClone.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c).length() == 1
                      ? '0' + String.valueOf(piuaClone.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c)
                      : String.valueOf(piuaClone.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c);

                if (!bookingPIUAListByItiItem.containsKey(itiItem.Id)) {
                  bookingPIUAListByItiItem.put(itiItem.Id, new List<KaptioTravel__PassengerItineraryUnitAssignment__c>{ piuaClone });
                } else if (!bookingPIUAListByItiItem.get(itiItem.Id).contains(piuaClone)) {
                  bookingPIUAListByItiItem.get(itiItem.Id).add(piuaClone);
                }

                if (!bookingPIUAListByItiItem.containsKey(itiItem.Id + '-' + room)) {
                  bookingPIUAListByItiItem.put(itiItem.Id + '-' + room, new List<KaptioTravel__PassengerItineraryUnitAssignment__c>{ piuaClone });
                } else if (!bookingPIUAListByItiItem.get(itiItem.Id + '-' + room).contains(piuaClone)) {
                  bookingPIUAListByItiItem.get(itiItem.Id + '-' + room).add(piuaClone);
                }
              }
            }
          }
        }
      }
    }

    for (String itiItem : bookingPIUAListByItiItem.keySet()) {
      for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : bookingPIUAListByItiItem.get(itiItem)) {
        String routeKey = String.valueOf(routeList.indexOf(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c)).length() == 1
          ? '0' + String.valueOf(routeList.indexOf(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c))
          : String.valueOf(routeList.indexOf(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c));

        String room = piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c == null
          ? '00'
          : String.valueOf(piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c).length() == 1
              ? '0' + String.valueOf(piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c)
              : String.valueOf(piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c);

        if (
          !piuaByBookingItiItemPax.containsKey(
            piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c +
            '-' +
            routeKey +
            '-' +
            room +
            '-' +
            piua.KaptioTravel__Passenger__c
          )
        ) {
          piuaByBookingItiItemPax.put(
            piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c +
            '-' +
            routeKey +
            '-' +
            room +
            '-' +
            piua.KaptioTravel__Passenger__c,
            piua
          );
        }
      }
    }

    return piuaByBookingItiItemPax;
  }

  /**
   * @description Sort Linked PIUA records
   * @author Anderson Morino | 04-05-2023
   * @param bookingPIUAListByItiItem
   * @param routeList
   * @param isLinked
   * @return Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>
   **/
  public Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c> sortPIUAList(
    Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingPIUAListByItiItem,
    List<String> routeList,
    Boolean isLinked
  ) {
    Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c> piuaByBookingItiItemPax = new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>();
    List<String> mobItinerariesRoomList = new List<String>();
    List<String> mobLinkedItinerariesList = new List<String>();

    for (String itiItem : bookingPIUAListByItiItem.keySet()) {
      for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : bookingPIUAListByItiItem.get(itiItem)) {
        String routeKey = String.valueOf(routeList.indexOf(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c)).length() == 1
          ? '0' + String.valueOf(routeList.indexOf(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c))
          : String.valueOf(routeList.indexOf(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c));

        String mobilityKey = piua.KaptioTravel__Passenger__r.Mobility_Needs__c ? 'hasMob' : 'noMob';

        String room = piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c == null
          ? '00'
          : String.valueOf(piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c).length() == 1
              ? '0' + String.valueOf(piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c)
              : String.valueOf(piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c);

        String bookingPIUAKey = !isLinked
          ? String.valueOf(piua.KaptioTravel__ItineraryItem__c)
          : piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c +
            '-' +
            String.valueOf(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c);

        String itineraryId = String.valueOf(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c);

        if (!isLinked) {
          if (!mobItinerariesRoomList.contains(bookingPIUAKey + '-' + room) && piua.KaptioTravel__Passenger__r.Mobility_Needs__c) {
            mobItinerariesRoomList.add(bookingPIUAKey + '-' + room);
            room = String.valueOf(piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c).length() == 1 ? '000' + room : '00' + room;
          } else if (mobItinerariesRoomList.contains(bookingPIUAKey + '-' + room)) {
            room = String.valueOf(piua.KaptioTravel__Passenger__r.KaptioTravel__AllocationId__c).length() == 1 ? '000' + room : '00' + room;
          }
        } else {
          if (!mobLinkedItinerariesList.contains(bookingPIUAKey + '-' + itineraryId) && piua.KaptioTravel__Passenger__r.Mobility_Needs__c) {
            mobLinkedItinerariesList.add(bookingPIUAKey + '-' + itineraryId);
            itineraryId = '0' + itineraryId;
          } else if (mobLinkedItinerariesList.contains(bookingPIUAKey + '-' + itineraryId)) {
            itineraryId = '0' + itineraryId;
          }
        }

        String piuaKey = !isLinked
          ? itineraryId + '-' + routeKey + '-' + room + '-' + mobilityKey + '-' + String.valueOf(piua.KaptioTravel__Passenger__c)
          : String.valueOf(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.LinkedItinerary__c) +
            '-' +
            routeKey +
            '-' +
            itineraryId +
            '-' +
            mobilityKey +
            '-' +
            room +
            '-' +
            String.valueOf(piua.KaptioTravel__Passenger__c);

        if (!piuaByBookingItiItemPax.containsKey(piuaKey)) {
          piuaByBookingItiItemPax.put(piuaKey, piua);
        }
      }
    }

    return piuaByBookingItiItemPax;
  }

  /**
   * @description Check if the booking has GoldLeaf LAK guests and over 36 guests
   * @author Anderson Morino | 05-08-2023
   * @param routeList
   * @param piua
   * @param availableSeatsByRailcarIdKey
   * @param hasExecuted
   * @param bookingPIUAListByItiItem
   * @return Boolean
   **/
  public Boolean isLAKGLOver36Guests(
    List<String> routeList,
    KaptioTravel__PassengerItineraryUnitAssignment__c piua,
    String availableSeatsByRailcarIdKey,
    Boolean hasExecutedLAKGL,
    Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingPIUAListByItiItem,
    String bookingPIUAListByItiItemKey,
    Map<String, RM_SeatingToolWrappers.RailcarWrapper> availableSeatsByRailcarId
  ) {
    Boolean isLAKGLOver36 = routeList.contains('Lake Louise to Kamloops') &&
      piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Price_Category__r.Name == 'GoldLeaf Adult' &&
      !hasExecutedLAKGL &&
      bookingPIUAListByItiItem.containsKey(bookingPIUAListByItiItemKey) &&
      bookingPIUAListByItiItem.get(bookingPIUAListByItiItemKey).size() > 36 &&
      availableSeatsByRailcarId.containsKey(availableSeatsByRailcarIdKey) &&
      availableSeatsByRailcarId.get(availableSeatsByRailcarIdKey).seatsCapacity == 36
      ? true
      : false;

    return isLAKGLOver36;
  }
}
// END - Ticket #39453 / #40026 / #40010 / #39498 / #39117 / #37921
// END - Ticket #32134 / #39498 / #40024 / #40025 / #40026
// END - Ticket #40446 / #40408 / #40046 / #40045 / #40023 / #40022 / #39836 / #39117
// END - Ticket #39117 / #40707 / #40408 / #40326 / #40064 / #40063 / #40054 / #40050 / #39502 / #39232
// END - Ticket #41032 / #41033 / #41003 / #30715 / #41034 / #40880 / #40065 / #40818 / #40869 / #40868 / #41037
