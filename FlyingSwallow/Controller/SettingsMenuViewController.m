//
//  SettingsMenuViewController.m
//  FlyingSwallow
//
//  Created by koupoo on 12-12-21. Email: koupoo@126.com
//  Copyright (c) 2012年 www.hexairbot.com. All rights reserved.
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License V2
//  as published by the Free Software Foundation.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "SettingsMenuViewController.h"
#import "Macros.h"
#import "Channel.h"
#import "ChannelSettingsViewController.h"
#import "util.h"
#import "BleSerialManager.h"
#import "Transmitter.h"
#import "OSDCommon.h"

#define kAileronElevatorMaxDeadBandRatio 0.2
#define kRudderMaxDeadBandRatio 0.2

#define kChannelListTableView 0
#define kPeripheralDeviceListTabelView 1

typedef enum settings_alert_dialog{
    settings_alert_dialog_connect,
    settings_alert_dialog_disconnect,
    settings_alert_dialog_default,
    settings_alert_dialog_calibrate_mag,
    settings_alert_dialog_calibrate_acc
}settings_alert_dialog;

@interface SettingsMenuViewController (){
    UITableViewCell *reorderTableViewCell;
    
    NSMutableArray *pageViewArray;
    NSMutableArray *pageTitleArray;
    
    int pageCount;
    
    Settings *settings;
    
    ChannelSettingsViewController *channelSettingsVC;
    
    NSArray *peripheralList;
    
    CBPeripheral *selectedPeripheral;
    
    BOOL isTryingConnect;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;


@end

@implementation SettingsMenuViewController
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {  
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil settings:(Settings *)settings_{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        pageViewArray = [[NSMutableArray alloc] initWithCapacity:5];
        pageTitleArray = [[NSMutableArray alloc] initWithCapacity:5];

        settings = [settings_ retain];
        
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissChannelSetttingsView) name:kNotificationDismissChannelSettingsView object:nil];
    }
    
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    channelListTableView.tag = kChannelListTableView;
    peripheralListTableView.tag = kPeripheralDeviceListTabelView;
}


- (void)updateSettingsUI{
    [self setSwitchButton:leftHandedSwitchButton withValue:settings.isLeftHanded];
    [self setSwitchButton:accModeSwitchButton withValue:settings.isAccMode];
    [self setSwitchButton:beginnerModeSwitchButton withValue:settings.isBeginnerMode];
    [self setSwitchButton:headfreeModeSwitchButton withValue:settings.isHeadFreeMode];
    
    interfaceOpacitySlider.value = settings.interfaceOpacity * 100;
    interfaceOpacityLabel.text = [NSString stringWithFormat:@"%d%%", (int)(settings.interfaceOpacity * 100)];
    [self setSwitchButton:ppmPolarityReversedSwitchButton withValue:settings.ppmPolarityIsNegative];
    takeOffThrottleSlider.value = settings.takeOffThrottle;
    [self updateTakeOffThrottleLabel];
    
    [self updateAileronElevatorDeadBandLabel];
    [self updateAileronElevatorDeadBandSlider];
    [self updateRudderDeadBandLabel];
    [self updateRudderDeadBandSlider];
    
    [channelListTableView reloadData];
}

