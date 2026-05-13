# 剧情图片目录

## 使用方法

1. 将你的图片（DDS 格式）放入本目录
2. 修改 `LiShiminPresentation.lua` 中的 `CORONATION_KILL_IMAGE` 变量为你的文件名
3. 修改 `LiShiminPresentation.xml` 中 `CoronationKillImage` 控件的 `Texture` 属性
4. 在 `LiShimin.modinfo` 的 `<Files>` 中注册新图片文件，例如：
   ```xml
   <File>src/UI/Coronation_Kill.dds</File>
   ```

## 图片要求

- 格式：DDS (DXT5 带 Alpha 通道)
- 推荐尺寸：1024x1024 或 512x512
- 文件名不要含中文或空格

## 当前图片映射

| momentKind | 变量 | 默认文件 | 说明 |
|---|---|---|---|
| `coronation_kill` | `CORONATION_KILL_IMAGE` | `Coronation_Kill.dds` | 李建成被天策上将俘获瞬间 |
