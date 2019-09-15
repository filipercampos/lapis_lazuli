import 'package:flutter/material.dart';
import 'package:lapis_lazuli/blocs/route_bloc.dart';
import 'package:lapis_lazuli/model/praca_pedagio.dart';
import 'package:lapis_lazuli/widgets/praca_tile.dart';

// ignore: must_be_immutable
class BottomWidget extends StatefulWidget {
  final double fullSizeHeight;
  final List<PracaPedagio> pracas;
  BottomWidgetState bottom;
  RouteBloc bloc;
  BottomWidget({
    @required this.pracas,
    @required this.fullSizeHeight,
    @required this.bloc,
  });

  @override
  BottomWidgetState createState() => BottomWidgetState();
}

class BottomWidgetState extends State<BottomWidget> {
  //start drag position of widget's gesture detector
  Offset startPosition;

  //offset from startPosition within drag event of widget's gesture detector
  double dyOffset;

  //boundaries for height of widget (bottom sheet)
  List<double> heights;

  //current height of widget (bottom sheet)
  double height;

  //ScrollController for inner ListView
  ScrollController innerListScrollController;

  //is user scrolling down inner ListView
  bool isInnerScrollDoingDown;

  List<PracaPedagio> pracas;

  final double defaultHeight = 300.0;

  @override
  void initState() {
    super.initState();
    const _persistantBottomSheetHeaderHeight = 50.0;
    heights = [
      _persistantBottomSheetHeaderHeight,
      widget.fullSizeHeight / 2,
      widget.fullSizeHeight
    ];
    height = heights[0];

    //initialize inner list's scroll controller and listen to its changes
    innerListScrollController = ScrollController();
    innerListScrollController.addListener(_scrollOffsetChanged);
    isInnerScrollDoingDown = false;

    dyOffset = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    //GestureDetector can catch drag events only if inner ListView isn't scrollable (only if _getScrollEnabled() returns false)
    return GestureDetector(
      onVerticalDragUpdate: (DragUpdateDetails dragDetails) {
        dyOffset += dragDetails.delta.dy;
      },
      onVerticalDragStart: (DragStartDetails dragDetails) {
        startPosition = dragDetails.globalPosition;
        dyOffset = 0;
      },
      onVerticalDragEnd: (DragEndDetails dragDetails) => _changeHeight(),
      child: StreamBuilder<bool>(
        stream: widget.bloc.outShow,
        builder: (context, snapshot) {
          return Container(
            height: snapshot.hasData && snapshot.data ? defaultHeight : height,
            color: Colors.transparent,
            child: InnerList(
              bloc: widget.bloc,
              pracas: widget.pracas,
              scrollEnabled: _getInnerScrollEnabled(),
              listViewScrollController: innerListScrollController,
            ),
          );
        }
      ),
    );
  }


  //returns if inner ListView scroll is enabled
  //true if:
  // 1) container's height is height of entire screen
  // 2) inner ListView has not been scrolled down from first element
  bool _getInnerScrollEnabled() {
    bool isFullSize = heights.last == height;
    bool isScrollZeroOffset = innerListScrollController.hasClients
        ? innerListScrollController.offset == 0.0 && isInnerScrollDoingDown
        : false;
    bool result = isFullSize && !isScrollZeroOffset;

    //reset isInnerScrollDoingDown
    if (!result ) isInnerScrollDoingDown = false;

    return result;
  }

  void _scrollOffsetChanged() {
    if (innerListScrollController.offset < 0.0) {
      isInnerScrollDoingDown = true;
    } else if (innerListScrollController.offset > 0.0) {
      isInnerScrollDoingDown = false;
    }

    if (innerListScrollController.offset <= 0.0) {
      setState(() {});
    }
  }

  void _changeHeight() {
    if (dyOffset < 0) {
      widget.bloc.scrollable();
      setState(() {
        int curIndex = heights.indexOf(height);
        int newIndex = curIndex + 1;
        height =
            newIndex >= heights.length ? heights[curIndex] : heights[newIndex];
      });
    } else if (dyOffset > 0) {
      setState(() {
        widget.bloc.scrollable();
        int curIndex = heights.indexOf(height);
        int newIndex = curIndex - 1;
        height = newIndex < 0 ? heights[curIndex] : heights[newIndex];
      });
    }
  }

  @override
  void dispose() {
    innerListScrollController.removeListener(_scrollOffsetChanged);

    super.dispose();
  }
}

class InnerList extends StatelessWidget {
  final bool scrollEnabled;
  final ScrollController listViewScrollController;
  final List<PracaPedagio> pracas;
  final RouteBloc bloc;

  InnerList(
      {@required this.pracas,
      @required this.scrollEnabled,
      @required this.listViewScrollController, this.bloc });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 10,
          margin: EdgeInsets.only(top: 8),
          color: Colors.transparent,
          child: Container(
            height: 2,
            width: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black,
                  Colors.black54,
                  Colors.black,
                ],
              ),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Pedágios",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Expanded(
          child:
          pracas.length > 0 ?
          ListView.builder(
            itemCount: pracas.length,
            controller: listViewScrollController,
            physics: scrollEnabled
                ? AlwaysScrollableScrollPhysics()
                : NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return PracaTile(pracas[index]);
            },
          ): Center(child:Text("Nenhum pedágio(s)")),
        )
      ],
    );
  }
}
