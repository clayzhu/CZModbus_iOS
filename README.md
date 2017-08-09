# CZModbus_iOS
封装 Modbus 串行通信协议和 iOS 通信的主要方法，包括计算、解析 Modbus，另外提供进制转换等工具方法。

## 介绍

接触过 `PLC（可编程逻辑控制器）` 相关设备的开发，就需要学习一种 `串行通信协议 - Modbus`。

> Modbus 是 Modicon 公司于 1979 年为使用可编程逻辑控制器（PLC）通信而发表。Modbus 是工业领域通信协议的业界标准（De facto），并且现在是工业电子设备之间相当常用的连接方式。
> —— [维基百科](https://zh.wikipedia.org/wiki/Modbus)

使用 Modbus 和设备进行通信，需要频繁地使用进制转换、计算 CRC16 校验码等，并需要解析返回的 Modbus。对这些方法进行封装，将极大地提高对 Modbus 的使用效率，避免大量的重复计算的代码。