-(void)settingsPageScrollViewDidTap:(UITapGestureRecognizer*)tapGr{
    [param1ScaleTextFiled resignFirstResponder];
    [param2ScaleTextFiled resignFirstResponder];
    [param3ScaleTextFiled resignFirstResponder];
    [param4ScaleTextFiled resignFirstResponder];
    [param5ScaleTextFiled resignFirstResponder];
    [param6ScaleTextFiled resignFirstResponder];
    [param7ScaleTextFiled resignFirstResponder];
    [param8ScaleTextFiled resignFirstResponder];
    [param9ScaleTextFiled resignFirstResponder];
    [param10ScaleTextFiled resignFirstResponder];
    [param11ScaleTextFiled resignFirstResponder];
    [param12ScaleTextFiled resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    leftHandedTitleLabel.text = getLocalizeString(@"LEFT HANDED");
    interfaceOpacityTitleLabel.text = getLocalizeString(@"INTERFACE OPACITY");
    accModeTitleLabel.text = getLocalizeString(@"Acc Mode");
    
    [pageViewArray addObject:testSettingsView];
    [pageTitleArray addObject:@"测试参数页面1"];
    
    [pageViewArray addObject:testSettingsView2];
    [pageTitleArray addObject:@"测试参数页面2"];

    [pageViewArray addObject:peripheralView];
    [pageTitleArray addObject:getLocalizeString(@"BLE DEVICES")];
    
    [pageViewArray addObject:personalSettingsPageView];
    [pageTitleArray addObject:getLocalizeString(@"PERSONAL SETTINGS")];
    
    [pageViewArray addObject:trimSettingsView];
    [pageTitleArray addObject:getLocalizeString(@"TRIM SETTINGS")];
    
    [pageViewArray addObject:modeSettingsPageView];
    [pageTitleArray addObject:getLocalizeString(@"MODE SETTINGS")];
    
    [pageViewArray addObject:aboutPageView];
    [pageTitleArray addObject:getLocalizeString(@"ABOUT")];

    pageCount = pageViewArray.count;
    
    CGFloat x = 0.f;
    for (UIView *pageView in pageViewArray)
    {
        CGRect frame = pageView.frame;
        frame.origin.x = x;
        [pageView setFrame:frame];
        [settingsPageScrollView addSubview:pageView];
        x += pageView.frame.size.width;
    }
    [settingsPageScrollView  setContentSize:CGSizeMake(x, settingsPageScrollView.frame.size.height)];
    UITapGestureRecognizer *tapReco = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(settingsPageScrollViewDidTap:)];
    tapReco.cancelsTouchesInView = NO;
    [settingsPageScrollView addGestureRecognizer:tapReco];
    
    [pageControl setNumberOfPages:pageCount];
    [pageControl setCurrentPage:0];
    
    pageTitleLabel.text = getLocalizeString(@"BLE DEVICES");
    ppmPolarityReversedTitleLabel.text = getLocalizeString(@"PPM POLARITY REVERSED");
    takeOffThrottleTitleLabel.text = getLocalizeString(@"Take Off Throttle");
    aileronElevatorDeadBandTitleLabel.text = getLocalizeString(@"Aileron/Elevator Dead Band");
    rudderDeadBandTitleLabel.text = getLocalizeString(@"Rudder Dead Band");
    beginnerModeTitleLabel.text = getLocalizeString(@"Beginner Mode");
    headfreeModeTitleLabel.text = getLocalizeString(@"Headfree Mode");
    
    [defaultSettingsButton setTitle:getLocalizeString(@"Default Settings") forState:UIControlStateNormal];
    [peripheralListScanButton setTitle:getLocalizeString(@"Scan") forState:UIControlStateNormal];
    
    isScanningTextLabel.text = getLocalizeString(@"Scanning Flexbot...");
    
    [magCalibrateButton setTitle:getLocalizeString(@"Calibrate Mag") forState:UIControlStateNormal];
    [accCalibrateButton setTitle:getLocalizeString(@"Calibrate Acc") forState:UIControlStateNormal];
    
    channelListTableView.backgroundColor = [UIColor clearColor];
    channelListTableView.backgroundView.hidden = YES;
    
    NSString *currentLan = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    NSURL *aboutFileURL = nil;
    
    if (![currentLan isEqual:@"en"] && ![currentLan isEqual:@"zh-Hans"] && ![currentLan isEqual:@"zh-Hant"]) {
        NSBundle *enBundle =[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"]];
        
        aboutFileURL = [NSURL fileURLWithPath:[enBundle pathForResource:@"About" ofType:@"html"]];
    }
    else{
        aboutFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"About" ofType:@"html"]];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:aboutFileURL];
    [aboutWebView loadRequest:request];
    
    [self updateSettingsUI];
    
    if(peripheralList == nil){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotificationPeripheralListDidChange) name:kNotificationPeripheralListDidChange object:nil];
        
        peripheralList =  [[[[Transmitter sharedTransmitter] bleSerialManager] bleSerialList] retain];
        
        [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateConnectionState) userInfo:nil repeats:YES];

        [connectionActivityIndicatorView stopAnimating];
        connectionActivityIndicatorView.hidden = YES;
    }
}

- (void)updateConnectionState{    
    CBPeripheral *peripheral = [[[Transmitter sharedTransmitter] bleSerialManager] currentBleSerial];

    if(isTryingConnect && ![peripheral isConnected]){
        return;
    }
    else{
        if ([peripheral isConnected]) {
            isTryingConnect = NO;
        }
        
        TransmitterState inputState = [[Transmitter sharedTransmitter] inputState];
        TransmitterState outputState = [[Transmitter sharedTransmitter] outputState];
        
        if ((inputState == TransmitterStateOk) && (outputState == TransmitterStateOk)) {
            connectionStateTextLabel.text = [NSString stringWithFormat:getLocalizeString(@"connected")];
            connectionActivityIndicatorView.hidden = YES;
        }
        else if((inputState == TransmitterStateOk) && (outputState != TransmitterStateOk)){
            connectionStateTextLabel.text = [NSString stringWithFormat:getLocalizeString(@"not connected")];
        }
        else if((inputState != TransmitterStateOk) && (outputState == TransmitterStateOk)){
            connectionStateTextLabel.text = [NSString stringWithFormat:getLocalizeString(@"not connected")];
        }
        else {
            connectionStateTextLabel.text = [NSString stringWithFormat:getLocalizeString(@"not connected")];
        }
    }
    
    peripheralListTableView.backgroundColor = [UIColor clearColor];

}

