/**
 * @description       : Seating Tool Project - Test Class to cover Batch Classes
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
public class RM_SeatingTool_BatchTest {
  @isTest(SeeAllData=true)
  static void RM_SeatingTool_DataSorting_BatchLAKSLTest() {
    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE
        Name IN (
          'Mocked_wrappedServiceClassGroupLAKSL',
          'Mocked_wrappedItineraries1',
          'Mocked_wrappedItineraries2',
          'Mocked_wrappedItineraries3',
          'Mocked_train'
        )
      ORDER BY Name ASC
    ];

    List<Id> batchJobIdList = new List<Id>();
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries3 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[3].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);
    wrappedItineraries.add(wrappedItineraries3);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[4].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_DataSorting_Batch b = new RM_SeatingTool_DataSorting_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>(),
      new List<String>(),
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_DataSorting_BatchLAKGLTest() {
    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE
        Name IN (
          'Mocked_wrappedServiceClassGroupLAKGL',
          'Mocked_wrappedItineraries1',
          'Mocked_wrappedItineraries2',
          'Mocked_wrappedItineraries3',
          'Mocked_train'
        )
      ORDER BY Name ASC
    ];

    List<Id> batchJobIdList = new List<Id>();
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries3 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[3].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);
    wrappedItineraries.add(wrappedItineraries3);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[4].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_DataSorting_Batch b = new RM_SeatingTool_DataSorting_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>(),
      new List<String>(),
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_DataSorting_BatchCJTest() {
    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE
        Name IN (
          'Mocked_wrappedServiceClassGroupCJ',
          'Mocked_wrappedItineraries1',
          'Mocked_wrappedItineraries2',
          'Mocked_wrappedItineraries3',
          'Mocked_train'
        )
      ORDER BY Name ASC
    ];

    List<Id> batchJobIdList = new List<Id>();
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries3 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[3].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);
    wrappedItineraries.add(wrappedItineraries3);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[4].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_DataSorting_Batch b = new RM_SeatingTool_DataSorting_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>(),
      new List<String>(),
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_DataSorting_BatchSLTest() {
    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE
        Name IN (
          'Mocked_wrappedServiceClassGroupSL',
          'Mocked_wrappedItineraries1',
          'Mocked_wrappedItineraries2',
          'Mocked_wrappedItineraries3',
          'Mocked_train'
        )
      ORDER BY Name ASC
    ];

    List<Id> batchJobIdList = new List<Id>();
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries3 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[3].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);
    wrappedItineraries.add(wrappedItineraries3);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[4].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_DataSorting_Batch b = new RM_SeatingTool_DataSorting_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>(),
      new List<String>(),
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_DataSorting_BatchGLTest() {
    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE
        Name IN (
          'Mocked_wrappedServiceClassGroupGL',
          'Mocked_wrappedItineraries1',
          'Mocked_wrappedItineraries2',
          'Mocked_wrappedItineraries3',
          'Mocked_train'
        )
      ORDER BY Name ASC
    ];

    List<Id> batchJobIdList = new List<Id>();
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries3 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[3].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);
    wrappedItineraries.add(wrappedItineraries3);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[4].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_DataSorting_Batch b = new RM_SeatingTool_DataSorting_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>(),
      new List<String>(),
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_DataSorting_BatchSLPTest() {
    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE Name IN ('Mocked_wrappedServiceClassGroupSLP', 'Mocked_wrappedItineraries1_SLP', 'Mocked_wrappedItineraries2_SLP', 'Mocked_train_SLP')
      ORDER BY Name ASC
    ];

    List<Id> batchJobIdList = new List<Id>();
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[3].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_DataSorting_Batch b = new RM_SeatingTool_DataSorting_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>(),
      new List<String>(),
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_LakeLouise_BatchTest() {
    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE Name IN ('Mocked_wrappedServiceClassGroupLAKSL', 'Mocked_wrappedItineraries1', 'Mocked_wrappedItineraries2', 'Mocked_wrappedItineraries3')
      ORDER BY Name ASC
    ];
    List<Id> batchJobIdList = new List<Id>();
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[0].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries3 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);
    wrappedItineraries.add(wrappedItineraries3);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[3].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_LakeLouise_Batch b = new RM_SeatingTool_LakeLouise_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      wrappedServiceClassGroup.wrappedSeatingBatchLAKSL,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>(),
      new List<String>(),
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_CircleJourney_BatchTest() {
    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE Name IN ('Mocked_wrappedServiceClassGroupCJ', 'Mocked_wrappedItineraries1', 'Mocked_wrappedItineraries2', 'Mocked_wrappedItineraries3')
      ORDER BY Name ASC
    ];
    List<Id> batchJobIdList = new List<Id>();
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[0].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries3 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);
    wrappedItineraries.add(wrappedItineraries3);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[3].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_CircleJourney_Batch b = new RM_SeatingTool_CircleJourney_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      wrappedServiceClassGroup.wrappedSeatingBatchCJ,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>(),
      new List<String>(),
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_EmailNotificationFB_BatchTest() {
    //need to find a itinerary with a passenger that has service dog or fully bound in order to test

    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE Name IN ('Mocked_wrappedServiceClassGroupSL_FB', 'Mocked_wrappedItineraries1_FB', 'Mocked_wrappedItineraries2_FB')
      ORDER BY Name ASC
    ];
    List<Id> batchJobIdList = new List<Id>();
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[0].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_EmailNotification_Batch b = new RM_SeatingTool_EmailNotification_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      wrappedServiceClassGroup.wrappedSeatingBatchSL,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>(),
      new List<String>(),
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_EmailNotificationSD_BatchTest() {
    //need to find a itinerary with a passenger that has service dog or fully bound in order to test

    List<StaticResource> staticResources = [
      SELECT name, Body
      FROM StaticResource
      WHERE Name IN ('Mocked_wrappedServiceClassGroupSL_SD', 'Mocked_wrappedItineraries1_SD', 'Mocked_wrappedItineraries2_SD')
      ORDER BY Name ASC
    ];
    List<Id> batchJobIdList = new List<Id>();
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[0].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_EmailNotification_Batch b = new RM_SeatingTool_EmailNotification_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      wrappedServiceClassGroup.wrappedSeatingBatchSL,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>(),
      new List<String>(),
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_MobilityGroup_BatchTest() {
    //need to find a itinerary with a passenger that has service dog or fully bound in order to test

    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE
        Name IN (
          'Mocked_wrappedServiceClassGroupGL_MobGroup',
          'Mocked_wrappedItineraries_MobGroup1',
          'Mocked_wrappedItineraries_MobGroup2',
          'Mocked_wrappedItineraries_MobGroup3',
          'Mocked_wrappedItineraries_MobGroup4'
        )
      ORDER BY Name ASC
    ];
    List<Id> batchJobIdList = new List<Id>();
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();
    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[0].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries3 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries4 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[3].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);
    wrappedItineraries.add(wrappedItineraries3);
    wrappedItineraries.add(wrappedItineraries4);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[4].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_MobilityGroup_Batch b = new RM_SeatingTool_MobilityGroup_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      wrappedServiceClassGroup.wrappedSeatingBatchGL,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>(),
      new List<String>(),
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_MobilityGroup2_BatchTest() {
    //need to find a itinerary with a passenger that has service dog or fully bound in order to test

    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE
        Name IN (
          'Mocked_wrappedServiceClassGroupGL_MobGroup2',
          'Mocked_wrappedItineraries_MobGroup1',
          'Mocked_wrappedItineraries_MobGroup2',
          'Mocked_wrappedItineraries_MobGroup3',
          'Mocked_wrappedItineraries_MobGroup4'
        )
      ORDER BY Name ASC
    ];
    List<Id> batchJobIdList = new List<Id>();
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();
    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[0].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries3 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries4 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[3].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);
    wrappedItineraries.add(wrappedItineraries3);
    wrappedItineraries.add(wrappedItineraries4);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[4].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_MobilityGroup_Batch b = new RM_SeatingTool_MobilityGroup_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      wrappedServiceClassGroup.wrappedSeatingBatchGL,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>{
        'No seated GL passengers' => new RM_SeatingToolWrappers.MobilityEmailWrapper(
          0,
          new List<KaptioTravel__PassengerItineraryUnitAssignment__c>()
        ),
        'Lake Louise to Banff-9541' => new RM_SeatingToolWrappers.MobilityEmailWrapper(
          0,
          new List<KaptioTravel__PassengerItineraryUnitAssignment__c>()
        ),
        'Kamloops to Lake Louise-9541' => new RM_SeatingToolWrappers.MobilityEmailWrapper(
          0,
          new List<KaptioTravel__PassengerItineraryUnitAssignment__c>()
        ),
        'Vancouver to Kamloops-9541' => new RM_SeatingToolWrappers.MobilityEmailWrapper(
          0,
          new List<KaptioTravel__PassengerItineraryUnitAssignment__c>()
        )
      },
      new List<String>(),
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_MobilityIndividual_BatchTest() {
    //need to find a itinerary with a passenger that has service dog or fully bound in order to test
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE
        Name IN (
          'Mocked_wrappedServiceClassGroupGL_Mob',
          'Mocked_wrappedItineraries1_mob',
          'Mocked_wrappedItineraries2_mob',
          'Mocked_wrappedItineraries3_mob',
          'Mocked_wrappedItineraries4_mob'
        )
      ORDER BY Name ASC
    ];
    List<Id> batchJobIdList = new List<Id>();

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[0].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries3 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries4 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[3].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);
    wrappedItineraries.add(wrappedItineraries3);
    wrappedItineraries.add(wrappedItineraries4);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[4].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_MobilityIndividual_Batch b = new RM_SeatingTool_MobilityIndividual_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      wrappedServiceClassGroup.wrappedSeatingBatchGL,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>(),
      new List<String>{
        'Vancouver to Kamloops',
        'Kamloops to Lake Louise',
        'Lake Louise to Banff',
        'Kamloops to Jasper',
        'Banff to Lake Louise',
        'Lake Louise to Kamloops',
        'Jasper to Kamloops',
        'Kamloops to Vancouver'
      },
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_MobilityIndividual2_BatchTest() {
    //need to find a itinerary with a passenger that has service dog or fully bound in order to test
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE
        Name IN (
          'Mocked_wrappedServiceClassGroupGL_Mob2',
          'Mocked_wrappedItineraries1_mob',
          'Mocked_wrappedItineraries2_mob',
          'Mocked_wrappedItineraries3_mob',
          'Mocked_wrappedItineraries4_mob'
        )
      ORDER BY Name ASC
    ];
    List<Id> batchJobIdList = new List<Id>();

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[0].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries3 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries4 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[3].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);
    wrappedItineraries.add(wrappedItineraries3);
    wrappedItineraries.add(wrappedItineraries4);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[4].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_MobilityIndividual_Batch b = new RM_SeatingTool_MobilityIndividual_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      wrappedServiceClassGroup.wrappedSeatingBatchGL,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>{
        'No seated GL passengers' => new RM_SeatingToolWrappers.MobilityEmailWrapper(
          0,
          new List<KaptioTravel__PassengerItineraryUnitAssignment__c>()
        ),
        'Lake Louise to Banff-9541' => new RM_SeatingToolWrappers.MobilityEmailWrapper(
          0,
          new List<KaptioTravel__PassengerItineraryUnitAssignment__c>()
        ),
        'Kamloops to Lake Louise-9541' => new RM_SeatingToolWrappers.MobilityEmailWrapper(
          0,
          new List<KaptioTravel__PassengerItineraryUnitAssignment__c>()
        ),
        'Vancouver to Kamloops-9541' => new RM_SeatingToolWrappers.MobilityEmailWrapper(
          0,
          new List<KaptioTravel__PassengerItineraryUnitAssignment__c>()
        )
      },
      new List<String>(),
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_Couples_BatchTest() {
    //need to find a itinerary with a passenger that has service dog or fully bound in order to test
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE
        Name IN (
          'Mocked_wrappedServiceClassGroupGL_couples',
          'Mocked_wrappedItineraries1_mob',
          'Mocked_wrappedItineraries2_mob',
          'Mocked_wrappedItineraries3_mob',
          'Mocked_wrappedItineraries4_mob'
        )
      ORDER BY Name ASC
    ];
    List<Id> batchJobIdList = new List<Id>();

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[0].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries3 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries4 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[3].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);
    wrappedItineraries.add(wrappedItineraries3);
    wrappedItineraries.add(wrappedItineraries4);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[4].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_Couples_Batch b = new RM_SeatingTool_Couples_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      wrappedServiceClassGroup.wrappedSeatingBatchGL,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>(),
      new List<String>{
        'Vancouver to Kamloops',
        'Kamloops to Lake Louise',
        'Lake Louise to Banff',
        'Banff to Lake Louise',
        'Lake Louise to Kamloops',
        'Kamloops to Vancouver'
      },
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_Odds_BatchTest() {
    //need to find a itinerary with a passenger that has service dog or fully bound in order to test
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE
        Name IN (
          'Mocked_wrappedServiceClassGroupGL_odds',
          'Mocked_wrappedItineraries_MobGroup1',
          'Mocked_wrappedItineraries_MobGroup2',
          'Mocked_wrappedItineraries_MobGroup3',
          'Mocked_wrappedItineraries_MobGroup4'
        )
      ORDER BY Name ASC
    ];
    List<Id> batchJobIdList = new List<Id>();

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[0].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries3 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries4 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[3].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);
    wrappedItineraries.add(wrappedItineraries3);
    wrappedItineraries.add(wrappedItineraries4);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[4].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_Odds_Batch b = new RM_SeatingTool_Odds_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      wrappedServiceClassGroup.wrappedSeatingBatchGL,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>(),
      new List<String>{
        'Vancouver to Kamloops',
        'Kamloops to Lake Louise',
        'Lake Louise to Banff',
        'Banff to Lake Louise',
        'Lake Louise to Kamloops',
        'Kamloops to Vancouver'
      },
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_LinkedItiCouples_BatchTest() {
    //need to find a itinerary with a passenger that has service dog or fully bound in order to test
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE
        Name IN (
          'Mocked_wrappedServiceClassGroupGL_LinkedCouples',
          'Mocked_wrappedItineraries_MobGroup1',
          'Mocked_wrappedItineraries_MobGroup2',
          'Mocked_wrappedItineraries_MobGroup3',
          'Mocked_wrappedItineraries_MobGroup4'
        )
      ORDER BY Name ASC
    ];
    List<Id> batchJobIdList = new List<Id>();

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[0].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries3 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries4 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[3].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);
    wrappedItineraries.add(wrappedItineraries3);
    wrappedItineraries.add(wrappedItineraries4);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[4].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_LinkedItineraries_Batch b = new RM_SeatingTool_LinkedItineraries_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      wrappedServiceClassGroup.wrappedSeatingBatchGL,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>(),
      new List<String>{
        'Vancouver to Kamloops',
        'Kamloops to Lake Louise',
        'Lake Louise to Banff',
        'Kamloops to Jasper',
        'Banff to Lake Louise',
        'Lake Louise to Kamloops',
        'Jasper to Kamloops',
        'Kamloops to Vancouver'
      },
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_LinkedItineraries_BatchTest() {
    //need to find a itinerary with a passenger that has service dog or fully bound in order to test
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE
        Name IN (
          'Mocked_wrappedServiceClassGroupGL_LinkedItineraries',
          'Mocked_wrappedItineraries_MobGroup1',
          'Mocked_wrappedItineraries_MobGroup2',
          'Mocked_wrappedItineraries_MobGroup3',
          'Mocked_wrappedItineraries_MobGroup4'
        )
      ORDER BY Name ASC
    ];
    List<Id> batchJobIdList = new List<Id>();

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[0].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries3 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries4 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[3].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);
    wrappedItineraries.add(wrappedItineraries3);
    //wrappedItineraries.add(wrappedItineraries4);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[4].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_LinkedItineraries_Batch b = new RM_SeatingTool_LinkedItineraries_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      wrappedServiceClassGroup.wrappedSeatingBatchGL,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>(),
      new List<String>{
        'Vancouver to Kamloops',
        'Kamloops to Lake Louise',
        'Lake Louise to Banff',
        'Kamloops to Jasper',
        'Banff to Lake Louise',
        'Lake Louise to Kamloops',
        'Jasper to Kamloops',
        'Kamloops to Vancouver'
      },
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_LinkedMobItineraries_BatchTest() {
    //need to find a itinerary with a passenger that has service dog or fully bound in order to test
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE
        Name IN (
          'Mocked_wrappedServiceClassGroupGL_LinkedMob',
          'Mocked_wrappedItineraries_MobGroup1',
          'Mocked_wrappedItineraries_MobGroup2',
          'Mocked_wrappedItineraries_MobGroup3',
          'Mocked_wrappedItineraries_MobGroup4'
        )
      ORDER BY Name ASC
    ];
    List<Id> batchJobIdList = new List<Id>();

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[0].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries3 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries4 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[3].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);
    wrappedItineraries.add(wrappedItineraries3);
    //wrappedItineraries.add(wrappedItineraries4);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[4].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_LinkedMobIndividual_Batch b = new RM_SeatingTool_LinkedMobIndividual_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      wrappedServiceClassGroup.wrappedSeatingBatchGL,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>(),
      new List<String>{
        'Vancouver to Kamloops',
        'Kamloops to Lake Louise',
        'Lake Louise to Banff',
        'Kamloops to Jasper',
        'Banff to Lake Louise',
        'Lake Louise to Kamloops',
        'Jasper to Kamloops',
        'Kamloops to Vancouver'
      },
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_LinkedMobGroup_BatchTest() {
    //need to find a itinerary with a passenger that has service dog or fully bound in order to test
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE
        Name IN (
          'Mocked_wrappedServiceClassGroupGL_LinkedMobGroup',
          'Mocked_wrappedItineraries_MobGroup1',
          'Mocked_wrappedItineraries_MobGroup2',
          'Mocked_wrappedItineraries_MobGroup3',
          'Mocked_wrappedItineraries_MobGroup4'
        )
      ORDER BY Name ASC
    ];
    List<Id> batchJobIdList = new List<Id>();

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[0].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries3 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries4 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[3].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);
    wrappedItineraries.add(wrappedItineraries3);
    //wrappedItineraries.add(wrappedItineraries4);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[4].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_LinkedMobilityGroup_Batch b = new RM_SeatingTool_LinkedMobilityGroup_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      wrappedServiceClassGroup.wrappedSeatingBatchGL,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>(),
      new List<String>{
        'Vancouver to Kamloops',
        'Kamloops to Lake Louise',
        'Lake Louise to Banff',
        'Kamloops to Jasper',
        'Banff to Lake Louise',
        'Lake Louise to Kamloops',
        'Jasper to Kamloops',
        'Kamloops to Vancouver'
      },
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_Others_BatchLAKSLTest() {
    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE
        Name IN (
          'Mocked_wrappedServiceClassGroupLAKSL',
          'Mocked_wrappedItineraries1',
          'Mocked_wrappedItineraries2',
          'Mocked_wrappedItineraries3',
          'Mocked_train'
        )
      ORDER BY Name ASC
    ];

    List<Id> batchJobIdList = new List<Id>();
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries3 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[3].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);
    wrappedItineraries.add(wrappedItineraries3);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[4].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_Others_Batch b = new RM_SeatingTool_Others_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      wrappedServiceClassGroup.wrappedSeatingBatchLAKSL,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>(),
      new List<String>{
        'Vancouver to Kamloops',
        'Kamloops to Lake Louise',
        'Lake Louise to Banff',
        'Banff to Lake Louise',
        'Lake Louise to Kamloops',
        'Kamloops to Vancouver'
      },
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_Others_BatchLAKGLTest() {
    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE
        Name IN (
          'Mocked_wrappedServiceClassGroupLAKGL',
          'Mocked_wrappedItineraries1',
          'Mocked_wrappedItineraries2',
          'Mocked_wrappedItineraries3',
          'Mocked_train'
        )
      ORDER BY Name ASC
    ];

    List<Id> batchJobIdList = new List<Id>();
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries3 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[3].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);
    wrappedItineraries.add(wrappedItineraries3);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[4].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_Others_Batch b = new RM_SeatingTool_Others_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      wrappedServiceClassGroup.wrappedSeatingBatchLAKGL,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>(),
      new List<String>{
        'Vancouver to Kamloops',
        'Kamloops to Lake Louise',
        'Lake Louise to Banff',
        'Banff to Lake Louise',
        'Lake Louise to Kamloops',
        'Kamloops to Vancouver'
      },
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_Others_BatchCJTest() {
    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE
        Name IN (
          'Mocked_wrappedServiceClassGroupCJ',
          'Mocked_wrappedItineraries1',
          'Mocked_wrappedItineraries2',
          'Mocked_wrappedItineraries3',
          'Mocked_train'
        )
      ORDER BY Name ASC
    ];

    List<Id> batchJobIdList = new List<Id>();
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries3 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[3].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);
    wrappedItineraries.add(wrappedItineraries3);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[4].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_Others_Batch b = new RM_SeatingTool_Others_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      wrappedServiceClassGroup.wrappedSeatingBatchCJ,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>(),
      new List<String>{
        'Vancouver to Kamloops',
        'Kamloops to Lake Louise',
        'Lake Louise to Banff',
        'Banff to Lake Louise',
        'Lake Louise to Kamloops',
        'Kamloops to Vancouver'
      },
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_Others_BatchSLTest() {
    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE
        Name IN (
          'Mocked_wrappedServiceClassGroupSL',
          'Mocked_wrappedItineraries1',
          'Mocked_wrappedItineraries2',
          'Mocked_wrappedItineraries3',
          'Mocked_train'
        )
      ORDER BY Name ASC
    ];

    List<Id> batchJobIdList = new List<Id>();
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries3 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[3].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);
    wrappedItineraries.add(wrappedItineraries3);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[4].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_Others_Batch b = new RM_SeatingTool_Others_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      wrappedServiceClassGroup.wrappedSeatingBatchSL,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>(),
      new List<String>{
        'Vancouver to Kamloops',
        'Kamloops to Lake Louise',
        'Lake Louise to Banff',
        'Banff to Lake Louise',
        'Lake Louise to Kamloops',
        'Kamloops to Vancouver'
      },
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_Others_BatchGLTest() {
    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE
        Name IN (
          'Mocked_wrappedServiceClassGroupGL',
          'Mocked_wrappedItineraries1',
          'Mocked_wrappedItineraries2',
          'Mocked_wrappedItineraries3',
          'Mocked_train'
        )
      ORDER BY Name ASC
    ];

    List<Id> batchJobIdList = new List<Id>();
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries3 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[3].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);
    wrappedItineraries.add(wrappedItineraries3);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[4].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_Others_Batch b = new RM_SeatingTool_Others_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      wrappedServiceClassGroup.wrappedSeatingBatchGL,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>(),
      new List<String>{
        'Vancouver to Kamloops',
        'Kamloops to Lake Louise',
        'Lake Louise to Banff',
        'Banff to Lake Louise',
        'Lake Louise to Kamloops',
        'Kamloops to Vancouver'
      },
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_Others_BatchSLPTest() {
    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE Name IN ('Mocked_wrappedServiceClassGroupSLP', 'Mocked_wrappedItineraries1_SLP', 'Mocked_wrappedItineraries2_SLP', 'Mocked_train_SLP')
      ORDER BY Name ASC
    ];

    List<Id> batchJobIdList = new List<Id>();
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>(
      [
        SELECT
          id,
          KaptioTravel__Passenger__r.MobilityGeneral__c,
          KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.KaptioTravel__BookingNumber__c,
          KaptioTravel__Passenger__r.KaptioTravel__LastName__c,
          KaptioTravel__Passenger__r.KaptioTravel__FirstName__c
        FROM KaptioTravel__PassengerItineraryUnitAssignment__c
        WHERE KaptioTravel__Passenger__r.MobilityGeneral__c = 'Visually Impaired'
        LIMIT 1
      ]
    );

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();
    RM_SeatingToolBatchHelper batchHelper = RM_SeatingToolBatchHelper.getInstance();
    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[3].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_Others_Batch b = new RM_SeatingTool_Others_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      wrappedServiceClassGroup.wrappedSeatingBatchSLP,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>(),
      new List<String>{
        'Vancouver to Kamloops',
        'Kamloops to Lake Louise',
        'Lake Louise to Banff',
        'Banff to Lake Louise',
        'Lake Louise to Kamloops',
        'Kamloops to Vancouver'
      },
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_PIUA2Update_BatchTest() {
    List<KaptioTravel__PassengerItineraryUnitAssignment__c> piua_List = [SELECT id FROM KaptioTravel__PassengerItineraryUnitAssignment__c LIMIT 1];

    Test.startTest();
    RM_SeatingTool_PIUA2Update_Batch b = new RM_SeatingTool_PIUA2Update_Batch(piua_List);
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_UtilsEmailTest() {
    List<KaptioTravel__PassengerItineraryUnitAssignment__c> piuaSpecialMobility2Notify = [
      SELECT
        id,
        KaptioTravel__Passenger__c,
        KaptioTravel__Passenger__r.passenger_full_name__c,
        KaptioTravel__Passenger__r.MobilityGeneral__c,
        KaptioTravel__ItineraryItem__r.KaptioTravel__ExternalItemName__c,
        Rail_Date__c,
        RailCarNumber__c,
        Passenger_Name__c,
        KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__r.KaptioTravel__BookingNumber__c,
        KaptioTravel__Passenger__r.MobilityRequirements__c
      FROM KaptioTravel__PassengerItineraryUnitAssignment__c
      WHERE
        KaptioTravel__Passenger__c != NULL
        AND KaptioTravel__ItineraryItem__c != NULL
        AND KaptioTravel__ItineraryItem__r.KaptioTravel__Itinerary__c != NULL
      LIMIT 1
    ];
    Id passengerId = piuaSpecialMobility2Notify[0].KaptioTravel__Passenger__c;
    List<KaptioTravel__Passenger__c> mobilityPassengerList = [SELECT Id FROM KaptioTravel__Passenger__c WHERE Id != :passengerId LIMIT 1];

    Set<String> mobilityPassengerSet = new Set<String>();
    mobilityPassengerSet.add(string.valueOf(mobilityPassengerList[0].Id));
    Test.startTest();
    RM_SeatingTool_Utils.sendProdOpsTeamEmail(piuaSpecialMobility2Notify, mobilityPassengerSet);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_Helper_sendNoROSApiEmailTest() {
    String scheduledDepartureDate = String.valueOf(date.newInstance(2022, 6, 11));
    String errorMessage = 'Test Error Message';

    Test.startTest();
    RM_SeatingToolBatchHelper.sendNoROSApiEmail(scheduledDepartureDate, errorMessage);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_Helper_createFakeLinkedBookingsWithPIUATest() {
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE
        Name IN (
          'Mocked_wrappedServiceClassGroupGL_LinkedItineraries',
          'Mocked_wrappedItineraries_MobGroup1',
          'Mocked_wrappedItineraries_MobGroup2',
          'Mocked_wrappedItineraries_MobGroup3',
          'Mocked_wrappedItineraries_MobGroup4'
        )
      ORDER BY Name ASC
    ];
    List<Id> batchJobIdList = new List<Id>();

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[0].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries3 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries4 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[3].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);
    wrappedItineraries.add(wrappedItineraries3);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[4].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_LinkedItineraries_Batch b = new RM_SeatingTool_LinkedItineraries_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      wrappedServiceClassGroup.wrappedSeatingBatchGL,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>(),
      new List<String>{
        'Vancouver to Kamloops',
        'Kamloops to Lake Louise',
        'Lake Louise to Banff',
        'Kamloops to Jasper',
        'Banff to Lake Louise',
        'Lake Louise to Kamloops',
        'Jasper to Kamloops',
        'Kamloops to Vancouver'
      },
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_Helper_createFakeBookingsWithPIUATest() {
    //need to find a itinerary with a passenger that has service dog or fully bound in order to test
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE
        Name IN (
          'Mocked_wrappedServiceClassGroupGL_couples',
          'Mocked_wrappedItineraries1_mob',
          'Mocked_wrappedItineraries2_mob',
          'Mocked_wrappedItineraries3_mob',
          'Mocked_wrappedItineraries4_mob'
        )
      ORDER BY Name ASC
    ];
    List<Id> batchJobIdList = new List<Id>();

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[0].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries3 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries4 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[3].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);
    wrappedItineraries.add(wrappedItineraries3);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[4].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_Couples_Batch b = new RM_SeatingTool_Couples_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      wrappedServiceClassGroup.wrappedSeatingBatchGL,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>(),
      new List<String>{
        'Vancouver to Kamloops',
        'Kamloops to Lake Louise',
        'Lake Louise to Banff',
        'Banff to Lake Louise',
        'Lake Louise to Kamloops',
        'Kamloops to Vancouver'
      },
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_createFakeMobilityBookingsWithPIUATest() {
    //need to find a itinerary with a passenger that has service dog or fully bound in order to test
    Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c> piua2UpdateMap = new Map<Id, KaptioTravel__PassengerItineraryUnitAssignment__c>();

    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE
        Name IN (
          'Mocked_wrappedServiceClassGroupGL_Mob',
          'Mocked_wrappedItineraries1_mob',
          'Mocked_wrappedItineraries2_mob',
          'Mocked_wrappedItineraries3_mob',
          'Mocked_wrappedItineraries4_mob'
        )
      ORDER BY Name ASC
    ];
    List<Id> batchJobIdList = new List<Id>();

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries1 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[0].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries2 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[1].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries3 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[2].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    RM_SeatingToolWrappers.ManagementLegWrapper wrappedItineraries4 = (RM_SeatingToolWrappers.ManagementLegWrapper) JSON.deserialize(
      staticResources[3].Body.toString(),
      RM_SeatingToolWrappers.ManagementLegWrapper.class
    );
    wrappedItineraries.add(wrappedItineraries1);
    wrappedItineraries.add(wrappedItineraries2);
    wrappedItineraries.add(wrappedItineraries3);

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper wrappedServiceClassGroup = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper();

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    wrappedServiceClassGroup = (RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper) JSON.deserialize(
      staticResources[4].Body.toString(),
      RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper.class
    );

    Test.startTest();
    RM_SeatingTool_MobilityIndividual_Batch b = new RM_SeatingTool_MobilityIndividual_Batch(
      wrappedItineraries,
      wrappedServiceClassGroup,
      wrappedServiceClassGroup.wrappedSeatingBatchGL,
      batchJobIdList,
      piua2UpdateMap,
      train,
      1,
      new Map<String, RM_SeatingToolWrappers.MobilityEmailWrapper>(),
      new List<String>{
        'Vancouver to Kamloops',
        'Kamloops to Lake Louise',
        'Lake Louise to Banff',
        'Kamloops to Jasper',
        'Banff to Lake Louise',
        'Lake Louise to Kamloops',
        'Jasper to Kamloops',
        'Kamloops to Vancouver'
      },
      new Map<String, KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__Itinerary_Item__c>()
    );
    Id batchID = DataBase.executeBatch(b, 200);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_Helper_createFakeOtherBookingsWithPIUATest() {
    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE Name IN ('Mocked_wrappedItineraries_SplitWestbound', 'Mocked_itiItemList')
      ORDER BY Name ASC
    ];

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();

    wrappedItineraries = (List<RM_SeatingToolWrappers.ManagementLegWrapper>) JSON.deserialize(
      staticResources[1].Body.toString(),
      List<RM_SeatingToolWrappers.ManagementLegWrapper>.class
    );

    List<String> routeList = new List<String>{ 'Banff to Lake Louise', 'Lake Louise to Kamloops', 'Jasper to Kamloops', 'Kamloops to Vancouver' };

    List<KaptioTravel__Itinerary_Item__c> itiItemList = new List<KaptioTravel__Itinerary_Item__c>();

    itiItemList = (List<KaptioTravel__Itinerary_Item__c>) JSON.deserialize(
      staticResources[0].Body.toString(),
      List<KaptioTravel__Itinerary_Item__c>.class
    );

    Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingPIUAListByItiItem = new Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>>();

    Test.startTest();

    RM_SeatingToolBatchHelper.getItinerariesByTransferSort(
      itiItemList,
      new RM_SeatingToolWrappers.SeatingRuleWrapper(
        new Map<String, List<KaptioTravel__Itinerary_Item__c>>(),
        new Map<String, KaptioTravel__Itinerary_Item__c>(),
        new Map<String, List<KaptioTravel__Itinerary_Item__c>>(),
        new List<KaptioTravel__Itinerary_Item__c>(),
        new Set<String>(),
        new Set<String>(),
        new List<KaptioTravel__PassengerItineraryUnitAssignment__c>(),
        new List<KaptioTravel__PassengerItineraryUnitAssignment__c>(),
        new Set<String>(),
        new Set<String>(),
        new List<KaptioTravel__Itinerary_Item__c>(),
        new List<KaptioTravel__Itinerary_Item__c>(),
        new List<KaptioTravel__Itinerary_Item__c>(),
        new List<KaptioTravel__Itinerary_Item__c>(),
        new List<KaptioTravel__Itinerary_Item__c>(),
        new List<KaptioTravel__Itinerary_Item__c>(),
        new List<KaptioTravel__Itinerary_Item__c>(),
        new List<KaptioTravel__Itinerary_Item__c>(),
        new List<KaptioTravel__Itinerary_Item__c>(),
        new List<KaptioTravel__Itinerary_Item__c>(),
        new List<KaptioTravel__Itinerary_Item__c>(),
        new List<KaptioTravel__Itinerary_Item__c>(),
        new Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>>(),
        new Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>>(),
        new Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>>(),
        new Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>>(),
        new Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>>(),
        new Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>>(),
        RM_SeatingToolBatchHelper.getInstance(),
        new Set<Id>(),
        new Set<Id>(),
        new Set<Id>()
      ),
      ''
    );
    RM_SeatingToolBatchHelper.getInstance().createFakeOtherBookingsWithPIUA(wrappedItineraries, itiItemList, bookingPIUAListByItiItem, routeList, 0);
    RM_SeatingToolBatchHelper.getInstance().createFakeBookingsWithPIUA(wrappedItineraries, itiItemList, bookingPIUAListByItiItem, routeList, 0);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_Helper_createFakeLinkedBookingsWithPIUAWestboundSplitTrainTest() {
    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE Name IN ('Mocked_wrappedItineraries_SplitWestbound_Linked', 'Mocked_itiItemList_LinkedBookings')
      ORDER BY Name ASC
    ];

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();

    wrappedItineraries = (List<RM_SeatingToolWrappers.ManagementLegWrapper>) JSON.deserialize(
      staticResources[1].Body.toString(),
      List<RM_SeatingToolWrappers.ManagementLegWrapper>.class
    );

    List<String> routeList = new List<String>{ 'Banff to Lake Louise', 'Lake Louise to Kamloops', 'Jasper to Kamloops', 'Kamloops to Vancouver' };

    List<KaptioTravel__Itinerary_Item__c> itiItemList = new List<KaptioTravel__Itinerary_Item__c>();

    itiItemList = (List<KaptioTravel__Itinerary_Item__c>) JSON.deserialize(
      staticResources[0].Body.toString(),
      List<KaptioTravel__Itinerary_Item__c>.class
    );

    Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingPIUAListByItiItem = new Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>>();

    Test.startTest();
    RM_SeatingToolBatchHelper.getInstance().createFakeLinkedBookingsWithPIUA(wrappedItineraries, itiItemList, bookingPIUAListByItiItem, routeList, 0);
    RM_SeatingToolBatchHelper.getInstance()
      .createFakeMobilityBookingsWithPIUA(wrappedItineraries, itiItemList, bookingPIUAListByItiItem, routeList, 0, true);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_Helper_createFakeLinkedBookingsWithPIUAWestboundTrainTest() {
    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE Name IN ('Mocked_wrappedItineraries_Westbound_Linked', 'Mocked_itiItemList_LinkedBookings')
      ORDER BY Name ASC
    ];

    List<RM_SeatingToolWrappers.ManagementLegWrapper> wrappedItineraries = new List<RM_SeatingToolWrappers.ManagementLegWrapper>();

    wrappedItineraries = (List<RM_SeatingToolWrappers.ManagementLegWrapper>) JSON.deserialize(
      staticResources[1].Body.toString(),
      List<RM_SeatingToolWrappers.ManagementLegWrapper>.class
    );

    List<String> routeList = new List<String>{ 'Banff to Lake Louise', 'Lake Louise to Kamloops', 'Kamloops to Vancouver' };

    List<KaptioTravel__Itinerary_Item__c> itiItemList = new List<KaptioTravel__Itinerary_Item__c>();

    itiItemList = (List<KaptioTravel__Itinerary_Item__c>) JSON.deserialize(
      staticResources[0].Body.toString(),
      List<KaptioTravel__Itinerary_Item__c>.class
    );

    Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingPIUAListByItiItem = new Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>>();

    Test.startTest();
    RM_SeatingToolBatchHelper.getInstance().createFakeLinkedBookingsWithPIUA(wrappedItineraries, itiItemList, bookingPIUAListByItiItem, routeList, 0);
    RM_SeatingToolBatchHelper.getInstance()
      .createFakeMobilityBookingsWithPIUA(wrappedItineraries, itiItemList, bookingPIUAListByItiItem, routeList, 0, true);
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_Helper_isLAKGLOver36Guests() {
    List<StaticResource> staticResources = [
      SELECT Body
      FROM StaticResource
      WHERE Name IN ('Mocked_bookingPIUAListByItiItem_LAKGLOver36Guests', 'Mocked_piua1')
      ORDER BY Name ASC
    ];

    List<String> routeList = new List<String>{ 'Lake Louise to Kamloops' };

    KaptioTravel__PassengerItineraryUnitAssignment__c piua = new KaptioTravel__PassengerItineraryUnitAssignment__c();

    piua = (KaptioTravel__PassengerItineraryUnitAssignment__c) JSON.deserialize(
      staticResources[1].Body.toString(),
      KaptioTravel__PassengerItineraryUnitAssignment__c.class
    );

    Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>> bookingPIUAListByItiItem = new Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>>();

    bookingPIUAListByItiItem = (Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>>) JSON.deserialize(
      staticResources[0].Body.toString(),
      Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>>.class
    );

    String availableSeatsByRailcarIdKey = 'Lake Louise to Kamloops-9557';

    Map<String, RM_SeatingToolWrappers.RailcarWrapper> availableSeatsByRailcarId = new Map<String, RM_SeatingToolWrappers.RailcarWrapper>{
      availableSeatsByRailcarIdKey => new RM_SeatingToolWrappers.RailcarWrapper(36, new List<String>())
    };

    Test.startTest();
    Boolean isisLAKGLOver36True = RM_SeatingToolBatchHelper.getInstance()
      .isLAKGLOver36Guests(
        routeList,
        piua,
        availableSeatsByRailcarIdKey,
        false,
        bookingPIUAListByItiItem,
        'a6w4R0000001p8KQAQ',
        availableSeatsByRailcarId
      );

    Boolean isisLAKGLOver36False = RM_SeatingToolBatchHelper.getInstance()
      .isLAKGLOver36Guests(
        routeList,
        piua,
        availableSeatsByRailcarIdKey,
        false,
        new Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>>(),
        'a6w4R0000001p8KQAQ',
        availableSeatsByRailcarId
      );
    Test.stopTest();
  }

  @isTest
  static void RM_SeatingToolWrappersTest() {
    RM_SeatingToolWrappers.ManagementLegWrapper mlw = new RM_SeatingToolWrappers.ManagementLegWrapper(
      '123',
      'Vancouver to Kamloops',
      '2023-03-10',
      new List<RM_ROS_IntegrationWrapper.TRAIN_CONSTRUCT>()
    );

    RM_SeatingToolWrappers.ROSRoutesServiceWrapper rsw = new RM_SeatingToolWrappers.ROSRoutesServiceWrapper(
      'testMasterLabel',
      new RM_ROS_IntegrationWrapper.TRAIN_ITINERARY()
    );

    RM_SeatingToolWrappers.RailcarWrapper rcw1 = new RM_SeatingToolWrappers.RailcarWrapper(1, 'railcarOrdinal');
    RM_SeatingToolWrappers.RailcarWrapper rcw2 = new RM_SeatingToolWrappers.RailcarWrapper(1, 'railcarOrdinal', 0);
    RM_SeatingToolWrappers.RailcarWrapper rcw3 = new RM_SeatingToolWrappers.RailcarWrapper('railcarId', 'serviceClass');
    RM_SeatingToolWrappers.RailcarWrapper rcw4 = new RM_SeatingToolWrappers.RailcarWrapper('direction', 0);
    RM_SeatingToolWrappers.RailcarWrapper rcw5 = new RM_SeatingToolWrappers.RailcarWrapper(1, new List<String>());
    RM_SeatingToolWrappers.RailcarWrapper rcw6 = new RM_SeatingToolWrappers.RailcarWrapper(new List<String>(), 1);
    RM_SeatingToolWrappers.RailcarWrapper rcw7 = new RM_SeatingToolWrappers.RailcarWrapper(
      'route',
      Date.newInstance(2022, 11, 2),
      'railcarId',
      1,
      'serviceClass',
      'direction',
      new List<Integer>(),
      new Map<String, String>(),
      new List<Integer>()
    );

    RM_SeatingToolWrappers.RailcarSeatWrapper rcsw = new RM_SeatingToolWrappers.RailcarSeatWrapper(
      1,
      'route',
      Date.newInstance(2022, 7, 4),
      'railcarId',
      'railcarOrdinal',
      'railcarSeatId',
      'railcarSeatLetter',
      1,
      false,
      false,
      false,
      'railcarSeries',
      'routeKey',
      'railcarSeriesKey',
      'railcarOrderKey',
      'railcarSeatKey',
      'availableRailcarSeatsListKey',
      1,
      new KaptioTravel__PassengerItineraryUnitAssignment__c()
    );
    RM_SeatingToolWrappers.SeatingRuleWrapper srw = new RM_SeatingToolWrappers.SeatingRuleWrapper(
      new Map<String, List<KaptioTravel__Itinerary_Item__c>>(),
      new Map<String, KaptioTravel__Itinerary_Item__c>(),
      new Map<String, List<KaptioTravel__Itinerary_Item__c>>(),
      new List<KaptioTravel__Itinerary_Item__c>(),
      new Set<String>(),
      new Set<String>(),
      new List<KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new List<KaptioTravel__PassengerItineraryUnitAssignment__c>(),
      new Set<String>(),
      new Set<String>(),
      new List<KaptioTravel__Itinerary_Item__c>(),
      new List<KaptioTravel__Itinerary_Item__c>(),
      new List<KaptioTravel__Itinerary_Item__c>(),
      new List<KaptioTravel__Itinerary_Item__c>(),
      new List<KaptioTravel__Itinerary_Item__c>(),
      new List<KaptioTravel__Itinerary_Item__c>(),
      new List<KaptioTravel__Itinerary_Item__c>(),
      new List<KaptioTravel__Itinerary_Item__c>(),
      new List<KaptioTravel__Itinerary_Item__c>(),
      new List<KaptioTravel__Itinerary_Item__c>(),
      new List<KaptioTravel__Itinerary_Item__c>(),
      new List<KaptioTravel__Itinerary_Item__c>(),
      new Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>>(),
      new Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>>(),
      new Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>>(),
      new Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>>(),
      new Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>>(),
      new Map<String, List<KaptioTravel__PassengerItineraryUnitAssignment__c>>(),
      RM_SeatingToolBatchHelper.getInstance(),
      new Set<Id>(),
      new Set<Id>(),
      new Set<Id>()
    );

    RM_SeatingToolWrappers.SeatingToolBatchWrapper stbw = new RM_SeatingToolWrappers.SeatingToolBatchWrapper(
      new List<String>(),
      new Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper>(),
      new RM_SeatingToolWrappers.SeatingRuleWrapper(),
      new Map<String, RM_SeatingToolWrappers.RailcarWrapper>(),
      false
    );

    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper stscgw = new RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper(
      new RM_SeatingToolWrappers.SeatingToolBatchWrapper(),
      new RM_SeatingToolWrappers.SeatingToolBatchWrapper(),
      new RM_SeatingToolWrappers.SeatingToolBatchWrapper(),
      new RM_SeatingToolWrappers.SeatingToolBatchWrapper(),
      new RM_SeatingToolWrappers.SeatingToolBatchWrapper(),
      new RM_SeatingToolWrappers.SeatingToolBatchWrapper()
    );
  }

  @isTest
  static void RM_SeatingTool_Utils_seatingServiceClassWrapperBuilderTest() {
    RM_SeatingToolWrappers.SeatingToolServiceClassGroupWrapper stscg = RM_SeatingTool_Utils.seatingServiceClassWrapperBuilder(
      new RM_SeatingToolWrappers.SeatingToolBatchWrapper(),
      new RM_SeatingToolWrappers.SeatingToolBatchWrapper(),
      new RM_SeatingToolWrappers.SeatingToolBatchWrapper(),
      new RM_SeatingToolWrappers.SeatingToolBatchWrapper(),
      new RM_SeatingToolWrappers.SeatingToolBatchWrapper(),
      new RM_SeatingToolWrappers.SeatingToolBatchWrapper()
    );
  }

  @isTest
  static void RM_SeatingTool_Utils_seatingBatchWrapperBuilderTest() {
    RM_SeatingToolWrappers.SeatingToolBatchWrapper stscg = RM_SeatingTool_Utils.seatingBatchWrapperBuilder(
      new List<String>(),
      new Map<String, RM_SeatingToolWrappers.RailcarSeatWrapper>(),
      new RM_SeatingToolWrappers.SeatingRuleWrapper(),
      new Map<String, RM_SeatingToolWrappers.RailcarWrapper>(),
      false
    );
  }

  @isTest
  static void RM_SeatingTool_Utils_seatingRulesWrapperBuilderTest() {
    RM_SeatingToolWrappers.SeatingRuleWrapper srw = RM_SeatingTool_Utils.seatingRulesWrapperBuilder(new RM_SeatingToolWrappers.SeatingRuleWrapper());
  }

  @isTest(SeeAllData=true)
  static void RM_SeatingTool_Utils_getItinerariesTransfersInfoTest() {
    Set<String> railServicesByBookings = new Set<String>();

    for (KaptioTravel__Itinerary_Item__c itineraryItems : [
      SELECT id, KaptioTravel__Itinerary__r.KaptioTravel__BookingNumber__c
      FROM KaptioTravel__Itinerary_Item__c
      WHERE
        KaptioTravel__Itinerary__r.KaptioTravel__BookingNumber__c != NULL
        AND KaptioTravel__Item__r.RecordType.DeveloperName = 'Transfer'
        AND (KaptioTravel__Item__r.KaptioTravel__TransferType__c = 'Transfer - Motorcoach - Station to Hotel'
        OR KaptioTravel__Item__r.KaptioTravel__TransferType__c = 'Transfer - Motorcoach - Hotel to Station')
        AND KaptioTravel__Item__r.KaptioTravel__Location__r.Name = 'Banff Region'
      LIMIT 10
    ]) {
      railServicesByBookings.add(String.valueOf(itineraryItems.KaptioTravel__Itinerary__r.KaptioTravel__BookingNumber__c));
    }
    Test.startTest();
    RM_SeatingToolBatchHelper.getItinerariesTransfersInfo(railServicesByBookings);
    Test.stopTest();
  }
  // END - Ticket #39453

  @isTest(SeeAllData=true)
  static void RM_SeatingToolBatchHelper_SendNoBookingsEmail() {
    List<StaticResource> staticResources = [SELECT Body FROM StaticResource WHERE Name IN ('Mocked_train') ORDER BY Name ASC];

    RM_ROS_IntegrationWrapper.TRAIN train = new RM_ROS_IntegrationWrapper.TRAIN();
    train = (RM_ROS_IntegrationWrapper.TRAIN) JSON.deserialize(staticResources[0].Body.toString(), RM_ROS_IntegrationWrapper.TRAIN.class);

    Test.startTest();
    RM_SeatingToolBatchHelper.getInstance().sendNoBookingsEmail(train, 'No Bookings');
    Test.stopTest();
  }
}
// END - Ticket #32134 / #39498 / #40024 / #40025 / #40026
// END - Ticket #40446 / #40408 / #40046 / #40045 / #40023 / #40022 / #39836 / #39117
// END - Ticket #39117 / #40707 / #40408 / #40326 / #40064 / #40063 / #40054 / #40050 / #39502 / #39232
// END - Ticket #41032 / #41033 / #41003 / #30715 / #41034 / #40880 / #40065 / #40818 / #40869 / #40868 / #41037
