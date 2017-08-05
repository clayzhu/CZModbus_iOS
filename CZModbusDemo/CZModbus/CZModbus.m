//
//  CZModbus.m
//  CalculateDemo
//
//  Created by Ug's iMac on 2017/1/9.
//  Copyright © 2017年 Ugoodtech. All rights reserved.
//

#import "CZModbus.h"

NSString *const kModbusAdditionalAddress = @"02";

NSString *const kModbusFunctionCodeReadHoldingRegisters = @"03";
NSString *const kModbusFunctionCodeWriteSingleRegister = @"06";
NSString *const kModbusFunctionCodeWriteMultipleRegisters = @"10";

@implementation CZModbus

#pragma mark - 进制转换
/** 十进制转十六进制 */
+ (NSString *)convertDecimalToHex:(long long int)decimal {
	NSString *nLetterValue;
	NSString *hexStr = @"";
	long long int ttmpig;
	for (int i = 0; i < 9; i ++) {
		ttmpig = decimal % 16;
		decimal = decimal / 16;
		switch (ttmpig) {
			case 10:
				nLetterValue = @"a";
				break;
			case 11:
				nLetterValue = @"b";
				break;
			case 12:
				nLetterValue = @"c";
				break;
			case 13:
				nLetterValue = @"d";
				break;
			case 14:
				nLetterValue = @"e";
				break;
			case 15:
				nLetterValue = @"f";
				break;
			default:
				nLetterValue = [[NSString alloc] initWithFormat:@"%lli", ttmpig];
				break;
		}
		hexStr = [nLetterValue stringByAppendingString:hexStr];
		if (decimal == 0) {
			break;
		}
	}
	return hexStr;
}

/** 十六进制转十进制 */
+ (unsigned long long)convertHexToDecimal:(NSString *)hexStr {
	unsigned long long decimal = 0;
	NSScanner *scanner = [NSScanner scannerWithString:hexStr];
	[scanner scanHexLongLong:&decimal];
	return decimal;
}

/** 十六进制字符串转 Bytes */
+ (NSData *)convertHexToDataBytes:(NSString *)hexStr {
	NSMutableData *dataBytes = [NSMutableData data];
	int idx;
	for (idx = 0; idx + 2 <= hexStr.length; idx += 2) {
		NSRange range = NSMakeRange(idx, 2);
		NSString *singleHexStr = [hexStr substringWithRange:range];
		NSScanner *scanner = [NSScanner scannerWithString:singleHexStr];
		unsigned int intValue;
		[scanner scanHexInt:&intValue];
		[dataBytes appendBytes:&intValue length:1];
	}
	return dataBytes;
}

/** Bytes 转换成十六进制 */
+ (NSString *)convertDataBytesToHex:(NSData *)dataBytes {
	if (!dataBytes || [dataBytes length] == 0) {
		return @"";
	}
	NSMutableString *hexStr = [[NSMutableString alloc] initWithCapacity:[dataBytes length]];
	[dataBytes enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
		unsigned char *dataBytes = (unsigned char *)bytes;
		for (NSInteger i = 0; i < byteRange.length; i ++) {
			NSString *singleHexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
			if ([singleHexStr length] == 2) {
				[hexStr appendString:singleHexStr];
			} else {
				[hexStr appendFormat:@"0%@", singleHexStr];
			}
		}
	}];
	return hexStr;
}

/** 把字符串类型的十六进制转换成基本类型 */
+ (uint16_t)convertHexStringToHexInt:(NSString *)hexStr {
	uint8_t ss[1];
	unsigned int anInt;
	NSScanner *scanner = [[NSScanner alloc] initWithString:hexStr];
	[scanner scanHexInt:&anInt];
	uint16_t hexInt = (uint16_t)anInt;
	ss[0] = hexInt;
	return hexInt;
}

