//
//  SerialGATT.m
//  HMSoft
//
//  Created by HMSofts on 7/13/12.
//  Copyright (c) 2012 jnhuamao.cn. All rights reserved.
//

#import "SerialGATT.h"

@implementation SerialGATT

@synthesize delegate;
@synthesize peripherals;
@synthesize manager;
@synthesize activePeripheral;

//@synthesize serialGATTService;
//@synthesize dataRecvrCharacteristic;

//@synthesize serialGATTNotifyService;
//@synthesize dataNotifyCharacteristic;


//@synthesize serviceWriteUUID;
//@synthesize serviceNotifyUUID;

/*!
 *  @method notification:
 *
 *  @param serviceUUID Service UUID to read from (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to read from (e.g. 0x2401)
 *  @param p CBPeripheral to read from
 *
 *  @discussion Main routine for enabling and disabling notification services. It converts integers 
 *  into CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service. 
 *  If this is found, the notfication is set. 
 *
 */
-(void) notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p on:(BOOL)on {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUIDEx:su p:p];
    if (!service) {
        printf("Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUIDEx:cu service:service];
    if (!characteristic) {
        printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        return;
    }
    [p setNotifyValue:on forCharacteristic:characteristic];
}


/*!
 *  @method swap:
 *
 *  @param s Uint16 value to byteswap
 *
 *  @discussion swap byteswaps a UInt16 
 *
 *  @return Byteswapped UInt16
 */

-(UInt16) swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}

/*
 * (void) setup
 * enable CoreBluetooth CentralManager and set the delegate for SerialGATT
 *
 */

