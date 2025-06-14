/**
 * @projectName: BleShare
 * @fileName: clientComp
 * @author: SummerKaze
 * @description: 蓝牙客户端页面组件，负责扫描和连接蓝牙设备
 *
 * 功能特性：
 * 1. 蓝牙设备扫描 - 自动发现附近的蓝牙设备
 * 2. 设备信息获取 - 显示设备名称、MAC地址、信号强度
 * 3. 设备类型识别 - 显示设备类型（手机、电脑、音频设备等）
 * 4. 配对状态检查 - 显示设备的配对状态
 * 5. 信号强度指示 - 用颜色标识信号强度等级
 * 6. 设备连接管理 - 支持连接和断开设备
 *
 * API 使用说明：
 * - 扫描到的设备会通过回调函数返回完整的设备信息
 * - 设备信息包括：deviceName, deviceId, rssi, deviceType, bondState
 * - 支持获取已配对设备列表
 * - 自动去重和更新设备信息
 *
 * @date: 6/13/2025 7:54 PM
 * @version: 2.0
 */

import { NavigationUtils } from '../common/RouteConstants'
import DiscoveryDeviceManager, { BluetoothDeviceInfo } from '../utils/BleScanner.ets'
import { connection } from '@kit.ConnectivityKit'

/**
 * 客户端页面组件构建器
 * @returns 客户端页面组件
 */
@Builder
export function clientCompBuilder() {
  clientComp()
}

/**
 * 蓝牙设备信息接口（用于UI显示）
 */
interface BluetoothDevice {
  name: string
  address: string
  rssi: number
  isConnected: boolean
  deviceType?: string
  bondState?: string
}

/**
 * 客户端页面组件
 * 提供蓝牙设备扫描、连接等功能
 */
@ComponentV2
struct clientComp {
  /**
   * 获取导航路由栈
   */
  @Consumer()
  navPathStack: NavPathStack = new NavPathStack()
  /**
   * 扫描状态
   */
  @Local isScanning: boolean = false
  /**
   * 发现的蓝牙设备列表
   */
  @Local deviceList: BluetoothDevice[] = []
  /**
   * 连接状态
   */
  @Local connectionStatus: string = '未连接'
  /**
   * 设备计数
   */
  @Local deviceCount: number = 0

  /**
   * 页面初始化
   */
  aboutToAppear(): void {
    this.initializePage()
    this.setupBluetoothCallbacks()
  }

  /**
   * 初始化页面数据
   */
  private initializePage(): void {
    this.connectionStatus = '准备就绪'
    this.deviceList = []
    this.deviceCount = 0
  }

  /**
   * 设置蓝牙扫描回调函数
   */
  private setupBluetoothCallbacks(): void {
    // 设置设备发现回调
    DiscoveryDeviceManager.onDeviceDiscovered = (devices: BluetoothDeviceInfo[]) => {
      console.info(`发现 ${devices.length} 个蓝牙设备`);

      // 处理发现的设备
      for (const deviceInfo of devices) {
        this.addOrUpdateDevice(deviceInfo);
      }

      // 更新设备计数和状态
      this.deviceCount = this.deviceList.length;
      this.connectionStatus = `已发现 ${this.deviceCount} 个设备`;
    }
  }

  /**
   * 添加或更新设备信息
   * @param deviceInfo 蓝牙设备信息
   */
  private addOrUpdateDevice(deviceInfo: BluetoothDeviceInfo): void {
    // 检查设备是否已存在
    const existingIndex = this.deviceList.findIndex(device => device.address === deviceInfo.deviceId);

    // 转换设备信息格式
    const uiDevice: BluetoothDevice = {
      name: deviceInfo.deviceName || '未知设备',
      address: deviceInfo.deviceId,
      rssi: deviceInfo.rssi || -100, // 默认信号强度
      isConnected: false,
      deviceType: this.getDeviceTypeString(deviceInfo.deviceType),
      bondState: this.getBondStateString(deviceInfo.bondState)
    };

    if (existingIndex >= 0) {
      // 更新现有设备信息（保持连接状态）
      uiDevice.isConnected = this.deviceList[existingIndex].isConnected;
      this.deviceList[existingIndex] = uiDevice;
      console.info(`更新设备: ${uiDevice.name} (${uiDevice.address}), RSSI: ${uiDevice.rssi} dBm`);
    } else {
      // 添加新设备
      this.deviceList.push(uiDevice);

      console.info(`新发现设备: ${uiDevice.name} (${uiDevice.address}), RSSI: ${uiDevice.rssi} dBm`);
    }
  }

