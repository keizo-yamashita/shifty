import 'package:flutter/material.dart';
class FixedTitlesView extends StatefulWidget {
  final double height;
  final double width;
  final double fixedHeight;
  final double fixedWidth;
  final Widget origin;
  final Widget colTitles;
  final Widget rowTitles;
  final Widget body;
  final double scrollBarThicknes;
  final double borederThicknes;
  final Color borderColor;

  const FixedTitlesView({
    Key? key,
    required this.height,
    required this.width,
    required this.fixedHeight,
    required this.fixedWidth,
    required this.origin,
    required this.colTitles,
    required this.rowTitles,
    required this.body,
    this.scrollBarThicknes = 16.0,
    this.borederThicknes = 0.5,
    this.borderColor = Colors.blueGrey,
  }) : super(key: key);

  @override
  _FixedTitlesState createState() => _FixedTitlesState();
}

class _FixedTitlesState extends State<FixedTitlesView> {
  final ScrollController _titleScrollController = ScrollController();
  final ScrollController _dataScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  bool? _scrollOriginTitle;

  @override
  Widget build(BuildContext context) {
    final BorderSide borderStyle = BorderSide(
      color: widget.borderColor,
      width: widget.borederThicknes,
    );

    return Stack(
      alignment: Alignment.topLeft,
      children: [
        Container(
          width: widget.width,
          height: widget.height,
          alignment: Alignment.topLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.origin,
              Container(
                width: widget.width - widget.fixedWidth - widget.borederThicknes * 2,
                height: widget.height - widget.borederThicknes * 2,
                alignment: Alignment.topLeft,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo is ScrollStartNotification) {
                      _scrollOriginTitle ??= true;
                    } else if (_scrollOriginTitle == true) {
                      if (scrollInfo is ScrollUpdateNotification) {
                        _dataScrollController.jumpTo(_titleScrollController.offset);
                      } else if (scrollInfo is ScrollEndNotification) {
                        _scrollOriginTitle = null;
                      }
                    }
                    return true;
                  },
                  child: Scrollbar(
                    controller: _titleScrollController,
                    scrollbarOrientation: ScrollbarOrientation.bottom,
                    thickness: widget.scrollBarThicknes,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _titleScrollController,
                      child: Container(
                        height: widget.height,
                        alignment: Alignment.topLeft,
                        child: widget.colTitles,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: widget.width,
          height: widget.height - widget.scrollBarThicknes,
          alignment: Alignment.topLeft,
          child: Column(
            children: [
              SizedBox(
                width: widget.width,
                height: widget.fixedHeight,
              ),
              SizedBox(
                height: widget.height - widget.fixedHeight - widget.borederThicknes * 2,
                child: Scrollbar(
                  controller: _verticalScrollController,
                  scrollbarOrientation: ScrollbarOrientation.right,
                  thickness: widget.scrollBarThicknes,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    controller: _verticalScrollController,
                    child: Row(
                      children: [
                        SizedBox(
                          width: widget.fixedWidth,
                          child: widget.rowTitles,
                        ),
                        SizedBox(
                          width: widget.width - widget.fixedWidth - widget.borederThicknes * 2,
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification scrollInfo) {
                              if (scrollInfo is ScrollStartNotification) {
                                _scrollOriginTitle ??= false;
                              } else if (_scrollOriginTitle == false) {
                                if (scrollInfo is ScrollUpdateNotification) {
                                  _titleScrollController.jumpTo(_dataScrollController.offset);
                                } else if (scrollInfo is ScrollEndNotification) {
                                  _scrollOriginTitle = null;
                                }
                              }
                              return true;
                            },
                            child: Scrollbar(
                              controller: _dataScrollController,
                              scrollbarOrientation: ScrollbarOrientation.bottom,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                controller: _dataScrollController,
                                child: widget.body,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}