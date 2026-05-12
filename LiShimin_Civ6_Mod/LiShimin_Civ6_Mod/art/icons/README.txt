两个 DDS 须放在本目录，文件名与 modinfo、src/XML/LiShimin_Icons.xml 中一致：

  Lishimin_Xuanwu.dds      — 玄武门：建筑图标 +「建成玄武门」通知小图
  Lishimin_Coronation.dds —「登基完成」通知小图

仓库里已带 64×64 的 DXT1 占位图，可直接进游戏验证管线；正式美术请用你自己的图覆盖（建议 256×256 或 512×512 正方形；需透明时用 BC7 / DXT5，并相应改 XML 里各 IconSize 行的 Filename 若你拆成多文件）。
