import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class RestaurantsListView extends StatefulWidget {
  const RestaurantsListView({Key? key, this.callBack}) : super(key: key);

  final Function()? callBack;

  @override
  _RestaurantsListViewState createState() => _RestaurantsListViewState();
}

class _RestaurantsListViewState extends State<RestaurantsListView>
    with TickerProviderStateMixin {
  AnimationController? animationController;

   final Stream<QuerySnapshot> _restStream=FirebaseFirestore.instance
      .collection('restaurant')
      .where('status_active', isEqualTo: 1)
      .orderBy('rate', descending: true)
      .snapshots();



  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);





    super.initState();
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: StreamBuilder<QuerySnapshot>(
        stream: _restStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    child: const CircularProgressIndicator(),
                  ),
                ],
              ),
            );
          } else {
            return GridView(
              padding: const EdgeInsets.all(4),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              children: List<Widget>.generate(
                snapshot.data!.docs.length,
                (int index) {
                  final int count = snapshot.data!.docs.length;
                  final Animation<double> animation =
                      Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animationController!,
                      curve: Interval((1 / count) * index, 1.0,
                          curve: Curves.fastOutSlowIn),
                    ),
                  );
                  animationController?.forward();
                  return RestaurantView(
                    callback: widget.callBack,
                    docShot: snapshot.data!.docs[index],
                    animation: animation,
                    animationController: animationController,
                  );
                },
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 18.0,
                crossAxisSpacing: 18.0,
                childAspectRatio: 0.9,
              ),
            );
          }
        },
      ),
    );
  }
}

class RestaurantView extends StatelessWidget {
  const RestaurantView(
      {Key? key,
      required this.docShot,
      this.animationController,
      this.animation,
      this.callback})
      : super(key: key);

  final VoidCallback? callback;
  final DocumentSnapshot docShot;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 50 * (1.0 - animation!.value), 0.0),
            child: InkWell(
              splashColor: Colors.transparent,
              // onTap: callback,
              onTap: () {},
              child: SizedBox(
                height: 115,
                child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          width: 170,
                          height: (MediaQuery.of(context).size.height / 4.95),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(35),
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                docShot['photo_url'],
                              ),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.25),
                                  BlendMode.srcOver),
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.amber
                                      .withOpacity(0.1),
                                  offset: const Offset(1, 1),
                                  blurRadius: 4.0),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(right: 6, left: 6, bottom: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Colors.transparent
                                    .withOpacity(0.3),
                                offset: const Offset(0.0, 0.0),
                                blurRadius: 0.0),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: AspectRatio(
                            aspectRatio: 1.6,
                            child: Center(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Text(
                                    docShot['rest_name'],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'WorkSans',
                                      fontSize: 15.5,
                                      letterSpacing: 0.27,
                                      color: Colors.white,
                                    ),
                                  ),
                                  RatingBar.builder(
                                    initialRating: docShot['rate'],
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemSize: 19,
                                    ignoreGestures: true,
                                    unratedColor: Colors.white,
                                    itemPadding: const EdgeInsets.symmetric(
                                        horizontal: 0.5),
                                    itemBuilder: (context, _) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (rating) {
                                      // print(rating);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  getStorageUrlStringProfilePic() async {
    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref()
        .child(docShot["photo_url"])
        .getDownloadURL();
    return downloadURL;
  }
}