- (void)viewDidUnload
{
    [personalSettingsPageView release];
    personalSettingsPageView = nil;
    [channelSetttingsPageView release];
    channelSetttingsPageView = nil;
    [modeSettingsPageView release];
    modeSettingsPageView = nil;
    [settingsPageScrollView release];
    settingsPageScrollView = nil;
    [previousPageButton release];
    previousPageButton = nil;
    [nextPageButton release];
    nextPageButton = nil;
    [pageTitleLabel release];
    pageTitleLabel = nil;
    [okButton release];
    okButton = nil;
    
    [pageViewArray release], pageViewArray = nil;
    [pageTitleArray release], pageViewArray = nil;
    
    [pageControl release];
    pageControl = nil;
    [aboutPageView release];
    aboutPageView = nil;
    [leftHandedTitleLabel release];
    leftHandedTitleLabel = nil;
    [leftHandedSwitchButton release];
    leftHandedSwitchButton = nil;
    [interfaceOpacityTitleLabel release];
    interfaceOpacityTitleLabel = nil;
    [interfaceOpacitySlider release];
    interfaceOpacitySlider = nil;
    [interfaceOpacityLabel release];
    interfaceOpacityLabel = nil;
    [channelListTableView release];
    channelListTableView = nil;
    
    [reorderTableViewCell release], reorderTableViewCell = nil;
    
    [ppmPolarityReversedTitleLabel release];
    ppmPolarityReversedTitleLabel = nil;
    [ppmPolarityReversedSwitchButton release];
    ppmPolarityReversedSwitchButton = nil;
    [defaultSettingsButton release];
    defaultSettingsButton = nil;
    [takeOffThrottleTitleLabel release];
    takeOffThrottleTitleLabel = nil;
    [takeOffThrottleLabel release];
    takeOffThrottleLabel = nil;
    [takeOffThrottleSlider release];
    takeOffThrottleSlider = nil;
    [aileronElevatorDeadBandTitleLabel release];
    aileronElevatorDeadBandTitleLabel = nil;
    [aileronElevatorDeadBandSlider release];
    aileronElevatorDeadBandSlider = nil;
    [aileronElevatorDeadBandLabel release];
    aileronElevatorDeadBandLabel = nil;
    [rudderDeadBandTitleLabel release];
    rudderDeadBandTitleLabel = nil;
    [rudderDeadBandSlider release];
    rudderDeadBandSlider = nil;
    [rudderDeadBandLabel release];
    rudderDeadBandLabel = nil;
    [aboutWebView release];
    aboutWebView = nil;
    [peripheralView release];
    peripheralView = nil;
    [peripheralListTableView release];
    peripheralListTableView = nil;
    [peripheralListScanButton release];
    peripheralListScanButton = nil;
    [connectionActivityIndicatorView release];
    connectionActivityIndicatorView = nil;
    [connectionStateTextLabel release];
    connectionStateTextLabel = nil;
    [isScanningTextLabel release];
    isScanningTextLabel = nil;
    [accCalibrateButton release];
    accCalibrateButton = nil;
    [magCalibrateButton release];
    magCalibrateButton = nil;
    [upTrimButton release];
    upTrimButton = nil;
    [downTrimButton release];
    downTrimButton = nil;
    [rightTrimButton release];
    rightTrimButton = nil;
    [leftTrimButton release];
    leftTrimButton = nil;
    [trimSettingsView release];
    trimSettingsView = nil;
    [accModeTitleLabel release];
    accModeTitleLabel = nil;
    [accModeSwitchButton release];
    accModeSwitchButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    
    if([channelSettingsVC.view superview] == nil)
        [channelSettingsVC release], channelSettingsVC = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationDismissChannelSettingsView object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationPeripheralListDidChange object:nil];

    [personalSettingsPageView release];
    [channelSetttingsPageView release];
    [modeSettingsPageView release];
    [settingsPageScrollView release];
    [previousPageButton release];
    [nextPageButton release];
    [pageTitleLabel release];
    [okButton release];
    
    [pageViewArray release];
    [pageTitleArray release];
    
    [pageControl release];
    [aboutPageView release];
    [leftHandedTitleLabel release];
    [leftHandedSwitchButton release];
    [interfaceOpacityTitleLabel release];
    [interfaceOpacitySlider release];
    [interfaceOpacityLabel release];
    [channelListTableView release];
    [reorderTableViewCell release];
    [settings release];
    [channelSettingsVC release];
    [ppmPolarityReversedTitleLabel release];
    [ppmPolarityReversedSwitchButton release];
    [defaultSettingsButton release];
    [takeOffThrottleTitleLabel release];
    [takeOffThrottleLabel release];
    [takeOffThrottleSlider release];
    [aileronElevatorDeadBandTitleLabel release];
    [aileronElevatorDeadBandSlider release];
    [aileronElevatorDeadBandLabel release];
    [rudderDeadBandTitleLabel release];
    [rudderDeadBandSlider release];
    [rudderDeadBandLabel release];
    [aboutWebView release];
    [peripheralView release];
    [peripheralListTableView release];
    [peripheralListScanButton release];
    [connectionActivityIndicatorView release];
    [connectionStateTextLabel release];
    [selectedPeripheral release];
    [isScanningTextLabel release];
    [accCalibrateButton release];
    [magCalibrateButton release];
    [upTrimButton release];
    [downTrimButton release];
    [rightTrimButton release];
    [leftTrimButton release];
    [trimSettingsView release];
    [accModeTitleLabel release];
    [accModeSwitchButton release];
    [beginnerModeSwitchButton release];
    [beginnerModeTitleLabel release];
    [headfreeModeTitleLabel release];
    [headfreeModeSwitchButton release];
    [param1Slider release];
    [param2Slider release];
    [param3Slider release];
    [param4Slider release];
    [param5Slider release];
    [param6Slider release];
    [param7Slider release];
    [param8Slider release];
    [param9Slider release];
    [param10Slider release];
    [param11Slider release];
    [param12Slider release];
    [param1Label release];
    [param2Label release];
    [param3Label release];
    [param4Label release];
    [param5Label release];
    [param6Label release];
    [param7Label release];
    [param8Label release];
    [param9Label release];
    [param10Label release];
    [param11Label release];
    [param12Label release];
    [testSettingsView release];
    [testSettingsView2 release];
    [param1ScaleTextFiled release];
    [param2ScaleTextFiled release];
    [param3ScaleTextFiled release];
    [param5ScaleTextFiled release];
    [param6ScaleTextFiled release];
    [param7ScaleTextFiled release];
    [param8ScaleTextFiled release];
    [param9ScaleTextFiled release];
    [param10ScaleTextFiled release];
    [param11ScaleTextFiled release];
    [param12ScaleTextFiled release];
    [param1ValueLabel release];
    [param4ScaleTextFiled release];
    [param2ValueLabel release];
    [param3ValueLabel release];
    [param4ValueLabel release];
    [param5ValueLabel release];
    [param6ValueLabel release];
    [param7ValueLabel release];
    [param8ValueLabel release];
    [param9ValueLabel release];
    [param10ValueLabel release];
    [param11ValueLabel release];
    [param12ValueLabel release];
    [super dealloc];
}

- (void)dismissChannelSetttingsView{
    [channelSettingsVC.view removeFromSuperview];
    [channelListTableView reloadData];
}