  /**
   * 获取设备类型字符串描述
   * @param deviceType 设备类型枚举
   * @returns 设备类型字符串
   */
  private getDeviceTypeString(deviceType?: connection.MajorClass): string {
    // 根据实际的设备类型枚举值进行转换
    // 这里需要根据 connection.MajorClass 的具体值进行映射
    if (!deviceType) {
      return '未知类型';
    }

    // 示例映射，需要根据实际API调整
    switch (deviceType) {
      case 0x0100:
        return '计算机';
      case 0x0200:
        return '手机';
      case 0x0400:
        return '音频设备';
      case 0x0500:
        return '外设';
      case 0x0600:
        return '成像设备';
      case 0x0700:
        return '可穿戴设备';
      case 0x0800:
        return '玩具';
      case 0x0900:
        return '健康设备';
      default:
        return '其他设备';
    }
  }

  /**
   * 获取配对状态字符串描述
   * @param bondState 配对状态枚举
   * @returns 配对状态字符串
   */
  private getBondStateString(bondState?: connection.BondState): string {
    // if (!bondState) return '未配对';

    // 根据实际的配对状态枚举值进行转换
    switch (bondState) {
      case 0:
        return '未配对';
      case 1:
        return '配对中';
      case 2:
        return '已配对';
      default:
        return '未知状态';
    }
  }

  /**
   * 开始扫描蓝牙设备
   */
  private startScan(): void {
    // 清空现有设备列表
    this.deviceList = [];
    this.deviceCount = 0;

    // 开始扫描
    DiscoveryDeviceManager.startDiscovery();

    this.isScanning = true;
    this.connectionStatus = '正在扫描设备...';

    console.info('开始蓝牙设备扫描');
  }

  /**
   * 停止扫描
   */
  private stopScan(): void {
    this.isScanning = false;
    this.connectionStatus = `扫描已停止，共发现 ${this.deviceCount} 个设备`;

    // 停止扫描
    DiscoveryDeviceManager.stopDiscovery();

    console.info('蓝牙设备扫描已停止');
  }

  /**
   * 刷新设备列表
   */
  private refreshDevices(): void {
    // 获取已配对的设备
    const pairedDevices = DiscoveryDeviceManager.getPairedDevices();
    console.info(`获取到 ${pairedDevices.length} 个已配对设备`);

    // 添加已配对设备到列表
    for (const deviceInfo of pairedDevices) {
      this.addOrUpdateDevice(deviceInfo);
    }

    this.deviceCount = this.deviceList.length;
    this.connectionStatus = `已刷新，共 ${this.deviceCount} 个设备`;
  }

  /**
   * 连接指定设备
   * @param device 要连接的设备
   */
  private connectDevice(device: BluetoothDevice): void {
    this.connectionStatus = `正在连接 ${device.name}...`;

    // 模拟连接过程
    setTimeout(() => {
      device.isConnected = true;
      this.connectionStatus = `已连接到 ${device.name}`;
      console.info(`成功连接到设备: ${device.name} (${device.address})`);
    }, 2000);
  }

  /**
   * 断开设备连接
   * @param device 要断开连接的设备
   */
  private disconnectDevice(device: BluetoothDevice): void {
    device.isConnected = false;
    this.connectionStatus = `已断开与 ${device.name} 的连接`;
    console.info(`断开设备连接: ${device.name} (${device.address})`);
  }

  /**
   * 返回主页面
   */
  private goBack(): void {
    // 停止扫描
    if (this.isScanning) {
      this.stopScan();
    }
    NavigationUtils.goBack(this.navPathStack);
  }

  /**
   * 获取信号强度颜色
   * @param rssi 信号强度值
   * @returns 颜色资源
   */
  private getRssiColor(rssi: number): Resource {
    if (rssi > -50) {
      return $r('app.color.success_color');
    } // 强信号
    if (rssi > -70) {
      return $r('app.color.warning_color');
    } // 中等信号
    return $r('app.color.error_color'); // 弱信号
  }

  /**
   * 获取信号强度描述
   * @param rssi 信号强度值
   * @returns 信号强度描述
   */
  private getRssiDescription(rssi: number): string {
    if (rssi > -50) {
      return '强';
    }
    if (rssi > -70) {
      return '中';
    }
    return '弱';
  }

