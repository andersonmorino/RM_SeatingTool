/**
 * @description       : Seating Tool Project - Test Class to cover the Apex Controller
 * @author            : Caio Reimberg
 * @group             :
 * @last modified on  : 05-11-2023
 * @last modified by  : Anderson Morino
 **/
// BEGINNING - Ticket #41032 / #41033 / #41003 / #30715 / #41034 / #40880 / #40065 / #40818 / #40869 / #40868 / #41037 - Solved bugs and implemented some missing notification tasks from the Seating Tool backlog
// BEGINNING - Ticket #39117 / #40707 / #40408 / #40326 / #40064 / #40063 / #40054 / #40050 / #39502 / #39232 - Fixed bugs for notifications and seating process bugs
// BEGINNING - Ticket #40446 / #40408 / #40046 / #40045 / #40023 / #40022 / #39836 / #39117 - Fixed bugs for Split Trains
// BEGINNING - Ticket #32134 / #39498 / #40024 / #40025 / #40026 - Fixed bugs
// BEGINNING - Ticket #39453 - Used static resources to mock entry point on test method for each batch
@isTest
public class RM_SeatingToolComponentControllerTest {
  @isTest(SeeAllData=true)
  static void SeatPassengers_GL_SL_Test() {
    String rosResponse = [SELECT Body FROM StaticResource WHERE Name = 'ROS_Integration_Response_TrainDetailsGLSL' LIMIT 1].Body.toString();

    Test.startTest();
    RM_SeatingToolComponentController.seatPassengers(rosResponse);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void UnseatPassengers_GL_SL_Test() {
    String rosResponse = [SELECT Body FROM StaticResource WHERE Name = 'ROS_Integration_Response_TrainDetailsGLSL' LIMIT 1].Body.toString();

    Test.startTest();
    RM_SeatingToolComponentController.unseatPassengers(rosResponse);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void SeatPassengers_SLP_SL_Test() {
    String rosResponse = [SELECT Body FROM StaticResource WHERE Name = 'ROS_Integration_Response_TrainDetailsSLP' LIMIT 1].Body.toString();

    Test.startTest();
    RM_SeatingToolComponentController.seatPassengers(rosResponse);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void getWestboundTrainRailServicesTest() {
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource('ROS_Integration_ResponseMockSplitTrain_West');
    mock.setStatusCode(200);
    mock.setHeader('Content-Type', 'application/json');
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    RM_SeatingToolComponentController.getROSTrains('2022-05-01');
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void getEastboundTrainRailServicesTest() {
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource('ROS_Integration_ResponseMockSplitTrain_East');
    mock.setStatusCode(200);
    mock.setHeader('Content-Type', 'application/json');
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    RM_SeatingToolComponentController.getROSTrains('2022-04-29');
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void getrailcarsDetailsTest() {
    string trainLeg = [SELECT Body FROM StaticResource WHERE Name = 'ROS_Integration_Response_MockTrainLeg' LIMIT 1].Body.toString();

    Test.startTest();
    RM_SeatingToolComponentController.railcarsDetails(trainLeg);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void getTrainRailServices() {
    string trainLeg = [SELECT Body FROM StaticResource WHERE Name = 'ROS_Integration_Response_MockTrainItinerary' LIMIT 1].Body.toString();

    Test.startTest();
    RM_SeatingToolComponentController.getTrainRailServices(trainLeg);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void sendEmailNotificationForEmptyItineraryTest() {
    Test.startTest();
    RM_SeatingToolComponentController.sendEmailNotificationForEmptyItinerary(Date.newInstance(2022, 7, 4), 'testTrain');
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void seatPassengersExceptionTest() {
    String rosResponse = '{}';
    Test.startTest();

    try {
      RM_SeatingToolComponentController.seatPassengers(rosResponse);
    } catch (Exception e) {
      System.assertEquals('Script-thrown exception', e.getMessage());
    }

    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void getROSTrainsExceptionTest() {
    String departureDate = '';
    Test.startTest();
    try {
      RM_SeatingToolComponentController.getROSTrains(departureDate);
    } catch (Exception e) {
      System.assertEquals('Methods defined as TestMethod do not support Web service callouts', e.getMessage());
    }

    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void railcarsDetailsExceptionTest() {
    String trainLeg = '';
    Test.startTest();
    try {
      RM_SeatingToolComponentController.railcarsDetails(trainLeg);
    } catch (Exception e) {
      System.assertEquals('Script-thrown exception', e.getMessage());
    }
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void unseatPassengersExceptionTest() {
    String trainDetails = '{}';
    Test.startTest();
    try {
      RM_SeatingToolComponentController.unseatPassengers(trainDetails);
    } catch (Exception e) {
      System.assertEquals('Script-thrown exception', e.getMessage());
    }
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void getBatchJobStatusExceptionTest() {
    Id jobId = '707000000000000';
    Test.startTest();
    try {
      RM_SeatingToolComponentController.getBatchJobStatus(jobId);
    } catch (Exception e) {
      System.assertEquals('Script-thrown exception', e.getMessage());
    }
    Test.stopTest();
  }
  // END - Ticket #39453

  @isTest
  static void RM_ROS_IntegrationWrapperTest() {
    RM_ROS_IntegrationWrapper.TRAIN_CONSTRUCT trainConstructWrapper = new RM_ROS_IntegrationWrapper.TRAIN_CONSTRUCT(
      'Rail_Car',
      'Rail_Car_Ordinal',
      1,
      'Rail_Car_Order',
      'Rail_Car_Is_Active'
    );
    List<RM_ROS_IntegrationWrapper.TRAIN_CONSTRUCT> trainConstructList = new List<RM_ROS_IntegrationWrapper.TRAIN_CONSTRUCT>();
    trainConstructList.add(trainConstructWrapper);

    RM_ROS_IntegrationWrapper.TRAIN_ITINERARY trainItineraryWrapper = new RM_ROS_IntegrationWrapper.TRAIN_ITINERARY(
      'Management_Leg_Name',
      'Origin_Station_Code',
      'Destination_Station_Code',
      'Scheduled_Arrival_Date',
      'Scheduled_Departure_Date',
      'Scheduled_Arrival_Time',
      'Scheduled_Departure_Time',
      trainConstructList
    );
    List<RM_ROS_IntegrationWrapper.TRAIN_ITINERARY> trainItineraryList = new List<RM_ROS_IntegrationWrapper.TRAIN_ITINERARY>();
    trainItineraryList.add(trainItineraryWrapper);

    RM_ROS_IntegrationWrapper.TRAIN trainWrapper = new RM_ROS_IntegrationWrapper.TRAIN(
      'Train_Name',
      'Scheduled_Departure_Date',
      'Origin_Station_Code',
      trainItineraryList
    );
  }
}
// END - Ticket #32134 / #39498 / #40024 / #40025 / #40026
// END - Ticket #40446 / #40408 / #40046 / #40045 / #40023 / #40022 / #39836 / #39117
// END - Ticket #39117 / #40707 / #40408 / #40326 / #40064 / #40063 / #40054 / #40050 / #39502 / #39232
// END - Ticket #41032 / #41033 / #41003 / #30715 / #41034 / #40880 / #40065 / #40818 / #40869 / #40868 / #41037