- (void)updateTakeOffThrottleLabel{
    Channel *throttleChannel = [settings channelByName:kChannelNameThrottle];
    
    float outputValue = clip(-1 + settings.takeOffThrottle * 2 + throttleChannel.trimValue, -1.0, 1.0); 
    
    if (throttleChannel.isReversing) {
        outputValue = -outputValue;
    }
    
    float takeOffThrottle = 1500 + 500 * (outputValue * throttleChannel.outputAdjustabledRange);
    
    takeOffThrottleLabel.text = [NSString stringWithFormat:@"%.2f, %dus", settings.takeOffThrottle, (int)takeOffThrottle];
}

- (void)updateRudderDeadBandLabel{
    rudderDeadBandLabel.text = [NSString stringWithFormat:@"%.2f%%", settings.rudderDeadBand * 100];
}

- (void)updateRudderDeadBandSlider{
    rudderDeadBandSlider.value = settings.rudderDeadBand / (float)kRudderMaxDeadBandRatio;
}

- (void)updateAileronElevatorDeadBandLabel{
    aileronElevatorDeadBandLabel.text = [NSString stringWithFormat:@"%.2f%%", settings.aileronDeadBand * 100];
}

- (void)updateAileronElevatorDeadBandSlider{
    aileronElevatorDeadBandSlider.value = settings.aileronDeadBand / (float)kAileronElevatorMaxDeadBandRatio;
}


#pragma mark UIWebViewDelegate Methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		[[UIApplication sharedApplication] openURL:[request URL]];
		return NO;
	} else {
		return YES;
	}
}
#pragma mark UIWebViewDelegate Methods end


#pragma mark UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == kChannelListTableView) {
        if([indexPath section] == ChannelListTableViewSectionChannels){
            Channel *channel = [settings channelAtIndex:[indexPath row]];
            
            if(channelSettingsVC == nil){
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                    channelSettingsVC  = [[ChannelSettingsViewController alloc] initWithNibName:@"ChannelSettingsViewController" bundle:nil channel:channel];
                } else {
                    channelSettingsVC  = [[ChannelSettingsViewController alloc] initWithNibName:@"ChannelSettingsViewController_iPhone" bundle:nil channel:channel];
                }
            }
            channelSettingsVC.channel = channel;
            
            [self.view addSubview:channelSettingsVC.view];
    }
    }
    else if(tableView.tag == kPeripheralDeviceListTabelView){
        CBPeripheral *peripheral = [peripheralList objectAtIndex:[indexPath row]];
        NSString *deviceName = peripheral.name;

        [selectedPeripheral release];
        selectedPeripheral = [peripheral retain];
        
        if ([[[Transmitter sharedTransmitter] bleSerialManager] currentBleSerial] == peripheral) {
           // if ([peripheral isConnected]) {
            if ([[Transmitter sharedTransmitter] isConnected]) {
                NSString *msg = getLocalizeString(@"Disconnect to Flexbot?");
                [self showAlertViewWithTitle:getLocalizeString(@"Connection") cancelButtonTitle:getLocalizeString(@"Cancel") okButtonTitle:getLocalizeString(@"Disconnect") message:msg tag:settings_alert_dialog_disconnect];
            }
            else{
                NSString *msg = getLocalizeString(@"Connect to Flexbot?");
                [self showAlertViewWithTitle:getLocalizeString(@"Connection") cancelButtonTitle:getLocalizeString(@"Cancel") okButtonTitle:getLocalizeString(@"Connect") message:msg tag:settings_alert_dialog_connect];
            }
        }
        else{
            NSString *msg = getLocalizeString(@"Connect to Flexbot?");
            [self showAlertViewWithTitle:getLocalizeString(@"Connection") cancelButtonTitle:getLocalizeString(@"Cancel") okButtonTitle:getLocalizeString(@"Connect") message:msg tag:settings_alert_dialog_connect];
        }
    }
}

#pragma mark UITableViewDelegate Methods end

#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == kChannelListTableView) {
        switch (section) {
            case ChannelListTableViewSectionChannels:
                return 8;
                break;
            default:
                return 0;
                break;
        }
    }
    else{
        return  [peripheralList count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (tableView.tag == kChannelListTableView) {
        switch (section) {
            case ChannelListTableViewSectionChannels:
                return getLocalizeString(@"CHANNELS");
                break;
            default:
                return @"";
                break;
        }
    }
    else{
       // return @"找到的BLE设备";
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == kChannelListTableView) {
        switch ([indexPath section]) {
            case ChannelListTableViewSectionChannels: {
                NSString *cellId = [NSString stringWithFormat:@"CellType%d", kChannelListTableView];
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId] autorelease];
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                }
                
                Channel *channel = [settings channelAtIndex:[indexPath row]];
                
                cell.textLabel.text = [NSString stringWithFormat:@"%d: %@", [channel idx] + 1, [channel name]];
                
                int minOutputPpm = (int)(1500 + 500 * clip(-1 + channel.trimValue, -1, 1) * channel.outputAdjustabledRange);
                int maxOutputPpm = (int)(1500 + 500 * clip(1 + channel.trimValue, -1, 1) * channel.outputAdjustabledRange);
                
                NSString *ppmRangeText = [NSString stringWithFormat:@"%d~%dus", minOutputPpm, maxOutputPpm];
                
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@:%.2f %@:%.2f %@", [channel isReversing] ? getLocalizeString(@"Reversed"):getLocalizeString(@"Normal"), getLocalizeString(@"Trim"), [channel trimValue], getLocalizeString(@"Adjustable"), [channel outputAdjustabledRange], ppmRangeText];
                
                return cell;
            }
            default:
                return nil;
        }
    }
    else{
        NSString *cellId = [NSString stringWithFormat:@"CellType%d", kPeripheralDeviceListTabelView];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId] autorelease];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        
        CBPeripheral *peripheral = [peripheralList objectAtIndex:[indexPath row]];
        //cell.textLabel.text = peripheral.name;
        cell.textLabel.text = @"Flexbot";
        //cell.detailTextLabel.text = [NSString stringWithFormat:@"RRSI:%d", [peripheral.RSSI intValue]];
        return cell;
    }
}

