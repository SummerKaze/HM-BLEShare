import { abilityAccessCtrl, Context, Permissions } from '@kit.AbilityKit';

/**
 * @projectName: interview_tong
 * @fileName: Permission
 * @author: SummerKaze
 * @description: 拉取权限授权工具类
 * @date: 2025/4/12 10:14
 * @version: 1.0
 */
export class Permission {
  /*
   * @param permissions<Array<Permissions>>: 权限列表
   * @return boolean: 是否授权成功
   * @author SummerKaze
   * @description 首次请求权限方法
   * @date 2025/4/12 10:16
   */
  static async requestPermission(permissions: Array<Permissions>) {
    // 获取上下文对象
    const ctx = AppStorage.get<Context>('context') || getContext()
    if (ctx) {
      // 创建权限管理器
      const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager()
      // 向用户 首次 请求权限 -> 返回 PermissionRequestResult 类型
      const result = await atManager.requestPermissionsFromUser(ctx, permissions)
      // 0 表示授权 1 表示拒绝授权 2 表示请求无效
      return result.authResults.every(item => item === 0)
    }
    return false
  }

  /*
   * @param permissions<Array<Permissions>>: 权限列表
   * @return boolean: 是否授权成功
   * @author SummerKaze
   * @description 二次请求权限方法 -> 打开系统权限设置
   * @date 2025/4/12 10:16
   */
  static async openPermissionSetting(permissions: Array<Permissions>) {
    // 获取上下文对象
    const ctx = AppStorage.get<Context>('context') || getContext()
    if (ctx) {
      // 创建权限管理器
      const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager()
      // 向用户 二次 请求权限 拉起系统权限设置弹窗 -> 返回 GrantStatus 枚举类型
      const result = await atManager.requestPermissionOnSetting(ctx, permissions)
      return result.every(item => item === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
    }
    return false
  }
}
