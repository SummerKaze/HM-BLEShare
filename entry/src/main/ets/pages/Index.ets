/**
 * @projectName: BleShare
 * @fileName: Index
 * @author: SummerKaze
 * @description: 蓝牙分享应用主页面，基于 OpenHarmony Navigation 组件实现页面导航
 * @date: 6/13/2025 7:54 PM
 * @version: 1.0
 */

import { clientCompBuilder } from './clientComp'
import { serveCompBuilder } from './serveComp'
import { RouteConstants, NavigationUtils } from '../common/RouteConstants'
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl'
import promptAction from '@ohos.promptAction'
import router from '@ohos.router'
import { Permission } from '../utils/Permission.ets'

/**
 * 应用主入口页面
 * 使用 Navigation 组件管理页面路由栈
 */
@Entry
@ComponentV2
struct Index {
  /**
   * 导航路由栈，用于管理页面间的导航
   */
  @Provider()
  navPathStack: NavPathStack = new NavPathStack()
  // 权限列表 
  private permissionList: Array<Permissions> = [
    "ohos.permission.ACCESS_BLUETOOTH"
  ]
  // 弹窗配置
  confirmConfig: promptAction.ShowDialogOptions = {
    title: "温馨提示",
    message: "蓝牙权限未授予，请先申请权限",
    buttons: [
      { text: '离开', color: "#333" },
      { text: '去授权', color: "#6cf" }
    ]
  }

  aboutToAppear() {
    this.getPermission()
  }

  // 获取权限
  async getPermission() {
    try {
      // 第一请求授权
      const isOk = await Permission.requestPermission(this.permissionList)
      if (isOk) {
        return
      }
      // 未授权弹窗提示
      const confirm = await promptAction.showDialog(this.confirmConfig)
      if (confirm.index === 1) {
        // 第二次请求权限
        const isOk2 = await Permission.openPermissionSetting(this.permissionList)
        if (isOk2) {
          return
        }
      }
      router.back()
    } catch (e) {
      promptAction.showToast({ message: '未授权' })
      router.back()
    }
  }

  /**
   * 根据路由名称构建对应的页面组件
   * @param name 路由名称
   * @returns 对应的页面组件构建器
   */
  @Builder
  private pageBuilder(name: string) {
    if (name === RouteConstants.CLIENT_PAGE) {
      clientCompBuilder()
    } else if (name === RouteConstants.SERVER_PAGE) {
      serveCompBuilder()
    }
  }

  /**
   * 导航到客户端页面
   */
  private navigateToClient(): void {
    NavigationUtils.navigateTo(this.navPathStack, RouteConstants.CLIENT_PAGE)
  }

  /**
   * 导航到服务端页面
   */
  private navigateToServer(): void {
    NavigationUtils.navigateTo(this.navPathStack, RouteConstants.SERVER_PAGE)
  }

  build() {
    Navigation(this.navPathStack) {
      Column({ space: 40 }) {
        // 应用标题
        Text('BleShare')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.title_color'))
          .margin({ top: 60 })

        // 应用描述
        Text('蓝牙文件分享应用')
          .fontSize(16)
          .fontColor($r('app.color.subtitle_color'))
          .opacity(0.8)

        // 功能选择区域
        Column({ space: 20 }) {
          // 客户端按钮
          Button('作为客户端连接')
            .type(ButtonType.Capsule)
            .width('80%')
            .height(50)
            .fontSize(16)
            .backgroundColor($r('app.color.primary_color'))
            .onClick(() => this.navigateToClient())

          // 服务端按钮
          Button('作为服务端等待连接')
            .type(ButtonType.Capsule)
            .width('80%')
            .height(50)
            .fontSize(16)
            .backgroundColor($r('app.color.secondary_color'))
            .onClick(() => this.navigateToServer())
        }
        .margin({ top: 40 })

        Blank()

        // 底部信息
        Text('请选择连接模式开始使用')
          .fontSize(14)
          .fontColor($r('app.color.hint_color'))
          .opacity(0.6)
          .margin({ bottom: 40 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor($r('app.color.background_color'))
    }
    .title('BleShare')
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(true)
    .navDestination(this.pageBuilder)
    .width('100%')
    .height('100%')
  }
}