#pragma mark UITableViewDataSource Methods end


- (void)setSwitchButton:(UIButton *)switchButton withValue:(BOOL)active
{
    if (active)
    {
        switchButton.tag = SWITCH_BUTTON_CHECKED;
        [switchButton setImage:[UIImage imageNamed:@"Btn_ON.png"] forState:UIControlStateNormal];
    }
    else
    {
        switchButton.tag = SWITCH_BUTTON_UNCHECKED;
        [switchButton setImage:[UIImage imageNamed:@"Btn_OFF.png"] forState:UIControlStateNormal];
    }
}

- (void)toggleSwitchButton:(UIButton *)switchButton
{
    [self setSwitchButton:switchButton withValue:(SWITCH_BUTTON_UNCHECKED == switchButton.tag) ? YES : NO];
}


- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
	int currentPage = (int) (settingsPageScrollView.contentOffset.x + .5f * settingsPageScrollView.frame.size.width) / settingsPageScrollView.frame.size.width;
    
    if (currentPage == 0)
    {
        [previousPageButton setHidden:YES];
        [nextPageButton setHidden:NO];
    }
    else if (currentPage == (pageCount - 1))
    {
        [previousPageButton setHidden:NO];
        [nextPageButton setHidden:YES];
    }
    else if (currentPage >= pageCount)
    {
        currentPage = pageCount - 1;
        [previousPageButton setHidden:NO];
        [nextPageButton setHidden:YES];
    }
    else
    {
        [previousPageButton setHidden:NO];
        [nextPageButton setHidden:NO];
    }
    
    [pageControl setCurrentPage:currentPage];
    [pageTitleLabel setText:[pageTitleArray objectAtIndex:currentPage]];
}

- (void)showPreviousPageView{
    int nextPage = ((int) (settingsPageScrollView.contentOffset.x + .5f * settingsPageScrollView.frame.size.width) / settingsPageScrollView.frame.size.width) - 1;
    if (0 > nextPage)
        nextPage = 0;
    CGFloat nextOffset = nextPage * settingsPageScrollView.frame.size.width;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    [settingsPageScrollView setContentOffset:CGPointMake(nextOffset, 0.f) animated:NO];
    [UIView commitAnimations];
}

- (void)showNextPageView{
    int nextPage = ((int) (settingsPageScrollView.contentOffset.x + .5f * settingsPageScrollView.frame.size.width) / settingsPageScrollView.frame.size.width) + 1;
    if (pageCount <= nextPage)
        nextPage = pageCount - 1;
    CGFloat nextOffset = nextPage *settingsPageScrollView.frame.size.width;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    [settingsPageScrollView setContentOffset:CGPointMake(nextOffset, 0.f) animated:NO];
    [UIView commitAnimations];
}

- (void)resetToDefaultSettings{
    [settings resetToDefault];
    [settings save];
    
    [self updateSettingsUI];
    
    if([_delegate respondsToSelector:@selector(settingsMenuViewController:leftHandedValueDidChange:)]){
        [_delegate settingsMenuViewController:self leftHandedValueDidChange:settings.isLeftHanded];
    }
    
    if([_delegate respondsToSelector:@selector(settingsMenuViewController:accModeValueDidChange:)]){
        [_delegate settingsMenuViewController:self accModeValueDidChange:settings.isAccMode];
    }
    
    if([_delegate respondsToSelector:@selector(settingsMenuViewController:ppmPolarityReversed:)]){
        [_delegate settingsMenuViewController:self ppmPolarityReversed:settings.ppmPolarityIsNegative];
    }
    
    
    if([_delegate respondsToSelector:@selector(settingsMenuViewController:interfaceOpacityValueDidChange:)]){
        [_delegate settingsMenuViewController:self interfaceOpacityValueDidChange:settings.interfaceOpacity];
    }
}

- (void)startConnect{
    isTryingConnect = YES;
    connectionStateTextLabel.text = getLocalizeString(@"Connecting...");
    [connectionActivityIndicatorView startAnimating];
    connectionActivityIndicatorView.hidden = NO;
    isScanningTextLabel.hidden = YES;
}

- (void)switchScan{
    BleSerialManager *manager = [[Transmitter sharedTransmitter] bleSerialManager];
    
    if ([manager isScanning]) {
        [peripheralListScanButton setTitle:getLocalizeString(@"Scan") forState:UIControlStateNormal];
        isScanningTextLabel.hidden = YES;
        connectionActivityIndicatorView.hidden = YES;
        [manager stopScan];
    }
    else{
        [[[Transmitter sharedTransmitter] bleSerialManager] disconnect];
        
        [manager scan];
        
        if ([manager isScanning]) {
            [peripheralListScanButton setTitle:getLocalizeString(@"Stop Scan") forState:UIControlStateNormal];
            isScanningTextLabel.hidden = NO;
            connectionActivityIndicatorView.hidden = NO;
            [connectionActivityIndicatorView startAnimating];
        }
    }
}

- (NSData *)getSimpleSetCmd:(int)cmdName{
    unsigned char cmd[6];
    cmd[0] = '$';
    cmd[1] = 'M';
    cmd[2] = '<';
    cmd[3] = 0;
    cmd[4] = cmdName; // MSP_ACC_CALIBRATION
    
    unsigned char checkSum = 0;
    
    checkSum ^= (cmd[3] & 0xFF);
    checkSum ^= (cmd[4] & 0xFF);
    
    cmd[5] = checkSum;
    
    return [NSData dataWithBytes:cmd length:6];
}

