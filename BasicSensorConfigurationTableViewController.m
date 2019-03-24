/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "BasicSensorConfigurationTableViewController.h"
#import "MBProgressHUD.h"
#import "ActionSheetStringPicker.h"

@interface BasicSensorConfigurationTableViewController() {
    NSMutableDictionary* cellVisibility; // cache visibility for known cells
}
@property UITextField *textField;
@end

@implementation BasicSensorConfigurationTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.device = BluetoothManager.instance.device;
    cellVisibility = [NSMutableDictionary dictionary];

    // Fix leading constraint for custom cells
    float version = UIDevice.currentDevice.systemVersion.floatValue;
    if (version < 11) {
        // iOS version dependent: 11 -> 0 (storyboard), 10 -> 12, 9 -> 8
        int margin = version < 10 ? 8 : 12;
        for (NSLayoutConstraint* c in self.customCellLeadingConstraints)
            c.constant = margin;
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    itemsEnabled = !self.device.isStarted;
    self.sensorToggleButton.title = self.device.isStarted ? @"Stop" : @"Start";
    [self.manager setSensorState:self.device.isStarted];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateSensorState:) name:IotSensorsManagerSensorStateReport object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConfigurationReport:) name:IotSensorsManagerConfigurationReport object:nil];
    [self.manager readConfiguration];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IotSensorsManagerSensorStateReport object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IotSensorsManagerConfigurationReport object:nil];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateUI];
}

- (void) updateUI {
    for (IotSettingsItem* item in self.manager.spec.allValues) {
        [item updateState];
    }
}

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    [(IotSettingsItem*) self.manager.specIndex[indexPath] updateUI];
    if (cellVisibility[indexPath])
        return cell; // known cell

    // Cell accessibility identifier is set to the corresponding setting key in the spec.
    // Cells with valid identifier are hidden if not present or set to hidden in the spec.
    if (cell.accessibilityIdentifier) {
        IotSettingsItem* item = self.manager.spec[cell.accessibilityIdentifier];
        BOOL visible = item && !item.hidden;
        cellVisibility[indexPath] = @(visible);
        if (item) {
            item.cell = cell;
            item.indexPath = indexPath;
            self.manager.specIndex[indexPath] = item;
            [item initUI];
        }
        if (!visible)
            [NSLayoutConstraint deactivateConstraints:cell.contentView.constraints];
    } else {
        cellVisibility[indexPath] = @YES;
    }

    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // "Hide" cells according to spec.
    if (cellVisibility[indexPath] && ![cellVisibility[indexPath] boolValue])
        return 0;

    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IotSettingsItem* item = self.manager.specIndex[indexPath];
    if (!item || item.readOnly)
        return;

    switch (item.type) {
        case IOT_SETTINGS_TYPE_LIST: {
            NSUInteger selection = [item.values indexOfObject:item.value];
            if (selection == NSNotFound)
                selection = 0;
            [ActionSheetStringPicker showPickerWithTitle:item.title
                                                    rows:item.labels
                                        initialSelection:selection
                                               doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                                   item.value = item.values[selectedIndex];
                                                   [item updateUI];
                                                   if ([self.manager updateValues])
                                                       [self showMessage:@"Settings saved"];
                                               }
                                             cancelBlock:nil
                                                  origin:item.cell];
            break;
        }

        case IOT_SETTINGS_TYPE_NUMERIC: {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:item.title
                                                                           message:item.message
                                                                    preferredStyle:UIAlertControllerStyleAlert];

            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                self.textField = textField;
                [self.textField setDelegate:self];
                [self.textField setText:[NSString stringWithFormat:@"%d", item.value.intValue]];
                [self.textField setKeyboardType:UIKeyboardTypeNumberPad];
                [self.textField select:nil];

                UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
                numberToolbar.barStyle = UIBarStyleDefault;
                numberToolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:@"+ / -" style:UIBarButtonItemStylePlain target:self action:@selector(togglePlusMinus)]];
                [numberToolbar sizeToFit];
                textField.inputAccessoryView = numberToolbar;
            }];

            UIAlertAction* saveButton = [UIAlertAction actionWithTitle:@"OK"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   int value = alert.textFields.firstObject.text.intValue;
                                                                   // Check range
                                                                   if (value < item.min || value > item.max) {
                                                                       [self showErrorMessage:[NSString stringWithFormat:@"Out of range! [%d..%d]", item.min, item.max]];
                                                                       return;
                                                                   }
                                                                   item.value = @(value);
                                                                   [item updateUI];
                                                                   if ([self.manager updateValues])
                                                                       [self showMessage:@"Settings saved"];
                                                               }];

            UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"Cancel"
                                                                 style:UIAlertActionStyleCancel
                                                               handler:^(UIAlertAction * action) {
                                                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                                               }];

            [alert addAction:saveButton];
            [alert addAction:cancelButton];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alert animated:YES completion:nil];
            });
            break;
        }

        case IOT_SETTINGS_TYPE_ACTION: {
            if (item.element && item.action)
                [item.element performSelector:item.action];
            break;
        }
    }
}

- (void) setItemEnabled:(UIView*)view enabled:(BOOL)enabled {
    view.alpha = enabled ? 1.f : 0.45f;
    view.userInteractionEnabled = enabled;
}

- (void) togglePlusMinus {
    NSString *text = self.textField.text;
    if ([text length] == 0)
        return;

    if ([text characterAtIndex:0] == '-') {
        self.textField.text = [text substringWithRange:NSMakeRange(1, text.length-1)];
    } else {
        self.textField.text = [@"-" stringByAppendingString:text];
    }
}

- (void) showMessage:(NSString*)message duration:(float)seconds{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (seconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if ([[MBProgressHUD HUDForView:self.navigationController.view] isEqual:hud])
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    });
}

- (void) showMessage:(NSString*)message {
    [self showMessage:message duration:0.5];
}

- (void) showErrorMessage:(NSString*)message {
    [self showMessage:message duration:1.5];
}

- (IBAction) onSwitchToggle:(id)sender {
    if ([self.manager updateValues])
        [self showMessage:@"Settings saved"];
}

- (IBAction) onSensorToggle:(id)sender {
    if ([self.sensorToggleButton.title isEqualToString:@"Stop"]) {
        [self.device.manager sendStopCommand];
        [self.sensorToggleButton setTitle:@"Start"];
    } else {
        [self.device.manager sendStartCommand];
        [self.sensorToggleButton setTitle:@"Stop"];
    }
}

- (void) didUpdateSensorState:(NSNotification*)notification {
    BOOL sensorState = [notification.object boolValue];
    itemsEnabled = !sensorState;
    self.sensorToggleButton.title = sensorState ? @"Stop" : @"Start";
    [self.manager setSensorState:sensorState];
    [self updateUI];
    return;
}

- (void) onConfigurationReport:(NSNotification*)notification {
    NSDictionary* report = notification.object;
    if ([self.manager processConfigurationReport:[report[@"command"] intValue] data:report[@"data"]])
        [self updateUI];
}

@end