-(void) setup
{
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

/*
 * -(int) findBTSmartPeripherals:(int)timeout
 *
 * search for the BTSmartPeripherals and stop in timeout
 */

-(int) findBTSmartPeripherals:(int)timeout
{
    if ([manager state] != CBCentralManagerStatePoweredOn) {
        printf("CoreBluetooth is not correctly initialized !\n");
        return -1;
    }
    
    [NSTimer scheduledTimerWithTimeInterval:(float)timeout target:self selector:@selector(scanTimer:) userInfo:nil repeats:NO];
    
    //[manager scanForPeripheralsWithServices:[NSArray arrayWithObject:serviceUUID] options:0]; // start Scanning
    [manager scanForPeripheralsWithServices:nil options:0];
    return 0;
}

/*
 * scanTimer
 * when findBTSmartPeripherals is timeout, this function will be called
 *
 */
-(void) scanTimer:(NSTimer *)timer
{
    [manager stopScan];
}

/*
 *  @method printPeripheralInfo:
 *
 *  @param peripheral Peripheral to print info of 
 *
 *  @discussion printPeripheralInfo prints detailed info about peripheral 
 *
 */
- (void) printPeripheralInfo:(CBPeripheral*)peripheral {
    CFStringRef s = CFUUIDCreateString(NULL, peripheral.UUID);
    printf("------------------------------------\r\n");
    printf("Peripheral Info :\r\n");
    printf("UUID : %s\r\n",CFStringGetCStringPtr(s, 0));
    printf("RSSI : %d\r\n",[peripheral.RSSI intValue]);
    printf("Name : %s\r\n",[peripheral.name cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
    printf("isConnected : %d\r\n",peripheral.isConnected);
    printf("-------------------------------------\r\n");
    
}

/*
 * connect
 * connect to a given peripheral
 *
 */
-(void) connect:(CBPeripheral *)peripheral
{
    if (![peripheral isConnected]) {
        [manager connectPeripheral:peripheral options:nil];
    }
}

/*
 * disconnect
 * disconnect to a given peripheral
 *
 */
-(void) disconnect:(CBPeripheral *)peripheral
{
    [manager cancelPeripheralConnection:peripheral];
}

#pragma mark - basic operations for SerialGATT service
-(void) write:(CBPeripheral *)peripheral data:(NSData *)data
{
    /*if (!serialGATTService || !dataRecvrCharacteristic) {
        return;
    }
    //fileService characteristicUUID:fileSub
    
    [peripheral writeValue:data forCharacteristic:dataRecvrCharacteristic type:CBCharacteristicWriteWithoutResponse];*/
    [self writeValue:fileService characteristicUUID:fileSub p:peripheral data:data];
    //[self writeValue:mainService characteristicUUID:mainSub3 p:peripheral data:data];
}

-(void) read:(CBPeripheral *)peripheral
{
    printf("begin reading\n");
    /*if (!serialGATTService || !dataRecvrCharacteristic) {
        return;
    }*/
    
    printf("now can reading......\n");
    //[peripheral readValueForCharacteristic:dataRecvrCharacteristic];
}

-(void) notify: (CBPeripheral *)peripheral on:(BOOL)on
{
    //if (!serialGATTService || !dataNotifyCharacteristic) {
    //    return;
    //}
    //char data = 0x01;
    //NSData *d = [[NSData alloc] initWithBytes:&data length:1];
    //[self writeValue:mainService characteristicUUID:mainSub1 p:peripheral data:d];
    //[self notification:mainService characteristicUUID:mainSub1 p:peripheral on:YES];
    //[self notification:mainService characteristicUUID:mainSub2 p:peripheral on:YES];
    //[self notification:mainService characteristicUUID:mainSub3 p:peripheral on:YES];
    //[self notification:mainService characteristicUUID:mainSub4 p:peripheral on:YES];
    //[self notification:mainService characteristicUUID:mainSub5 p:peripheral on:YES];
    [self notification:fileService characteristicUUID:fileSub p:peripheral on:YES];

    //[peripheral setNotifyValue:on forCharacteristic:dataNotifyCharacteristic];
}

#pragma mark - Finding CBServices and CBCharacteristics

-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)peripheral
{//查找的是主服务，找到主服务后再找char
    printf("the services count is %d\n", peripheral.services.count);
    for (CBService *s in peripheral.services) {
        printf("<%s> is found!\n", [[s.UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
        // compare s with UUID
        if ([[s.UUID data] isEqualToData:[UUID data]]) {
            return s;
        }
    }
    return  nil;
}

-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID p:(CBPeripheral *)peripheral service:(CBService *)service
{
    for (CBCharacteristic *c in service.characteristics) {
        printf("characteristic <%s> is found!\n", [[UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
        if ([[c.UUID data] isEqualToData:[UUID data]]) {
            return c;
        }
    }
    return nil;
}


#pragma mark - CBCentralManager Delegates

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    //TODO: to handle the state updates
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    if (!peripherals) {
        peripherals = [[NSMutableArray alloc] initWithObjects:peripheral, nil];
    }
    else {
        // Add the new peripheral to the peripherals array
        for (int i = 0; i < [peripherals count]; i++) {
            CBPeripheral *p = [peripherals objectAtIndex:i];
            
            CFUUIDBytes b1 = CFUUIDGetUUIDBytes(p.UUID);
            CFUUIDBytes b2 = CFUUIDGetUUIDBytes(peripheral.UUID);
            if (memcmp(&b1, &b2, 16) == 0) {
                // these are the same, and replace the old peripheral information
                [peripherals replaceObjectAtIndex:i withObject:peripheral];
                printf("Duplicated peripheral is found...\n");
                [delegate peripheralFound: peripheral];
                return;
            }
        }
        [peripherals addObject:peripheral];
        [delegate peripheralFound:peripheral];
    }
    printf("%s\n", __FUNCTION__);
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    activePeripheral = peripheral;
    activePeripheral.delegate = self;
    
    [activePeripheral discoverServices:nil];
    
    [self printPeripheralInfo:peripheral];
    
    printf("connected to the active peripheral\n");
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    activePeripheral = nil;
    printf("disconnected to the active peripheral\n");
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"failed to connect to peripheral %@: %@\n", [peripheral name], [error localizedDescription]);
}

#pragma mark - CBPeripheral delegates

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    printf("in updateValueForCharacteristic function\n");
    
    if (error) {
        printf("updateValueForCharacteristic failed\n");
        return;
    }
    [delegate serialGATTCharValueUpdated:@"FFE1" value:characteristic.value];

    /*
    // Compare the characteristic with SERIAL_PERIPHERAL_CHAR_RECV_UUID and SERIAL_PERIPHERAL_CHAR_NOTIFY_UUID
    CBUUID *charRecvUUID = [CBUUID UUIDWithString:SERIAL_PERIPHERAL_CHAR_RECV_UUID];
    CBUUID *charNotifyUUID = [CBUUID UUIDWithString:SERIAL_PERIPHERAL_CHAR_NOTIFY_UUID];

    if ([[characteristic.UUID data] isEqualToData:[charRecvUUID data]]) {
        // TODO: read the data from SERIAL_PERIPHERAL_CHAR_RECV_UUID, which can be used to write and read data
        [delegate serialGATTCharValueUpdated:SERIAL_PERIPHERAL_CHAR_RECV_UUID value:characteristic.value];
    } else  if ([[characteristic.UUID data] isEqualToData:[charNotifyUUID data]]) {
        // TODO: read the data from SERIAL_PERIPHERAL_CHAR_NOTIFY_UUID
        [delegate serialGATTCharValueUpdated:SERIAL_PERIPHERAL_CHAR_NOTIFY_UUID value:characteristic.value];
    }
     */

}

//////////////////////////////////////////////////////////////////////////////////////////////

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    
}

/*
 *  @method getAllCharacteristicsFromKeyfob
 *
 *  @param p Peripheral to scan
 *
 *
 *  @discussion getAllCharacteristicsFromKeyfob starts a characteristics discovery on a peripheral
 *  pointed to by p
 *
 */
-(void) getAllCharacteristicsFromKeyfob:(CBPeripheral *)p{
    for (int i=0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        printf("Fetching characteristics for service with UUID : %s\r\n",[self CBUUIDToString:s.UUID]);
        [p discoverCharacteristics:nil forService:s];
    }
}

/*
 *  @method didDiscoverServices
 *
 *  @param peripheral Pheripheral that got updated
 *  @error error Error message if something went wrong
 *
 *  @discussion didDiscoverServices is called when CoreBluetooth has discovered services on a 
 *  peripheral after the discoverServices routine has been called on the peripheral
 *
 */

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (!error) {
        printf("Services of peripheral with UUID : %s found\r\n",[self UUIDToString:peripheral.UUID]);
        [self getAllCharacteristicsFromKeyfob:peripheral];
    }
    else {
        printf("Service discovery was unsuccessfull !\r\n");
    }
}

/*
 *  @method didDiscoverCharacteristicsForService
 *
 *  @param peripheral Pheripheral that got updated
 *  @param service Service that characteristics where found on
 *  @error error Error message if something went wrong
 *
 *  @discussion didDiscoverCharacteristicsForService is called when CoreBluetooth has discovered 
 *  characteristics on a service, on a peripheral after the discoverCharacteristics routine has been called on the service
 *
 */

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (!error) {
        printf("Characteristics of service with UUID : %s found\r\n",[self CBUUIDToString:service.UUID]);
        for(int i=0; i < service.characteristics.count; i++) {
            CBCharacteristic *c = [service.characteristics objectAtIndex:i]; 
            printf("Found characteristic %s\r\n",[ self CBUUIDToString:c.UUID]);
            /*
            CBService *s = [peripheral.services objectAtIndex:(peripheral.services.count - 1)];
            if([self compareCBUUID:service.UUID UUID2:s.UUID]) {
                printf("Finished discovering characteristics\n");
                //char data = 0x01;
                //NSData *d = [[NSData alloc] initWithBytes:&data length:1];
                //[self writeValue:mainService characteristicUUID:mainSub p:peripheral data:d];
                //[self writeValue:fileService characteristicUUID:fileSub p:peripheral data:d];
                [self notify:peripheral on:YES];
            }
             */
        }
        
        char t[16];
        t[0] = (fileService >> 8) & 0xFF;
        t[1] = fileService & 0xFF;
        NSData *data = [[NSData alloc] initWithBytes:t length:16];
        CBUUID *uuid = [CBUUID UUIDWithData:data];
        
        if ([self compareCBUUID:service.UUID UUID2:uuid]) {
            printf("xxxxxTry to open notify\n");
            printf("Finished discovering characteristics\n");
            [self notify:peripheral on:YES];
        }
    }
    else {
        printf("Characteristic discorvery unsuccessfull !\r\n");
    }
}

/*- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (!error) {
        printf("The services are found\n");
        serialGATTService = [self findServiceFromUUID:[CBUUID UUIDWithString:SERIAL_PERIPHERAL_SERVICE_UUID] p:peripheral]; //FFF0
        if (!serialGATTService) {
            printf("The SERIAL_PERIPHERAL_SERVICE_UUID desired service is not found!\n");
            return;
        } else {
            [peripheral discoverCharacteristics:nil forService:serialGATTService];
        }

        serialGATTNotifyService = [self findServiceFromUUID:[CBUUID UUIDWithString:SERIAL_PERIPHERAL_NOTIFY_SERVICE_UUID] p:peripheral]; //FFE0
        if (!serialGATTNotifyService) {
            printf("The SERIAL_PERIPHERAL_NOTIFY_SERVICE_UUID desired service is not found\n");
            return;
        } else {
            [peripheral discoverCharacteristics:nil forService:serialGATTNotifyService];
        }
    }
    else {
        printf("discoverservices is uncesessful!\n");
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (!error) {
        printf("The characteristics are found for the service!\n");
        dataRecvrCharacteristic = [self findCharacteristicFromUUID:[CBUUID UUIDWithString:SERIAL_PERIPHERAL_CHAR_RECV_UUID] p:peripheral service:serialGATTService];//FFF1
        dataNotifyCharacteristic = [self findCharacteristicFromUUID:[CBUUID UUIDWithString:SERIAL_PERIPHERAL_CHAR_NOTIFY_UUID] p:peripheral service:serialGATTNotifyService];//FFE1
        if (!dataNotifyCharacteristic || !dataRecvrCharacteristic) {
            printf("The desired characteristics can't be found!\n");
            return;
        } else {
            printf("begin setting notify!\n");
            char data = 0x01;
            NSData *d = [[NSData alloc] initWithBytes:&data length:1];
            [self writeValue:mainService characteristicUUID:mainSub p:peripheral data:d];
            [self writeValue:fileService characteristicUUID:fileSub p:peripheral data:d];
            [self notify:peripheral on:YES];
        }
    }
}*/

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (!error) {
        printf("Updated notification state for characteristic with UUID %s on service with  UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],[self UUIDToString:peripheral.UUID]);
        [delegate setConnect];
    }
    else {
        printf("Error in setting notification state for characteristic with UUID %s on service with  UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],[self UUIDToString:peripheral.UUID]);
        printf("Error code was %s\r\n",[[error description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
    }
}

/*
 *  @method CBUUIDToString
 *
 *  @param UUID UUID to convert to string
 *
 *  @returns Pointer to a character buffer containing UUID in string representation
 *
 *  @discussion CBUUIDToString converts the data of a CBUUID class to a character pointer for easy printout using printf()
 *
 */
-(const char *) CBUUIDToString:(CBUUID *) UUID {
    return [[UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
}


/*
 *  @method UUIDToString
 *
 *  @param UUID UUID to convert to string
 *
 *  @returns Pointer to a character buffer containing UUID in string representation
 *
 *  @discussion UUIDToString converts the data of a CFUUIDRef class to a character pointer for easy printout using printf()
 *
 */
-(const char *) UUIDToString:(CFUUIDRef)UUID {
    if (!UUID) return "NULL";
    CFStringRef s = CFUUIDCreateString(NULL, UUID);
    return CFStringGetCStringPtr(s, 0);		
    
}

/*
 *  @method compareCBUUID
 *
 *  @param UUID1 UUID 1 to compare
 *  @param UUID2 UUID 2 to compare
 *
 *  @returns 1 (equal) 0 (not equal)
 *
 *  @discussion compareCBUUID compares two CBUUID's to each other and returns 1 if they are equal and 0 if they are not
 *
 */

-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2 {
    char b1[16];
    char b2[16];
    [UUID1.data getBytes:b1];
    [UUID2.data getBytes:b2];
    if (memcmp(b1, b2, UUID1.data.length) == 0)return 1;
    else return 0;
}

/*
 *  @method compareCBUUIDToInt
 *
 *  @param UUID1 UUID 1 to compare
 *  @param UUID2 UInt16 UUID 2 to compare
 *
 *  @returns 1 (equal) 0 (not equal)
 *
 *  @discussion compareCBUUIDToInt compares a CBUUID to a UInt16 representation of a UUID and returns 1 
 *  if they are equal and 0 if they are not
 *
 */
-(int) compareCBUUIDToInt:(CBUUID *)UUID1 UUID2:(UInt16)UUID2 {
    char b1[16];
    [UUID1.data getBytes:b1];
    UInt16 b2 = [self swap:UUID2];
    if (memcmp(b1, (char *)&b2, 2) == 0) return 1;
    else return 0;
}
/*
 *  @method CBUUIDToInt
 *
 *  @param UUID1 UUID 1 to convert
 *
 *  @returns UInt16 representation of the CBUUID
 *
 *  @discussion CBUUIDToInt converts a CBUUID to a Uint16 representation of the UUID
 *
 */
-(UInt16) CBUUIDToInt:(CBUUID *) UUID {
    char b1[16];
    [UUID.data getBytes:b1];
    return ((b1[0] << 8) | b1[1]);
}

/*
 *  @method IntToCBUUID
 *
 *  @param UInt16 representation of a UUID
 *
 *  @return The converted CBUUID
 *
 *  @discussion IntToCBUUID converts a UInt16 UUID to a CBUUID
 *
 */
-(CBUUID *) IntToCBUUID:(UInt16)UUID {
    char t[16];
    t[0] = ((UUID >> 8) & 0xff); t[1] = (UUID & 0xff);
    NSData *data = [[NSData alloc] initWithBytes:t length:16];
    return [CBUUID UUIDWithData:data];
}


/*
 *  @method findServiceFromUUID:
 *
 *  @param UUID CBUUID to find in service list
 *  @param p Peripheral to find service on
 *
 *  @return pointer to CBService if found, nil if not
 *
 *  @discussion findServiceFromUUID searches through the services list of a peripheral to find a 
 *  service with a specific UUID
 *
 */
-(CBService *) findServiceFromUUIDEx:(CBUUID *)UUID p:(CBPeripheral *)p {
    for(int i = 0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        if ([self compareCBUUID:s.UUID UUID2:UUID]) return s;
    }
    return nil; //Service not found on this peripheral
}

/*
 *  @method findCharacteristicFromUUID:
 *
 *  @param UUID CBUUID to find in Characteristic list of service
 *  @param service Pointer to CBService to search for charateristics on
 *
 *  @return pointer to CBCharacteristic if found, nil if not
 *
 *  @discussion findCharacteristicFromUUID searches through the characteristic list of a given service 
 *  to find a characteristic with a specific UUID
 *
 */
-(CBCharacteristic *) findCharacteristicFromUUIDEx:(CBUUID *)UUID service:(CBService*)service {
    for(int i=0; i < service.characteristics.count; i++) {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
    }
    return nil; //Characteristic not found on this service
}


/*!
 *  @method writeValue:
 *
 *  @param serviceUUID Service UUID to write to (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to write to (e.g. 0x2401)
 *  @param data Data to write to peripheral
 *  @param p CBPeripheral to write to
 *
 *  @discussion Main routine for writeValue request, writes without feedback. It converts integer into
 *  CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service. 
 *  If this is found, value is written. If not nothing is done.
 *
 */

-(void) writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUIDEx:su p:p];
    if (!service) {
        printf("Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUIDEx:cu service:service];
    if (!characteristic) {
        printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        return;
    }
    [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
}


/*!
 *  @method readValue:
 *
 *  @param serviceUUID Service UUID to read from (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to read from (e.g. 0x2401)
 *  @param p CBPeripheral to read from
 *
 *  @discussion Main routine for read value request. It converts integers into
 *  CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service. 
 *  If this is found, the read value is started. When value is read the didUpdateValueForCharacteristic 
 *  routine is called.
 *
 *  @see didUpdateValueForCharacteristic
 */

-(void) readValue: (int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p {
    printf("In read Value");
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUIDEx:su p:p];
    if (!service) {
        printf("Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUIDEx:cu service:service];
    if (!characteristic) {
        printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        return;
    }  
    [p readValueForCharacteristic:characteristic];
}

@end