- (IBAction)buttonClick:(id)sender {
    if(sender == okButton){
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDismissSettingsMenuView object:self userInfo:nil];
    }
    else if(sender == previousPageButton){
        [self showPreviousPageView];
    }
    else if(sender == nextPageButton){
        [self showNextPageView];
    }
    else if(sender == defaultSettingsButton){
        NSString *msg = getLocalizeString(@"Reset to defaut settings?");
        [self showAlertViewWithTitle:nil cancelButtonTitle:getLocalizeString(@"Cancel") okButtonTitle:getLocalizeString(@"Reset") message:msg tag:settings_alert_dialog_default];
    }
    else if(sender == peripheralListScanButton){
        [self switchScan];
    }
    else if(sender == accCalibrateButton){
        NSString *msg = getLocalizeString(@"Calibrate the accelerator of Flexbot?");
        [self showAlertViewWithTitle:nil cancelButtonTitle:getLocalizeString(@"Cancel") okButtonTitle:getLocalizeString(@"Calibrate") message:msg tag:settings_alert_dialog_calibrate_acc];
    }
    else if(sender == magCalibrateButton){
        NSString *msg = getLocalizeString(@"Calibrate the magnetometer of Flexbot?");
        [self showAlertViewWithTitle:nil cancelButtonTitle:getLocalizeString(@"Cancel") okButtonTitle:getLocalizeString(@"Calibrate") message:msg tag:settings_alert_dialog_calibrate_mag];
    }
    else if(sender == upTrimButton){
        [[Transmitter sharedTransmitter] transmmitSimpleCommand:MSP_TRIM_UP];
    }
    else if(sender == downTrimButton){
        [[Transmitter sharedTransmitter] transmmitSimpleCommand:MSP_TRIM_DOWN];
    }
    else if(sender == leftTrimButton){
        [[Transmitter sharedTransmitter] transmmitSimpleCommand:MSP_TRIM_LEFT];
    }
    else if(sender == rightTrimButton){
        [[Transmitter sharedTransmitter] transmmitSimpleCommand:MSP_TRIM_RIGHT];
    }
    else{
    }
}

- (IBAction)switchButtonClick:(id)sender {
    [self toggleSwitchButton:sender];
    
    if(sender == leftHandedSwitchButton){
        settings.isLeftHanded = (SWITCH_BUTTON_CHECKED == [sender tag]) ? YES : NO;
        [settings save];
        
        if([_delegate respondsToSelector:@selector(settingsMenuViewController:leftHandedValueDidChange:)]){
            [_delegate settingsMenuViewController:self leftHandedValueDidChange:settings.isLeftHanded];
        }
    }
    else if(sender == ppmPolarityReversedSwitchButton){
        settings.ppmPolarityIsNegative = (SWITCH_BUTTON_CHECKED == [sender tag]) ? YES : NO;
        [settings save];
        
        if([_delegate respondsToSelector:@selector(settingsMenuViewController:ppmPolarityReversed:)]){
            [_delegate settingsMenuViewController:self ppmPolarityReversed:settings.ppmPolarityIsNegative];
        }
    }
    else if(sender == accModeSwitchButton){
        settings.isAccMode = (SWITCH_BUTTON_CHECKED == [sender tag]) ? YES : NO;
        [settings save];

        if ([_delegate respondsToSelector:@selector(settingsMenuViewController:accModeValueDidChange:)]) {
            [_delegate settingsMenuViewController:self accModeValueDidChange:settings.isAccMode];
        }
    }
    else if(sender == beginnerModeSwitchButton){
        settings.isBeginnerMode = (SWITCH_BUTTON_CHECKED == [sender tag]) ? YES : NO;
        [settings save];
        
        if ([_delegate respondsToSelector:@selector(settingsMenuViewController:beginnerModeValueDidChange:)]) {
            [_delegate settingsMenuViewController:self beginnerModeValueDidChange:settings.isBeginnerMode];
        }
    }
    else if(sender == headfreeModeSwitchButton){
        settings.isHeadFreeMode = (SWITCH_BUTTON_CHECKED == [sender tag]) ? YES : NO;
        
        [settings save];
        
        if ([_delegate respondsToSelector:@selector(settingsMenuViewController:headfreeModeValueDidChange:)]) {
            [_delegate settingsMenuViewController:self headfreeModeValueDidChange:settings.isHeadFreeMode];
        }
    }
}

- (IBAction)sliderRelease:(id)sender {
    if(sender == interfaceOpacitySlider){
        [settings save];

        if([_delegate respondsToSelector:@selector(settingsMenuViewController:interfaceOpacityValueDidChange:)]){
            [_delegate settingsMenuViewController:self interfaceOpacityValueDidChange:settings.interfaceOpacity];
        }
    }
    else if(sender == takeOffThrottleSlider){
        [settings save];
    }
    else if(sender == aileronElevatorDeadBandSlider) {
        [settings save];
    }
    else if(sender == rudderDeadBandSlider){
        [settings save];
    }
}

