/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "DeviceTableViewController.h"
#import "SensorViewController.h"
#import "DeviceTableViewCell.h"
#import "MBProgressHUD.h"
#import "BluetoothDefines.h"
#import "IotSensorsDevice.h"
#import "InternalAPI.h"
#import "CloudManager.h"
#import "SettingsVault.h"

#define BACKGROUND_SCAN_FULL true
#define BACKGROUND_SCAN_INTERVAL 1
#define BACKGROUND_SCAN_DUTY_CYCLE 20

@interface DeviceTableViewController () {
    BluetoothManager* bluetoothManager;
    BOOL showCloudButton;
    BOOL scanning;
    BOOL connecting;
    NSTimer* connectTimer;
    BOOL assetTrackingEnabled;
    BOOL assetTracking;
    BOOL backgroundScan;
    NSMutableDictionary* assets;
    CLLocationManager* locationManager;
    CLBeaconRegion* beaconRegion;
    BOOL beaconScan;
    NSUUID* beaconAssetUUID;
    CBUUID* iotServiceUUID;
}
@end

@implementation DeviceTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.devices     = [[NSMutableArray alloc] init];
    self.devicesInfo = [[NSMutableArray alloc] init];

    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor = [UIColor colorWithRed:0.2 green:0.48 blue:0.72 alpha:1];
    [self.refreshControl addTarget:self
                            action:@selector(startScanning)
                  forControlEvents:UIControlEventValueChanged];

    //showCloudButton = [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowCloudMenuOnScanScreen"];
    //self.navigationItem.leftBarButtonItem = showCloudButton ? self.cloudButton : nil;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;

    iotServiceUUID = [CBUUID UUIDWithString:DIALOG_WEARABLES_SERVICE_SCAN_UUID];
    beaconAssetUUID = [[NSUUID alloc] initWithUUIDString:DIALOG_IBEACON_ASSET_UUID];

    bluetoothManager = BluetoothManager.instance;
    bluetoothManager.delegate = self;
    if (bluetoothManager.centralManager.state == CBCentralManagerStatePoweredOn)
        [self startScanning];

    assets = [NSMutableDictionary dictionaryWithCapacity:20];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCloudConfiguration:) name:NotificationBLELayerConfiguration object:nil];
    assetTrackingEnabled = [[SettingsVault sharedSettingsVault] getConfigAssetTrackingEnable];
    if (assetTrackingEnabled && bluetoothManager.centralManager.state == CBCentralManagerStatePoweredOn)
        [self startAssetTracking];
    
    //Natali added for segment control
    self.segmentControl.selectedSegmentIndex = 0;
    [self.segmentControl addTarget:self action:@selector(onSegmentControlTap) forControlEvents:UIControlEventValueChanged];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

//Natali added for segment control

