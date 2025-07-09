import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
void main() => runApp(const MyApp());
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FlipPage(),
    );
  }
}

//--------------------------------------------------------------------------------------------------------
//-------------------------------I am the dividing line---------------------------------------------------
//--------------------------------------------------------------------------------------------------------

class MyPoint {
  double x;
  double y;
  String alias;
  MyPoint(this.x, this.y,[this.alias = ""]);

  factory MyPoint.initial({alias = ""}) {
    return MyPoint(0, 0,alias);
  }

  @override
  String toString() {
    return "(${x.toString()},${y.toString()})";
  }

  bool equals(MyPoint other){
    return x == other.x && y == other.y;
  }

}

class MyPointTween extends Tween<MyPoint> {

  MyPoint? middle;

  MyPointTween({required MyPoint begin, required MyPoint end}) : super(begin: begin, end: end);

  void setMiddle (MyPoint middle){
    this.middle = middle;
  }

  @override
  MyPoint lerp(double t) {
    if (middle == null) {
      return MyPoint(
          ui.lerpDouble(begin!.x, end!.x, t)!,
          ui.lerpDouble(begin!.y, end!.y, t)!,
          begin!.alias
      );
    }
    if (t < 0.5) {
      // 前半段动画，从 begin 到 middle
      final adjustedT = t*2;
      return MyPoint(
          ui.lerpDouble(begin!.x, middle!.x, adjustedT)!,
          ui.lerpDouble(begin!.y, middle!.y, adjustedT)!,
      );
    } else {
      // 后半段动画，从 middle 到 end
      final adjustedT = (t-0.5)*2;
      return MyPoint(
          ui.lerpDouble(middle!.x, end!.x, adjustedT)!,
          ui.lerpDouble(middle!.y, end!.y, adjustedT)!,
      );
    }
  }
}

enum TouchArea {
  TOP_RIGHT,
  BOTTOM_RIGHT
}

class FlipPage extends StatefulWidget {
  const FlipPage({Key? key}) : super(key: key);

  @override
  FlipPageState createState() => FlipPageState();
}

class FlipPageState extends State<FlipPage> with TickerProviderStateMixin {

  TouchArea touchArea = TouchArea.BOTTOM_RIGHT;

  Size? screenSize;
  bool isInit = false;
  late MyPoint a,f,g,e,h,c,j,b,k,d,i;
  late List<MyPoint> points;
  late Paint pointPaint,bgPaint;