- (IBAction)sliderValueChanged:(id)sender {
    if(sender == interfaceOpacitySlider){
        interfaceOpacityLabel.text = [NSString stringWithFormat:@"%d %%", (int)interfaceOpacitySlider.value];
        settings.interfaceOpacity = interfaceOpacitySlider.value / 100.0f;
    }
    else if(sender == takeOffThrottleSlider){
        settings.takeOffThrottle = takeOffThrottleSlider.value;
        [self updateTakeOffThrottleLabel];
    }
    else if(sender == aileronElevatorDeadBandSlider){ //无效区在0~kAileronElevatorMaxDeadBandRatio之间
        settings.aileronDeadBand = kAileronElevatorMaxDeadBandRatio * aileronElevatorDeadBandSlider.value;  
        settings.elevatorDeadBand = settings.aileronDeadBand;
        
        [self updateAileronElevatorDeadBandLabel];
    }
    else if(sender == rudderDeadBandSlider){ //无效区在0~kRudderMaxDeadBandRatio之间
        settings.rudderDeadBand = kRudderMaxDeadBandRatio * rudderDeadBandSlider.value;
        [self updateRudderDeadBandLabel];
    }
    else  if(sender == param1Slider){
        param1Label.text = [NSString stringWithFormat:@"%d", (int)param1Slider.value];
        param1ValueLabel.text = [NSString stringWithFormat:@"%.2f", (int)param1Slider.value * [param1ScaleTextFiled.text floatValue]];
    }
    else  if(sender == param2Slider){
        param2Label.text = [NSString stringWithFormat:@"%d", (int)param2Slider.value];
        param2ValueLabel.text = [NSString stringWithFormat:@"%.2f", (int)param2Slider.value * [param2ScaleTextFiled.text floatValue]];
    }
    else  if(sender == param3Slider){
        param3Label.text = [NSString stringWithFormat:@"%d", (int)param3Slider.value];
        param3ValueLabel.text = [NSString stringWithFormat:@"%.2f", (int)param3Slider.value * [param3ScaleTextFiled.text floatValue]];
    }
    else  if(sender == param4Slider){
        param4Label.text = [NSString stringWithFormat:@"%d", (int)param4Slider.value];
        param4ValueLabel.text = [NSString stringWithFormat:@"%.2f", (int)param4Slider.value * [param4ScaleTextFiled.text floatValue]];
    }
    else  if(sender == param5Slider){
        param5Label.text = [NSString stringWithFormat:@"%d", (int)param5Slider.value];
        param5ValueLabel.text = [NSString stringWithFormat:@"%.2f", (int)param5Slider.value * [param5ScaleTextFiled.text floatValue]];
    }
    else  if(sender == param6Slider){
        param6Label.text = [NSString stringWithFormat:@"%d", (int)param6Slider.value];
        param6ValueLabel.text = [NSString stringWithFormat:@"%.2f", (int)param6Slider.value * [param6ScaleTextFiled.text floatValue]];
    }
    else  if(sender == param7Slider){
        param7Label.text = [NSString stringWithFormat:@"%d", (int)param7Slider.value];
        param7ValueLabel.text = [NSString stringWithFormat:@"%.2f", (int)param7Slider.value * [param7ScaleTextFiled.text floatValue]];
    }
    else  if(sender == param8Slider){
        param8Label.text = [NSString stringWithFormat:@"%d", (int)param8Slider.value];
        param8ValueLabel.text = [NSString stringWithFormat:@"%.2f", (int)param8Slider.value * [param8ScaleTextFiled.text floatValue]];
    }
    else  if(sender == param9Slider){
        param9Label.text = [NSString stringWithFormat:@"%d", (int)param9Slider.value];
        param9ValueLabel.text = [NSString stringWithFormat:@"%.2f", (int)param9Slider.value * [param9ScaleTextFiled.text floatValue]];
    }
    else  if(sender == param10Slider){
        param10Label.text = [NSString stringWithFormat:@"%d", (int)param10Slider.value];
        param10ValueLabel.text = [NSString stringWithFormat:@"%.2f", (int)param10Slider.value * [param10ScaleTextFiled.text floatValue]];
    }
    else  if(sender == param11Slider){
        param11Label.text = [NSString stringWithFormat:@"%d", (int)param11Slider.value];
        param11ValueLabel.text = [NSString stringWithFormat:@"%.2f", (int)param11Slider.value * [param11ScaleTextFiled.text floatValue]];
    }
    else  if(sender == param12Slider){
        param12Label.text = [NSString stringWithFormat:@"%d", (int)param12Slider.value];
        param12ValueLabel.text = [NSString stringWithFormat:@"%.2f", (int)param12Slider.value * [param12ScaleTextFiled.text floatValue]];
    }
}

- (IBAction)write:(id)sender {
    unsigned char package[22];
    
    package[0] = '$';
    package[1] = 'M';
    package[2] = '<';
    package[3] = 12;
    
    package[4] = MSP_SET_TEST_PARAM;
    
    unsigned char checkSum = 0;
    
    int dataSizeIdx = 3;
    int checkSumIdx = 17;
    
    //package[dataSizeIdx] = 6;
    
    checkSum ^= (package[dataSizeIdx] & 0xFF);
    checkSum ^= (package[dataSizeIdx + 1] & 0xFF);
    
    package[5]  = (int)(param1Slider.value);  // param 1 alpha
    package[6]  = (int)(param2Slider.value);  // param 2 p
    package[7]  = (int)(param3Slider.value);  // param 3 i
    package[8]  = (int)(param4Slider.value);  // param 4 d
    package[9]  = (int)(param5Slider.value);  // param 5
    package[10] = (int)(param6Slider.value);  // param 6
    package[11] = (int)(param7Slider.value);  // param 7
    package[12] = (int)(param8Slider.value);  // param 8
    package[13] = (int)(param9Slider.value);  // param 9
    package[14] = (int)(param10Slider.value); // param 10
    package[15] = (int)(param11Slider.value); // param 11
    package[16] = (int)(param12Slider.value); // param 11
    
    NSLog(@"write p3=%d, p4=%d", package[7], package[8]);
    
    checkSum ^= (package[5] & 0xFF);
    checkSum ^= (package[6] & 0xFF);
    checkSum ^= (package[7] & 0xFF);
    checkSum ^= (package[8] & 0xFF);
    checkSum ^= (package[9] & 0xFF);
    checkSum ^= (package[10] & 0xFF);
    checkSum ^= (package[11] & 0xFF);
    checkSum ^= (package[12] & 0xFF);
    checkSum ^= (package[13] & 0xFF);
    checkSum ^= (package[14] & 0xFF);
    checkSum ^= (package[15] & 0xFF);
    checkSum ^= (package[16] & 0xFF);
    
    package[checkSumIdx] = checkSum;
    
    NSMutableData *params = [NSMutableData dataWithBytes:package length:18];
    
    [[Transmitter sharedTransmitter] transmmitData:params];
}

