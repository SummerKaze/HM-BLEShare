# BleShare - 蓝牙文件分享应用

## 项目简介

BleShare 是一个基于 OpenHarmony 开发的蓝牙文件分享应用，采用现代化的 Navigation 导航架构，提供客户端和服务端两种工作模式，实现设备间的无缝文件传输。

## 功能特性

### 🔄 双模式支持
- **客户端模式**: 扫描并连接到附近的蓝牙设备
- **服务端模式**: 作为服务端等待其他设备连接

### 📱 用户体验
- 现代化的 UI 设计，符合 OpenHarmony 设计规范
- 流畅的页面导航和交互体验
- 实时的连接状态和传输进度显示

### 🛠 技术特性
- 基于 Navigation 组件的页面路由管理
- 响应式状态管理和数据绑定
- 模块化的代码架构设计

## 技术架构

### Navigation 导航架构

本项目基于 OpenHarmony 的 Navigation 组件实现页面导航，具有以下特点：

#### 1. 路由管理
```typescript
// 路由常量定义
export class RouteConstants {
  static readonly CLIENT_PAGE = 'clientPage'
  static readonly SERVER_PAGE = 'servePage'
}

// 统一的导航工具类
export class NavigationUtils {
  static navigateTo(navPathStack: NavPathStack, routeName: string): void
  static goBack(navPathStack: NavPathStack): void
}
```

#### 2. 页面组件结构
```
pages/
├── Index.ets          # 主入口页面，Navigation容器
├── clientComp.ets     # 客户端页面组件
└── serveComp.ets      # 服务端页面组件
```

#### 3. 导航流程
1. **主页面 (Index)**: 使用 `Navigation` 组件作为根容器
2. **路由注册**: 通过 `pageBuilder` 方法注册页面路由映射
3. **页面导航**: 使用 `NavPathStack` 管理页面栈
4. **页面组件**: 各子页面使用 `NavDestination` 包装

### 状态管理

#### Provider/Consumer 模式
```typescript
// 主页面提供导航栈
@Provider()
navPathStack: NavPathStack = new NavPathStack()

// 子页面消费导航栈
@Consumer()
navPathStack: NavPathStack = new NavPathStack()
```

#### 响应式状态
- `@State`: 管理组件内部状态
- `@ComponentV2`: 使用新版本的组件装饰器

## 项目结构

```
BleShare/
├── entry/src/main/
│   ├── ets/
│   │   ├── common/
│   │   │   └── RouteConstants.ets    # 路由常量和工具
│   │   ├── pages/
│   │   │   ├── Index.ets             # 主页面
│   │   │   ├── clientComp.ets        # 客户端页面
│   │   │   └── serveComp.ets         # 服务端页面
│   │   ├── entryability/
│   │   └── entrybackupability/
│   └── resources/
│       ├── base/
│       │   ├── element/
│       │   │   └── color.json        # 颜色资源
│       │   ├── media/                # 图片资源
│       │   └── profile/
│       │       └── main_pages.json   # 页面路由配置
│       └── rawfile/
├── AppScope/
├── build-profile.json5
├── oh-package.json5
└── README.md
```

## Navigation 实现详解

### 1. 主页面导航容器

```typescript
@Entry
@ComponentV2
struct Index {
  @Provider()
  navPathStack: NavPathStack = new NavPathStack()

  // 页面路由构建器
  @Builder
  private pageBuilder(name: string) {
    if (name === RouteConstants.CLIENT_PAGE) {
      clientCompBuilder()
    } else if (name === RouteConstants.SERVER_PAGE) {
      serveCompBuilder()
    }
  }

  build() {
    Navigation(this.navPathStack) {
      // 主页面内容
    }
    .navDestination(this.pageBuilder)  // 注册路由
  }
}
```

### 2. 子页面导航目标

```typescript
@ComponentV2
struct clientComp {
  @Consumer()
  navPathStack: NavPathStack = new NavPathStack()

  build() {
    NavDestination() {
      // 页面内容
    }
    .title('页面标题')
    .onBackPressed(() => {
      NavigationUtils.goBack(this.navPathStack)
      return true
    })
  }
}
```

### 3. 页面间导航

```typescript
// 前进导航
NavigationUtils.navigateTo(this.navPathStack, RouteConstants.CLIENT_PAGE)

// 返回导航
NavigationUtils.goBack(this.navPathStack)
```

## 开发环境

- **开发工具**: DevEco Studio
- **框架版本**: OpenHarmony API 12+
- **开发语言**: ArkTS (TypeScript)
- **UI框架**: ArkUI

## 构建和运行

1. 使用 DevEco Studio 打开项目
2. 配置签名和证书
3. 连接 OpenHarmony 设备或启动模拟器
4. 点击运行按钮进行构建和安装

## 特性说明

### 🎨 UI 设计特点
- 采用现代化的卡片式设计
- 使用系统主题色彩搭配
- 响应式布局适配不同屏幕尺寸
- 流畅的动画和过渡效果

### 🔧 代码质量
- 完整的函数级注释
- TypeScript 类型安全
- 模块化的代码组织
- 统一的代码风格

### 📋 开发规范
- 遵循 OpenHarmony 开发规范
- 使用最新的 @ComponentV2 装饰器
- Provider/Consumer 状态共享模式
- 规范的文件命名和项目结构

## 扩展计划

- [ ] 添加文件选择和传输功能
- [ ] 实现蓝牙权限管理
- [ ] 添加传输进度和状态监控
- [ ] 支持多设备同时连接
- [ ] 添加传输历史记录功能

## 贡献指南

欢迎提交 Issue 和 Pull Request 来改进项目。请确保：

1. 遵循现有的代码风格
2. 添加适当的注释和文档
3. 进行充分的测试

## 许可证

本项目采用 MIT 许可证，详情请参阅 [LICENSE](LICENSE) 文件。

---

*基于 OpenHarmony Navigation 架构构建的现代化蓝牙文件分享应用* 