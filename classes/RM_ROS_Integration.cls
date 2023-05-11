/**
 * @description       : Class to do a callout to ROS API
 * @author            : Adrian Flores
 * @group             :
 * @last modified on  : 05-11-2023
 * @last modified by  : Anderson Morino
 **/
// BEGINNING - Ticket #41032 / #41033 / #41003 / #30715 / #41034 / #40880 / #40065 / #40818 / #40869 / #40868 / #41037 - Solved bugs and implemented some missing notification tasks from the Seating Tool backlog
// BEGINNING - Ticket #40010 - Documented class
// BEGINNING - Ticket #30715 - Refactorings
public without sharing class RM_ROS_Integration {
  /**
   * @description Method to get ROS response by train departure date
   * @author Anderson Morino | 03-22-2023
   * @param departureDate
   * @return String
   **/
  public static String getTrainsByDate(String departureDate) {
    ROS_Seating_Tool__mdt rosAPI = [
      SELECT DeveloperName, Endpoint__c, Subscription_Key__c
      FROM ROS_Seating_Tool__mdt
      WHERE DeveloperName = 'Request_Seating_Trains'
    ];

    // Instantiate a new http object
    Http h = new Http();

    // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
    HttpRequest req = new HttpRequest();

    req.setEndpoint(rosAPI.Endpoint__c + '?subscription-key=' + rosAPI.Subscription_Key__c + '&DepartureDate=' + departureDate);
    req.setTimeout(120000);
    req.setMethod('GET');

    HttpResponse res;
    RM_ROS_IntegrationWrapper parsedResponse;

    if (Test.isRunningTest()) {
      res = new HttpResponse();
      res.setStatusCode(404);
    } else {
      // Send the request, and return a response
      res = h.send(req);
    }

    if (res.getStatusCode() != 200) {
      RM_SeatingToolBatchHelper.sendNoROSApiEmail(departureDate, res.getStatusCode() + ' ' + res.getStatus());

      String errorMessage =
        'There was an error in the ROS API Callout, please share this message with your manager: ' +
        res.getStatusCode() +
        ' ' +
        res.getStatus();

      return errorMessage;
    }

    return res.getBody();
  }
}
// END - Ticket #30715
// END - Ticket #40010
// END - Ticket #41032 / #41033 / #41003 / #30715 / #41034 / #40880 / #40065 / #40818 / #40869 / #40868 / #41037