  List<String> bookPages = [
    '''
　　滚滚长江东逝水，浪花淘尽英雄。是非成败转头空。青山依旧在，几度夕阳红。白发渔樵江渚上，惯看秋月春风。一壶浊酒喜相逢。古今多少事，都付笑谈中。

　　——《临江仙》

　　话说天下大势，分久必合，合久必分：周末七国分争，并入于秦；及秦灭之后，楚、汉分争，又并入于汉；汉朝自高祖斩白蛇而起义，一统天下，后来光武中兴，传至献帝，遂分为三国。推其致乱之由，殆始于桓、灵二帝。桓帝禁锢善类，崇信宦官。及桓帝崩，灵帝即位，大将军窦武、太傅陈蕃共相辅佐。时有宦官曹节等弄权，窦武、陈蕃谋诛之，机事不密，反为所害。中涓自此愈横。

　　建宁二年四月望日，帝御温德殿。方升座，殿角狂风骤起，只见一条大青蛇从梁上飞将下来，蟠于椅上。帝惊倒，左右急救入宫；百官俱奔避。须臾，蛇不见了。忽然大雷大雨，加以冰雹，落到半夜方止，坏却房屋无数。建宁四年二月，洛阳地震；又海水泛溢，沿海居民尽被大浪卷入海中。光和元年，雌鸡化雄；[1]
    ''',

    '''
六月朔，黑气十馀丈飞入温德殿中；秋七月，有虹现于玉堂，五原山岸尽皆崩裂。种种不祥，非止一端。

　　帝下诏问群臣以灾异之由。议郎蔡邕上疏，以为蜺堕、鸡化，乃妇寺干政之所致，言颇切直。帝览奏叹息，因起更衣。曹节在后窃视，悉宣告左右。遂以他事陷邕于罪，放归田里。

　　后张让、赵忠、封谞、段珪、曹节、侯览、蹇硕、程旷、夏恽、郭胜十人朋比为奸，号为“十常侍”。帝尊信张让，呼为“阿父”。朝政日非，以致天下人心思乱，盗贼蜂起。
    
　　时巨鹿郡有兄弟三人，一名张角，一名张宝，一名张梁。那张角本是个不第秀才，因入山采药，遇一老人，碧眼童颜，手执藜杖，唤角至一洞中，以天书三卷授之，曰：“此名《太平要术》。汝得之，当代天宣化，普救世人。若萌异心，必获恶报。”角拜问姓名，老人曰：“吾乃南华老仙也。”言讫，化阵清风而去。角得此书，晓夜攻习，能呼风唤雨，号为“太平道人”。 [2]
    ''',

    '''
　　中平元年正月内，疫气流行。张角散施符水，为人治病，自称“大贤良师”。角有徒弟五百馀人，云游四方，皆能书符念咒。次后徒众日多，角乃立三十六方：大方万馀人，小方六七千，各立渠帅，称为将军。讹言：“苍天已死，黄天当立。”又云：“岁在甲子，天下大吉。”令人各以白土书“甲子”二字于家中大门上。青、幽、徐、冀、荆、扬、兖、豫八州之人，家家侍奉大贤良师张角名字。

　　角遣其党马元义暗赍金帛，结交中涓封谞，以为内应。角与二弟商议曰：“至难得者，民心也。今民心已顺，若不乘势取天下，诚为可惜。”遂一面私造黄旗，约期举事；一面使弟子唐周驰书报封谞。唐周乃径赴省中告变。帝召大将军何进调兵擒马元义，斩之；次收封谞等一干人下狱。张角闻知事露，星夜举兵，自称“天公将军”，张宝称“地公将军”，张梁称“人公将军”。申言于众曰：“今汉运将终，大圣人出。汝等皆宜顺天从正，以乐太平。”四方百姓裹黄巾从张角反者四五十万，贼势浩大，官军望风而靡。何进奏帝火速降诏，令各处备御，讨贼立功；一面遣中郎将卢植、皇甫嵩、朱儁各引精兵，分三路讨之。 [3]
    ''',

    '''
　　且说张角一军前犯幽州界分。幽州太守刘焉乃江夏竟陵人氏，汉鲁恭王之后也。当时闻得贼兵将至，召校尉邹靖计议。靖曰：“贼兵众，我兵寡，明公宜作速招军应敌。”刘焉然其说，随即出榜招募义兵。

　　榜文行到涿县，引出涿县中一个英雄。那人不甚好读书；性宽和，寡言语，喜怒不形于色；素有大志，专好结交天下豪杰；生得身长七尺五寸，两耳垂肩，双手过膝，目能自顾其耳，面如冠玉，唇若涂脂：中山靖王刘胜之后，汉景帝阁下玄孙，姓刘名备，字玄德。昔刘胜之子刘贞，汉武时封涿鹿亭侯，后坐酎金失侯，因此遗这一枝在涿县。玄德祖刘雄，父刘弘。弘曾举孝廉，亦尝作吏，早丧。玄德幼孤，事母至孝。家贫，贩屦织席为业。家住本县楼桑村。其家之东南有一大桑树，高五丈馀，遥望之，童童如车盖。相者云：“此家必出贵人。”玄德幼时，与乡中小儿戏于树下，曰：“我为天子，当乘此车盖。”叔父刘元起奇其言，曰：“此儿非常人也。”因见玄德家贫，常资给之。年十五岁，母使游学，尝师事郑玄、卢植，与公孙瓒等为友。及刘焉发榜招军时，玄德年已二十八岁矣。 [4]
    '''
  ];

  double deltaX = 0;

  double flipSpeedX = 0; //翻页动作的速度
  bool touchPointLessQuarterX = false;//松手的点是否小于屏幕的1/4
  int currentPage = 0;//当前的页码
  @override
  initState(){
    super.initState();
  }

  void initMyPoint(){
    a = touchArea == TouchArea.BOTTOM_RIGHT
        ? MyPoint(screenSize!.width-1, screenSize!.height-1,"a")
        : MyPoint(screenSize!.width-1, 1,"a");
    f = touchArea == TouchArea.BOTTOM_RIGHT
        ? MyPoint(screenSize!.width, screenSize!.height,"f")
        : MyPoint(screenSize!.width, 0,"f");
    g = MyPoint.initial(alias: "g");
    e = MyPoint.initial(alias: "e");
    h = MyPoint.initial(alias: "h");
    c = MyPoint.initial(alias: "c");
    j = MyPoint.initial(alias: "j");
    b = MyPoint.initial(alias: "b");
    k = MyPoint.initial(alias: "k");
    d = MyPoint.initial(alias: "d");
    i = MyPoint.initial(alias: "i");
    calcPointsXY(a, f);
    points = [a,f,g,e,h,c,j,b,k,d,i];
  }