-(void) onSegmentControlTap {
    if (self.segmentControl.selectedSegmentIndex == 1) {
        self.mapView = [[YMKMapView alloc] initWithFrame: CGRectMake(0, (self.segmentControl.frame.size.height), self.view.frame.size.width, (self.view.frame.size.height-self.segmentControl.frame.size.height))];
        /*YMKPoint *target = [YMKPoint pointWithLatitude:55.677688 longitude:37.632798];
        YMKPoint *target2 = [YMKPoint pointWithLatitude:55.676275 longitude:37.632636];
        YMKPoint *target3 = [YMKPoint pointWithLatitude:55.676282 longitude:37.632672];*/
        self.target = [YMKPoint pointWithLatitude:55.678137 longitude:37.630726];
        self.target2 = [YMKPoint pointWithLatitude:55.678108 longitude:37.631070];
        //self.target3 = [YMKPoint pointWithLatitude:55.676455 longitude:37.633078];
        [self.mapView.mapWindow.map moveWithCameraPosition:[YMKCameraPosition cameraPositionWithTarget:_target
                                                                                                  zoom:17
                                                                                               azimuth:0
                                                                                                  tilt:0]];
        if (self.devices.count == 1) {
            //CBPeripheral *peripheral = self.devices[0];
            NSMutableDictionary *info = self.devicesInfo[0];
            
            NSData* data = info[CBAdvertisementDataManufacturerDataKey];
            NSLog(@"Data %@", data); //80eaca70 a5d502
            NSString *arr = [NSString stringWithFormat:@"%@", data.length == 3 ? data : [data subdataWithRange:NSMakeRange(3, 3)]];
            NSLog(@"Arr %@", arr);
            //NSUUID *arr = [[NSUUID alloc] initWithUUIDString:@"DA01B247-BC6A-9C20-08F2-F5D819EB926C"];
            if ([arr isEqual: @"<70a5ce>"]) { // 70a5ce  70a5d5
                [self createPlaceMarkWithTarget:_target andIcon:@"porsche"];
                
            } else {
                [self createPlaceMarkWithTarget:_target2 andIcon:@"audi"];
            }
            
        } else if (self.devices.count == 2) {
            for (int i=0; i<2; i++) {
                NSMutableDictionary *info = self.devicesInfo[i];
                
                NSData* data = info[CBAdvertisementDataManufacturerDataKey];
                NSLog(@"Data %@", data); //80eaca70 a5d502
                NSString *arr = [NSString stringWithFormat:@"%@", data.length == 3 ? data : [data subdataWithRange:NSMakeRange(3, 3)]];
                NSLog(@"Arr %@", arr);
                if ([arr isEqual: @"<70a5ce>"]) {
                    [self createPlaceMarkWithTarget:_target andIcon:@"porsche"];
                } else {
                    [self createPlaceMarkWithTarget:_target2 andIcon:@"audi"];
                }
                
            }
            
        } /*else if (self.devices.count == 3) {
            for (int i=0; i<3; i++) {
                CBPeripheral *peripheral = self.devices[i];
                NSMutableDictionary *info = self.devicesInfo[i];
                NSString* name = info[CBAdvertisementDataLocalNameKey];
                if (!name)
                    name = peripheral.name;
                int type = [IotDeviceSpec getDeviceTypeFromAdvName:name];
                if (type == DEVICE_TYPE_IOT_585) {
                    [self createPlaceMarkWithTarget:_target andIcon:@"main-road"];
                    [self createPlaceMarkWithTarget:_target2 andIcon:@"main-road"];
                } else {
                    [self createPlaceMarkWithTarget:_target3 andIcon:@"icon-give-way"];
                }
            }
            
        }*/
        
        
        /*YMKPlacemarkMapObject *placemark = [self.mapView.mapWindow.map.mapObjects addPlacemarkWithPoint: target];
        placemark.opacity = 0.5;
        placemark.draggable = true;
        [placemark setIconWithImage:[UIImage imageNamed: @"main-road"]];
        */
        
        [self.mapView.mapWindow.map.mapObjects addTapListenerWithTapListener: self];
        [self.tableView addSubview:self.mapView];
    } else {
        [self.mapView removeFromSuperview];
        for (int i=0; i<self.placemarks.count; i++) {
            [self.mapView.mapWindow.map.mapObjects removeWithMapObject:self.placemarks[i]];
        }
    }
}

- (void)createPlaceMarkWithTarget:(YMKPoint *)target andIcon:(NSString *)icon {
    YMKPlacemarkMapObject *placemark = [self.mapView.mapWindow.map.mapObjects addPlacemarkWithPoint: target];
    placemark.opacity = 0.5;
    placemark.draggable = true;
    [placemark setIconWithImage:[UIImage imageNamed: icon]];
    [self.placemarks addObject:placemark];
}

/*- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.view.center = CGPointMake(self.view.frame.size.width/2, (self.view.frame.size.height/2- self.segmentControl.frame.size.height));
    [scrollView bringSubviewToFront:self.view];
}*/

