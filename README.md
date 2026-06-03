# MOMENTUM

[![iOS Build](https://github.com/<你的用户名>/MOMENTUM/actions/workflows/ios-build.yml/badge.svg)](https://github.com/<你的用户名>/MOMENTUM/actions/workflows/ios-build.yml)

轻创作图像 App — iOS 17+ / SwiftUI

## 在 GitHub 上验证编译（无需 Mac）

本项目已配置 GitHub Actions，push 到 GitHub 后会在云端 macOS 上自动编译。

### 首次推送步骤

```bash
cd D:\AI_Workstation\Ai_code_project\MOMENTUM
git init
git add .
git commit -m "Initial commit: MOMENTUM MVP"
git branch -M main
git remote add origin https://github.com/LNTanoZZH/MOMENTUM.git
git push -u origin main
```

### 查看构建结果

1. 打开 GitHub 仓库页面
2. 点击 **Actions** 标签
3. 选择 **iOS Build** workflow
4. 绿色 ✓ 表示编译通过；红色 ✗ 可点进日志查看 Swift 报错

也可在 commit 旁看到 ✓ / ✗ 状态徽章。

### 手动触发

Actions → iOS Build → **Run workflow**

### 本地 Mac 运行（可选）

1. 在 Mac 上用 Xcode 15+ 打开 `MOMENTUM.xcodeproj`
2. 选择 Development Team（Signing & Capabilities）
3. 运行到模拟器或真机

## MVP 功能

- **色卡**：5 种布局、K-Means 取色、网格/光谱/RGB 选色、吸管、纯色/渐变/条纹/颗粒、文字
- **波点**：随机/逐个/路径三种模式，双区域蒙版（原图覆盖 / 色卡镂空）
- **导出**：典藏动画、SwiftData 作品集、保存相册
- **体验**：撤销重做、触觉/音效反馈、Live Photo 标识

## 项目结构

```
MOMENTUM/
├── App/                 # 入口与路由
├── DesignSystem/        # 奶油风 UI 组件与令牌
├── Features/            # Home、ColorCard 编辑、Export
├── Engine/              # 图像合成引擎
└── Services/            # 导入、导出、反馈、存储
```

## 后续模块（已预留接口）

贴纸抠图、画笔、底图模糊、日历 — 见 `EditProject` 与 `ImageComposer` 扩展点。
