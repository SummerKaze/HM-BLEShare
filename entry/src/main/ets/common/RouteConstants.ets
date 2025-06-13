/**
 * @projectName: BleShare
 * @fileName: RouteConstants
 * @author: SummerKaze
 * @description: 路由常量定义，统一管理应用中的所有路由名称
 * @date: 6/13/2025 8:00 PM
 * @version: 1.0
 */

/**
 * 路由常量类
 * 定义应用中所有页面的路由名称常量
 */
export class RouteConstants {
  /**
   * 客户端页面路由
   */
  static readonly CLIENT_PAGE = 'clientPage'

  /**
   * 服务端页面路由
   */
  static readonly SERVER_PAGE = 'servePage'
}

/**
 * 导航工具类
 * 提供统一的页面导航方法
 */
export class NavigationUtils {
  /**
   * 导航到指定页面
   * @param navPathStack 导航路由栈
   * @param routeName 路由名称
   */
  static navigateTo(navPathStack: NavPathStack, routeName: string): void {
    navPathStack.pushPath({ name: routeName })
  }

  /**
   * 返回上一页
   * @param navPathStack 导航路由栈
   */
  static goBack(navPathStack: NavPathStack): void {
    navPathStack.pop()
  }
}