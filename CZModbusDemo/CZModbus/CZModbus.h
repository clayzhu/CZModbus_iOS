//
//  CZModbus.h
//  CalculateDemo
//
//  Created by Ug's iMac on 2017/1/9.
//  Copyright © 2017年 Ugoodtech. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Modbus 从地址（地址域） */
FOUNDATION_EXPORT NSString * const kModbusAdditionalAddress;

/** 自定义 Modbus 功能码类型，直接使用十六进制字符串 */
typedef NSString * kModbusFunctionCode NS_EXTENSIBLE_STRING_ENUM;

/** 
 Modbus 功能码：03(0x03)，读一个或多个地址连续的寄存器
 Request: Function code	        | 1 Byte  | 0x03
          Starting Address      | 2 Bytes | 0x0000 to 0xFFFF
          Quantity of Registers | 2 Bytes | 1 to 125 (0x7D)
 Response: Function code  | 1 Byte       | 0x03
           Byte count     | 1 Byte       | 2 x N*
           Register value | N* x 2 Bytes |
           *N = Quantity of Registers
 Error: Error code     | 1 Byte | 0x83
        Exception code | 1 Byte | 01 or 02 or 03 or 04
 */
FOUNDATION_EXPORT kModbusFunctionCode const kModbusFunctionCodeReadHoldingRegisters;
/** 
 Modbus 功能码：06(0x06)，写单个寄存器
 Request: Function code    | 1 Byte  | 0x06
          Register Address | 2 Bytes | 0x0000 to 0xFFFF
          Register Value   | 2 Bytes | 0x0000 to 0xFFFF
 Response: Function code    | 1 Byte  | 0x06
           Register Address | 2 Bytes | 0x0000 to 0xFFFF
           Register Value   | 2 Bytes | 0x0000 to 0xFFFF
 Error: Error code     | 1 Byte | 0x86
        Exception code | 1 Byte | 01 or 02 or 03 or 04
 */
FOUNDATION_EXPORT kModbusFunctionCode const kModbusFunctionCodeWriteSingleRegister;
/** 
 Modbus 功能码：16(0x10)，写多个地址连续的寄存器
 Request: Function code         | 1 Byte       | 0x10
          Starting Address      | 2 Bytes      | 0x0000 to 0xFFFF
          Quantity of Registers | 2 Bytes      | 0x0001 to 0x007B
          Byte Count            | 1 Byte       | 2 x N*
          Registers Value       | N* x 2 Bytes | value
          *N = Quantity of Registers
 Response: Function code         | 1 Byte  | 0x10
		   Starting Address      | 2 Bytes | 0x0000 to 0xFFFF
           Quantity of Registers | 2 Bytes | 1 to 123 (0x7B)
 Error: Error code     | 1 Byte | 0x90
        Exception code | 1 Byte | 01 or 02 or 03 or 04
 */
FOUNDATION_EXPORT kModbusFunctionCode const kModbusFunctionCodeWriteMultipleRegisters;

/**
 Modbus 返回的错误代码，具体含义请参阅：http://www.485-can-tcp.com/technology/232485/Modbus-extremely.htm

 - ModbusExceptionCodeIllegalFunction: 非法功能
 - ModbusExceptionCodeIllegalDataAddress: 非法数据地址
 - ModbusExceptionCodeIllegalDataValue: 非法数据值
 - ModbusExceptionCodeSlaveDeviceFailure: 从站设备故障
 - ModbusExceptionCodeAcknowledge: 确认
 - ModbusExceptionCodeSlaveDeviceBusy: 从属设备忙
 - ModbusExceptionCodeMemoryParityError: 存储奇偶性差错
 - ModbusExceptionCodeGatewayPathUnavailable: 不可用网关路径
 - ModbusExceptionCodeGatewayTargetDeviceFailedToRespond: 网关目标设备响应失败
 */
typedef NS_ENUM(NSUInteger, ModbusExceptionCodes) {
	ModbusExceptionCodeIllegalFunction = 0x01,
	ModbusExceptionCodeIllegalDataAddress = 0x02,
	ModbusExceptionCodeIllegalDataValue = 0x03,
	ModbusExceptionCodeSlaveDeviceFailure = 0x04,
	ModbusExceptionCodeAcknowledge = 0x05,
	ModbusExceptionCodeSlaveDeviceBusy = 0x07,
	ModbusExceptionCodeMemoryParityError = 0x08,
	ModbusExceptionCodeGatewayPathUnavailable = 0x0A,
	ModbusExceptionCodeGatewayTargetDeviceFailedToRespond = 0x0B,
};

