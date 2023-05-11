/**
 * @description       : Pre-Batch to only get and order bookings data prior to execute all business rules to seat their piua records
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
// BEGINNING - Ticket #35471 - Pre-Batch to only get and order bookings data prior to execute all business rules to seat their piua records
// BEGINNING - Ticket #37921 / #31294 - Added list of routes and call the business method only if there are elegible bookings
// BEGINNING - Ticket #38145 / #38487 / #38498 / #38790 - Sort data in order to start the LAK seating process
// BEGINNING - Ticket #39745 / #39544 / #39498 / #37922 / #37921 / #32134 / #31236 - Fixed bugs when seating bookings, improving the order of bookings and passengers by Room Id
global class RM_SeatingTool_DataSorting_Batch implements Database.Batchable<sObject>, Database.Stateful {
  private List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries;
  private RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup;
  private List<Id> batchJobIdList;
  private Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap;
  private RM_ROS_IntegrationWrapper.TRAIN trainInfo;
  private Integer sizeOfPIUA2UpdateMap;
  private Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper> mapMobility_Railcar;
  private List<String> routeList;
  private Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c> railcarIdByLAKGLBookingPIUAOver36;
  private List<KaptioTravel__Itinerary_Item__c> bookingList;

  public RM_SeatingTool_DataSorting_Batch(
    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries,
    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup,
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
    Map<Id, KaptioTravel__Itinerary_Item__c> lakeLouiseSLScopeMap = new Map<Id, KaptioTravel__Itinerary_Item__c>();
    Map<Id, KaptioTravel__Itinerary_Item__c> lakeLouiseGLScopeMap = new Map<Id, KaptioTravel__Itinerary_Item__c>();
    Map<Id, KaptioTravel__Itinerary_Item__c> circleJourneyScopeMap = new Map<Id, KaptioTravel__Itinerary_Item__c>();
    Map<Id, KaptioTravel__Itinerary_Item__c> silverLeafScopeMap = new Map<Id, KaptioTravel__Itinerary_Item__c>();
    Map<Id, KaptioTravel__Itinerary_Item__c> goldLeafScopeMap = new Map<Id, KaptioTravel__Itinerary_Item__c>();
    Map<Id, KaptioTravel__Itinerary_Item__c> silverLeafPlusScopeMap = new Map<Id, KaptioTravel__Itinerary_Item__c>();
    Map<Id, KaptioTravel__Itinerary_Item__c> scopeMap = new Map<Id, KaptioTravel__Itinerary_Item__c>();

    String testChecker = Test.isrunningTest() ? ' LIMIT 100' : '';

    if (!wrappedServiceClassGroup.wrappedSeatingBatchLAKSL.hasExecuted) {
      Map<Id, KaptioTravel__Itinerary_Item__c> trainBookingMap = new Map<Id, KaptioTravel__Itinerary_Item__c>();

      for (
        KaptioTravel__Itinerary_Item__c itiItem : (List<KaptioTravel__Itinerary_Item__c>) Database.query(
          RM_SeatingToolBatchHelper.getBookingsWithPIUA(wrappedItineraries) +
          ' AND KaptioTravel__Price_Category__r.Name = \'SilverLeaf Adult\'' +
          ' ORDER BY KaptioTravel__Itinerary__r.LinkedItinerary__c, KaptioTravel__Itinerary__c ASC' +
          testChecker
        )
      ) {
        trainBookingMap.put(itiItem.Id, itiItem);
      }

      List<KaptioTravel__PassengerItineraryUnitAssignment__c> bookingPIUAList = new List<KaptioTravel__PassengerItineraryUnitAssignment__c>();

      Map<String, List<String>> externalItemListByItineraryMap = new Map<String, List<String>>();

      for (KaptioTravel__Itinerary_Item__c itiItem : trainBookingMap.values()) {
        bookingPIUAList.addAll(itiItem.KaptioTravel__PassengerItineraryUnitAssignments__r);

        if (!externalItemListByItineraryMap.containsKey(itiItem.KaptioTravel__Itinerary__c)) {
          externalItemListByItineraryMap.put(itiItem.KaptioTravel__Itinerary__c, new List<String>{ itiItem.KaptioTravel__ExternalItemName__c });
        } else if (!externalItemListByItineraryMap.get(itiItem.KaptioTravel__Itinerary__c).contains(itiItem.KaptioTravel__ExternalItemName__c)) {
          externalItemListByItineraryMap.get(itiItem.KaptioTravel__Itinerary__c).add(itiItem.KaptioTravel__ExternalItemName__c);
        }
      }

      Set<Id> lakeLouisePassengerIdSet = new Set<Id>();

      for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : bookingPIUAList) {
        if (
          !lakeLouisePassengerIdSet.contains(piua.KaptioTravel__Passenger__c) &&
          externalItemListByItineraryMap.containsKey(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c) &&
          ((piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c == 'Kamloops to Lake Louise' &&
          !externalItemListByItineraryMap.get(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c).contains('Lake Louise to Banff')) ||
          (piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c == 'Lake Louise to Kamloops' &&
          !externalItemListByItineraryMap.get(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c).contains('Banff to Lake Louise')))
        ) {
          lakeLouisePassengerIdSet.add(piua.KaptioTravel__Passenger__c);
        }
      }

      for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : bookingPIUAList) {
        if (
          lakeLouisePassengerIdSet.contains(piua.KaptioTravel__Passenger__c) && !lakeLouiseSLScopeMap.containsKey(piua.KaptioTravel__ItineraryItem__c)
        ) {
          lakeLouiseSLScopeMap.put(piua.KaptioTravel__ItineraryItem__c, trainBookingMap.get(piua.KaptioTravel__ItineraryItem__c));

          if (!bookingList.contains(trainBookingMap.get(piua.KaptioTravel__ItineraryItem__c))) {
            bookingList.add(trainBookingMap.get(piua.KaptioTravel__ItineraryItem__c));
          }
        }
      }

      if (lakeLouiseSLScopeMap.isEmpty()) {
        wrappedServiceClassGroup.wrappedSeatingBatchLAKSL.hasExecuted = true;
      }
    }

    if (!wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.hasExecuted) {
      Map<Id, KaptioTravel__Itinerary_Item__c> trainBookingMap = new Map<Id, KaptioTravel__Itinerary_Item__c>();

      for (
        KaptioTravel__Itinerary_Item__c itiItem : (List<KaptioTravel__Itinerary_Item__c>) Database.query(
          RM_SeatingToolBatchHelper.getBookingsWithPIUA(wrappedItineraries) +
          ' AND KaptioTravel__Price_Category__r.Name = \'GoldLeaf Adult\'' +
          ' ORDER BY KaptioTravel__Itinerary__c ASC' +
          testChecker
        )
      ) {
        trainBookingMap.put(itiItem.Id, itiItem);
      }

      List<KaptioTravel__PassengerItineraryUnitAssignment__c> bookingPIUAList = new List<KaptioTravel__PassengerItineraryUnitAssignment__c>();

      Map<String, List<String>> externalItemListByItineraryMap = new Map<String, List<String>>();

      for (KaptioTravel__Itinerary_Item__c itiItem : trainBookingMap.values()) {
        bookingPIUAList.addAll(itiItem.KaptioTravel__PassengerItineraryUnitAssignments__r);

        if (!externalItemListByItineraryMap.containsKey(itiItem.KaptioTravel__Itinerary__c)) {
          externalItemListByItineraryMap.put(itiItem.KaptioTravel__Itinerary__c, new List<String>{ itiItem.KaptioTravel__ExternalItemName__c });
        } else if (!externalItemListByItineraryMap.get(itiItem.KaptioTravel__Itinerary__c).contains(itiItem.KaptioTravel__ExternalItemName__c)) {
          externalItemListByItineraryMap.get(itiItem.KaptioTravel__Itinerary__c).add(itiItem.KaptioTravel__ExternalItemName__c);
        }
      }

      Set<Id> lakeLouisePassengerIdSet = new Set<Id>();

      for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : bookingPIUAList) {
        if (
          !lakeLouisePassengerIdSet.contains(piua.KaptioTravel__Passenger__c) &&
          externalItemListByItineraryMap.containsKey(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c) &&
          ((piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c == 'Kamloops to Lake Louise' &&
          !externalItemListByItineraryMap.get(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c).contains('Lake Louise to Banff')) ||
          (piua.KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c == 'Lake Louise to Kamloops' &&
          !externalItemListByItineraryMap.get(piua.KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c).contains('Banff to Lake Louise')))
        ) {
          lakeLouisePassengerIdSet.add(piua.KaptioTravel__Passenger__c);
        }
      }

      for (KaptioTravel__PassengerItineraryUnitAssignment__c piua : bookingPIUAList) {
        if (
          lakeLouisePassengerIdSet.contains(piua.KaptioTravel__Passenger__c) && !lakeLouiseGLScopeMap.containsKey(piua.KaptioTravel__ItineraryItem__c)
        ) {
          lakeLouiseGLScopeMap.put(piua.KaptioTravel__ItineraryItem__c, trainBookingMap.get(piua.KaptioTravel__ItineraryItem__c));

          if (!bookingList.contains(trainBookingMap.get(piua.KaptioTravel__ItineraryItem__c))) {
            bookingList.add(trainBookingMap.get(piua.KaptioTravel__ItineraryItem__c));
          }
        }
      }

      if (lakeLouiseGLScopeMap.isEmpty()) {
        wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.hasExecuted = true;
      }
    }

    if (!wrappedServiceClassGroup.wrappedSeatingBatchCJ.hasExecuted) {
      for (
        KaptioTravel__Itinerary_Item__c itiItem : (List<KaptioTravel__Itinerary_Item__c>) Database.query(
          RM_SeatingToolBatchHelper.getBookingsWithPIUA(wrappedItineraries) +
          ' AND KaptioTravel__Itinerary__r.CircleJourney__c = TRUE' +
          ' AND KaptioTravel__Price_Category__r.Name = \'GoldLeaf Adult\'' +
          ' ORDER BY KaptioTravel__Itinerary__c ASC' +
          testChecker
        )
      ) {
        if (
          (itiItem.KaptioTravel__Itinerary__r.LinkedItinerary__c == null &&
          !wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.wrappedSeatingRule.itinerarySet.contains(itiItem.KaptioTravel__Itinerary__c)) ||
          (itiItem.KaptioTravel__Itinerary__r.LinkedItinerary__c != null &
          !wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.wrappedSeatingRule.linkedItinerarySet.contains(
            itiItem.KaptioTravel__Itinerary__r.LinkedItinerary__c
          ))
        ) {
          circleJourneyScopeMap.put(itiItem.Id, itiItem);

          if (!bookingList.contains(itiItem)) {
            bookingList.add(itiItem);
          }
        }
      }

      if (circleJourneyScopeMap.isEmpty()) {
        wrappedServiceClassGroup.wrappedSeatingBatchCJ.hasExecuted = true;
      }
    }

    if (
      wrappedServiceClassGroup.wrappedSeatingBatchLAKSL.hasExecuted &&
      wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.hasExecuted &&
      wrappedServiceClassGroup.wrappedSeatingBatchCJ.hasExecuted
    ) {
      if (!wrappedServiceClassGroup.wrappedSeatingBatchSL.hasExecuted) {
        for (
          KaptioTravel__Itinerary_Item__c itiItem : (List<KaptioTravel__Itinerary_Item__c>) Database.query(
            RM_SeatingToolBatchHelper.getBookingsWithPIUA(wrappedItineraries) +
            ' AND KaptioTravel__Price_Category__r.Name = \'SilverLeaf Adult\'' +
            ' ORDER BY KaptioTravel__Itinerary__c ASC' +
            testChecker
          )
        ) {
          if (
            (itiItem.KaptioTravel__Itinerary__r.LinkedItinerary__c == null &&
            !wrappedServiceClassGroup.wrappedSeatingBatchLAKSL.wrappedSeatingRule.itinerarySet.contains(itiItem.KaptioTravel__Itinerary__c)) ||
            (itiItem.KaptioTravel__Itinerary__r.LinkedItinerary__c != null &
            !wrappedServiceClassGroup.wrappedSeatingBatchLAKSL.wrappedSeatingRule.linkedItinerarySet.contains(
              itiItem.KaptioTravel__Itinerary__r.LinkedItinerary__c
            ))
          ) {
            silverLeafScopeMap.put(itiItem.Id, itiItem);

            if (!bookingList.contains(itiItem)) {
              bookingList.add(itiItem);
            }
          }
        }

        if (silverLeafScopeMap.isEmpty()) {
          wrappedServiceClassGroup.wrappedSeatingBatchSL.hasExecuted = true;
        }
      }

      if (!wrappedServiceClassGroup.wrappedSeatingBatchGL.hasExecuted) {
        for (
          KaptioTravel__Itinerary_Item__c itiItem : (List<KaptioTravel__Itinerary_Item__c>) Database.query(
            RM_SeatingToolBatchHelper.getBookingsWithPIUA(wrappedItineraries) +
            ' AND KaptioTravel__Price_Category__r.Name = \'GoldLeaf Adult\'' +
            ' ORDER BY KaptioTravel__Itinerary__c ASC' +
            testChecker
          )
        ) {
          if (
            (itiItem.KaptioTravel__Itinerary__r.LinkedItinerary__c == null &&
            !wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.wrappedSeatingRule.itinerarySet.contains(itiItem.KaptioTravel__Itinerary__c) &&
            !wrappedServiceClassGroup.wrappedSeatingBatchCJ.wrappedSeatingRule.itinerarySet.contains(itiItem.KaptioTravel__Itinerary__c)) ||
            (itiItem.KaptioTravel__Itinerary__r.LinkedItinerary__c != null &&
            !wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.wrappedSeatingRule.linkedItinerarySet.contains(
              itiItem.KaptioTravel__Itinerary__r.LinkedItinerary__c
            ) &&
            !wrappedServiceClassGroup.wrappedSeatingBatchCJ.wrappedSeatingRule.linkedItinerarySet.contains(
              itiItem.KaptioTravel__Itinerary__r.LinkedItinerary__c
            ))
          ) {
            goldLeafScopeMap.put(itiItem.Id, itiItem);

            if (!bookingList.contains(itiItem)) {
              bookingList.add(itiItem);
            }
          }
        }

        if (goldLeafScopeMap.isEmpty()) {
          wrappedServiceClassGroup.wrappedSeatingBatchGL.hasExecuted = true;
        }
      }

      if (!wrappedServiceClassGroup.wrappedSeatingBatchSLP.hasExecuted) {
        for (
          KaptioTravel__Itinerary_Item__c itiItem : (List<KaptioTravel__Itinerary_Item__c>) Database.query(
            RM_SeatingToolBatchHelper.getBookingsWithPIUA(wrappedItineraries) +
            ' AND KaptioTravel__Price_Category__r.Name = \'SilverLeaf Plus Adult\'' +
            ' ORDER BY KaptioTravel__Itinerary__c ASC' +
            testChecker
          )
        ) {
          silverLeafPlusScopeMap.put(itiItem.Id, itiItem);

          if (!bookingList.contains(itiItem)) {
            bookingList.add(itiItem);
          }
        }

        if (silverLeafPlusScopeMap.isEmpty()) {
          wrappedServiceClassGroup.wrappedSeatingBatchSLP.hasExecuted = true;
        }
      }
    }

    if (!wrappedServiceClassGroup.wrappedSeatingBatchLAKSL.hasExecuted) {
      return lakeLouiseSLScopeMap.values();
    } else if (!wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.hasExecuted) {
      return lakeLouiseGLScopeMap.values();
    } else if (!wrappedServiceClassGroup.wrappedSeatingBatchCJ.hasExecuted) {
      return circleJourneyScopeMap.values();
    } else if (!wrappedServiceClassGroup.wrappedSeatingBatchSL.hasExecuted) {
      return silverLeafScopeMap.values();
    } else if (!wrappedServiceClassGroup.wrappedSeatingBatchGL.hasExecuted) {
      return goldLeafScopeMap.values();
    } else if (!wrappedServiceClassGroup.wrappedSeatingBatchSLP.hasExecuted) {
      return silverLeafPlusScopeMap.values();
    }

    return scopeMap.values();
  }

  global void execute(Database.BatchableContext BC, List<KaptioTravel__Itinerary_Item__c> scope) {
    if (!wrappedServiceClassGroup.wrappedSeatingBatchLAKSL.hasExecuted) {
      RM_SeatingToolBatchHelper.getItinerariesByTransferSort(
        scope,
        wrappedServiceClassGroup.wrappedSeatingBatchLAKSL.wrappedSeatingRule,
        'SilverLeaf Adult'
      );

      return;
    } else if (!wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.hasExecuted) {
      RM_SeatingToolBatchHelper.getItinerariesByTransferSort(
        scope,
        wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.wrappedSeatingRule,
        'GoldLeaf Adult'
      );

      return;
    } else if (!wrappedServiceClassGroup.wrappedSeatingBatchCJ.hasExecuted) {
      RM_SeatingToolBatchHelper.getItinerariesByTransferSort(
        scope,
        wrappedServiceClassGroup.wrappedSeatingBatchCJ.wrappedSeatingRule,
        'GoldLeaf Adult'
      );

      return;
    } else {
      if (!wrappedServiceClassGroup.wrappedSeatingBatchSL.hasExecuted) {
        RM_SeatingToolBatchHelper.getItinerariesByTransferSort(
          scope,
          wrappedServiceClassGroup.wrappedSeatingBatchSL.wrappedSeatingRule,
          'SilverLeaf Adult'
        );

        return;
      } else if (!wrappedServiceClassGroup.wrappedSeatingBatchGL.hasExecuted) {
        RM_SeatingToolBatchHelper.getItinerariesByTransferSort(
          scope,
          wrappedServiceClassGroup.wrappedSeatingBatchGL.wrappedSeatingRule,
          'GoldLeaf Adult'
        );

        return;
      } else if (!wrappedServiceClassGroup.wrappedSeatingBatchSLP.hasExecuted) {
        RM_SeatingToolBatchHelper.getItinerariesByTransferSort(
          scope,
          wrappedServiceClassGroup.wrappedSeatingBatchSLP.wrappedSeatingRule,
          'SilverLeaf Plus Adult'
        );

        return;
      }
    }
  }

  // BEGINNING - Ticket #39505 - Fixed to synch railcarSeatMap subtracting for following processes
  global void finish(Database.BatchableContext BC) {
    // ticket 30718 START
    if (bookingList.isEmpty() && this.trainInfo != null) {
      RM_SeatingToolBatchHelper seatTool = RM_SeatingToolBatchHelper.getInstance();
      seatTool.sendNoBookingsEmail(this.trainInfo, 'No Bookings');
    }
    // ticket 30718 ENDS

    if (!wrappedServiceClassGroup.wrappedSeatingBatchLAKSL.hasExecuted) {
      Id lakeLouiseSLBatchJobId = Database.executeBatch(
        new RM_SeatingTool_LakeLouise_Batch(
          wrappedItineraries,
          wrappedServiceClassGroup,
          wrappedServiceClassGroup.wrappedSeatingBatchLAKSL,
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
      batchJobIdList.add(lakeLouiseSLBatchJobId);
      if (Test.isRunningTest()) {
        system.abortJob(lakeLouiseSLBatchJobId);
      }
      return;
    } else if (!wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.hasExecuted) {
      Id lakeLouiseGLBatchJobId = Database.executeBatch(
        new RM_SeatingTool_LakeLouise_Batch(
          wrappedItineraries,
          wrappedServiceClassGroup,
          wrappedServiceClassGroup.wrappedSeatingBatchLAKGL,
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
      batchJobIdList.add(lakeLouiseGLBatchJobId);
      if (Test.isRunningTest()) {
        system.abortJob(lakeLouiseGLBatchJobId);
      }
      return;
    } else if (!wrappedServiceClassGroup.wrappedSeatingBatchCJ.hasExecuted) {
      if (wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.hasExecuted) {
        for (Integer i = 0; i < wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.mapKeySet.size(); i++) {
          // BEGINNING - Ticket #35471 - Fixed to get the right key to sync occupied seats from LAK to Circle Journey RailcarSeatMap
          String wrappedKey =
            wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.railcarSeatMap.get(wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.mapKeySet[i])
              .routeKey +
            '-' +
            wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.railcarSeatMap.get(wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.mapKeySet[i])
              .railcarSeriesKey +
            '-' +
            wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.railcarSeatMap.get(wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.mapKeySet[i])
              .railcarOrderKey +
            '-' +
            wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.railcarSeatMap.get(wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.mapKeySet[i])
              .railcarId +
            '-' +
            wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.railcarSeatMap.get(wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.mapKeySet[i])
              .railcarSeatKey;

          if (
            wrappedServiceClassGroup.wrappedSeatingBatchCJ.railcarSeatMap.containsKey(wrappedKey) &&
            wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.railcarSeatMap.get(wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.mapKeySet[i])
              .occupied
          ) {
            wrappedServiceClassGroup.wrappedSeatingBatchCJ.railcarSeatMap.put(
              wrappedKey,
              wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.railcarSeatMap.get(wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.mapKeySet[i])
            );
          }
          // END - Ticket #35471
        }

        for (String routeRailcarKey : wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.availableSeatsByRailcarId.keySet()) {
          if (wrappedServiceClassGroup.wrappedSeatingBatchCJ.availableSeatsByRailcarId.containsKey(routeRailcarKey)) {
            wrappedServiceClassGroup.wrappedSeatingBatchCJ.availableSeatsByRailcarId.get(routeRailcarKey).seatsCapacity = routeList.contains(
                'Lake Louise to Kamloops'
              )
              ? (wrappedServiceClassGroup.wrappedSeatingBatchCJ.availableSeatsByRailcarId.get(routeRailcarKey).seatsCapacity - 36) +
                wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.availableSeatsByRailcarId.get(routeRailcarKey).seatsCapacity
              : wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.availableSeatsByRailcarId.get(routeRailcarKey).seatsCapacity;
          }
        }
      }

      Id circleJourneyBatchJobId = Database.executeBatch(
        new RM_SeatingTool_CircleJourney_Batch(
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
      batchJobIdList.add(circleJourneyBatchJobId);
      if (Test.isRunningTest()) {
        system.abortJob(circleJourneyBatchJobId);
      }
      return;
    } else {
      if (!wrappedServiceClassGroup.wrappedSeatingBatchSL.hasExecuted) {
        if (wrappedServiceClassGroup.wrappedSeatingBatchLAKSL.hasExecuted) {
          for (Integer i = 0; i < wrappedServiceClassGroup.wrappedSeatingBatchLAKSL.mapKeySet.size(); i++) {
            if (
              wrappedServiceClassGroup.wrappedSeatingBatchSL.railcarSeatMap.containsKey(
                wrappedServiceClassGroup.wrappedSeatingBatchLAKSL.mapKeySet[i]
              ) &&
              wrappedServiceClassGroup.wrappedSeatingBatchLAKSL.railcarSeatMap.get(wrappedServiceClassGroup.wrappedSeatingBatchLAKSL.mapKeySet[i])
                .occupied
            ) {
              wrappedServiceClassGroup.wrappedSeatingBatchSL.railcarSeatMap.put(
                wrappedServiceClassGroup.wrappedSeatingBatchLAKSL.mapKeySet[i],
                wrappedServiceClassGroup.wrappedSeatingBatchLAKSL.railcarSeatMap.get(wrappedServiceClassGroup.wrappedSeatingBatchLAKSL.mapKeySet[i])
              );
            }
          }

          for (String routeRailcarKey : wrappedServiceClassGroup.wrappedSeatingBatchLAKSL.availableSeatsByRailcarId.keySet()) {
            if (wrappedServiceClassGroup.wrappedSeatingBatchSL.availableSeatsByRailcarId.containsKey(routeRailcarKey)) {
              wrappedServiceClassGroup.wrappedSeatingBatchSL.availableSeatsByRailcarId.get(routeRailcarKey)
                .seatsCapacity = wrappedServiceClassGroup.wrappedSeatingBatchLAKSL.availableSeatsByRailcarId.get(routeRailcarKey).seatsCapacity;
            }
          }
        }

        Id emailNotificationSLBatchJobId = Database.executeBatch(
          new RM_SeatingTool_EmailNotification_Batch(
            wrappedItineraries,
            wrappedServiceClassGroup,
            wrappedServiceClassGroup.wrappedSeatingBatchSL,
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
        batchJobIdList.add(emailNotificationSLBatchJobId);
        if (Test.isRunningTest()) {
          system.abortJob(emailNotificationSLBatchJobId);
        }
        return;
      } else if (!wrappedServiceClassGroup.wrappedSeatingBatchGL.hasExecuted) {
        if (wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.hasExecuted) {
          for (Integer i = 0; i < wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.mapKeySet.size(); i++) {
            if (
              wrappedServiceClassGroup.wrappedSeatingBatchGL.railcarSeatMap.containsKey(
                wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.mapKeySet[i]
              ) &&
              wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.railcarSeatMap.get(wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.mapKeySet[i])
                .occupied
            ) {
              wrappedServiceClassGroup.wrappedSeatingBatchGL.railcarSeatMap.put(
                wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.mapKeySet[i],
                wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.railcarSeatMap.get(wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.mapKeySet[i])
              );
            }
          }

          for (String routeRailcarKey : wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.availableSeatsByRailcarId.keySet()) {
            if (wrappedServiceClassGroup.wrappedSeatingBatchGL.availableSeatsByRailcarId.containsKey(routeRailcarKey)) {
              wrappedServiceClassGroup.wrappedSeatingBatchGL.availableSeatsByRailcarId.get(routeRailcarKey).seatsCapacity = routeList.contains(
                  'Lake Louise to Kamloops'
                )
                ? (wrappedServiceClassGroup.wrappedSeatingBatchGL.availableSeatsByRailcarId.get(routeRailcarKey).seatsCapacity - 36) +
                  wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.availableSeatsByRailcarId.get(routeRailcarKey).seatsCapacity
                : wrappedServiceClassGroup.wrappedSeatingBatchLAKGL.availableSeatsByRailcarId.get(routeRailcarKey).seatsCapacity;
            }
          }
        }

        if (wrappedServiceClassGroup.wrappedSeatingBatchCJ.hasExecuted) {
          for (Integer i = 0; i < wrappedServiceClassGroup.wrappedSeatingBatchCJ.mapKeySet.size(); i++) {
            // BEGINNING - Ticket #35471 - Fixed to get the right key to sync occupied seats from LAK to Circle Journey RailcarSeatMap
            String wrappedKey =
              wrappedServiceClassGroup.wrappedSeatingBatchCJ.railcarSeatMap.get(wrappedServiceClassGroup.wrappedSeatingBatchCJ.mapKeySet[i])
                .routeKey +
              '-' +
              wrappedServiceClassGroup.wrappedSeatingBatchCJ.railcarSeatMap.get(wrappedServiceClassGroup.wrappedSeatingBatchCJ.mapKeySet[i])
                .railcarOrderKey +
              '-' +
              wrappedServiceClassGroup.wrappedSeatingBatchCJ.railcarSeatMap.get(wrappedServiceClassGroup.wrappedSeatingBatchCJ.mapKeySet[i])
                .railcarId +
              '-' +
              wrappedServiceClassGroup.wrappedSeatingBatchCJ.railcarSeatMap.get(wrappedServiceClassGroup.wrappedSeatingBatchCJ.mapKeySet[i])
                .railcarSeatKey;

            if (
              wrappedServiceClassGroup.wrappedSeatingBatchGL.railcarSeatMap.containsKey(wrappedKey) &&
              wrappedServiceClassGroup.wrappedSeatingBatchCJ.railcarSeatMap.get(wrappedServiceClassGroup.wrappedSeatingBatchCJ.mapKeySet[i]).occupied
            ) {
              wrappedServiceClassGroup.wrappedSeatingBatchGL.railcarSeatMap.put(
                wrappedKey,
                wrappedServiceClassGroup.wrappedSeatingBatchCJ.railcarSeatMap.get(wrappedServiceClassGroup.wrappedSeatingBatchCJ.mapKeySet[i])
              );
            }
          }

          for (String routeRailcarKey : wrappedServiceClassGroup.wrappedSeatingBatchCJ.availableSeatsByRailcarId.keySet()) {
            if (wrappedServiceClassGroup.wrappedSeatingBatchGL.availableSeatsByRailcarId.containsKey(routeRailcarKey)) {
              wrappedServiceClassGroup.wrappedSeatingBatchGL.availableSeatsByRailcarId.get(routeRailcarKey)
                .seatsCapacity = wrappedServiceClassGroup.wrappedSeatingBatchCJ.availableSeatsByRailcarId.get(routeRailcarKey).seatsCapacity;
            }
          }
        }

        Id emailNotificationGLBatchJobId = Database.executeBatch(
          new RM_SeatingTool_EmailNotification_Batch(
            wrappedItineraries,
            wrappedServiceClassGroup,
            wrappedServiceClassGroup.wrappedSeatingBatchGL,
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
        batchJobIdList.add(emailNotificationGLBatchJobId);
        if (Test.isRunningTest()) {
          System.AbortJob(emailNotificationGLBatchJobId);
        }
        return;
      } else if (!wrappedServiceClassGroup.wrappedSeatingBatchSLP.hasExecuted) {
        Id emailNotificationSLPBatchJobId = Database.executeBatch(
          new RM_SeatingTool_EmailNotification_Batch(
            wrappedItineraries,
            wrappedServiceClassGroup,
            wrappedServiceClassGroup.wrappedSeatingBatchSLP,
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
        batchJobIdList.add(emailNotificationSLPBatchJobId);
        if (Test.isRunningTest()) {
          system.abortJob(emailNotificationSLPBatchJobId);
        }
        return;
      } else {
        if (!piua2UpdateMap.isEmpty()) {
          for (Id piuaId : piua2UpdateMap.keySet()) {
            if (piua2UpdateMap.get(piuaId).isClone()) {
              piua2UpdateMap.remove(piuaId);
            }
          }

          Id piua2UpdateBatchJobId = Database.executeBatch(new RM_SeatingTool_PIUA2Update_Batch(piua2UpdateMap.values()), 100);

          batchJobIdList.add(piua2UpdateBatchJobId);
        }

        List<KaptioTravel__PassengerItineraryUnitAssignment__c> piuaSpecialMobility2Notify = new List<KaptioTravel__PassengerItineraryUnitAssignment__c>();
        Set<String> mobilityPassengerSet = new Set<String>();

        List<String> routeRailcarIdList = new List<String>();
        routeRailcarIdList.addAll(mapMobility_Railcar.keySet());

        for (Integer i = 0; i < routeRailcarIdList.size(); i++) {
          if (mapMobility_Railcar.containsKey(routeRailcarIdList[i]) && !mapMobility_Railcar.get(routeRailcarIdList[i]).mobilityPIUAList.isEmpty()) {
            piuaSpecialMobility2Notify.addAll(mapMobility_Railcar.get(routeRailcarIdList[i]).mobilityPIUAList);
          }
        }

        if (!piuaSpecialMobility2Notify.isEmpty()) {
          RM_SeatingTool_Utils.sendProdOpsTeamEmail(piuaSpecialMobility2Notify, mobilityPassengerSet);
        }

        if (!railcarIdByLAKGLBookingPIUAOver36.isEmpty()) {
          RM_SeatingTool_Utils.sendLAKGLOver36ProdOpsTeamEmail(railcarIdByLAKGLBookingPIUAOver36, trainInfo);
        }
      }
    }
  }
}
// END - Ticket #38145 / #38487 / #38498 / #38790
// END - Ticket #37921 / #31294
// END - Ticket #35471
// END - Ticket #39453 / #40026 / #40010 / #39498 / #39117 / #37921
// END - Ticket #32134 / #39498 / #40024 / #40025 / #40026 - Fixed bugs
// END - Ticket #40446 / #40408 / #40046 / #40045 / #40023 / #40022 / #39836 / #39117
// END - Ticket #39117 / #40707 / #40408 / #40326 / #40064 / #40063 / #40054 / #40050 / #39502 / #39232
// END - Ticket #41032 / #41033 / #41003 / #30715 / #41034 / #40880 / #40065 / #40818 / #40869 / #40868 / #41037