/** 把字符串类型的十六进制转换成元素为 uint16_t 的 uint8_t 数组 */
+ (uint8_t *)convertHexToInt8Array:(NSString *)hexStr {
	uint8_t *hexArray = calloc(hexStr.length / 2, sizeof(uint8_t));
	bzero(hexArray, hexStr.length / 2);
	for (int i = 0; i < hexStr.length - 1; i += 2) {
		unsigned int anInt;
		NSString *singleHexStr = [hexStr substringWithRange:NSMakeRange(i, 2)];
		NSScanner *scanner = [[NSScanner alloc] initWithString:singleHexStr];
		[scanner scanHexInt:&anInt];
		hexArray[i / 2] = (uint16_t)anInt;
	}
	return hexArray;
}

/** 十六进制转二进制 */
+ (NSString *)convertHexToBinary:(NSString *)hexStr {
	NSMutableDictionary *hexDic = [[NSMutableDictionary alloc] init];
	hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
	[hexDic setObject:@"0000" forKey:@"0"];
	[hexDic setObject:@"0001" forKey:@"1"];
	[hexDic setObject:@"0010" forKey:@"2"];
	[hexDic setObject:@"0011" forKey:@"3"];
	[hexDic setObject:@"0100" forKey:@"4"];
	[hexDic setObject:@"0101" forKey:@"5"];
	[hexDic setObject:@"0110" forKey:@"6"];
	[hexDic setObject:@"0111" forKey:@"7"];
	[hexDic setObject:@"1000" forKey:@"8"];
	[hexDic setObject:@"1001" forKey:@"9"];
	[hexDic setObject:@"1010" forKey:@"a"];
	[hexDic setObject:@"1011" forKey:@"b"];
	[hexDic setObject:@"1100" forKey:@"c"];
	[hexDic setObject:@"1101" forKey:@"d"];
	[hexDic setObject:@"1110" forKey:@"e"];
	[hexDic setObject:@"1111" forKey:@"f"];
	
	NSMutableString *binaryStr = [[NSMutableString alloc] init];
	for (int i = 0; i < hexStr.length; i ++) {
		NSRange rage;
		rage.length = 1;
		rage.location = i;
		NSString *key = [hexStr substringWithRange:rage];
		[binaryStr appendString:hexDic[key]];
	}
	return binaryStr;
}

/** 二进制转十六进制 */
+ (NSString *)convertBinaryToHex:(NSString *)binaryStr {
	NSMutableDictionary *hexDic = [[NSMutableDictionary alloc] init];
	hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
	[hexDic setObject:@"0000" forKey:@"0"];
	[hexDic setObject:@"0001" forKey:@"1"];
	[hexDic setObject:@"0010" forKey:@"2"];
	[hexDic setObject:@"0011" forKey:@"3"];
	[hexDic setObject:@"0100" forKey:@"4"];
	[hexDic setObject:@"0101" forKey:@"5"];
	[hexDic setObject:@"0110" forKey:@"6"];
	[hexDic setObject:@"0111" forKey:@"7"];
	[hexDic setObject:@"1000" forKey:@"8"];
	[hexDic setObject:@"1001" forKey:@"9"];
	[hexDic setObject:@"1010" forKey:@"a"];
	[hexDic setObject:@"1011" forKey:@"b"];
	[hexDic setObject:@"1100" forKey:@"c"];
	[hexDic setObject:@"1101" forKey:@"d"];
	[hexDic setObject:@"1110" forKey:@"e"];
	[hexDic setObject:@"1111" forKey:@"f"];
	
	NSMutableString *hexStr = [[NSMutableString alloc] init];
	for (int i = 0; i < binaryStr.length; i += 4) {
		NSString *subStr = [binaryStr substringWithRange:NSMakeRange(i, 4)];
		int index = 0;
		for (NSString *str in hexDic.allValues) {
			index ++;
			if ([subStr isEqualToString:str]) {
				[hexStr appendString:hexDic.allKeys[index - 1]];
				break;
			}
		}
	}
	return hexStr;
}

/** 二进制转十进制 */
+ (NSString *)convertBinaryToDecimal:(NSString *)binaryStr {
	int ll = 0 ;
	int temp = 0 ;
	for (int i = 0; i < binaryStr.length; i ++) {
		temp = [[binaryStr substringWithRange:NSMakeRange(i, 1)] intValue];
		temp = temp * powf(2, binaryStr.length - i - 1);
		ll += temp;
	}
	
	NSString * result = [NSString stringWithFormat:@"%d",ll];
	return result;
}