@interface CZModbus : NSObject

#pragma mark - 进制转换
/** 十进制转十六进制 */
+ (NSString *)convertDecimalToHex:(long long int)decimal;
/** 十六进制转十进制 */
+ (unsigned long long)convertHexToDecimal:(NSString *)hexStr;

/** 十六进制字符串转 Bytes */
+ (NSData *)convertHexToDataBytes:(NSString *)hexStr;
/** Bytes 转换成十六进制 */
+ (NSString *)convertDataBytesToHex:(NSData *)dataBytes;

/** 把字符串类型的十六进制转换成基本类型 */
+ (uint16_t)convertHexStringToHexInt:(NSString *)hexStr;
/** 把字符串类型的十六进制转换成元素为 uint16_t 的 uint8_t 数组 */
+ (uint8_t *)convertHexToInt8Array:(NSString *)hexStr;

/** 十六进制转二进制 */
+ (NSString *)convertHexToBinary:(NSString *)hexStr;
/** 二进制转十六进制 */
+ (NSString *)convertBinaryToHex:(NSString *)binaryStr;

/** 二进制转十进制 */
+ (NSString *)convertBinaryToDecimal:(NSString *)binaryStr;

#pragma mark - CRC16
/******************************************************************************
 ** 函数名称: CaculateCRC
 ** 功能描述: 计算MODBUS帧的CRC校验码
 ** 输　入:   pbuf   缓冲地址
             len    缓冲长度
 ** 输　出:   无
 ** 返回值:   RTU格式帧的CRC校验码
 *******************************************************************************/
uint16_t CalculateCRC(const uint8_t *pbuf, int len);

#pragma mark - 计算 Modbus
/**
 计算 Modbus RTU 通讯协议，适用于读取或写入一个寄存器
 
 @param deviceAddress 从地址（地址域），使用十六进制字符串，比如：01，02，可直接传递：kModbusAdditionalAddress
 @param functionCode 功能码，使用十六进制字符串，比如：03， 06，10，可直接传递：kModbusFunctionCodeReadHoldingRegisters，kModbusFunctionCodeWriteSingleRegister，kModbusFunctionCodeWriteMultipleRegisters
 @param functionAddress 寄存器起始地址，使用十进制 NSInteger
 @param registerCount 寄存器数量，使用十进制 NSInteger。在写入一个寄存器时，传0
 @param data 数据域。读取时，传 nil
 @return NSString 类型的 Modbus RTU 通讯协议
 */
+ (NSString *)calculateModbusRTUStringWithDeviceAddress:(NSString *)deviceAddress
										   functionCode:(kModbusFunctionCode)functionCode
										functionAddress:(NSInteger)functionAddress
										  registerCount:(NSInteger)registerCount
												   data:(NSNumber *)data;

/**
 计算 Modbus RTU 通讯协议，适用于读取或写入一个寄存器
 
 @param deviceAddress 从地址（地址域），使用十六进制字符串，比如：01，02，可直接传递：kModbusAdditionalAddress
 @param functionCode 功能码，使用十六进制字符串，比如：03， 06，10，可直接传递：kModbusFunctionCodeReadHoldingRegisters，kModbusFunctionCodeWriteSingleRegister，kModbusFunctionCodeWriteMultipleRegisters
 @param functionAddress 寄存器起始地址，使用十进制 NSInteger
 @param registerCount 寄存器数量，使用十进制 NSInteger。在写入一个寄存器时，传0
 @param data 数据域。读取时，传 nil
 @return NSData 类型的 Modbus RTU 通讯协议
 */
+ (NSData *)calculateModbusRTUBytesWithDeviceAddress:(NSString *)deviceAddress
										functionCode:(kModbusFunctionCode)functionCode
									 functionAddress:(NSInteger)functionAddress
									   registerCount:(NSInteger)registerCount
												data:(NSNumber *)data;

/**
 计算 Modbus RTU 通讯协议，适用于写入多个寄存器

 @param deviceAddress 从地址（地址域），使用十六进制字符串，比如：01，02，可直接传递：kModbusAdditionalAddress
 @param functionCode 功能码，使用十六进制字符串，比如：03， 06，10，可直接传递：kModbusFunctionCodeReadHoldingRegisters，kModbusFunctionCodeWriteSingleRegister，kModbusFunctionCodeWriteMultipleRegisters
 @param functionAddress 寄存器起始地址，使用十进制 NSInteger
 @param registerCount 寄存器数量，使用十进制 NSInteger。在写入一个寄存器时，传0
 @param byteCount 字节数，使用十进制 NSInteger。在读取或写入一个寄存器时，传0；写入多个寄存器时，传 registerCount * 2
 @param data 数据域，使用元素为 NSNumber 的数组。读取时，传 nil
 @return NSString 类型的 Modbus RTU 通讯协议
 */
