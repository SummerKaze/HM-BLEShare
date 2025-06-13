/**
 * @projectName: BleShare
 * @fileName: clientComp
 * @author: SummerKaze
 * @description: 蓝牙客户端页面组件，负责扫描和连接蓝牙设备
 * @date: 6/13/2025 7:54 PM
 * @version: 1.0
 */

import { NavigationUtils } from '../common/RouteConstants'

/**
 * 客户端页面组件构建器
 * @returns 客户端页面组件
 */
@Builder
export function clientCompBuilder() {
  clientComp()
}

/**
 * 蓝牙设备信息接口
 */
interface BluetoothDevice {
  name: string
  address: string
  rssi: number
  isConnected: boolean
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
   * 页面初始化
   */
  aboutToAppear(): void {
    this.initializePage()
  }

  /**
   * 初始化页面数据
   */
  private initializePage(): void {
    this.connectionStatus = '准备就绪'
    // 模拟一些设备数据用于演示
    this.deviceList = [
      { name: 'iPhone 15', address: '00:1A:2B:3C:4D:5E', rssi: -45, isConnected: false },
      { name: 'Samsung Galaxy', address: '00:1A:2B:3C:4D:5F', rssi: -60, isConnected: false },
      { name: 'Xiaomi Phone', address: '00:1A:2B:3C:4D:60', rssi: -75, isConnected: false }
    ]
  }

  /**
   * 开始扫描蓝牙设备
   */
  private startScan(): void {
    this.isScanning = true
    this.connectionStatus = '正在扫描设备...'
    
    // 模拟扫描过程
    setTimeout(() => {
      this.isScanning = false
      this.connectionStatus = `发现 ${this.deviceList.length} 个设备`
    }, 3000)
  }

  /**
   * 停止扫描
   */
  private stopScan(): void {
    this.isScanning = false
    this.connectionStatus = '扫描已停止'
  }

  /**
   * 连接指定设备
   * @param device 要连接的设备
   */
  private connectDevice(device: BluetoothDevice): void {
    this.connectionStatus = `正在连接 ${device.name}...`
    
    // 模拟连接过程
    setTimeout(() => {
      device.isConnected = true
      this.connectionStatus = `已连接到 ${device.name}`
    }, 2000)
  }

  /**
   * 返回主页面
   */
  private goBack(): void {
    NavigationUtils.goBack(this.navPathStack)
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
      Image($r('sys.media.wifi_router_fill'))
        .width(40)
        .height(40)
        .fillColor(device.isConnected ? $r('app.color.success_color') : $r('app.color.primary_color'))

      Column({ space: 4 }) {
        // 设备名称
        Text(device.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        // 设备地址
        Text(device.address)
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .opacity(0.7)

        // 信号强度
        Text(`信号强度: ${device.rssi} dBm`)
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .opacity(0.7)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 连接按钮
      Button(device.isConnected ? '已连接' : '连接')
        .type(ButtonType.Capsule)
        .width(80)
        .height(36)
        .fontSize(14)
        .backgroundColor(device.isConnected ? $r('app.color.success_color') : $r('app.color.primary_color'))
        .enabled(!device.isConnected)
        .onClick(() => this.connectDevice(device))
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
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
             .padding({ left: 12, right: 12, top: 6, bottom: 6 })
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
            .onClick(() => this.initializePage())
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
          ForEach(this.deviceList, (device: BluetoothDevice, index: number) => {
            ListItem() {
              this.deviceItemBuilder(device, index)
            }
          })
        }
                 .layoutWeight(1)
         .padding({ left: 16, right: 16 })
         .scrollBar(BarState.Auto)

        // 底部信息
        Text('提示: 请确保目标设备已开启蓝牙并处于可发现状态')
          .fontSize(12)
          .fontColor($r('app.color.hint_color'))
          .opacity(0.6)
                     .textAlign(TextAlign.Center)
           .padding({ left: 20, right: 20, top: 16, bottom: 16 })
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