  late Animation<MyPoint> _resumeAnimation;
  late MyPointTween _resumeTween;
  AnimationController? _resumeController;//没有翻页翻过去的动画控制器，回到初始位置

  late Animation<MyPoint> _flippedAnimation;
  late MyPointTween _flippedTween;
  AnimationController? _flippedController;//翻页翻过去的动画控制器

  late Animation<MyPoint> _flipReverseAnimation;
  late MyPointTween _flipReverseTween;
  AnimationController? _flipReverseController;//翻页翻回来的动画控制器

  bool flippedAnimationActing = false; //翻过去的动画是否正在执行
  bool flipReverseAnimationActing = false; //翻过去的动画是否正在执行

  void initAnimationControllers(){
    _resumeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _resumeTween = MyPointTween(
      begin: a,
      end: MyPoint(f.x-1, 1),
    );
    _resumeAnimation = _resumeTween.animate(
        CurvedAnimation(
          parent: _resumeController!,
          curve: Curves.fastLinearToSlowEaseIn,
        )
    );
    _resumeAnimation.addListener(() {
      setState(() {
        a.x = _resumeAnimation.value.x;
        a.y = _resumeAnimation.value.y;
        calcPointsXY(a,f);
      });
    });

    _flippedController = AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _flippedTween = MyPointTween(
      begin: a,
      end: MyPoint(-(f.x-1), f.y-1)
    );
    _flippedAnimation = _flippedTween.animate(
        CurvedAnimation(
          parent: _flippedController!,
          curve: Curves.fastLinearToSlowEaseIn,
        )
    );
    _flippedAnimation..addListener(() {
      setState(() {
        a.x = _flippedAnimation.value.x;
        a.y = _flippedAnimation.value.y;
        flippedAnimationActing = true;
        calcPointsXY(a,f);
      });
    })..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        flippedAnimationActing = false;
        if (currentPage < bookPages.length-1) currentPage++;
        initMyPoint();
        initialStartEndPoint();
      }
    });

    _flipReverseController = AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _flipReverseTween = MyPointTween(
      begin: MyPoint(-(f.x-1),f.y-1),
      end: a,
    );
    _flipReverseAnimation = _flipReverseTween.animate(
        CurvedAnimation(
          parent: _flipReverseController!,
          curve: Curves.linear,
        )
    );
    _flipReverseAnimation..addListener(() {
      setState(() {
        a.x = _flipReverseAnimation.value.x;
        a.y = _flipReverseAnimation.value.y;
        flipReverseAnimationActing = true;
        calcPointsXY(a,f);
      });
    })..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        flipReverseAnimationActing = false;
        initialStartEndPoint();
      }
    });
  }

  void doFlip(){
    _flippedTween.begin = a;
    _flippedTween.end = touchArea == TouchArea.BOTTOM_RIGHT ? MyPoint(-(f.x-1), f.y-1) :  MyPoint(-(f.x-1), 1);
    _flippedController?.forward(from: _flippedController?.lowerBound);
  }

  void doFlipReverse(){
    _flipReverseTween.begin = touchArea==TouchArea.BOTTOM_RIGHT?MyPoint(0,(screenSize!.height-1)):MyPoint(0,1);
    _flipReverseTween.middle = touchArea==TouchArea.BOTTOM_RIGHT
        ?MyPoint(endPoint.x, endPoint.y < screenSize!.height/4*3 ? screenSize!.height/4*3 : endPoint.y)
        :MyPoint(endPoint.x, endPoint.y > screenSize!.height/4 ? screenSize!.height/4 : endPoint.y);
    _flipReverseTween.end = touchArea==TouchArea.BOTTOM_RIGHT?MyPoint((f.x-1),screenSize!.height-1):MyPoint((f.x-1),1);
    _flipReverseController?.forward(from: _flipReverseController?.lowerBound);
    if (currentPage > 0) currentPage--;
  }

  void doResume(){
    _resumeController?.forward(from: _resumeController?.lowerBound);
  }

  void init(){
    initMyPoint();
    initialStartEndPoint();
    initAnimationControllers();
    pointPaint = Paint()
      ..color = const Color(0xeeeeeee0)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.fill;
    bgPaint = Paint()
     ..color = const Color(0xeeeeeee0)
     ..strokeWidth = 5.0
     ..style = PaintingStyle.fill;
    isInit = true;
  }

  MyPoint calcPointC(MyPoint touchPoint, MyPoint f) {
    var ax = touchPoint.x;
    var ay = touchPoint.y;
    var fx = f.x;
    var fy = f.y;
    var gx = (ax + fx) / 2;
    var gy = (ay + fy) / 2;
    var ex = gx - (fy - gy) * (fy - gy) / (fx - gx);
    var ey = fy;
    var hx = fx;
    var hy = gy - (fx - gx) * (fx - gx) / (fy - gy);
    var cx = ex - (fx - ex) / 2;
    var cy = fy;
    return MyPoint(cx, cy);
  }

  MyPoint recalculateWhenCOutOfLeftEdge(MyPoint touchPont, MyPoint f, MyPoint cc) {
    var w0 = screenSize!.width - cc.x;
    var w1 = (f.x - touchPont.x).abs();
    var w2 = screenSize!.width * w1 / w0;
    var ax = (f.x - w2).abs();
    var h1 = (f.y - touchPont.y).abs();
    double h2 = w2 * h1 / w1;
    var ay = (f.y - h2).abs();
    return MyPoint(ax, ay);
  }

  calcPointsXY(MyPoint touchPont, MyPoint f){
    var ax = touchPont.x;
    var ay = touchPont.y;
    var fx = f.x;
    var fy = f.y;

    var cc = calcPointC(touchPont, f);
    if (!flippedAnimationActing) {
      if (cc.x < 0) {
        MyPoint a1 = recalculateWhenCOutOfLeftEdge(touchPont, f,cc);
        ax = a1.x;
        ay = a1.y;
      }
    }

    var gx = (ax + fx) / 2;
    var gy = (ay + fy) / 2;

    var ex = gx - (fy - gy) * (fy - gy) / (fx - gx);
    var ey = fy;

    var hx = fx;
    var hy = gy - (fx - gx) * (fx - gx) / (fy - gy);

    var cx = ex - (fx - ex) / 2;
    var cy = fy;

    var jx = fx;
    var jy = hy - (fy - hy) / 2;

    var b_temp = getIntersectionPoint(MyPoint(ax, ay),MyPoint(ex, ey),MyPoint(cx, cy),MyPoint(jx, jy));
    var k_temp = getIntersectionPoint(MyPoint(ax, ay),MyPoint(hx, hy),MyPoint(cx, cy),MyPoint(jx, jy));
    var bx = b_temp.x;
    var by = b_temp.y;
    var kx = k_temp.x;
    var ky = k_temp.y;

    var dx = (cx + 2 * ex + bx) / 4;
    var dy = (2 * ey + cy + by) / 4;

    var ix = (jx + 2 * hx + kx) / 4;
    var iy = (2 * hy + jy + ky) / 4;

    a.x = ax;
    a.y = ay;

    g.x = gx;
    g.y = gy;
    e.x = ex;
    e.y = ey;
    h.x = hx;
    h.y = hy;
    c.x = cx;
    c.y = cy;
    j.x = jx;
    j.y = jy;
    b.x = bx;
    b.y = by;
    k.x = kx;
    k.y = ky;
    d.x = dx;
    d.y = dy;
    i.x = ix;
    i.y = iy;
  }

  MyPoint getIntersectionPoint(MyPoint lineOne_My_pointOne, MyPoint lineOne_My_pointTwo, MyPoint lineTwo_My_pointOne, MyPoint lineTwo_My_pointTwo){
    double x1,y1,x2,y2,x3,y3,x4,y4;
    x1 = lineOne_My_pointOne.x;
    y1 = lineOne_My_pointOne.y;
    x2 = lineOne_My_pointTwo.x;
    y2 = lineOne_My_pointTwo.y;
    x3 = lineTwo_My_pointOne.x;
    y3 = lineTwo_My_pointOne.y;
    x4 = lineTwo_My_pointTwo.x;
    y4 = lineTwo_My_pointTwo.y;
    double pointX =((x1 - x2) * (x3 * y4 - x4 * y3) - (x3 - x4) * (x1 * y2 - x2 * y1))
        / ((x3 - x4) * (y1 - y2) - (x1 - x2) * (y3 - y4));
    double pointY =((y1 - y2) * (x3 * y4 - x4 * y3) - (x1 * y2 - x2 * y1) * (y3 - y4))
        / ((y1 - y2) * (x3 - x4) - (x1 - x2) * (y3 - y4));
    return MyPoint(pointX,pointY);
  }

  bool isShowDialog = false;
  void showPageDialog(BuildContext context,String title,String content) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                isShowDialog = false;
              }, // 关闭弹窗
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  late MyPoint startPoint;
  late MyPoint endPoint;
  void initialStartEndPoint(){
    startPoint = MyPoint.initial();
    endPoint = MyPoint.initial();
  }

  @override
  Widget build(BuildContext context) {
    screenSize ??= MediaQuery.of(context).size;
    if (!isInit) init();
    return Scaffold(
      body: GestureDetector(
        onTapUp: (TapUpDetails details){
          this.endPoint = MyPoint(details.localPosition.dx, details.localPosition.dy);
        },
        onPanDown: (DragDownDetails details) {
          this.startPoint = MyPoint(details.localPosition.dx, details.localPosition.dy);
          if (details.localPosition.dy < screenSize!.height / 2) {
            f.y = 0;
            touchArea = TouchArea.TOP_RIGHT;
          }else {
            f.y = screenSize!.height;
            touchArea = TouchArea.BOTTOM_RIGHT;
          }
        },
        onPanEnd: (DragEndDetails details) {
          if (isShowDialog) return;
          flipSpeedX = details.velocity.pixelsPerSecond.dx; //负数为向左翻页，正数为向右翻页
          if (
          (endPoint.x - startPoint.x) > screenSize!.width/3 ||
              flipSpeedX > 500) {
            if (currentPage <= 0) {
              isShowDialog = true;
              showPageDialog(context,'提示','这是第一页，不能往前翻了');
              return;
            }
            doFlipReverse();
            return;
          }
          if ((startPoint.x - endPoint.x) > screenSize!.width/2.3 || flipSpeedX <= -500) {//整页翻过去
            if (currentPage >= bookPages.length-1) {
              showPageDialog(context,'提示','这是最后一页了，不能再翻了');
              return;
            }
            doFlip();
          } else {
            if (startPoint.x < screenSize!.width / 2) {
              return;
            }
            doResume();
          }

        },
        onPanUpdate: (DragUpdateDetails details) {
          if (isShowDialog) return;
          final touchPoint = MyPoint(details.localPosition.dx,details.localPosition.dy);
          endPoint = MyPoint(touchPoint.x, touchPoint.y);
          deltaX = details.delta.dx;
          touchPointLessQuarterX = endPoint.x < screenSize!.width / 4 ? true : false;
          if (startPoint.x < screenSize!.width / 2) {
            return;
          }
          if (deltaX < 0 || //从右往左
              startPoint.x > screenSize!.width / 2) {
            if (currentPage >= bookPages.length-1) {
              isShowDialog = true;
              showPageDialog(context,'提示','这是最后一页了，不能再翻了');
              return;
            }
            setState(() {
              _resumeTween.begin = touchPoint;
              _resumeTween.end = touchArea == TouchArea.BOTTOM_RIGHT ? MyPoint(f.x-1, f.y-1) :  MyPoint(f.x-1, 1);
              calcPointsXY(touchPoint,f);
            });
          }
        },
        child: CustomPaint(
          size: Size.infinite,
          painter: FlipPagePainter(screenSize!,pointPaint,bgPaint,
              a,f,g,e,h,c,j,b,k,d,i, points,touchArea)
            ..setTexts(bookPages[currentPage],
                currentPage < bookPages.length-1
                ? bookPages[currentPage+1]
                : bookPages[currentPage]),
        )
      )
    );
  }

  @override
  void dispose() {
    _resumeController?.dispose();
    _flippedController?.dispose();
    _flipReverseController?.dispose();
    super.dispose();
  }

}

