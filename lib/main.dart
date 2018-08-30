import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class AnimationDemoView extends StatefulWidget {
  @override
  State createState() {
    return _AnimationState();
  }
}

class _AnimationState extends State<AnimationDemoView>
    with SingleTickerProviderStateMixin {

  static const padding = 16.0;

  AnimationController controller;
  Animation<double> left;
  Animation<Color> color;

  @override
  void initState() {
    super.initState();
    // 只有在 initState 执行完，我们才能通过 MediaQuery.of(context) 获取
    // mediaQueryData。这里通过创建一个 Future 从而在 Dart 事件队列里插入
    // 一个事件，以达到延后执行的目的（类似于在 Android 里 post 一个 Runnable）
    // 关于 Dart 的事件队列，读者可以参考 https://webdev.dartlang.org/articles/performance/event-loop
    Future(_initState);
  }

  void _initState() {
    // 1. 创建一个 Animation<T>，最简单的方式就是直接使用 AnimationController。
    // Animation 用户控制动画的进度、状态，但它并不关心屏幕上是什么东西在做动画。
    // AnimationController 输出的值在 0 ~ 1 之间
    controller = AnimationController(
        duration: const Duration(milliseconds: 2000),
        // 注意类定义的 with SingleTickerProviderStateMixin，提供 vsync 最简单的方法
        // 就是继承一个 SingleTickerProviderStateMixin。这里的 vsync 跟 Android 里
        // 的 vsync 类似，用来提供时针滴答，触发动画的更新。
        vsync: this);

    // 我们通过 MediaQuery 获取屏幕宽度
    final mediaQueryData = MediaQuery.of(context);
    final displayWidth = mediaQueryData.size.width;
    debugPrint('width = $displayWidth');
    // 2. 我们用 Tween 把 controller 输出的 0 ~ 1 之间的值映射到 [begin, end]
    // Tween.animate(controller) 返回一个 Animatable<T>，通过这个 Animatable<T> 我们
    // 可以获取映射过的值
    left = Tween(begin: padding, end: displayWidth - padding).animate(controller)
      // 每一帧都会回调这里添加的回调函数
      ..addListener(() {
        // 3. 调用 setState 触发他重新 build 一个 Widget。在 build 方法里，我们根据
        //    Animatable<T> 的当前值来创建 Widget，达到动画的效果（类似 Android 的属
        //    性动画）。
        setState(() {
          // nothing have to do
        });
      })
      // 监听动画状态变化
      ..addStatusListener((status) {
        // 这里我们让动画往复不断执行

        // 一次动画完成
        if (status == AnimationStatus.completed) {
          // 我们让动画反正执行一遍
          controller.reverse();
        // 反着执行的动画结束
        } else if (status == AnimationStatus.dismissed) {
          // 正着重新开始
          controller.forward();
        }
      });
    color = ColorTween(begin: Colors.red, end: Colors.blue).animate(controller);
    // 4. 开始动画
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    // 假定一个单位是 24
    final unit = 24.0;
    final marginLeft = left == null ? padding : left.value;

    // 把 marginLeft 单位化
    final unitizedLeft = (marginLeft - padding) / unit;
    final unitizedTop = math.sin(unitizedLeft);
    // unitizedTop + 1 是了把 [-1, 1] 之间的值映射到 [0, 2]
    // (unitizedTop+1) * unit 后把单位化的值转回来
    final marginTop = (unitizedTop + 1) * unit + padding;
    final color = this.color == null ? Colors.red : this.color.value;
    return Container(
      // 我们根据动画的进度设置圆点的位置
      margin: EdgeInsets.only(left: marginLeft, top: marginTop),
      // 画一个小红点
      child: Container(
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(7.5)),
        width: 15.0,
        height: 15.0,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter animation demo',
      home: Scaffold(
        appBar: AppBar(title: Text('Animation demo')),
        body: AnimationDemoView(),
      ),
    );
  }
}