//- (void) onMapObjectTap:(YMKMapObject *)mapObject style:(YMKPoint *)point {
- (BOOL)onMapObjectTapWithMapObject:(nonnull YMKMapObject *)mapObject
                              point:(nonnull YMKPoint *)point {
    [self stopScanning];
    
    if (connecting)
        return false;
    connecting = true;
    
    CBPeripheral *peripheral;
    NSMutableDictionary *info;
    
    //guard let placemark = mapObject as? YMKPlacemarkMapObject else { return false }
    YMKPlacemarkMapObject *place = (YMKPlacemarkMapObject *)(mapObject);
    if (!place.geometry) {
        NSLog(@"FAIL");
        return false;
    }
    
    
    
    if (self.devices.count == 1) {
        peripheral = self.devices[0];
        info = self.devicesInfo[0];
    } else if (self.devices.count == 2) {
        for (int i=0; i<2; i++) {
            YMKPlacemarkMapObject *choosedPlace = self.placemarks[i];
            
            
            NSLog(@"%f %f", place.geometry.latitude, place.geometry.longitude);
            NSLog(@"%f %f", choosedPlace.geometry.latitude, choosedPlace.geometry.longitude);
            if (self.target.latitude == place.geometry.latitude) {
                
                peripheral = self.devices[0];
                info = self.devicesInfo[0];
                NSData* data = info[CBAdvertisementDataManufacturerDataKey];
                NSLog(@"Data %@", data); //80eaca70 a5d502
                NSString *arr = [NSString stringWithFormat:@"%@", data.length == 3 ? data : [data subdataWithRange:NSMakeRange(3, 3)]];
                NSLog(@"Arr %@", arr);
                if ([arr isEqual: @"<70a5ce>"]) {
                } else {
                    peripheral = self.devices[1];
                    info = self.devicesInfo[1];
                }
                
            } else {
                peripheral = self.devices[0];
                info = self.devicesInfo[0];
                NSData* data = info[CBAdvertisementDataManufacturerDataKey];
                NSLog(@"Data %@", data); //80eaca70 a5d502
                NSString *arr = [NSString stringWithFormat:@"%@", data.length == 3 ? data : [data subdataWithRange:NSMakeRange(3, 3)]];
                NSLog(@"Arr %@", arr);
                if ([arr isEqual: @"<70a5ce>"]) {
                    peripheral = self.devices[1];
                    info = self.devicesInfo[1];
                } else {
                    
                }
            }
            
            
            /*
            if (point.latitude < 55.680) {
                peripheral = self.devices[0];
                info = self.devicesInfo[0];
            } else {
                peripheral = self.devices[1];
                info = self.devicesInfo[1];
            }*/
        }
        
    } else if (self.devices.count>0 && point == self.target3) {
        peripheral = self.devices[2];
        info = self.devicesInfo[2];
    } else {
        return false;
    }
    
    
    //CBPeripheral *peripheral = self.devices[0];
    //NSMutableDictionary *info = self.devicesInfo[0];
    
    bluetoothManager.device = [[IotSensorsDevice alloc] initWithPeripheral:peripheral type:[info[@"deviceType"] intValue] ekid:info[@"ekid"]];
    [bluetoothManager.device connect];
    
    //Natali added
    NSData* data = info[CBAdvertisementDataManufacturerDataKey];
    NSLog(@"Data %@", data); //80eaca70 a5d502
    NSString *arr = [NSString stringWithFormat:@"%@", data.length == 3 ? data : [data subdataWithRange:NSMakeRange(3, 3)]];
    NSLog(@"Arr %@", arr);
    if ([arr isEqual: @"<70a5ce>"]) {
        bluetoothManager.device.model = @"low_poly_911.obj"; //@"iot585.obj";
        bluetoothManager.device.texture = @"pattern.png"; //@"iot585_texture_mirror.png";
    } else {
        bluetoothManager.device.model = @"Audi TT.obj";
        bluetoothManager.device.texture = @"green.png";
    }
    //
    
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Connecting";
    connectTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                    target:self
                                                  selector:@selector(connectionTimeout:)
                                                  userInfo:nil
                                                   repeats:NO];
    
    // Notify that a cloud-capable EK will connect
    if (bluetoothManager.device.cloudSupport) {
        [CloudManager sharedCloudManager];
        if([[SettingsVault sharedSettingsVault] getConfigCloudEnable]) {
            [[CloudManager sharedCloudManager] startCloudManager];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationCloudCapableEKWillConnect object:info[@"ekid"] userInfo:nil];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ShowCloudMenuOnScanScreen"];
    }
    return true;
}

