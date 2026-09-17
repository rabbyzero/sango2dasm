# 滚动面板行模板命名决策

- **Category:** important_decision_experience
- **Memory ID:** 46188581-dfca-47cd-9ea6-e81696be52de
- **Keywords:** 命名规范, UI模板, nametable, 反汇编

## Content

## 决策场景
为非属性数据的滚动面板行模板分组命名

## 决策内容
将 $DDC5-$DE24 区域按视觉风格分为三组，每组 $20 字节，命名为：
1. `ScrollPanel_RowTemplate_Ornate` ($DDC5-$DDD4): 装饰性强，使用 $AA, $5F, $6E 等图案化边框
2. `ScrollPanel_RowTemplate_Solid` ($DDE5-$DDF4): 坚实风格，以 $FF, $EE, $CD 等重色块为主
3. `ScrollPanel_RowTemplate_Plain` ($DE05-$DE14): 简约风格，边框细($22/$88)，内部多为空($00/$A0)

## 适用范围
反汇编中识别和命名具有视觉语义的 nametable 行模板数据