class AreaPath {
  late Path pathA;
  late Path pathB;
  late Path pathC;
  late Path pathAC;
  late Path pathBC;
  Size screenSize;
  MyPoint a,f,g,e,h,c,j,b,k,d,i;
  TouchArea touchArea;
  AreaPath(this.a,this.f,this.g,this.e,this.h,this.c,this.j,this.b,this.k,this.d,this.i,this.screenSize,this.touchArea){
    calcPaths();
  }

  //区域B,下一页的可视区域
  void calcPaths(){
    pathA = touchArea == TouchArea.BOTTOM_RIGHT
        ? getPathAFromBottomRight()
        : getPathAFromTopRight();

    Path pathc = Path();
    pathc.moveTo(i.x,i.y);//移动到i点
    pathc.lineTo(d.x,d.y);//移动到d点
    pathc.lineTo(b.x,b.y);//移动到b点
    pathc.lineTo(a.x,a.y);//移动到a点
    pathc.lineTo(k.x,k.y);//移动到k点
    pathc.lineTo(i.x,i.y);//移动到k点
    pathc.close();//闭合区域
    this.pathC = pathc;

    Path pathb = Path();
    pathb.lineTo(0, screenSize.height);//移动到左下角
    pathb.lineTo(screenSize.width,screenSize.height);//移动到右下角
    pathb.lineTo(screenSize.width,0);//移动到右上角
    pathb.close();//闭合区域
    this.pathAC = ui.Path.combine(ui.PathOperation.union, this.pathA, this.pathC);
    pathb = ui.Path.combine(ui.PathOperation.difference, pathb, this.pathAC);
    this.pathB = pathb;

    Path path = Path();
    path.lineTo(0, screenSize.height);//移动到左下角
    path.lineTo(screenSize.width,screenSize.height);//移动到右下角
    path.lineTo(screenSize.width,0);//移动到右上角
    path.close();//闭合区域
    this.pathBC = ui.Path.combine(ui.PathOperation.difference, path, pathA);
  }