#pragma mark - CRC16
/* Table of CRC values for high-order byte */
static const unsigned char array_crc_low[] = {
 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0,
 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
 0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0,
 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40,
 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1,
 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41,
 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1,
 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0,
 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40,
 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1,
 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40,
 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0,
 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40,
 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0,
 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40,
 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0,
 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
 0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0,
 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0,
 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40,
 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1,
 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0,
 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40
};

/* Table of CRC values for low-order byte */
static const unsigned char array_crc_high[] = {
 0x00, 0xC0, 0xC1, 0x01, 0xC3, 0x03, 0x02, 0xC2, 0xC6, 0x06,
 0x07, 0xC7, 0x05, 0xC5, 0xC4, 0x04, 0xCC, 0x0C, 0x0D, 0xCD,
 0x0F, 0xCF, 0xCE, 0x0E, 0x0A, 0xCA, 0xCB, 0x0B, 0xC9, 0x09,
 0x08, 0xC8, 0xD8, 0x18, 0x19, 0xD9, 0x1B, 0xDB, 0xDA, 0x1A,
 0x1E, 0xDE, 0xDF, 0x1F, 0xDD, 0x1D, 0x1C, 0xDC, 0x14, 0xD4,
 0xD5, 0x15, 0xD7, 0x17, 0x16, 0xD6, 0xD2, 0x12, 0x13, 0xD3,
 0x11, 0xD1, 0xD0, 0x10, 0xF0, 0x30, 0x31, 0xF1, 0x33, 0xF3,
 0xF2, 0x32, 0x36, 0xF6, 0xF7, 0x37, 0xF5, 0x35, 0x34, 0xF4,
 0x3C, 0xFC, 0xFD, 0x3D, 0xFF, 0x3F, 0x3E, 0xFE, 0xFA, 0x3A,
 0x3B, 0xFB, 0x39, 0xF9, 0xF8, 0x38, 0x28, 0xE8, 0xE9, 0x29,
 0xEB, 0x2B, 0x2A, 0xEA, 0xEE, 0x2E, 0x2F, 0xEF, 0x2D, 0xED,
 0xEC, 0x2C, 0xE4, 0x24, 0x25, 0xE5, 0x27, 0xE7, 0xE6, 0x26,
 0x22, 0xE2, 0xE3, 0x23, 0xE1, 0x21, 0x20, 0xE0, 0xA0, 0x60,
 0x61, 0xA1, 0x63, 0xA3, 0xA2, 0x62, 0x66, 0xA6, 0xA7, 0x67,
 0xA5, 0x65, 0x64, 0xA4, 0x6C, 0xAC, 0xAD, 0x6D, 0xAF, 0x6F,
 0x6E, 0xAE, 0xAA, 0x6A, 0x6B, 0xAB, 0x69, 0xA9, 0xA8, 0x68,
 0x78, 0xB8, 0xB9, 0x79, 0xBB, 0x7B, 0x7A, 0xBA, 0xBE, 0x7E,
 0x7F, 0xBF, 0x7D, 0xBD, 0xBC, 0x7C, 0xB4, 0x74, 0x75, 0xB5,
 0x77, 0xB7, 0xB6, 0x76, 0x72, 0xB2, 0xB3, 0x73, 0xB1, 0x71,
 0x70, 0xB0, 0x50, 0x90, 0x91, 0x51, 0x93, 0x53, 0x52, 0x92,
 0x96, 0x56, 0x57, 0x97, 0x55, 0x95, 0x94, 0x54, 0x9C, 0x5C,
 0x5D, 0x9D, 0x5F, 0x9F, 0x9E, 0x5E, 0x5A, 0x9A, 0x9B, 0x5B,
 0x99, 0x59, 0x58, 0x98, 0x88, 0x48, 0x49, 0x89, 0x4B, 0x8B,
 0x8A, 0x4A, 0x4E, 0x8E, 0x8F, 0x4F, 0x8D, 0x4D, 0x4C, 0x8C,
 0x44, 0x84, 0x85, 0x45, 0x87, 0x47, 0x46, 0x86, 0x82, 0x42,
 0x43, 0x83, 0x41, 0x81, 0x80, 0x40
};

