# 根据模拟地形生成的 SAR 图像

## 简介

本段代码大幅修改自[MATLAB 官方提供的示例](https://ww2.mathworks.cn/help/radar/ug/simulated-land-scenes-for-synthetic-aperture-radar-image-formation.html)，作出如下修改：

- 路径修改，目标中心点设定于`(1000±20,0)`，路径标识文件在`simulator_angle.ggb`表述。路径标识文件请使用[GeoGebra](https://www.geogebra.org/)打开。
- 图片会输出成一个图片文件，示例图片在`pic_5000.zip`里面。

使用该段代码前，请安装 MATLAB Radar Toolbox。

## 文件概述

`*` 表示这个函数在将来也许不会使用

1. helperDotTurn：计算一个点(x0,y0)对于中心点(x,y)旋转angle度后的点(x1,y1).
2. helperPlotGroundTruth*：查看模拟地形和雷达运动轨迹.
3. helperPlotRawIQ*：查看模拟生成雷达回波进程的东西.
4. helperPlotReflectivityMap*：查看地形反射率.
5. helperPlotSimulatedTerrain*：查看模拟地形.
6. helperRandomTerrainGenerator：模拟地形生成器.
7. helperSaveSLC：通过雷达回波生成并保存图像.
8. helperSimulatorScript：主要执行脚本.
9. helperUpdatePlotRawIQ*：更新雷达回波.

## 雷达路径

参考了[论文A](https://ieeexplore.ieee.org/document/9931024)中提到的 SAR COOPERATIVE OBSERVATION MODEL 和在实践中总结的角度 12 度以内融合变化畸形小的特点，我决定如此安排路径：

TODO：图片上传

## 模拟雷达的参数

Define an L-band SAR imaging system with a range resolution approximately equal to 5 m. This system is mounted on an airborne platform flying at an altitude of 1000 meters. 

## 模拟过程

1. 生成地形，设定目标点
2. 设定一个场景，加入雷达
3. 根据雷达路径生成图像