# flip_page_effect

一个翻页效果的DEMO。



**( 1 )** 仅实现效果，功能性能未优化

**( 2 )** 可根据需要自行修改和丰富功能

**( 3 )** 单个文件，可直接复制添加到工程；也可clone整个project



✅ 左右翻页效果

✅ 翻页阴影

✅ 背面文字印效果

✅ 纯flutter实现了左右翻页的效果，不添加其他依赖和文件

  

ON Flutter 3.16.1 • channel stable • Dart 3.2.1 • DevTools 2.28.3

### 效果演示
![effect.gif](https://p6-xtjj-sign.byteimg.com/tos-cn-i-73owjymdk6/40f8dd6c2d1e42b9b8418599ada75ef2~tplv-73owjymdk6-jj-mark-v1:0:0:0:0:5o6Y6YeR5oqA5pyv56S-5Yy6IEAg55So5oi3NzQyNzk4NzczNzU5:q75.awebp?rk3s=f64ab15b&x-expires=1752656314&x-signature=MIThxNy3AHheq%2Fd%2FuOvMK%2FbdMzg%3D)


**有几个需要注意的地方：**

1. 矩阵的实例化是按照列为顺序的，需要转置使用；
2. canvas的矩阵变换函数是整个屏幕坐标系的变换，记得save和restore；
3. 左右翻页的动画，触摸手势与触摸点所在屏幕区域的控制需要再斟酌一下，细节比较多；
4. 区域A B C的绘制顺序以及有贝塞尔曲线参与的区域闭合和裁剪；
5. 阴影的绘制与计算相关参数可能需要再微调一下；
6. 首页和尾页的处理方式。
