import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:auto_size_text/auto_size_text.dart';

/*
 * Will be used for reuse of carousel component throughout pages.
 * Cleans up code substantially by reducing file size across the board.
 * Will be fed a List and BuildContext
 */

class Carousel extends StatefulWidget {
  final BuildContext context;
  final List list;
  Carousel({Key key, @required this.list, @required this.context})
      : super(key: key);

  @override
  _CarouselState createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  int _current = 0;

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  Widget build(BuildContext context) {
    return widget.list.length == 0
        ? Center(
            child: Text("No items to display."),
          )
        : Column(
            children: <Widget>[
              CarouselSlider(
                viewportFraction: 0.8,
                enlargeCenterPage: true,
                enableInfiniteScroll: widget.list.length > 1 ? true : false,
                onPageChanged: (index) {
                  setState(() {
                    _current = index;
                  });
                },
                items: widget.list.map((recipe) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: CupertinoColors.extraLightBackgroundGray,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            recipe is String ? recipe : recipe["imageURL"],
                            fit: BoxFit.fill,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent loadingProgress) {
                              if (loadingProgress == null)
                                return Stack(
                                  fit: StackFit.expand,
                                  children: <Widget>[
                                    child,
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        height: 55,
                                        padding: EdgeInsets.only(
                                          top: 10,
                                          bottom: 10,
                                          left: 10,
                                          right: 10,
                                        ),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: CupertinoColors
                                              .extraLightBackgroundGray,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Expanded(
                                              child: AutoSizeText(
                                                recipe is String
                                                    ? "Recipe Title"
                                                    : recipe["title"],
                                                softWrap: true,
                                                maxLines: 2,
                                                minFontSize: 14,
                                                style: TextStyle(
                                                  color: CupertinoColors.black,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Icon(
                                              CupertinoIcons.heart,
                                              color: CupertinoColors.systemRed,
                                              size: 30,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              return Center(
                                child: CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                    Color(0xfff79c4f),
                                  ),
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: map<Widget>(
                  widget.list,
                  (index, url) {
                    return Container(
                      width: 10.0,
                      height: 10.0,
                      margin:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _current == index
                            ? Color(0xfff79c4f)
                            : CupertinoColors.lightBackgroundGray,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
  }
}