////////////////

- (void) onCloudConfiguration:(NSNotification*)notification {
    ConfigurationMsg* msg = (ConfigurationMsg*) notification.object;
    if (!msg)
        return;
    NSLog(@"Configuration message: %@", msg.StopFw);

    assetTrackingEnabled = true;
    for (NSNumber* event in msg.StopFw) {
        if (event.intValue == eEventTypes_Advertise) {
            assetTrackingEnabled = false;
            break;
        }
    }
    if (assetTrackingEnabled)
        [self startAssetTracking];
    else
        [self stopAssetTracking];
}

- (void) startScanning {
    [NSTimer cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopScanning) object:nil];
    [self stopScanning];
    [self cancelConnection];

    self.devices     = [[NSMutableArray alloc] init];
    self.devicesInfo = [[NSMutableArray alloc] init];
    [self.tableView reloadData];

    // Scan for beacon assets in order to enable the cloud button.
    if (!showCloudButton && !assetTracking) {
        bluetoothManager.assetTracking = true;
        [self startBeaconScan];
    }

    scanning = true;
    [bluetoothManager startScanning];
    [self performSelector:@selector(stopScanning) withObject:nil afterDelay:10];
}

- (void) stopScanning {
    [self.refreshControl endRefreshing];

    if (!assetTracking) {
        bluetoothManager.assetTracking = false;
        if (beaconScan)
            [self stopBeaconScan];
    }

    scanning = false;
    if (!assetTracking || !BACKGROUND_SCAN_FULL && !backgroundScan)
        [bluetoothManager stopScanning];
}

- (void) startAssetTracking {
    if (assetTracking)
        return;
    assetTracking = true;
    bluetoothManager.assetTracking = true;
    NSLog(@"Start asset tracking");

    [assets removeAllObjects];
    [self startBeaconScan];
    if (BACKGROUND_SCAN_FULL) {
        [bluetoothManager startScanning];
        [self performSelector:@selector(backgroundScanTimer) withObject:nil afterDelay:BACKGROUND_SCAN_INTERVAL];
    } else {
        backgroundScan = false;
        [self backgroundScanTimer];
    }
}

- (void) stopAssetTracking {
    if (!assetTracking)
        return;
    assetTracking = false;
    bluetoothManager.assetTracking = false;
    NSLog(@"Stop asset tracking");

    [NSTimer cancelPreviousPerformRequestsWithTarget:self selector:@selector(backgroundScanTimer) object:nil];
    backgroundScan = false;
    [assets removeAllObjects];
    [self stopBeaconScan];
    if (!scanning)
        [bluetoothManager stopScanning];
}

- (void) backgroundScanTimer {
    [NSTimer cancelPreviousPerformRequestsWithTarget:self selector:@selector(backgroundScanTimer) object:nil];

    if (BACKGROUND_SCAN_FULL) {
        [self performSelector:@selector(backgroundScanTimer) withObject:nil afterDelay:BACKGROUND_SCAN_INTERVAL];
        [self sendAssetsToCloud];
        return;
    }

    if (!backgroundScan) {
        backgroundScan = true;
        //[assets removeAllObjects];
        [bluetoothManager startScanning];
        [self performSelector:@selector(backgroundScanTimer) withObject:nil afterDelay:BACKGROUND_SCAN_INTERVAL * BACKGROUND_SCAN_DUTY_CYCLE / 100];
    } else {
        backgroundScan = false;
        if (!scanning)
            [bluetoothManager stopScanning];
        [self performSelector:@selector(backgroundScanTimer) withObject:nil afterDelay:BACKGROUND_SCAN_INTERVAL - (BACKGROUND_SCAN_INTERVAL * BACKGROUND_SCAN_DUTY_CYCLE / 100)];
        [self sendAssetsToCloud];
    }
}

