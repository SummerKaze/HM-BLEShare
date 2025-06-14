import { connection } from '@kit.ConnectivityKit';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 蓝牙设备信息接口
 */
export interface BluetoothDeviceInfo {
  /** 设备名称 */
  deviceName: string;
  /** 设备MAC地址 */
  deviceId: string;
  /** 信号强度 (dBm) */
  rssi?: number;
  /** 设备类型 */
  deviceType?: connection.MajorClass;
  /** 设备状态 */
  bondState?: connection.BondState;
}

/**
 * 蓝牙设备发现管理器
 * 负责蓝牙设备的扫描、发现和管理
 */
export class DiscoveryDeviceManager {
  /**
   * 设备发现回调函数
   * @param devices 发现的蓝牙设备列表
   */
  onDeviceDiscovered?: (devices: BluetoothDeviceInfo[]) => void;

  /**
   * 扫描结果处理函数
   * 处理原始扫描数据并转换为设备信息对象
   * @param data 扫描到的设备MAC地址数组
   */
  private onReceiveEvent = (data: Array<string>) => {
    console.info('bluetooth raw data: ' + JSON.stringify(data));
    
    if (data && data.length > 0) {
      const devices: BluetoothDeviceInfo[] = [];
      
      // 遍历每个发现的设备MAC地址
      for (const deviceId of data) {
        try {
          // 获取设备的详细信息
          const deviceInfo = this.getDeviceInfo(deviceId);
          devices.push(deviceInfo);
        } catch (error) {
          console.error(`获取设备 ${deviceId} 信息失败:`, error);
          // 即使获取详细信息失败，也添加基本信息
          devices.push({
            deviceName: '未知设备',
            deviceId: deviceId,
            rssi: undefined
          });
        }
      }
      
      // 调用设备发现回调
      if (this.onDeviceDiscovered) {
        this.onDeviceDiscovered(devices);
      }
    }
  };

  /**
   * 获取指定设备的详细信息
   * @param deviceId 设备MAC地址
   * @returns 设备信息对象
   */
  private getDeviceInfo(deviceId: string): BluetoothDeviceInfo {
    try {
      // 获取设备名称
      let deviceName = '未知设备';
      try {
        deviceName = connection.getRemoteDeviceName(deviceId) || '未知设备';
      } catch (nameError) {
        console.warn(`无法获取设备 ${deviceId} 的名称:`, nameError);
      }

      // 获取设备类型
      let deviceType: connection.MajorClass | undefined;
      try {
        deviceType = connection.getRemoteDeviceClass(deviceId)?.majorClass;
      } catch (typeError) {
        console.warn(`无法获取设备 ${deviceId} 的类型:`, typeError);
      }

      // 获取配对状态
      let bondState: connection.BondState | undefined;
      try {
        bondState = connection.getPairState(deviceId);
      } catch (bondError) {
        console.warn(`无法获取设备 ${deviceId} 的配对状态:`, bondError);
      }

      // 获取RSSI信号强度（注意：部分API版本可能不支持直接获取RSSI）
      let rssi: number | undefined;
      try {
        // 这里尝试获取RSSI，如果API不支持会捕获异常
        // 注意：某些HarmonyOS版本可能需要不同的API来获取RSSI
        // rssi = connection.getRemoteRssiValue(deviceId);
      } catch (rssiError) {
        console.warn(`无法获取设备 ${deviceId} 的RSSI:`, rssiError);
      }

      return {
        deviceName,
        deviceId,
        rssi,
        deviceType,
        bondState
      };
    } catch (error) {
      console.error(`处理设备 ${deviceId} 信息时发生错误:`, error);
      return {
        deviceName: '未知设备',
        deviceId: deviceId,
        rssi: undefined
      };
    }
  }

  /**
   * 开始蓝牙设备扫描
   */
  public startDiscovery(): void {
    try {
      // 注册设备发现事件监听
      connection.on('bluetoothDeviceFind', this.onReceiveEvent);
      console.info('蓝牙设备发现事件监听已注册');
    } catch (err) {
      console.error('注册蓝牙设备发现事件失败: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }

    try {
      // 检查是否正在扫描
      let isScanning = connection.isBluetoothDiscovering();
      if (!isScanning) {
        // 开始扫描设备
        connection.startBluetoothDiscovery();
        console.info('开始蓝牙设备扫描');
      } else {
        console.info('蓝牙设备扫描已在进行中');
      }
    } catch (err) {
      console.error('开始蓝牙扫描失败: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  /**
   * 停止蓝牙设备扫描
   */
  public stopDiscovery(): void {
    try {
      // 检查是否正在扫描
      let isScanning = connection.isBluetoothDiscovering();
      if (isScanning) {
        // 停止扫描设备
        connection.stopBluetoothDiscovery();
        console.info('蓝牙设备扫描已停止');
      }
      
      // 取消设备发现事件监听
      connection.off('bluetoothDeviceFind', this.onReceiveEvent);
      console.info('蓝牙设备发现事件监听已取消');
    } catch (err) {
      console.error('停止蓝牙扫描失败: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  /**
   * 设置蓝牙扫描模式
   */
  public setScanMode(): void {
    try {
      // 获取当前扫描模式
      let currentScanMode: connection.ScanMode = connection.getBluetoothScanMode();
      console.info('当前扫描模式: ' + currentScanMode);
      
      if (currentScanMode !== connection.ScanMode.SCAN_MODE_CONNECTABLE_GENERAL_DISCOVERABLE) {
        // 设置为可被发现和可被连接模式
        connection.setBluetoothScanMode(connection.ScanMode.SCAN_MODE_CONNECTABLE_GENERAL_DISCOVERABLE, 0);
        console.info('扫描模式已设置为可发现和可连接');
      }
    } catch (err) {
      console.error('设置扫描模式失败: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  /**
   * 获取已配对的设备列表
   * @returns 已配对设备的信息数组
   */
  public getPairedDevices(): BluetoothDeviceInfo[] {
    try {
      // 获取已配对设备列表
      let pairedDeviceIds = connection.getPairedDevices();
      console.info('已配对设备: ' + JSON.stringify(pairedDeviceIds));
      
      const pairedDevices: BluetoothDeviceInfo[] = [];
      
      // 获取每个已配对设备的详细信息
      for (const deviceId of pairedDeviceIds) {
        try {
          const deviceInfo = this.getDeviceInfo(deviceId);
          pairedDevices.push(deviceInfo);
          
          // 检查配对状态
          let pairState = connection.getPairState(deviceId);
          console.info(`设备 ${deviceId} 配对状态: ${pairState}`);
        } catch (error) {
          console.error(`获取已配对设备 ${deviceId} 信息失败:`, error);
        }
      }
      
      return pairedDevices;
    } catch (err) {
      console.error('获取已配对设备失败: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
      return [];
    }
  }

  /**
   * 获取指定设备的当前RSSI值
   * @param deviceId 设备MAC地址
   * @returns RSSI值，如果无法获取则返回undefined
   */
  public getDeviceRssi(deviceId: string): number | undefined {
    try {
      // 注意：这个方法可能在某些HarmonyOS版本中不可用
      // 需要根据实际API文档调整
      // return connection.getRemoteRssiValue(deviceId);
      console.warn('RSSI获取功能可能需要特定API版本支持');
      return undefined;
    } catch (error) {
      console.error(`获取设备 ${deviceId} RSSI失败:`, error);
      return undefined;
    }
  }
}

// 创建单例实例
let discoveryDeviceManager = new DiscoveryDeviceManager();
export default discoveryDeviceManager as DiscoveryDeviceManager;