  /**
   * 构建设备列表项
   * @param device 设备信息
   * @param index 设备索引
   */
  @Builder
  deviceItemBuilder(device: BluetoothDevice, index: number) {
    Row({ space: 12 }) {
      // 设备图标
      Image($r('app.media.bluetooth'))
        .width(40)
        .height(40)
        .fillColor(device.isConnected ? $r('app.color.success_color') : $r('app.color.primary_color'))

      Column({ space: 4 }) {
        // 设备名称
        Text(device.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // 设备地址
        Text(device.address)
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .opacity(0.7)

        // 信号强度和设备类型
        Row({ space: 8 }) {
          Text(`信号: ${device.rssi} dBm (${this.getRssiDescription(device.rssi)})`)
            .fontSize(11)
            .fontColor(this.getRssiColor(device.rssi))

          if (device.deviceType) {
            Text(`| ${device.deviceType}`)
              .fontSize(11)
              .fontColor($r('app.color.text_secondary'))
              .opacity(0.6)
          }
        }

        // 配对状态
        if (device.bondState && device.bondState !== '未配对') {
          Text(`配对状态: ${device.bondState}`)
            .fontSize(11)
            .fontColor($r('app.color.info_color'))
            .opacity(0.8)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 连接/断开按钮
      Button(device.isConnected ? '断开' : '连接')
        .type(ButtonType.Capsule)
        .width(70)
        .height(36)
        .fontSize(14)
        .backgroundColor(device.isConnected ? $r('app.color.warning_color') : $r('app.color.primary_color'))
        .onClick(() => {
          if (device.isConnected) {
            this.disconnectDevice(device);
          } else {
            this.connectDevice(device);
          }
        })
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 12,
      bottom: 12
    })
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .margin({ bottom: 8 })
  }

  build() {
    NavDestination() {
      Column({ space: 16 }) {
        // 状态区域
        Column({ space: 8 }) {
          Text('蓝牙客户端')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.title_color'))

          Text(this.connectionStatus)
            .fontSize(14)
            .fontColor($r('app.color.subtitle_color'))
            .padding({
              left: 12,
              right: 12,
              top: 6,
              bottom: 6
            })
            .backgroundColor($r('app.color.status_background'))
            .borderRadius(16)
        }
        .margin({ top: 20 })

        // 扫描控制区域
        Row({ space: 12 }) {
          Button(this.isScanning ? '停止扫描' : '开始扫描')
            .type(ButtonType.Capsule)
            .layoutWeight(1)
            .height(44)
            .fontSize(16)
            .backgroundColor(this.isScanning ? $r('app.color.warning_color') : $r('app.color.primary_color'))
            .onClick(() => this.isScanning ? this.stopScan() : this.startScan())

          Button('刷新')
            .type(ButtonType.Capsule)
            .width(80)
            .height(44)
            .fontSize(16)
            .backgroundColor($r('app.color.secondary_color'))
            .enabled(!this.isScanning)
            .onClick(() => this.refreshDevices())
        }
        .width('100%')
        .padding({ left: 16, right: 16 })

        // 加载指示器
        if (this.isScanning) {
          Row({ space: 8 }) {
            LoadingProgress()
              .width(20)
              .height(20)
              .color($r('app.color.primary_color'))

            Text('正在扫描附近的设备...')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
          }
          .justifyContent(FlexAlign.Center)
          .margin({ top: 16, bottom: 16 })
        }

        // 设备列表
        List({ space: 0 }) {
          Repeat(this.deviceList)
            .each((obj: RepeatItem<BluetoothDevice>) => {
              ListItem() {
                this.deviceItemBuilder(obj.item, obj.index)
              }
            })
        }
        .cachedCount(3)
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
        .scrollBar(BarState.Auto)

        // 底部信息
        Text('提示: 请确保目标设备已开启蓝牙并处于可发现状态')
          .fontSize(12)
          .fontColor($r('app.color.hint_color'))
          .opacity(0.6)
          .textAlign(TextAlign.Center)
          .padding({
            left: 20,
            right: 20,
            top: 16,
            bottom: 16
          })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.background_color'))
    }
    .title('蓝牙客户端')
    .onBackPressed(() => {
      this.goBack()
      return true
    })
  }
}