- (void) sendAssetsToCloud {
    NSLog(@"Asset tracking: Found %d devices", assets.count);
    for (NSString* ekid in assets) {
        DataMsg* dataMsg = [[DataMsg alloc] initWithEKID:ekid];
        [dataMsg.Events addObject:[[DataEvent alloc] initWithType:eEventTypes_Advertise data:[NSString stringWithFormat:@"%@ %@", ekid, assets[ekid]]]];
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationBLELayerEvent object:dataMsg userInfo:nil];
    }
    [assets removeAllObjects];
}

- (NSString*) getAsset:(CBPeripheral*)peripheral advertisementData:(NSDictionary *)advertisementData {
    NSData* data = [self getManufacturerSpecificData:advertisementData id:0xd2]; // Dialog ID
    if (!data || data.length < 7)
        return nil;
    const uint8_t* raw = data.bytes;
    // Check for iBeacon asset (with Dialog ID)
    if (data.length == 23) {
        if (raw[0] != 2 && raw[1] != 21 || ![beaconAssetUUID isEqual:[[NSUUID alloc] initWithUUIDBytes:raw + 2]])
            return nil;
        return [NSString stringWithFormat:@"80:EA:%02X:%02X:%02X:%02X", raw[18], raw[19], raw[20], raw[21]];
    }
    // Check for IoT+ asset
    if (raw[6] != DEVICE_TYPE_IOT_585)
        return nil;
    return [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", raw[0], raw[1], raw[2], raw[3], raw[4], raw[5]];
}

- (void) startBeaconScan {
    if (!locationManager) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beaconAssetUUID identifier:@"com.diasemi.ibeacon_asset"];
    }

    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"Beacon scan authorization request");
            [locationManager requestAlwaysAuthorization];
            break;

        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]] || ![CLLocationManager isRangingAvailable]) {
                NSLog(@"Beacon scan not supported");
                break;
            }
            if (beaconScan)
                return;
            NSLog(@"Start scanning for iBeacons");
            beaconScan = true;
            [locationManager startRangingBeaconsInRegion:beaconRegion];
            break;

        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            NSLog(@"Beacon scan not authorized");
            break;
    }
}

- (void) stopBeaconScan {
    NSLog(@"Stop scanning for iBeacons");
    beaconScan = false;
    [locationManager stopRangingBeaconsInRegion:beaconRegion];
}

- (void) locationManager:(CLLocationManager*)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"Location manager authorization status: %d", status);
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            if (assetTrackingEnabled)
                [self startBeaconScan];
            break;

        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            NSLog(@"Beacon scan not authorized");
            [self stopBeaconScan];
            break;

        case kCLAuthorizationStatusNotDetermined:
            break;
    }
}

- (void) locationManager:(CLLocationManager*)manager didRangeBeacons:(NSArray<CLBeacon*>*)beacons inRegion:(CLBeaconRegion*)region {
    if (!showCloudButton && beacons.count) {
        showCloudButton = true;
        [self.navigationItem setLeftBarButtonItem:self.cloudButton animated:YES];
        if (!assetTracking)
            return;
    }
    for (CLBeacon* beacon in beacons) {
        // When a beacon gets out of range, it is still reported for a while with zero RSSI.
        if (beacon.rssi == 0)
            continue;
        // Major/Minor are set to the last 4 bytes of BD address.
        uint16_t major = beacon.major.unsignedShortValue;
        uint16_t minor = beacon.minor.unsignedShortValue;
        NSString* ekid = [NSString stringWithFormat:@"80:EA:%02X:%02X:%02X:%02X", major >> 8, major & 0xff, minor >> 8, minor & 0xff];
        assets[ekid] = @(beacon.rssi);
    }
}

- (void) locationManager:(CLLocationManager*)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion*)region withError:(NSError*)error {
    NSLog(@"Beacon scan failed: %@", error);
}

