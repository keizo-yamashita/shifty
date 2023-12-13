import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;


class TwoDimensionalGridView extends TwoDimensionalScrollView {
  const TwoDimensionalGridView({
    super.key,
    super.primary,
    super.mainAxis = Axis.horizontal,
    super.verticalDetails = const ScrollableDetails.vertical(),
    super.horizontalDetails = const ScrollableDetails.horizontal(),
    required TwoDimensionalChildBuilderDelegate delegate,
    required this.firstColumnWidth,
    required this.otherColumnWidth,
    required this.firstRowHeight,
    required this.otherRowHeight,
    super.cacheExtent,
    super.diagonalDragBehavior = DiagonalDragBehavior.none,
    super.dragStartBehavior = DragStartBehavior.start,
    super.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    super.clipBehavior = Clip.hardEdge,
  }) : super(delegate: delegate);

  final double firstColumnWidth;
  final double otherColumnWidth;
  final double firstRowHeight;
  final double otherRowHeight;

  @override
  Widget buildViewport(
    BuildContext context,
    ViewportOffset verticalOffset,
    ViewportOffset horizontalOffset,
  ) {
    return TwoDimensionalGridViewport(
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalDetails.direction,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalDetails.direction,
      mainAxis: mainAxis,
      delegate: delegate as TwoDimensionalChildBuilderDelegate,
      firstColumnWidth: firstColumnWidth,
      otherColumnWidth: otherColumnWidth,
      firstRowHeight: firstRowHeight,
      otherRowHeight: otherRowHeight,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
    );
  }
}

class TwoDimensionalGridViewport extends TwoDimensionalViewport {
  const TwoDimensionalGridViewport({
    super.key,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required TwoDimensionalChildBuilderDelegate super.delegate,
    required super.mainAxis,
    required this.firstColumnWidth,
    required this.otherColumnWidth,
    required this.firstRowHeight,
    required this.otherRowHeight,
    super.cacheExtent,
    super.clipBehavior = Clip.hardEdge,
  });

  final double firstColumnWidth;
  final double otherColumnWidth;
  final double firstRowHeight;
  final double otherRowHeight;

  @override
  RenderTwoDimensionalViewport createRenderObject(BuildContext context) {
    return RenderTwoDimensionalGridViewport(
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalAxisDirection,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalAxisDirection,
      mainAxis: mainAxis,
      delegate: delegate as TwoDimensionalChildBuilderDelegate,
      childManager: context as TwoDimensionalChildManager,
      firstColumnWidth: firstColumnWidth,
      otherColumnWidth: otherColumnWidth,
      firstRowHeight: firstRowHeight,
      otherRowHeight: otherRowHeight,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTwoDimensionalGridViewport renderObject,
  ) {
    renderObject
      ..horizontalOffset = horizontalOffset
      ..horizontalAxisDirection = horizontalAxisDirection
      ..verticalOffset = verticalOffset
      ..verticalAxisDirection = verticalAxisDirection
      ..mainAxis = mainAxis
      ..delegate = delegate
      ..cacheExtent = cacheExtent
      ..clipBehavior = clipBehavior;
  }
}

class RenderTwoDimensionalGridViewport extends RenderTwoDimensionalViewport {
  RenderTwoDimensionalGridViewport({
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required TwoDimensionalChildBuilderDelegate delegate,
    required super.mainAxis,
    required super.childManager,
    required this.firstColumnWidth,
    required this.otherColumnWidth,
    required this.firstRowHeight,
    required this.otherRowHeight,
    super.cacheExtent,
    super.clipBehavior = Clip.hardEdge,
  }) : super(delegate: delegate);

  final double firstColumnWidth;
  final double otherColumnWidth;
  final double firstRowHeight;
  final double otherRowHeight;

  @override
  void layoutChildSequence() {
    final double horizontalPixels = horizontalOffset.pixels;
    final double verticalPixels   = verticalOffset.pixels;
    final double viewportWidth    = viewportDimension.width + cacheExtent;
    final double viewportHeight   = viewportDimension.height + cacheExtent;
    final TwoDimensionalChildBuilderDelegate builderDelegate = delegate as TwoDimensionalChildBuilderDelegate;

    final int maxRowIndex    = builderDelegate.maxYIndex!;
    final int maxColumnIndex = builderDelegate.maxXIndex!;

    final int leadingColumn  = math.max(((horizontalPixels+otherColumnWidth-firstColumnWidth) / otherColumnWidth).floor(), 0);
    final int leadingRow     = math.max(((verticalPixels+otherRowHeight-firstRowHeight) / otherRowHeight).floor(), 0);
    final int trailingColumn = math.min(((horizontalPixels + viewportWidth) / otherColumnWidth).ceil(), maxColumnIndex);
    final int trailingRow    = math.min(((verticalPixels + viewportHeight) / otherRowHeight).ceil(), maxRowIndex);

    double xLayoutOffset = (leadingColumn == 0 ? 0 : (firstColumnWidth + (leadingColumn - 1) * otherColumnWidth)) - horizontalOffset.pixels;
    
    for (int column = leadingColumn; column <= trailingColumn; column++) {
      double yLayoutOffset = (leadingRow == 0 ? 0 : (firstRowHeight + (leadingRow - 1) * otherRowHeight)) - verticalOffset.pixels;

      for (int row = leadingRow; row <= trailingRow; row++) {
        final ChildVicinity vicinity = ChildVicinity(xIndex: column, yIndex: row);
        final RenderBox child = buildOrObtainChildFor(vicinity)!;
        child.layout(constraints.loosen());

        // Subclasses only need to set the normalized layout offset. The super
        // class adjusts for reversed axes.
        parentDataOf(child).layoutOffset = Offset(xLayoutOffset, yLayoutOffset);
        if(row == 0) {
          yLayoutOffset += firstRowHeight;
        } else {
          yLayoutOffset += otherRowHeight;
        }
      }
      if(column == 0) {
        xLayoutOffset += firstColumnWidth;
      } else {
        xLayoutOffset += otherColumnWidth;
      }
    }

    // Set the min and max scroll extents for each axis.
    final double verticalExtent = otherRowHeight * (maxRowIndex + 1) + (firstRowHeight-otherRowHeight)*2;
    verticalOffset.applyContentDimensions(
      0.0,
      clampDouble(
        verticalExtent - viewportDimension.height, 1.0, double.infinity),
    );
    final double horizontalExtent = otherColumnWidth * (maxColumnIndex + 1) + (firstColumnWidth-otherColumnWidth)*2;
    horizontalOffset.applyContentDimensions(
      0.0,
      clampDouble(
        horizontalExtent - viewportDimension.width, 1.0, double.infinity),
    );
    // Super class handles garbage collection too!
  }
}
