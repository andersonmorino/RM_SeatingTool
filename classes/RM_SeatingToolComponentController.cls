/**
 * @description       : Seating Tool LWC Apex Controller
 * @author            : Adrian Flores
 * @group             :
 * @last modified on  : 05-11-2023
 * @last modified by  : Anderson Morino
 **/
// BEGINNING - Ticket #41032 / #41033 / #41003 / #30715 / #41034 / #40880 / #40065 / #40818 / #40869 / #40868 / #41037 - Solved bugs and implemented some missing notification tasks from the Seating Tool backlog
// BEGINNING - Ticket #40010 - Documented class
// BEGINNING - Ticket #35471 - LWC Apex Controller
public with sharing class RM_SeatingToolComponentController {
  /**
   * @description Get Train Rail Services from ROS API
   * @author Adrian Flores | 08-29-2022
   * @param itineraries
   * @return String
   **/
  @AuraEnabled(cacheable=true)
  public static String getTrainRailServices(String itineraries) {
    String result;
    try {
      List<RM_ROS_IntegrationWrapper.TRAIN_ITINERARY> trainItineraries = (List<RM_ROS_IntegrationWrapper.TRAIN_ITINERARY>) JSON.deserialize(
        itineraries,
        List<RM_ROS_IntegrationWrapper.TRAIN_ITINERARY>.class
      );

      result = JSON.serialize(RM_SeatingToolService.rosRoutesServices(trainItineraries));
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
    return result;
  }

  /**
   * @description Seat passengers
   * @author Adrian Flores | 08-26-2022
   * @param trainDetails
   **/
  @AuraEnabled
  public static void seatPassengers(String trainDetails) {
    try {
      RM_SeatingToolService.seatPassengers(trainDetails);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description Get Trains from ROS
   * @author Adrian Flores | 08-19-2022
   * @param departureDate
   * @return String
   **/
  @AuraEnabled(cacheable=true)
  public static String getROSTrains(String departureDate) {
    String result = RM_SeatingToolService.getROSTrains(departureDate);

    return result;
  }

  /**
   * @description Returns data about the railcars on a leg train
   * @author Adrian Flores | 08-23-2022
   * @param trainLeg
   * @return Map<Integer, RM_SeatingToolWrappers.RailcarWrapper>
   **/
  @AuraEnabled(cacheable=true)
  public static Map<Integer, RM_SeatingToolWrappers.RailcarWrapper> railcarsDetails(String trainLeg) {
    Map<Integer, RM_SeatingToolWrappers.RailcarWrapper> result;

    try {
      RM_ROS_IntegrationWrapper.TRAIN_ITINERARY wrappedTrainLeg = (RM_ROS_IntegrationWrapper.TRAIN_ITINERARY) JSON.deserialize(
        trainLeg,
        RM_ROS_IntegrationWrapper.TRAIN_ITINERARY.class
      );

      result = RM_SeatingToolService.getRailcarsInfo(wrappedTrainLeg);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
    return result;
  }

  /**
   * @description Unseat Trains on a specific Departure Date
   * @author Anderson Morino | 09-01-2022
   * @param trainDetails
   **/
  @AuraEnabled
  // BEGINNING - Ticket #31237 - Method changed to adapt the process from Queueable to a Batchable class
  public static void unseatPassengers(String trainDetails) {
    try {
      RM_SeatingToolService.unseatPassengers(trainDetails);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
  // END - Ticket #31237

  /**
   * @description Show progress bar of seating batch execution
   * @author Anderson Morino | 10-31-2022
   * @param jobId
   * @return AsyncApexJob
   **/
  @AuraEnabled
  public static AsyncApexJob getBatchJobStatus(Id jobId) {
    AsyncApexJob jobInfo = new AsyncApexJob();
    try {
      jobInfo = RM_SeatingToolService.getBatchJobStatus(jobId);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
    return jobInfo;
  }

  // BEGINNING - Ticket #30919 - START
  /**
   * @description Send email notification if there is no train construct from ROS response
   * @author Anderson Morino | 03-22-2023
   * @param scheduledDepartureDate
   * @param trainName
   * @return boolean
   **/
  @AuraEnabled
  public static boolean sendEmailNotificationForEmptyItinerary(Date scheduledDepartureDate, String trainName) {
    try {
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
      mail.setSubject('No Railcars assigned to Consist - ' + trainName);

      // Specify any html body
      Date departureDate = Date.valueOf(scheduledDepartureDate);

      htmlBody = 'There are no railcars assigned to the consist for <b>' + trainName + '</b><br>';
      htmlBody += 'Departure Date: <b>' + String.valueOf(departureDate) + '</b>';
      mail.setHtmlBody(htmlBody);

      // Add emails to the list
      lstMails.add(mail);
      Messaging.sendEmail(lstMails);
    } catch (Exception ex) {
      throw new RM_SeatingToolException(ex);
    }
    return true;
  }
  // END - Ticket #30919
}
// END - Ticket #35471
// END - Ticket #40010
// END - Ticket #41032 / #41033 / #41003 / #30715 / #41034 / #40880 / #40065 / #40818 / #40869 / #40868 / #41037
