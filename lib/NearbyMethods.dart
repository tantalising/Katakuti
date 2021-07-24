import 'package:get/get.dart';
import 'package:katakuti/GameScreen.dart';
import 'package:katakuti/gameController.dart';
import 'package:katakuti/settings.dart';
import 'package:katakuti/startPage.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:flutter/material.dart';
import 'helperMethods.dart';

checkPermissions() async {
  if (!await Nearby().checkLocationPermission()) {
    if (!await Nearby().askLocationPermission()) {
      showSnack(
        title: "Permission Error",
        message: "Please grant location permission",
        side: SnackPosition.BOTTOM,
      );
      gameController.value.permissionGranted = false;
      return;
    }
  }

  if (!await Nearby().checkLocationEnabled()) {
    if (!await Nearby().enableLocationServices()) {
      showSnack(
        title: "Location Required",
        message: "Can't continue without location services enabled",
        side: SnackPosition.BOTTOM,
      );
      gameController.value.permissionGranted = false;
      return;
    }
  }

  gameController.value.permissionGranted = true;
}

startConnection() {
  startAdvertising();
  startDiscovery();
}

void startAdvertising() async {
  try {
    await Nearby().startAdvertising(
      gameController.value.userName,
      Strategy.P2P_POINT_TO_POINT,
      onConnectionInitiated: onConnectionInit,
      onConnectionResult: (id, status) {
        if (status == Status.CONNECTED) {
          Nearby().stopAdvertising();
          Nearby().stopDiscovery();
          Get.to(() => GameView());
        }

        if(status == Status.REJECTED){
          Nearby().stopAdvertising();
          Nearby().stopDiscovery();
          Get.offAll(() => StartPage());
          showSnack(title: "Katakuti", message: "Can't play! Connection Rejected.");
        }
      },
      onDisconnected: (id) {
        showSnack(title: "Connection", message: "The connection is lost!");
        Nearby().stopDiscovery();
        Nearby().stopAdvertising();
        Nearby().stopAllEndpoints();
        Get.offAll(() => StartPage());
      },
      serviceId: "app.tanbirsoft.katakuti",
    );
  } catch (exception) {
    print("Exception at point 1");
  }
}

void startDiscovery() async {
  try {
    await Nearby().startDiscovery(
      gameController.value.userName,
      Strategy.P2P_POINT_TO_POINT,
      onEndpointFound: (id, name, serviceId) {
// show sheet automatically to request connection
        showModalBottomSheet(
          isDismissible: false,
          enableDrag: false,
          context: Get.context,
          builder: (builder) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    "User found : \"$name\"",
                    style: TextStyle(
                        color: Colors.pinkAccent, fontSize: Get.width / 18),
                  ),
                  ElevatedButton(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: Get.width / 18,
                          bottom: Get.width / 18,
                          left: Get.width / 36,
                          right: Get.width / 36),
                      child: Text(
                        "Request Connection",
                        style: TextStyle(fontSize: Get.width / 18),
                      ),
                    ),
                    onPressed: () {
                      Get.back();
                      Nearby().requestConnection(
                        gameController.value.userName,
                        id,
                        onConnectionInitiated: (id, info) {
                          onConnectionInit(id, info);
                        },
                        onConnectionResult: (id, status) {
                          if (status == Status.CONNECTED) {
                            Get.to(() => GameView());
                          }

                          if(status == Status.REJECTED) {
                            showSnack(title: "Katakuti", message: "Connection failed successfully(rejected)!");
                            Nearby().stopAdvertising();
                            Nearby().stopDiscovery();
                            Get.offAll(() => StartPage());
                          }

                          if(status == Status.ERROR) {
                            showSnack(title: "Katakuti", message: "Eror! probably User is not available!");
                            Nearby().stopAdvertising();
                            Nearby().stopDiscovery();
                            Get.offAll(() => StartPage());
                          }
                        },
                        onDisconnected: (id) {
                          showSnack(title: "Katakuti", message: "Disconnected!");
                          Nearby().stopDiscovery();
                          Nearby().stopAdvertising();
                          Nearby().stopAllEndpoints();
                          Get.offAll(() => StartPage());
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
      onEndpointLost: (id) {
        showSnack(title: "Connection Lost", message: "The connection is lost!");
        Nearby().stopDiscovery();
        Nearby().stopAdvertising();
        Nearby().stopAllEndpoints();
        Get.offAll(()=> StartPage());
      },
      serviceId: "app.tanbirsoft.katakuti",
    );
  } catch (e) {
    print("error at point 3");
  }
}

void onConnectionInit(
  String id,
  ConnectionInfo info,
) {
  showModalBottomSheet(
    context: Get.context,
    isDismissible: false,
    enableDrag: false,
    builder: (builder) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text(
              " User  \"${info.endpointName}\" available for pairing",
              style:
                  TextStyle(color: Colors.pinkAccent, fontSize: Get.width / 18),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: Get.width / 24,
                        bottom: Get.width / 24,
                        left: Get.width / 36,
                        right: Get.width / 36),
                    child: Text(
                      "Accept",
                      style: TextStyle(fontSize: Get.width / 18),
                    ),
                  ),
                  onPressed: () async {
                    Get.back();
                    settings.value.player2 = info.endpointName;
                    settings.value.player1 = gameController.value.userName;
                    settings.value.opponentId = id;

                    // A bug in android probably. This improves the connection, otherwise disconnects often.
                    await Future.delayed(Duration(milliseconds: 200));

                    Nearby().acceptConnection(
                      id,
                      onPayLoadRecieved: (endId, payload) async {
                        if (payload.type == PayloadType.BYTES) {
                          String cellId = String.fromCharCodes(payload.bytes);

                          settings.value.clickReceived = true;
                          gameController.update((controller) {
                            controller.handleOfflineClick(int.parse(cellId));
                          });
                        }
                      },
                      onPayloadTransferUpdate: (endId, payloadTransferUpdate) {
                        if (payloadTransferUpdate.status ==
                            PayloadStatus.IN_PROGRESS) {
                          print(payloadTransferUpdate.bytesTransferred);
                        } else if (payloadTransferUpdate.status ==
                            PayloadStatus.FAILURE) {
                          Get.offAll(() => StartPage());
                          showSnack(
                            title: "Error",
                            message: "Connection Interrupted",
                          );
                        }
                      },
                    );
                  },
                ),
                ElevatedButton(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Get.theme.errorColor)),
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: Get.width / 24,
                        bottom: Get.width / 24,
                        left: Get.width / 36,
                        right: Get.width / 36),
                    child: Text(
                      "Reject",
                      style: TextStyle(fontSize: Get.width / 18),
                    ),
                  ),
                  onPressed: () async {
                        showSnack(title: "Rejection", message: "Connection rejected");
                        Get.offAll(() => StartPage());
                    try {
                      await Nearby().rejectConnection(id);
                    } catch (e) {
                      print("exception at point 2");
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
