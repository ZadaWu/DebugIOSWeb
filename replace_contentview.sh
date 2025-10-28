#!/bin/bash

# 代码重构 - 替换ContentView.swift
# 这个脚本会备份旧文件并使用新的模块化版本

PROJECT_DIR="/Users/zada/Documents/Project/AI-Projects/LiveHttpServer/LiveHttpServer/LiveHttpServer"
cd "$PROJECT_DIR"

echo "🚀 开始替换 ContentView.swift..."

# 1. 备份旧文件
if [ -f "ContentView.swift" ]; then
    echo "📦 备份旧文件 -> ContentView_BACKUP_$(date +%Y%m%d_%H%M%S).swift"
    cp ContentView.swift "ContentView_BACKUP_$(date +%Y%m%d_%H%M%S).swift"
fi

# 2. 使用新文件替换
if [ -f "ContentView_NEW.swift" ]; then
    echo "✅ 使用新文件替换..."
    cp ContentView_NEW.swift ContentView.swift
    echo "✨ ContentView.swift 已更新！"
else
    echo "❌ 错误：找不到 ContentView_NEW.swift"
    exit 1
fi

# 3. 检查必要的文件是否存在
echo ""
echo "📋 检查模块文件..."

missing_files=()

# Models
[ ! -f "Models/ConsoleLog.swift" ] && missing_files+=("Models/ConsoleLog.swift")
[ ! -f "Models/NetworkRequest.swift" ] && missing_files+=("Models/NetworkRequest.swift")
[ ! -f "Models/NetworkThrottlingProfile.swift" ] && missing_files+=("Models/NetworkThrottlingProfile.swift")

# Managers
[ ! -f "Managers/DeveloperToolsManager.swift" ] && missing_files+=("Managers/DeveloperToolsManager.swift")
[ ! -f "Managers/SimpleHTTPServer.swift" ] && missing_files+=("Managers/SimpleHTTPServer.swift")

# WebView
[ ! -f "WebView/JavaScriptInjection.swift" ] && missing_files+=("WebView/JavaScriptInjection.swift")
[ ! -f "WebView/WebViewCoordinator.swift" ] && missing_files+=("WebView/WebViewCoordinator.swift")
[ ! -f "WebView/WebViewWrapper.swift" ] && missing_files+=("WebView/WebViewWrapper.swift")

# Views
[ ! -f "Views/ConsoleViews.swift" ] && missing_files+=("Views/ConsoleViews.swift")
[ ! -f "Views/NetworkViews.swift" ] && missing_files+=("Views/NetworkViews.swift")

if [ ${#missing_files[@]} -eq 0 ]; then
    echo "✅ 所有模块文件都存在"
else
    echo "⚠️  缺少以下文件："
    for file in "${missing_files[@]}"; do
        echo "   - $file"
    done
    echo ""
    echo "请确保这些文件已添加到Xcode项目中！"
fi

echo ""
echo "🎉 替换完成！"
echo ""
echo "📝 下一步："
echo "1. 在Xcode中: ⌘ + Shift + K (Clean)"
echo "2. 构建项目: ⌘ + B"
echo "3. 如果有编译错误，请确保所有新文件都已添加到Target"
echo ""
echo "📖 查看详细指南: MIGRATION_GUIDE.md"
