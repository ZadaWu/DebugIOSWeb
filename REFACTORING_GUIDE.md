# LiveHttpServer 代码重构指南

## 📊 当前状态

- **ContentView.swift**: 2988行 ❌ 过大，难以维护
- **已完成**: Models和Managers已拆分 ✅

## 🎯 重构目标

将单一的`ContentView.swift`拆分成模块化结构，提高代码可读性和可维护性。

## 📁 目标目录结构

```
LiveHttpServer/
├── Models/                              ✅ 已完成
│   ├── ConsoleLog.swift                 ✅
│   ├── NetworkRequest.swift             ✅
│   └── NetworkThrottlingProfile.swift   ✅
│
├── Managers/                            ✅ 已完成
│   ├── DeveloperToolsManager.swift      ✅
│   └── SimpleHTTPServer.swift           ✅
│
├── WebView/                             ⏳ 待创建
│   ├── WebViewWrapper.swift
│   ├── WebViewCoordinator.swift
│   └── JavaScriptInjection.swift
│
├── Views/                               ⏳ 待创建
│   ├── Console/
│   │   ├── ConsoleView.swift
│   │   └── ConsoleLogRow.swift
│   │
│   ├── Network/
│   │   ├── NetworkView.swift
│   │   ├── NetworkRequestRow.swift
│   │   ├── NetworkRequestDetailView.swift
│   │   ├── NetworkThrottlingBar.swift
│   │   └── FilterButton.swift
│   │
│   └── Editor/
│       └── EditorView.swift
│
└── ContentView.swift                    ⏳ 需要简化 (目前2988行 → 目标<300行)
```

## ✅ 已完成的文件

### 1. Models/ConsoleLog.swift
- `ConsoleLog` struct
- `LogType` enum (log, warn, error, info)
- 颜色和图标定义

### 2. Models/NetworkRequest.swift
- `NetworkRequest` struct
- `RequestType` enum (XHR, Fetch, JS, CSS, etc.)
- 类型颜色映射

### 3. Models/NetworkThrottlingProfile.swift
- `NetworkThrottlingProfile` enum
- 网络配置 (downloadSpeed, uploadSpeed, latency)
- UI配置 (icon, color, description)

### 4. Managers/DeveloperToolsManager.swift
- Console logs 管理
- Network requests 管理
- 浏览器数据清理
- 网络节流配置

### 5. Managers/SimpleHTTPServer.swift
- HTTP服务器逻辑
- 网络连接处理
- IP地址获取

## 📋 下一步重构步骤

### 步骤1: 创建WebView相关文件 (关键)

#### WebView/JavaScriptInjection.swift
```swift
import Foundation

struct JavaScriptInjection {
    // 生成完整的JavaScript注入代码
    static func getFullInjectionScript(
        throttling: NetworkThrottlingProfile
    ) -> String {
        return """
        \(consoleMonitoringScript)
        \(networkMonitoringScript(throttling: throttling))
        \(performanceObserverScript)
        """
    }

    private static var consoleMonitoringScript: String {
        // Console拦截代码
    }

    private static func networkMonitoringScript(
        throttling: NetworkThrottlingProfile
    ) -> String {
        // Network拦截代码 (fetch/XHR)
    }

    private static var performanceObserverScript: String {
        // PerformanceObserver代码
    }
}
```

#### WebView/WebViewCoordinator.swift
```swift
import WebKit

class WebViewCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    var devTools: DeveloperToolsManager
    weak var webView: WKWebView?
    var currentFetchTask: URLSessionDataTask?

    // 跟踪状态
    var lastLoadedHTML: String = ""
    var lastRefreshTrigger: Int = 0
    var lastLoadedURL: String = ""
    var lastPreviewMode: PreviewMode = .url

    // WKScriptMessageHandler实现
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        // 处理console和network消息
    }

    // 网络节流获取
    func fetchURLWithThrottling(...) {
        // 实现
    }
}
```

#### WebView/WebViewWrapper.swift
```swift
import SwiftUI
import WebKit

struct WebViewWrapper: UIViewRepresentable {
    let htmlContent: String
    @ObservedObject var devTools: DeveloperToolsManager
    let refreshTrigger: Int
    let previewMode: PreviewMode
    let previewURL: String

    func makeUIView(context: Context) -> WKWebView {
        // 创建WKWebView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // 更新WebView
    }
}
```