- (IBAction)read:(id)sender {
    [[Transmitter sharedTransmitter] transmmitSimpleCommand:MSP_READ_TEST_PARAM];
    
    [self performSelector:@selector(updateTestParams) withObject:nil afterDelay:1];
}

- (void)handleNotificationPeripheralListDidChange{
    [peripheralListTableView reloadData];
}

- (void)showAlertViewWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle message:(NSString *)message tag:(int)tag{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:cancelButtonTitle
                                              otherButtonTitles:okButtonTitle, nil];
    alertView.tag = tag;
    [alertView show];
    [alertView release];
}

#pragma mark UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        switch (alertView.tag) {
            case settings_alert_dialog_connect:
                [[[Transmitter sharedTransmitter] bleSerialManager] disconnect];
                isTryingConnect = YES;
                [[[Transmitter sharedTransmitter] bleSerialManager] connect:selectedPeripheral];
                break;
            case settings_alert_dialog_disconnect:
                isTryingConnect = NO;
                [[[Transmitter sharedTransmitter] bleSerialManager] disconnect];
                break;
            case settings_alert_dialog_default:
                [self resetToDefaultSettings];
                break;
            case settings_alert_dialog_calibrate_mag:
                [[[Transmitter sharedTransmitter] bleSerialManager] sendControlData:[self getSimpleSetCmd:206]]; // MSP_MAG_CALIBRATION
                break;
            case settings_alert_dialog_calibrate_acc:
                [[[Transmitter sharedTransmitter] bleSerialManager] sendControlData:[self getSimpleSetCmd:205]];  // MSP_ACC_CALIBRATION
                break;
            default:
                break;
        }
    }
    else{
    }
}
#pragma mark UIAlertViewDelegate Methods end


- (void)updateTestParams{
    OSDData *osdData = [Transmitter sharedTransmitter].osdData;
    
    param1Slider.value  = osdData.param1;
    param2Slider.value  = osdData.param2;
    param3Slider.value  = osdData.param3;
    param4Slider.value  = osdData.param4;
    param5Slider.value  = osdData.param5;
    param6Slider.value  = osdData.param6;
    param7Slider.value  = osdData.param7;
    param8Slider.value  = osdData.param8;
    param9Slider.value  = osdData.param9;
    param10Slider.value = osdData.param10;
    param11Slider.value = osdData.param11;
    param12Slider.value = osdData.param12;
    
    param1Label.text  = [NSString stringWithFormat:@"%d", (int)param1Slider.value];
    param2Label.text  = [NSString stringWithFormat:@"%d", (int)param2Slider.value];
    param3Label.text  = [NSString stringWithFormat:@"%d", (int)param3Slider.value];
    param4Label.text  = [NSString stringWithFormat:@"%d", (int)param4Slider.value];
    param5Label.text  = [NSString stringWithFormat:@"%d", (int)param5Slider.value];
    param6Label.text  = [NSString stringWithFormat:@"%d", (int)param6Slider.value];
    param7Label.text  = [NSString stringWithFormat:@"%d", (int)param7Slider.value];
    param8Label.text  = [NSString stringWithFormat:@"%d", (int)param8Slider.value];
    param9Label.text  = [NSString stringWithFormat:@"%d", (int)param9Slider.value];
    param10Label.text = [NSString stringWithFormat:@"%d", (int)param10Slider.value];
    param11Label.text = [NSString stringWithFormat:@"%d", (int)param11Slider.value];
    param12Label.text = [NSString stringWithFormat:@"%d", (int)param12Slider.value];
    
    param1ValueLabel.text = [NSString stringWithFormat:@"%.2f", (int)param1Slider.value * [param1ScaleTextFiled.text floatValue]];
    param2ValueLabel.text = [NSString stringWithFormat:@"%.2f", (int)param2Slider.value * [param2ScaleTextFiled.text floatValue]];
    param3ValueLabel.text = [NSString stringWithFormat:@"%.2f", (int)param3Slider.value * [param3ScaleTextFiled.text floatValue]];
    param4ValueLabel.text = [NSString stringWithFormat:@"%.2f", (int)param4Slider.value * [param4ScaleTextFiled.text floatValue]];
    param5ValueLabel.text = [NSString stringWithFormat:@"%.2f", (int)param5Slider.value * [param5ScaleTextFiled.text floatValue]];
    param6ValueLabel.text = [NSString stringWithFormat:@"%.2f", (int)param6Slider.value * [param6ScaleTextFiled.text floatValue]];
    param7ValueLabel.text = [NSString stringWithFormat:@"%.2f", (int)param7Slider.value * [param7ScaleTextFiled.text floatValue]];
    param8ValueLabel.text = [NSString stringWithFormat:@"%.2f", (int)param8Slider.value * [param8ScaleTextFiled.text floatValue]];
    param9ValueLabel.text = [NSString stringWithFormat:@"%.2f", (int)param9Slider.value * [param9ScaleTextFiled.text floatValue]];
    param10ValueLabel.text = [NSString stringWithFormat:@"%.2f", (int)param10Slider.value * [param10ScaleTextFiled.text floatValue]];
    param11ValueLabel.text = [NSString stringWithFormat:@"%.2f", (int)param11Slider.value * [param11ScaleTextFiled.text floatValue]];
    param12ValueLabel.text = [NSString stringWithFormat:@"%.2f", (int)param12Slider.value * [param12ScaleTextFiled.text floatValue]];
}

@end
