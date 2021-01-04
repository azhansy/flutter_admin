import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_admin/common/cry_root.dart';
import 'package:flutter_admin/common/routes.dart';
import 'package:flutter_admin/enum/MenuDisplayType.dart';
import 'package:flutter_admin/pages/common/page_404.dart';
import 'package:flutter_admin/pages/layout/layout_app_bar.dart';
import 'package:flutter_admin/models/menu.dart';
import 'package:flutter_admin/pages/layout/layout_menu.dart';
import 'package:flutter_admin/pages/layout/layout_setting.dart';
import 'package:flutter_admin/utils/store_util.dart';
import 'package:flutter_admin/utils/utils.dart';

class Layout extends StatefulWidget {
  @override
  _LayoutState createState() => _LayoutState();
}

class _LayoutState extends State with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldStateKey = GlobalKey<ScaffoldState>();
  List<Menu> menuOpened = [];
  TabController tabController;
  Container content = Container();
  int length = 0;

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: length);
    init();
  }

  init() async {
    if (!StoreUtil.instance.inited) {
      await StoreUtil.instance.init();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!StoreUtil.instance.inited) {
      return Container();
    }

    var configuration = CryRootScope.of(context).state.configuration;
    Color themeColor = configuration.themeColor;
    TabBar tabBar = TabBar(
      onTap: (index) => _openPage(menuOpened[index]),
      controller: tabController,
      isScrollable: true,
      indicator: const UnderlineTabIndicator(),
      tabs: menuOpened.map<Tab>((Menu menu) {
        return Tab(
          child: Row(
            children: <Widget>[
              Text(Utils.isLocalEn(context) ? menu.nameEn ?? '' : menu.name ?? ''),
              SizedBox(width: 3),
              InkWell(
                child: Icon(Icons.close, size: 10),
                onTap: () => _closePage(menu),
              ),
            ],
          ),
        );
      }).toList(),
    );

    var layoutMenu = LayoutMenu(onClick: _openPage);
    Row body = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        configuration.menuDisplayType == MenuDisplayType.side ? layoutMenu : Container(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: tabBar,
                      decoration: BoxDecoration(
                        color: themeColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black54,
                            offset: Offset(2.0, 2.0),
                            blurRadius: 4.0,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              content,
            ],
          ),
        ),
      ],
    );
    Scaffold subWidget = Scaffold(
      key: scaffoldStateKey,
      drawer: layoutMenu,
      endDrawer: LayoutSetting(),
      body: body,
      appBar: LayoutAppBar(
        context,
        type: 2,
        openMenu: () {
          scaffoldStateKey.currentState.openDrawer();
        },
        openSetting: () {
          scaffoldStateKey.currentState.openEndDrawer();
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.settings),
      //   onPressed: () {
      //     scaffoldStateKey.currentState.openEndDrawer();
      //   },
      // ),
    );
    return Theme(
      data: ThemeData(
        primaryColor: themeColor,
        iconTheme: IconThemeData(color: themeColor),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: themeColor,
        ),
        buttonTheme: ButtonThemeData(buttonColor: themeColor),
      ),
      child: subWidget,
    );
  }

  _closePage(menu) {
    menuOpened.remove(menu);
    --length;
    tabController = TabController(vsync: this, length: length);
    var openPage;
    if (length > 0) {
      tabController.index = length - 1;
      openPage = menuOpened[0];
    }
    _openPage(openPage);
    setState(() {});
  }

  _openPage(Menu menu) {
    if (menu == null) {
      content = Container();
      return;
    }
    Widget body = menu.url != null && layoutRoutesData[menu.url] != null ? layoutRoutesData[menu.url] : Page404();
    content = Container(
      child: Expanded(
        child: body,
      ),
    );

    int index = menuOpened.indexWhere((note) => note.id == menu.id);
    if (index > -1) {
      tabController.index = index;
    } else {
      menuOpened.add(menu);
      tabController = TabController(vsync: this, length: ++length);
      tabController.index = length - 1;
    }
    setState(() {});
  }
}