  //区域A，当前页面
  ui.Path getPathAFromTopRight() {
    ui.Path patha = ui.Path();
    patha.lineTo(c.x,c.y);//移动到c点
    patha.quadraticBezierTo(e.x,e.y,b.x,b.y);
    patha.lineTo(a.x,a.y);//移动到a点
    patha.lineTo(k.x,k.y);//移动到k点
    patha.quadraticBezierTo(h.x,h.y,j.x,j.y);
    patha.lineTo(screenSize.width,screenSize.height);
    patha.lineTo(0, screenSize.height);
    patha.close();
    return patha;
  }

  ui.Path getPathAFromBottomRight(){
    ui.Path patha = ui.Path();
    patha.lineTo(0, screenSize.height);
    patha.lineTo(c.x, c.y);
    patha.quadraticBezierTo(e.x, e.y, b.x, b.y);
    patha.lineTo(a.x, a.y);
    patha.lineTo(k.x, k.y);
    patha.quadraticBezierTo(h.x, h.y, j.x, j.y);
    patha.lineTo(screenSize.width, 0);
    patha.close();
    return patha;
  }

}

class FlipPagePainter extends CustomPainter {

  final double topPadding = 70;

  TouchArea touchArea;
  Size screenSize;
  MyPoint a,f,g,e,h,c,j,b,k,d,i;
  List<MyPoint> points;
  late Paint pointPaint,bgPaint;
  late String pathAText;
  late String pathBText;