- (void) didUpdateState:(CBManagerState)state {
    switch (state) {
        case CBCentralManagerStatePoweredOn:
            [self startScanning];
            if (assetTrackingEnabled)
                [self startAssetTracking];
            break;

        case CBCentralManagerStatePoweredOff:
            [self stopScanning];
            [self stopAssetTracking];
            break;

        case CBCentralManagerStateUnknown:
        case CBCentralManagerStateResetting:
        case CBCentralManagerStateUnsupported:
        case CBCentralManagerStateUnauthorized:
            break;
    }
}

- (NSData*) getManufacturerSpecificData:(NSDictionary *)advertisementData id:(uint16_t)manufacturerID {
    if (!advertisementData[CBAdvertisementDataManufacturerDataKey])
        return nil;
    // Check and remove manufacturer ID.
    uint16_t id;
    [advertisementData[CBAdvertisementDataManufacturerDataKey] getBytes:&id length:2];
    if (id != manufacturerID)
        return nil;
    NSData* data = advertisementData[CBAdvertisementDataManufacturerDataKey];
    return [data subdataWithRange:NSMakeRange(2, data.length - 2)];
}

- (void) didDiscoverPeripheral:(CBPeripheral*)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    if (!showCloudButton && [self getAsset:peripheral advertisementData:advertisementData]) {
        showCloudButton = true;
        [self.navigationItem setLeftBarButtonItem:self.cloudButton animated:YES];
    }

    if (assetTracking) {
        NSString* ekid = [self getAsset:peripheral advertisementData:advertisementData];
        if (ekid)
            assets[ekid] = RSSI;
    }

    if (!scanning)
        return;

    if (![(NSArray*)advertisementData[CBAdvertisementDataServiceUUIDsKey] containsObject:iotServiceUUID])
        return;

    // Prevent duplicate entries.
    if ([self.devices containsObject:peripheral])
        return;

    NSData* data = [self getManufacturerSpecificData:advertisementData id:0xd2]; // Dialog ID
    // Prevent adding the device when no manufacturer data is available.
    if (!data)
        return;

    NSMutableDictionary* info = [advertisementData mutableCopy];
    info[CBAdvertisementDataManufacturerDataKey] = data;
    info[@"RSSI"] = RSSI;
    [self.devices addObject:peripheral];
    [self.devicesInfo addObject:info];
    [self.tableView reloadData];
}

- (void) didConnectPeripheral:(CBPeripheral*)peripheral {
    connecting = false;
    if (connectTimer && connectTimer.isValid) {
        [connectTimer invalidate];
        connectTimer = nil;
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self performSegueWithIdentifier:@"showDevice" sender:self];
}

- (void) didDisconnectPeripheral:(CBPeripheral*)peripheral {
}

- (void) didFailToConnectPeripheral:(CBPeripheral*)peripheral {
    [self cancelConnection];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failure" message:@"Failed to connect to device." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void) connectionTimeout:(NSTimer*)timer {
    connectTimer = nil;
    [self didFailToConnectPeripheral:bluetoothManager.device.peripheral];
}

