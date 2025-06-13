/**
 * @projectName: BleShare
 * @fileName: serveComp
 * @author: SummerKaze
 * @description: 蓝牙服务端页面组件，提供蓝牙服务和文件共享功能
 * @date: 6/13/2025 7:55 PM
 * @version: 1.0
 */

import { NavigationUtils } from '../common/RouteConstants'

/**
 * 服务端页面组件构建器
 * @returns 服务端页面组件
 */
@Builder
export function serveCompBuilder() {
  serveComp()
}

/**
 * 连接的客户端信息接口
 */
interface ConnectedClient {
  name: string
  address: string
  connectTime: string
  transferProgress: number
}

/**
 * 文件传输记录接口
 */
interface FileTransferRecord {
  fileName: string
  fileSize: string
  clientName: string
  status: 'completed' | 'failed' | 'in_progress'
  timestamp: string
}

/**
 * 服务端页面组件
 * 提供蓝牙服务端功能，等待客户端连接和文件传输
 */
@ComponentV2
export struct serveComp {
  /**
   * 获取导航路由栈
   */
  @Consumer()
  navPathStack: NavPathStack = new NavPathStack()

  /**
   * 服务状态
   */
  @Local isServerRunning: boolean = false

  /**
   * 可发现状态
   */
  @Local isDiscoverable: boolean = false

  /**
   * 连接的客户端列表
   */
  @Local connectedClients: ConnectedClient[] = []

  /**
   * 传输记录列表
   */
  @Local transferRecords: FileTransferRecord[] = []

  /**
   * 服务状态描述
   */
  @Local serverStatus: string = '服务未启动'

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
    this.serverStatus = '准备就绪'
    // 模拟一些传输记录用于演示
    this.transferRecords = [
      {
        fileName: 'document.pdf',
        fileSize: '2.3 MB',
        clientName: 'iPhone 15',
        status: 'completed',
        timestamp: '2025-06-13 19:30'
      },
      {
        fileName: 'photo.jpg',
        fileSize: '1.8 MB',
        clientName: 'Samsung Galaxy',
        status: 'completed',
        timestamp: '2025-06-13 19:25'
      }
    ]
  }

  /**
   * 启动蓝牙服务
   */
  private startServer(): void {
    this.isServerRunning = true
    this.isDiscoverable = true
    this.serverStatus = '服务已启动，等待客户端连接...'
  }

  /**
   * 停止蓝牙服务
   */
  private stopServer(): void {
    this.isServerRunning = false
    this.isDiscoverable = false
    this.connectedClients = []
    this.serverStatus = '服务已停止'
  }

  /**
   * 返回主页面
   */
  private goBack(): void {
    NavigationUtils.goBack(this.navPathStack)
  }

  build() {
    NavDestination() {
      Column({ space: 16 }) {
        // 状态区域
        Column({ space: 12 }) {
          Text('蓝牙服务端')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.title_color'))

          // 服务状态
          Row({ space: 8 }) {
            Circle({ width: 8, height: 8 })
              .fill(this.isServerRunning ? $r('app.color.success_color') : $r('app.color.error_color'))
            
            Text(this.serverStatus)
              .fontSize(14)
              .fontColor($r('app.color.subtitle_color'))
          }
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor($r('app.color.status_background'))
          .borderRadius(16)
        }
        .margin({ top: 20 })

        // 控制区域
        Row({ space: 12 }) {
          Button(this.isServerRunning ? '停止服务' : '启动服务')
            .type(ButtonType.Capsule)
            .layoutWeight(1)
            .height(44)
            .fontSize(16)
            .backgroundColor(this.isServerRunning ? $r('app.color.error_color') : $r('app.color.primary_color'))
            .onClick(() => this.isServerRunning ? this.stopServer() : this.startServer())

          Button('设置')
            .type(ButtonType.Capsule)
            .width(80)
            .height(44)
            .fontSize(14)
            .backgroundColor($r('app.color.secondary_color'))
        }
        .width('100%')
        .padding({ left: 16, right: 16 })

        // 信息展示区域
        Column({ space: 20 }) {
          if (this.isServerRunning) {
            Text('服务正在运行中...')
              .fontSize(16)
              .fontColor($r('app.color.success_color'))
              .textAlign(TextAlign.Center)
          } else {
            Text('点击启动服务开始接收文件')
              .fontSize(16)
              .fontColor($r('app.color.text_secondary'))
              .textAlign(TextAlign.Center)
          }

          // 传输记录
          if (this.transferRecords.length > 0) {
            Column({ space: 8 }) {
              Text('最近传输记录')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.title_color'))
                .alignSelf(ItemAlign.Start)

              List({ space: 8 }) {
                ForEach(this.transferRecords, (record: FileTransferRecord) => {
                  ListItem() {
                    Row({ space: 12 }) {
                      Image($r('sys.media.wifi_router_fill'))
                        .width(32)
                        .height(32)
                        .fillColor($r('app.color.primary_color'))

                      Column({ space: 2 }) {
                        Text(record.fileName)
                          .fontSize(14)
                          .fontColor($r('app.color.text_primary'))

                        Text(`${record.fileSize} • ${record.clientName}`)
                          .fontSize(12)
                          .fontColor($r('app.color.text_secondary'))
                      }
                      .alignItems(HorizontalAlign.Start)
                      .layoutWeight(1)

                      Text(record.status === 'completed' ? '成功' : '失败')
                        .fontSize(12)
                        .fontColor(record.status === 'completed' ? $r('app.color.success_color') : $r('app.color.error_color'))
                    }
                    .width('100%')
                    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                    .backgroundColor($r('app.color.card_background'))
                    .borderRadius(8)
                  }
                })
              }
              .height(200)
              .scrollBar(BarState.Auto)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
        }
        .layoutWeight(1)
        .width('100%')
        .padding({ left: 16, right: 16 })
        .justifyContent(FlexAlign.Center)

        // 底部信息
        Text('提示: 确保设备蓝牙已开启，并保持应用在前台运行')
          .fontSize(12)
          .fontColor($r('app.color.hint_color'))
          .opacity(0.6)
          .textAlign(TextAlign.Center)
          .padding({ left: 20, right: 20, top: 12, bottom: 16 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.background_color'))
    }
    .title('蓝牙服务端')
    .onBackPressed(() => {
      this.goBack()
      return true
    })
  }
}