/******************************************************************************
 ** 函数名称: CaculateLRC
 ** 功能描述: 计算MODBUS帧的CRC校验码
 ** 输　入:   pbuf   缓冲地址
 len    缓冲长度
 ** 输　出:   无
 ** 返回值:   RTU格式帧的CRC校验码
 *******************************************************************************/
uint16_t CalculateCRC(const uint8_t *pbuf, int len) {
	uint8_t  crc_high, crc_low;
	uint32_t index;
	
	crc_high = crc_low = 0xff;
	while(len -- > 0) {
		index = crc_low ^ *pbuf++;
		crc_low  = crc_high ^ array_crc_low[index];
		crc_high = array_crc_high[index];
	}
	return (crc_low + (crc_high << 8));
}

#pragma mark - 计算 Modbus
+ (NSString *)calculateModbusRTUStringWithDeviceAddress:(NSString *)deviceAddress
										   functionCode:(kModbusFunctionCode)functionCode
										functionAddress:(NSInteger)functionAddress
										  registerCount:(NSInteger)registerCount
												   data:(NSNumber *)data {
	NSString *commandHexStr = [CZModbus calculateMultiRegistersModbusRTUStringWithDeviceAddress:deviceAddress functionCode:functionCode functionAddress:functionAddress registerCount:registerCount byteCount:0 data:[NSArray arrayWithObjects:data, nil]];
	return commandHexStr;
}

+ (NSData *)calculateModbusRTUBytesWithDeviceAddress:(NSString *)deviceAddress
										functionCode:(kModbusFunctionCode)functionCode
									 functionAddress:(NSInteger)functionAddress
									   registerCount:(NSInteger)registerCount
												data:(NSNumber *)data {
	NSString *commandHexStr = [CZModbus calculateModbusRTUStringWithDeviceAddress:deviceAddress functionCode:functionCode functionAddress:functionAddress registerCount:registerCount data:data];
	NSData *commandBytes = [CZModbus convertHexToDataBytes:commandHexStr];
	return commandBytes;
}