### 步骤2: 创建Views文件

#### Views/Console/ConsoleView.swift
- Console标签页主视图
- JavaScript代码执行器

#### Views/Console/ConsoleLogRow.swift
- 单条日志显示
- 展开/折叠详情

#### Views/Network/NetworkView.swift
- Network标签页主视图
- 请求列表

#### Views/Network/NetworkRequestRow.swift
- 单条请求显示

#### Views/Network/NetworkRequestDetailView.swift
- 请求详情页面

#### Views/Network/NetworkThrottlingBar.swift
- 网络节流配置栏

#### Views/Editor/EditorView.swift
- HTML编辑器
- URL输入框

### 步骤3: 简化ContentView.swift

目标：**从2988行减少到<300行**

```swift
import SwiftUI

enum PreviewMode {
    case url, editor
}

struct ContentView: View {
    @StateObject private var server = SimpleHTTPServer()
    @StateObject private var devTools = DeveloperToolsManager()
    @State private var selectedTab = 0
    @State private var previewMode: PreviewMode = .url

    var body: some View {
        NavigationView {
            VStack {
                statusBar
                TabView(selection: $selectedTab) {
                    EditorView(...)
                    PreviewView(...)
                    ConsoleView(devTools: devTools)
                    NetworkView(devTools: devTools)
                }
            }
            .navigationTitle("HTML Server")
            .toolbar { ... }
        }
    }
}
```

## 🚀 执行计划

### 阶段1: WebView拆分 (最关键)
1. ✅ 创建 `WebView/JavaScriptInjection.swift`
2. ✅ 创建 `WebView/WebViewCoordinator.swift`
3. ✅ 创建 `WebView/WebViewWrapper.swift`
4. ✅ 在ContentView导入并使用

### 阶段2: Views拆分
1. ✅ 创建 Console Views
2. ✅ 创建 Network Views
3. ✅ 创建 Editor View
4. ✅ 在ContentView导入并使用

### 阶段3: 清理ContentView
1. ✅ 删除已迁移的代码
2. ✅ 验证功能完整性
3. ✅ 测试所有功能

## 📝 迁移检查清单

### WebView部分
- [ ] JavaScript注入代码 (Console监控)
- [ ] JavaScript注入代码 (Network监控)
- [ ] JavaScript注入代码 (PerformanceObserver)
- [ ] WebViewCoordinator (消息处理)
- [ ] WebViewCoordinator (网络节流获取)
- [ ] WebViewWrapper (UI创建和更新)

### Views部分
- [ ] ConsoleView (日志列表+代码执行)
- [ ] ConsoleLogRow (日志行)
- [ ] NetworkView (请求列表)
- [ ] NetworkRequestRow (请求行)
- [ ] NetworkRequestDetailView (请求详情)
- [ ] NetworkThrottlingBar (节流配置)
- [ ] FilterButton (筛选按钮)
- [ ] EditorView (编辑器+URL输入)

### ContentView清理
- [ ] 移除Models定义
- [ ] 移除Managers定义
- [ ] 移除WebView定义
- [ ] 移除Views定义
- [ ] 保留主逻辑和状态管理

## 🎉 预期收益

- **代码可读性**: ⬆️ 大幅提升
- **维护性**: ⬆️ 更容易定位和修复bug
- **可测试性**: ⬆️ 独立组件更易测试
- **团队协作**: ⬆️ 不同开发者可并行工作在不同文件
- **性能**: ➡️ 相同 (仅结构优化，不影响性能)

## 💡 最佳实践建议

1. **一次迁移一个文件** - 避免大规模改动导致编译错误
2. **每次迁移后测试** - 确保功能正常
3. **使用Git提交** - 每完成一个文件就commit
4. **保留注释** - 代码分离时保留MARK注释
5. **统一命名** - 保持命名风格一致

## 📞 需要帮助？

如果在重构过程中遇到问题，可以：
1. 查看已完成的Models和Managers文件作为参考
2. 逐个文件创建，每次测试
3. 保持原有功能不变，只做结构调整

---

**开始重构吧！** 🚀