  late double rPathAShadowDis,lPathAShadowDis;

  FlipPagePainter(this.screenSize,this.pointPaint,this.bgPaint,
      this.a,this.f,this.g,this.e, this.h, this.c, this.j,
      this.b, this.k, this.d,this.i,this.points,this.touchArea);

  setTexts(String pathAText,String pathBText){
    this.pathAText = pathAText;
    this.pathBText = pathBText;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paths = AreaPath(a,f,g,e,h,c,j,b,k,d,i,screenSize,touchArea);
    paintFlipEffect(canvas, size,paths.pathA, paths.pathB, paths.pathC);

    //下面是绘制阴影
    calcLRShadowDis();
    drawPathBShadow(canvas,paths.pathBC,paths.pathC);
    drawPathBShadow(canvas,paths.pathBC,paths.pathB,color1:const Color(0x22111111));
    drawPathALeftShadow(canvas, paths.pathA);
    drawPathARightShadow(canvas,paths.pathA);
  }

  void calcLRShadowDis(){
    double rA = a.y-h.y;
    double rB = h.x-a.x;
    double rC = a.x*h.y-h.x*a.y;
    rPathAShadowDis = ( (rA*i.x+rB*i.y+rC)/sqrt(pow(rA, 2)+pow(rB, 2)) ).abs();

    double lA = a.y-e.y;
    double lB = e.x-a.x;
    double lC = a.x*e.y-e.x*a.y;
    lPathAShadowDis = ((lA*d.x+lB*d.y+lC)/sqrt(pow(lA, 2)+pow(lB, 2)) ).abs();
  }