+ (NSString *)calculateMultiRegistersModbusRTUStringWithDeviceAddress:(NSString *)deviceAddress
														 functionCode:(kModbusFunctionCode)functionCode
													  functionAddress:(NSInteger)functionAddress
														registerCount:(NSInteger)registerCount
															byteCount:(NSInteger)byteCount
																 data:(NSArray<NSNumber *> *)data {
	// 计算起始地址的十六进制
	NSString *functionAddressHex = [CZModbus convertDecimalToHex:functionAddress];
	// 补齐起始地址的十六进制位数到4位，前面补0
	NSUInteger functionAddressHexNeedZeroCount = 4 - functionAddressHex.length;	// 还需要补齐的0的个数
	for (NSUInteger i = 0; i < functionAddressHexNeedZeroCount; i ++) {
		functionAddressHex = [NSString stringWithFormat:@"0%@", functionAddressHex];
	}
	
	// 计算寄存器数量的十六进制
	NSString *registerCountHex;
	if (registerCount > 0) {	// 寄存器数量大于0
		registerCountHex = [CZModbus convertDecimalToHex:registerCount];
		// 补齐寄存器数量的十六进制位数到4位，前面补0
		NSUInteger registerCountHexNeedZeroCount = 4 - registerCountHex.length;	// 还需要补齐的0的个数
		for (NSUInteger i = 0; i < registerCountHexNeedZeroCount; i ++) {
			registerCountHex = [NSString stringWithFormat:@"0%@", registerCountHex];
		}
	} else {
		registerCountHex = @"";
	}
	
	// 计算字节数的十六进制
	NSString *byteCountHex;
	if (byteCount > 0) {	// 字节数大于0
		byteCountHex = [CZModbus convertDecimalToHex:byteCount];
		// 补齐寄存器数量的十六进制位数到4位，前面补0
		NSUInteger byteCountHexNeedZeroCount = 2 - byteCountHex.length;	// 还需要补齐的0的个数
		for (NSUInteger i = 0; i < byteCountHexNeedZeroCount; i ++) {
			byteCountHex = [NSString stringWithFormat:@"0%@", byteCountHex];
		}
	} else {
		byteCountHex = @"";
	}
	
	// 计算数据的十六进制
	NSString *dataHex = @"";
	if (data.count > 0) {
		for (NSUInteger i = 0; i < data.count; i ++) {
			NSString *singleDataHex = [CZModbus convertDecimalToHex:[data[i] longLongValue]];
			// 补齐数据的十六进制位数到4位，前面补0
			NSUInteger dataHexNeedZeroCount = 4 - singleDataHex.length;	// 还需要补齐的0的个数
			for (NSUInteger i = 0; i < dataHexNeedZeroCount; i ++) {
				singleDataHex = [NSString stringWithFormat:@"0%@", singleDataHex];
			}
			dataHex = [NSString stringWithFormat:@"%@%@", dataHex, singleDataHex];;
		}
	} else {
		dataHex = @"";
	}
	
	NSString *hexStr = [NSString stringWithFormat:@"%@%@%@%@%@%@", deviceAddress, functionCode, functionAddressHex, registerCountHex, byteCountHex, dataHex];
	uint8_t *hexArray = [CZModbus convertHexToInt8Array:hexStr];
	uint16_t crc16 = CalculateCRC(hexArray, (int)hexStr.length / 2);
	NSString *crc16Str = [NSString stringWithFormat:@"%x", crc16];	// 原始 CRC16
	// 补齐 CRC16 数据的十六进制位数到4位，前面补0
	NSUInteger crc16StrNeedZeroCount = 4 - crc16Str.length;	// CRC16 还需要补齐的0的个数
	for (NSUInteger i = 0; i < crc16StrNeedZeroCount; i ++) {
		crc16Str = [NSString stringWithFormat:@"0%@", crc16Str];
	}
	NSString *exchangeCRC16Str = [NSString stringWithFormat:@"%@%@", [crc16Str substringFromIndex:2], [crc16Str substringToIndex:2]];	// 高低位互换的 CRC16
	NSString *commandHexStr = [hexStr stringByAppendingString:exchangeCRC16Str];
	NSLog(@"Modbus:%@", commandHexStr);
	return commandHexStr;
}

+ (NSData *)calculateMultiRegistersModbusRTUBytesWithDeviceAddress:(NSString *)deviceAddress
													  functionCode:(kModbusFunctionCode)functionCode
												   functionAddress:(NSInteger)functionAddress
													 registerCount:(NSInteger)registerCount
														 byteCount:(NSInteger)byteCount
															  data:(NSArray<NSNumber *> *)data {
	NSString *commandHexStr = [CZModbus calculateMultiRegistersModbusRTUStringWithDeviceAddress:deviceAddress functionCode:functionCode functionAddress:functionAddress registerCount:registerCount byteCount:byteCount data:data];
	NSData *commandBytes = [CZModbus convertHexToDataBytes:commandHexStr];
	return commandBytes;
}

#pragma mark - 解析返回数据
+ (NSArray<NSString *> *)calculateReadResponseModbusDataHexList:(NSString *)responseModbus {
	if ([CZModbus isResponseModbusError:responseModbus] == NO) {
		NSString *dataHex = [responseModbus substringWithRange:NSMakeRange(6, responseModbus.length - 6 - 4)];
		NSMutableArray *dataHexMA = [NSMutableArray array];
		for (int i = 0; i < dataHex.length; i += 4) {
			NSUInteger length;
			if ([dataHex substringFromIndex:i].length >= 4) {
				length = 4;
			} else {
				length = 2;
			}
			NSString *singleDataHex = [dataHex substringWithRange:NSMakeRange(i, length)];
			[dataHexMA addObject:singleDataHex];
		}
		return dataHexMA;
	}
	return nil;
}