- (void) cancelConnection {
    if (!connecting)
        return;
    connecting = false;
    if (connectTimer && connectTimer.isValid) {
        [connectTimer invalidate];
        connectTimer = nil;
    }
    if (bluetoothManager.device.state != CBPeripheralStateDisconnected)
        [bluetoothManager.device disconnect];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceCell" forIndexPath:indexPath];
    
    CBPeripheral *peripheral = self.devices[indexPath.row];
    NSMutableDictionary *info = self.devicesInfo[indexPath.row];
    //NSLog(@"peripheral %@", peripheral);
    //NSLog(@"info %@", info);

    NSString* name = info[CBAdvertisementDataLocalNameKey];
    if (!name)
        name = peripheral.name;
    int type = [IotDeviceSpec getDeviceTypeFromAdvName:name];

    // Check manufacturer data for EKID and device type.
    NSData* data = info[CBAdvertisementDataManufacturerDataKey];
    const uint8_t* raw = data.bytes;
    NSString* ekid = nil;
    switch (data.length) {
        case 3:
            // Last 3 bytes of BD address, use Dialog prefix for EKID
            ekid = [NSString stringWithFormat:@"80:EA:CA:%02X:%02X:%02X", raw[0], raw[1], raw[2]];
            break;
        case 6:
        case 7:
            // Full BD address with device type
            ekid = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", raw[0], raw[1], raw[2], raw[3], raw[4], raw[5]];
            if (data.length > 6 && raw[6] <= DEVICE_TYPE_MAX)
                type = raw[6];
            break;
    }

    NSString* icon = [IotDeviceSpec getDeviceIcon:type];
    BOOL rawProject = type == DEVICE_TYPE_IOT_580 && [IotDeviceSpec isRawProjectFromAdvName:name];
    NSString* mode = rawProject ? @"RAW" : @"SFL";

    info[@"deviceType"] = @(type);
    info[@"ekid"] = ekid;
    //
    NSString *arr = [NSString stringWithFormat:@"%@", data.length == 3 ? data : [data subdataWithRange:NSMakeRange(3, 3)]];
    if ([arr isEqual: @"<70a5ce>"]) {
        cell.deviceNameLabel.text = @"Porsche 911"; //@"Главная дорога";
        cell.deviceImageView.image = [UIImage imageNamed: @"porsche911.jpg"]; //[UIImage imageNamed: @"mainRoad.png"];
        cell.versionLabel.text = @"Автомобиль"; //@"Дорожный знак №2.1";
    } else {
        cell.deviceNameLabel.text = @"Audi TT";
        cell.deviceImageView.image = [UIImage imageNamed: @"auditt.jpg"];
        cell.versionLabel.text = @"Автомобиль";
    }
    //cell.deviceNameLabel.text = [IotDeviceSpec getProperNameFromAdvName:name];
    //cell.deviceImageView.image = [UIImage imageNamed:icon];
    //cell.versionLabel.text = [NSString stringWithFormat:@"Software: %@", mode];
    cell.addressLabel.text = @""; //[NSString stringWithFormat:@"BDA: %@", data.length == 3 ? data : [data subdataWithRange:NSMakeRange(3, 3)]];

    if (info[@"RSSI"]) {
        NSNumber *RSSI = info[@"RSSI"];
        cell.deviceRangeView.rssi = RSSI.intValue;
        cell.rssiLabel.text = [NSString stringWithFormat:@"%d dB", RSSI.intValue];
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self stopScanning];

    if (connecting)
        return;
    connecting = true;

    CBPeripheral *peripheral = self.devices[indexPath.row];
    NSMutableDictionary *info = self.devicesInfo[indexPath.row];
    bluetoothManager.device = [[IotSensorsDevice alloc] initWithPeripheral:peripheral type:[info[@"deviceType"] intValue] ekid:info[@"ekid"]];
    [bluetoothManager.device connect];
    
    //Natali added
    NSData* data = info[CBAdvertisementDataManufacturerDataKey];
    NSLog(@"Data %@", data); //80eaca70 a5d502
    NSString *arr = [NSString stringWithFormat:@"%@", data.length == 3 ? data : [data subdataWithRange:NSMakeRange(3, 3)]];
    NSLog(@"Arr %@", arr);
    if ([arr isEqual: @"<70a5ce>"]) { //70a5ce  70a5d5 - old
        bluetoothManager.device.model = @"low_poly_911.obj"; //@"iot585.obj";
        bluetoothManager.device.texture = @"pattern.png"; //@"iot585_texture_mirror.png";
    } else {
        bluetoothManager.device.model = @"Audi TT.obj";
        bluetoothManager.device.texture = @"green.png";
    }
    //

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Connecting";
    connectTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                    target:self
                                                  selector:@selector(connectionTimeout:)
                                                  userInfo:nil
                                                   repeats:NO];

    // Notify that a cloud-capable EK will connect
    if (bluetoothManager.device.cloudSupport) {
        [CloudManager sharedCloudManager];
        if([[SettingsVault sharedSettingsVault] getConfigCloudEnable]) {
            [[CloudManager sharedCloudManager] startCloudManager];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationCloudCapableEKWillConnect object:info[@"ekid"] userInfo:nil];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ShowCloudMenuOnScanScreen"];
    }
}

@end