+ (NSString *)calculateMultiRegistersModbusRTUStringWithDeviceAddress:(NSString *)deviceAddress
														 functionCode:(kModbusFunctionCode)functionCode
													  functionAddress:(NSInteger)functionAddress
														registerCount:(NSInteger)registerCount
															byteCount:(NSInteger)byteCount
																 data:(NSArray<NSNumber *> *)data;

/**
 计算 Modbus RTU 通讯协议，适用于写入多个寄存器
 
 @param deviceAddress 从地址（地址域），使用十六进制字符串，比如：01，02，可直接传递：kModbusAdditionalAddress
 @param functionCode 功能码，使用十六进制字符串，比如：03， 06，10，可直接传递：kModbusFunctionCodeReadHoldingRegisters，kModbusFunctionCodeWriteSingleRegister，kModbusFunctionCodeWriteMultipleRegisters
 @param functionAddress 寄存器起始地址，使用十进制 NSInteger
 @param registerCount 寄存器数量，使用十进制 NSInteger。在写入一个寄存器时，传0
 @param byteCount 字节数，使用十进制 NSInteger。在读取或写入一个寄存器时，传0；写入多个寄存器时，传 registerCount * 2
 @param data 数据域，使用元素为 NSNumber 的数组。读取时，传 nil
 @return NSData 类型的 Modbus RTU 通讯协议
 */
+ (NSData *)calculateMultiRegistersModbusRTUBytesWithDeviceAddress:(NSString *)deviceAddress
													  functionCode:(kModbusFunctionCode)functionCode
												   functionAddress:(NSInteger)functionAddress
													 registerCount:(NSInteger)registerCount
														 byteCount:(NSInteger)byteCount
															  data:(NSArray<NSNumber *> *)data;

#pragma mark - 解析返回数据
/**
 根据返回的 Modbus 命令计算返回数据，拆分每个数据，将原始十六进制成一个数组

 @param responseModbus 返回的 Modbus 命令
 @return 有错误时返回 nil，没有错误时返回一个包含每个数据的原始十六进制的数组
 */
+ (NSArray<NSString *> *)calculateReadResponseModbusDataHexList:(NSString *)responseModbus;
/**
 根据返回的 Modbus 命令计算返回数据，拆分每个数据，并转换成十进制组成一个数组

 @param responseModbus 返回的 Modbus 命令
 @return 有错误时返回 nil，没有错误时返回一个包含每个数据的十进制的数组
 */
+ (NSArray<NSString *> *)calculateReadResponseModbusDataDecimalList:(NSString *)responseModbus;
/**
 根据返回的 Modbus 命令计算返回数据，拆分每个数据，并转换成二进制组成一个数组
 
 @param responseModbus 返回的 Modbus 命令
 @return 有错误时返回 nil，没有错误时返回一个包含每个数据的二进制的数组
 */
+ (NSArray<NSString *> *)calculateReadResponseModbusDataBinaryList:(NSString *)responseModbus;
/**
 根据返回的 Modbus 命令计算返回数据，数据类型为 Double Word，转换成十进制
 
 @param responseModbus 返回的 Modbus 命令
 @return 有错误时返回 nil，没有错误时返回一个十进制数据
 */
+ (NSString *)calculateReadResponseModbusDataDoubleWord:(NSString *)responseModbus;

#pragma mark - 解析错误
/**
 根据返回的 Modbus 命令判断发送的命令是否有错
 
 @param responseModbus 返回的 Modbus 命令
 @return YES 错误，NO 正确
 */
+ (BOOL)isResponseModbusError:(NSString *)responseModbus;
/**
 根据返回的 Modbus 命令计算错误码

 @param responseModbus 返回的 Modbus 命令
 @return Modbus 错误码，没有错误时返回 0x00
 */
+ (ModbusExceptionCodes)modbusExceptionCode:(NSString *)responseModbus;
/**
 根据返回的 Modbus 命令计算错误码对应的名称

 @param responseModbus 返回的 Modbus 命令
 @return Modbus 错误码对应的名称，没有错误时返回 nil
 */
+ (NSString *)modbusExceptionName:(NSString *)responseModbus;

@end