+ (NSArray<NSString *> *)calculateReadResponseModbusDataDecimalList:(NSString *)responseModbus {
	if ([CZModbus isResponseModbusError:responseModbus] == NO) {
		NSArray *dataHexList = [CZModbus calculateReadResponseModbusDataHexList:responseModbus];
		NSMutableArray *dataDecimalStrMA = [NSMutableArray array];
		for (NSString *dataHex in dataHexList) {
			unsigned long long dataDecimal = [CZModbus convertHexToDecimal:dataHex];
			NSString *dataDecimalStr = [NSString stringWithFormat:@"%llu", dataDecimal];
			[dataDecimalStrMA addObject:dataDecimalStr];
		}
		return dataDecimalStrMA;
	}
	return nil;
}

+ (NSArray<NSString *> *)calculateReadResponseModbusDataBinaryList:(NSString *)responseModbus {
	if ([CZModbus isResponseModbusError:responseModbus] == NO) {
		NSArray *dataHexList = [CZModbus calculateReadResponseModbusDataHexList:responseModbus];
		NSMutableArray *dataDecimalStrMA = [NSMutableArray array];
		for (NSString *dataHex in dataHexList) {
			NSString *dataBinary = [CZModbus convertHexToBinary:dataHex];
			NSString *dataBinaryStr = [NSString stringWithFormat:@"%@", dataBinary];
			[dataDecimalStrMA addObject:dataBinaryStr];
		}
		return dataDecimalStrMA;
	}
	return nil;
}

+ (NSString *)calculateReadResponseModbusDataDoubleWord:(NSString *)responseModbus {
	if ([CZModbus isResponseModbusError:responseModbus] == NO) {
		NSArray *dataList = [CZModbus calculateReadResponseModbusDataHexList:responseModbus];
		NSString *dataHex = @"";
		for (NSString *singleHex in dataList) {
			dataHex = [dataHex stringByAppendingString:singleHex];
		}
		unsigned long long dataDecimal = [CZModbus convertHexToDecimal:dataHex];
		NSString *dataDecimalStr = [NSString stringWithFormat:@"%llu", dataDecimal];
		return dataDecimalStr;
	}
	return nil;
}

#pragma mark - 解析错误
+ (BOOL)isResponseModbusError:(NSString *)responseModbus {
	if ([responseModbus hasPrefix:[NSString stringWithFormat:@"%@8", kModbusAdditionalAddress]] || [responseModbus hasPrefix:[NSString stringWithFormat:@"%@9", kModbusAdditionalAddress]]) {
		return YES;
	}
	return NO;
}

+ (ModbusExceptionCodes)modbusExceptionCode:(NSString *)responseModbus {
	if ([CZModbus isResponseModbusError:responseModbus]) {
		NSString *exceptionCodeStr = [responseModbus substringWithRange:NSMakeRange(4, 2)];
		return [CZModbus convertHexStringToHexInt:exceptionCodeStr];
	}
	return 0x00;
}

+ (NSString *)modbusExceptionName:(NSString *)responseModbus {
	ModbusExceptionCodes exceptionCode = [CZModbus modbusExceptionCode:responseModbus];
	switch (exceptionCode) {
		case ModbusExceptionCodeIllegalFunction:
			return @"非法功能";
			break;
		case ModbusExceptionCodeIllegalDataAddress:
			return @"非法数据地址";
			break;
		case ModbusExceptionCodeIllegalDataValue:
			return @"非法数据值";
			break;
		case ModbusExceptionCodeSlaveDeviceFailure:
			return @"从站设备故障";
			break;
		case ModbusExceptionCodeAcknowledge:
			return @"确认";
			break;
		case ModbusExceptionCodeSlaveDeviceBusy:
			return @"从属设备忙";
			break;
		case ModbusExceptionCodeMemoryParityError:
			return @"存储奇偶性差错";
			break;
		case ModbusExceptionCodeGatewayPathUnavailable:
			return @"不可用网关路径";
			break;
		case ModbusExceptionCodeGatewayTargetDeviceFailedToRespond:
			return @"网关目标设备响应失败";
			break;
		default:
			break;
	}
	return nil;
}

@end
