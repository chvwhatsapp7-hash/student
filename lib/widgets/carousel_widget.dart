import 'package:flutter/material.dart';

class CarouselWidget extends StatefulWidget {
  final List<Widget> items;
  final Axis scrollDirection;
  final double viewportFraction;
  final bool enableInfiniteScroll;
  final double spacing;

  const CarouselWidget({
    super.key,
    required this.items,
    this.scrollDirection = Axis.horizontal,
    this.viewportFraction = 1.0,
    this.enableInfiniteScroll = false,
    this.spacing = 8.0,
  });

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: widget.viewportFraction,
    );
  }

  void _scrollNext() {
    if (_currentPage < widget.items.length - 1) {
      _currentPage++;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (widget.enableInfiniteScroll) {
      _currentPage = 0;
      _pageController.jumpToPage(_currentPage);
    }
  }

  void _scrollPrev() {
    if (_currentPage > 0) {
      _currentPage--;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (widget.enableInfiniteScroll) {
      _currentPage = widget.items.length - 1;
      _pageController.jumpToPage(_currentPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHorizontal = widget.scrollDirection == Axis.horizontal;

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          scrollDirection: widget.scrollDirection,
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(
                left: isHorizontal ? widget.spacing / 2 : 0,
                right: isHorizontal ? widget.spacing / 2 : 0,
                top: isHorizontal ? 0 : widget.spacing / 2,
                bottom: isHorizontal ? 0 : widget.spacing / 2,
              ),
              child: widget.items[index],
            );
          },
          onPageChanged: (index) {
            setState(() => _currentPage = index);
          },
        ),
        // Previous Button
        Positioned(
          left: isHorizontal ? 0 : null,
          top: isHorizontal ? null : 0,
          bottom: isHorizontal ? null : 0,
          child: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _scrollPrev,
            tooltip: 'Previous Slide',
          ),
        ),
        // Next Button
        Positioned(
          right: isHorizontal ? 0 : null,
          bottom: isHorizontal ? null : 0,
          top: isHorizontal ? null : 0,
          child: IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _scrollNext,
            tooltip: 'Next Slide',
          ),
        ),
      ],
    );
  }
}