  void drawPathALeftShadow(Canvas canvas, Path pathA) {
    canvas.restore();
    canvas.save();
    const deepColor = Color(0x66666666);
    const lightColor = Color(0x01666666);
    final gradientColors = [lightColor, deepColor];
    double left, right;
    final top = e.y;
    final bottom = e.y + screenSize.height;
    late Gradient gradient;
    if (touchArea == TouchArea.TOP_RIGHT) {
      left = e.x - lPathAShadowDis / 2;
      right = e.x;
      gradient = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: gradientColors
      );
    } else {
      left = e.x;
      right = e.x + lPathAShadowDis / 2;
      gradient = LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: gradientColors
      );
    }
    // 裁剪出我们需要的区域
    final mPath = Path()
      ..moveTo(a.x - max(rPathAShadowDis, lPathAShadowDis) / 2, a.y)
      ..lineTo(d.x, d.y)
      ..lineTo(e.x, e.y)
      ..lineTo(a.x, a.y)
      ..close();
    canvas.clipPath(pathA);
    canvas.clipPath(mPath);
    final radians = atan2(e.x - a.x, a.y - e.y);
    canvas.translate(e.x, e.y);
    canvas.rotate(radians);
    canvas.translate(-e.x, -e.y);
    final rect = Rect.fromLTRB(left, top, right, bottom);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void drawPathARightShadow(Canvas canvas, Path pathA) {
    canvas.restore();
    canvas.save();
    const deepColor = Color(0x66666666);
    const lightColor = Color(0x01666666);
    final gradientColors = [deepColor, lightColor, lightColor];
    final viewDiagonalLength = sqrt(pow(screenSize.width, 2) + pow(screenSize.height, 2));
    final left = h.x;
    final right = h.x + viewDiagonalLength * 10;
    double top, bottom;
    late Gradient gradient;
    if (touchArea == TouchArea.TOP_RIGHT) {
      top = h.y - rPathAShadowDis / 2;
      bottom = h.y;
      gradient = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: gradientColors
      );
    } else {
      top = h.y;
      bottom = h.y + rPathAShadowDis / 2;
      gradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors
      );
    }
    final rect = Rect.fromLTRB(left, top, right, bottom);
    final paint = Paint()..shader = gradient.createShader(rect);
    //裁剪出我们需要的区域
    Path mPath = Path();
    mPath.moveTo(a.x- max(rPathAShadowDis,lPathAShadowDis)/2,a.y);
    mPath.lineTo(h.x,h.y);
    mPath.lineTo(a.x,a.y);
    mPath.close();
    canvas.clipPath(pathA);
    canvas.clipPath(mPath, doAntiAlias: false);
    final radians = atan2(a.y - h.y, a.x - h.x);
    canvas.translate(h.x, h.y);
    canvas.rotate(radians);
    canvas.translate(-h.x, -h.y);
    canvas.drawRect(rect, paint);
  }

  void drawPathBShadow(Canvas canvas, ui.Path path1,ui.Path path2,
      {Color? color1,Color? color2}) {
    canvas.restore();
    canvas.save();
    color1 ??= const Color(0xffdddddd);
    color2 ??= const Color(0x08dddddd);
    final gradientColors = [color2!,color1!, color2!];
    const deepOffset = 0; // 深色端的偏移值
    const lightOffset = 0; // 浅色端的偏移值
    final aTof = sqrt(pow(a.x - f.x, 2) + pow(a.y - f.y, 2)); // a到f的距离
    final viewDiagonalLength = sqrt(pow(screenSize.width, 2) + pow(screenSize.height, 2));
    double left, right;
    final top = c.y;
    final bottom = viewDiagonalLength + c.y;

    late Gradient gradient;
    if (touchArea == TouchArea.TOP_RIGHT) { // f点在右上角
      // 从左向右线性渐变
      left = c.x - deepOffset; // c点位于左上角
      right = c.x + aTof / 4 + lightOffset;
      gradient = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: gradientColors
      );
    } else {
      // 从右向左线性渐变
      left = c.x - aTof / 4 - lightOffset; // c点位于左下角
      right = c.x + deepOffset;
      gradient = LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: gradientColors
      );
    }
    final rect = Rect.fromLTRB(left, top, right, bottom);
    final paint = Paint()..shader = gradient.createShader(rect);
    // 计算旋转角度（Dart使用弧度制）
    final radians = atan2(e.x - f.x, h.y - f.y);
    final rotation = Matrix4.identity()
      ..translate(c.x, c.y)
      ..rotateZ(radians)
      ..translate(-c.x, -c.y);
    canvas.clipPath(path1);
    canvas.clipPath(path2);
    canvas.transform(rotation.storage);
    canvas.drawRect(rect, paint);

  }

  void drawAuxiliaryPoints(Canvas canvas){
    for (var item in points) {
      var textPainter = TextPainter(
        text: TextSpan(
          text: item.alias,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(item.x-10, item.y-30));
      var pointPainter = Paint()
        ..color = Colors.purple
        ..strokeWidth = 2.0
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(item.x, item.y), 2.0, pointPainter);
    }
  }

  void paintFlipEffect(Canvas canvas,Size size,Path pathA,Path pathB,Path pathC){
    canvas.drawPath(pathC, Paint()..color = pointPaint.color.withOpacity(0.5));
    canvas.drawPath(pathA, pointPaint);
    canvas.drawPath(pathB, bgPaint);
    // //画辅助点
    // drawAuxiliaryPoints(canvas);
    var textPainterA = TextPainter(
      text: TextSpan(
        text: pathAText,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: null,
    );
    textPainterA.layout(maxWidth: screenSize.width * 0.9);
    canvas.save();
    canvas.clipPath(pathA);
    textPainterA.paint(canvas, Offset(screenSize.width * 0.05, topPadding));
    canvas.restore();

    var textPainterB = TextPainter(
      text: TextSpan(
        text: pathBText,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: null,
    );
    textPainterB.layout(maxWidth: screenSize.width * 0.9);
    canvas.save();
    canvas.clipPath(pathB);
    textPainterB.paint(canvas, Offset(screenSize.width * 0.05,topPadding));
    canvas.restore();

    var textPainterC = TextPainter(
      text: TextSpan(
        text: pathAText,
        style: TextStyle(
          color: Colors.black.withOpacity(0.5),
          fontSize: 20,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: null,
    );
    textPainterC.layout(maxWidth: screenSize.width * 0.9);
    canvas.save();
    canvas.clipPath(pathC);
    Matrix4 matrix  = getPathCMatrix4();
    canvas.transform(matrix.storage);
    textPainterC.paint(canvas, Offset(screenSize.width * 0.05,topPadding));
    canvas.restore();
  }



  //翻转、旋转、平移矩阵
  Matrix4 getPathCMatrix4(){
    double eh = sqrt(pow(f.x - e.x, 2) + pow(h.y - f.y, 2));
    double sin0 = (f.x - e.x) / eh;
    double cos0 = (h.y - f.y) / eh;
    //按照书写规则，需要转置
    Matrix4 matrixM1 = Matrix4( //y轴翻转矩阵
      -1, 0,0,0,
      0, 1,0,0,
      0, 0,1,0,
      0, 0,0,1
    ).transposed();

    // 注：α = 2θ，cosα=cos2θ=2cosθcosθ−1，sinα=sin2θ=2sinθcosθ
    Matrix4 matrixR = Matrix4(
        2*pow(cos0,2)-1, 2*sin0*cos0,     0, 0,
        -2*sin0*cos0,    2*pow(cos0,2)-1,   0, 0,
        0,               0,                1, 0,
        0,               0,                0, 1
    ).transposed();

    /*
    * 右下角f点坐标为 (w,h)
      翻转后：F(w,h,1)=(−w,h,1)
      旋转后：R(−w,h,1)=(−w*cosα+h*sinα,w*sinα+h*cosα,1)
      设平移向量为(tx,ty)，需满足(−w*cosα+h*sinα)+tx = x
                              (w*sinα+h*cosα)+ty = y
      解得：tx = x+w*cosα-h*sinα
           ty = y-w*sinα-h*cosα
      注：α = 2θ，cosα=cos2θ=2cosθcosθ−1，sinα=sin2θ=2sinθcosθ
      同理右上角时，f(w,0)
      * w->f.x,h->f.y
     */
    var tx = a.x + f.x*(2*pow(cos0,2)-1) - f.y*(2*sin0*cos0);
    var ty = a.y - f.x*(2*sin0*cos0) - f.y*(2*pow(cos0,2)-1);
    Matrix4 matrixM3 = Matrix4(
      1, 0, 0, tx,
      0, 1, 0, ty,
      0, 0, 1, 0,
      0, 0, 0, 1,
    ).transposed();

    Matrix4 matrixM = matrixM3 * matrixR * matrixM1;
    // Matrix4 matrixM = matrixM3 * matrixM1;

    return matrixM;
  }

  @override
  bool shouldRepaint(covariant FlipPagePainter oldDelegate) {
    return true;
  }

}
