/* eslint-disable @lwc/lwc/no-api-reassignments */
// BEGINNING - Ticket #35471 - LWC Controller
import { LightningElement, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

/**
 * Apex methods imports
 */
import getROSTrains from "@salesforce/apex/RM_SeatingToolComponentController.getROSTrains";
import getTrainRailServices from "@salesforce/apex/RM_SeatingToolComponentController.getTrainRailServices";
import railcarsDetails from "@salesforce/apex/RM_SeatingToolComponentController.railcarsDetails";
import unseatPassengers from "@salesforce/apex/RM_SeatingToolComponentController.unseatPassengers";
import seatPassengers from "@salesforce/apex/RM_SeatingToolComponentController.seatPassengers";
import sendEmailNotificationForEmptyItinerary from "@salesforce/apex/RM_SeatingToolComponentController.sendEmailNotificationForEmptyItinerary";

export default class RmSeatingToolMain extends LightningElement {
  // HTML bind variables
  loading = false;
  trainOptions = [];
  legOptions = [];
  selectedDate = "";

  // LWC Controller variables

  @track trains = "";
  @track selectedTrain = [];
  @track stringSelectedTrain = "";
  @track show = false;
  @track railcarData = [];
  @track trainValue = "";
  @track selectedLeg = "";
  @track legValue = "";

  disabledButton = true;

  // Lifecycle Hooks

  connectedCallback() {}

  // Event Handlers

  handleChange(event) {
    let inputField = event.target.name;

    if (inputField === "trainOptions") {
      this.disabledButton = false;

      this.trainValue = event.target.value;
      this.selectedLeg = "";
      this.legOptions = [];
      this.show = false;

      this.trains.forEach((element) => {
        if (element.TRAIN.Train_Name === this.trainValue) {
          this.selectedTrain = element.TRAIN;
        }
      });

      this.stringSelectedTrain = JSON.stringify(this.selectedTrain);

      if (this.selectedTrain.TRAIN_ITINERARY.length === 0) {
        // BEGINNING - Ticket #39117 / #40707 / #40408 / #40326 / #40064 / #40063 / #40054 / #40050 / #39502 / #39232 - Fixed bugs for notifications and seating process bugs
        let errorHeader = "No Railcars assigned to Consist - " + this.selectedTrain.Train_Name;
        let errorMessage = "There are no railcars assigned to the consist for " + this.selectedTrain.Train_Name + ". ";
        errorMessage += "Departure Date: " + this.selectedTrain.Scheduled_Departure_Date;
        this.showNotification(errorHeader, errorMessage, "error");
        // END - Ticket #39117 / #40707 / #40408 / #40326 / #40064 / #40063 / #40054 / #40050 / #39502 / #39232

        // BEGINNING - Ticket #30919 START
        sendEmailNotificationForEmptyItinerary({
          scheduledDepartureDate: this.selectedTrain.Scheduled_Departure_Date,
          trainName: this.selectedTrain.Train_Name
        })
          .then(() => {
            this.loading = false;
          })
          .catch((error) => {
            this.showNotification("Error", error.body.message, "error");
            this.loading = false;
          });
        // END - Ticket #30919
      } else {
        this.trainRailServices();
      }
    } else if (inputField === "legsOptions") {
      this.loading = true;
      this.legValue = event.detail.value;
      this.selectedLeg = event.target.options.find((opt) => opt.value === event.detail.value).label;

      this.getRailcarsDetailsByLeg(this.legValue);
    } else if (inputField === "seatPassengerAction") {
      this.loading = true;
      seatPassengers({ trainDetails: this.stringSelectedTrain })
        .then(() => {
          this.showNotification("Success", "The Seating process has been scheduled successfully", "Success");
          this.loading = false;
        })
        .catch((error) => {
          this.showNotification("Error", error.body.message, "error");
          this.loading = false;
        });
      // }
    } else if (inputField === "unseatPassengerAction") {
      this.loading = true;
      /**
       * Get Passenger Itinerary Unit Assignment from SF by sending the Departure Date
       * and unseat all Trains
       */
      unseatPassengers({ trainDetails: this.stringSelectedTrain })
        .then(() => {
          this.show = false;

          this.showNotification("Success", "The Unseating process has been scheduled successfully", "Success");
          this.loading = false;
        })
        .catch((error) => {
          this.showNotification("Error", error.body.message, "error");
          this.loading = false;
        });
    }
  }

  onSelectedDate(event) {
    // BEGINNING - Ticket #30919 START
    this.disabledButton = true;
    // END - Ticket #30919
    this.loading = true;
    this.show = false;
    this.selectedDate = "";

    if (this.trainOptions.length > 0) {
      this.trainOptions = [];
      this.legOptions = [];
      this.trainValue = "";
      this.selectedLeg = "";
    }
    this.selectedDate = event.target.value;
    getROSTrains({ departureDate: this.selectedDate })
      .then((result) => {
        if (!result.startsWith("There was an error in the ROS API Callout")) {
          let response = JSON.parse(result);

          if (response.TRAINS.length === 0) {
            this.showNotification("Warning", "The selected departure date has no trains", "warning");
          } else {
            this.trains = response.TRAINS;

            if (this.legOptions.length > 0) {
              this.legOptions = [];
            }

            this.trains.forEach((element) => {
              this.trainOptions = [
                ...this.trainOptions,
                {
                  label: element.TRAIN.Train_Name,
                  value: element.TRAIN.Train_Name
                }
              ];
            });
          }
        } else {
          this.showNotification("Error", result, "error");
        }

        this.loading = false;
      })
      .catch((error) => {
        // TODO Error handling
        this.showNotification("Error", error.body.message, "error");
        this.loading = false;
      });
  }

  // Main Logic

  /**
   * Get Rail Services from SF by sending the Itinerary elements
   * and populates the leg options combobox
   */
  trainRailServices() {
    getTrainRailServices({ itineraries: JSON.stringify(this.selectedTrain.TRAIN_ITINERARY) })
      .then((result) => {
        const res = JSON.parse(result);
        res.forEach((element) => {
          this.legOptions = [
            ...this.legOptions,
            {
              label: element.masterLabel,
              value: JSON.stringify(element.itinerary)
            }
          ];
        });
      })
      .catch((error) => {
        this.showNotification("Error", error.body.message, "error");
      });
  }

  /**
   * Get railcars details for selected leg
   */
  getRailcarsDetailsByLeg(trainLeg) {
    railcarsDetails({ trainLeg: trainLeg })
      .then((result) => {
        this.railcarData = [];
        let lineList = [];
        let lineObj = [];

        let _map = result;

        for (const key in _map) {
          if (Object.hasOwnProperty.call(result, key)) {
            let element = {
              route: _map[key].route,
              departureDate: _map[key].departureDate,
              railcarId: _map[key].railcarId,
              seatsCapacity: _map[key].seatsCapacity,
              serviceClass: _map[key].serviceClass,
              direction: _map[key].direction,
              occupiedSeatsNumber: _map[key].occupiedSeatsNumber,
              piuaIdsBySeatNumber: _map[key].piuaIdsBySeatNumber,
              inactiveSeatsNumber: _map[key].inactiveSeatsNumber
            };

            if (element.route === this.selectedLeg) {
              lineList = [];

              for (let i = 1; i < 5; i++) {
                lineObj = { values: [], lineNumber: i };

                for (let j = i; j <= element.seatsCapacity; j = j + 4) {
                  if (element.inactiveSeatsNumber.includes(j)) {
                    lineObj.values.push({ seat: j, occupied: false, passengerURL: null, inactive: true });
                  } else if (element.occupiedSeatsNumber.includes(j)) {
                    lineObj.values.push({ seat: j, occupied: true, passengerURL: "/" + element.piuaIdsBySeatNumber[j], inactive: false });
                  } else {
                    lineObj.values.push({ seat: j, occupied: false, passengerURL: null, inactive: false });
                  }
                }

                lineList.push(lineObj);

                if (i === 2) {
                  let emptyLineObj = { values: [], lineNumber: 0 };
                  lineObj.values.forEach(function () {
                    emptyLineObj.values.push({ seat: null, occupied: false, passengerURL: null, inactive: false });
                  });
                  lineList.push(emptyLineObj);
                }
              }

              element.lines = lineList;
              this.railcarData.push(element);
            }
          }
        }
        this.show = true;
        this.loading = false;
      })
      .catch((error) => {
        this.showNotification("Error", error.body.message, "error");
        this.loading = false;
      });
  }

  showNotification(title, message, variant) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(evt);
  }
}
// END - Ticket #35471
