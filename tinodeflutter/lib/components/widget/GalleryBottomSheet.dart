

import 'dart:io';


import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' hide Trans;
import 'package:http_parser/http_parser.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:video_player/video_player.dart';

import '../../Constants/ColorConstants.dart';
import '../../Constants/ImageConstants.dart';
import '../../Constants/utils.dart';
import '../../app_text.dart';
import 'app_button.dart';


class GalleryBottomSheet extends StatefulWidget {
  ScrollController? controller;
  Function(List<Medium>) onTapSend;
  int limitCnt;
  String sendText;
  bool onlyImage;
  GalleryBottomSheet({Key? key, this.controller, required this.onTapSend, this.limitCnt = 10 , this.sendText = "", this.onlyImage = false}) : super(key: key);

  @override
  State<GalleryBottomSheet> createState() => _GalleryBottomSheet();
}

class _GalleryBottomSheet extends State<GalleryBottomSheet> {
  List<Medium> _media = [];
  late Album album;

  late Future albumFuture;

  final gridController = DragSelectGridViewController();
  final Set<int> selectedIndexes = Set<int>();
  final key = GlobalKey();
  int? startTarget;
  bool isStart = false;
  final Set<int> _trackTaped = Set<int>();

  int page = 0;
  bool isLast = false;

  _detectTapedItem(PointerEvent event) {
    if(!isStart || getSelectedCount() >= widget.limitCnt)
      return;
    final RenderBox box = key.currentContext!.findRenderObject()! as RenderBox;
    final result = BoxHitTestResult();
    Offset local = box.globalToLocal(event.position);
    if (box.hitTest(result, position: local)) {
      for (final hit in result.path) {
        /// temporary variable so that the [is] allows access of [index]
        final target = hit.target;
        print(target);
        if (target is _MediaItem) {
          if(_trackTaped.isNotEmpty && _trackTaped.first != target.index! && _trackTaped.last != target.index!)
          if(startTarget == null){
            startTarget = target.index!;
          }
          _trackTaped.clear();
          if(startTarget! < target.index!) {
            for(int i=startTarget!;i<=target.index!;i++){
              if(!selectedIndexes.contains(i)){
                if(getSelectedCount() < widget.limitCnt){
                  _trackTaped.add(i);
                }else{
                  break;
                }
              }
            }
          }else if(startTarget! > target.index!){
            for(int i=target.index!;i<=startTarget!;i++){
              if(!selectedIndexes.contains(i)){
                if(getSelectedCount() < widget.limitCnt){
                  _trackTaped.add(i);
                }else{
                  break;
                }
              }
            }
          }else{
            _trackTaped.add(target.index!);
          }
          _selectIndex();
        }
      }
    }
  }

  _selectIndex() {
    setState(() {

    });
  }

  int getSelectedCount(){
    Set<int> tempSet = Set<int>();
    tempSet.addAll(selectedIndexes);
    tempSet.addAll(_trackTaped);
    return tempSet.length;
  }

  void _clearSelection(PointerUpEvent event) {
    selectedIndexes.addAll(_trackTaped);
    _trackTaped.clear();
    setState(() {
      isStart = false;
      startTarget = null;
    });
  }



  @override
  void initState() {
    albumFuture = initAsync();
    super.initState();
    gridController.addListener(scheduleRebuild);
    widget.controller?.addListener(getNextPhotos);
  }

  @override
  void dispose() {
    gridController.removeListener(scheduleRebuild);
    widget.controller?.removeListener(getNextPhotos);
    super.dispose();
  }

  void scheduleRebuild() => setState(() {});

  Future<List<Medium>> initAsync() async {
    List<Album> albums = await PhotoGallery.listAlbums();
    int maxAlbumCnt = 0;
    int maxAlbumindex = 0;
    for(int i=0;i<albums.length;i++){
      if(albums[i].count > maxAlbumCnt){
        maxAlbumindex = i;
        maxAlbumCnt = albums[i].count;
      }
    }
    album = albums[maxAlbumindex];
    MediaPage mediaPage = await album.listMedia(
      take: 30
    );
    isLast = mediaPage.isLast;
    page = 1;
    if(widget.onlyImage) {
      for (int i = 0; i < mediaPage.items.length; i++) {
        if(mediaPage.items[i].mediumType == MediumType.image){
          _media.add(mediaPage.items[i]);
        }
      }
    }else {
      _media.addAll(mediaPage.items);
    }
    return _media;
  }
  int skipNum=30;
  int takeNumb=30;

  bool isLoading = false;

  Future<void> getNextPhotos() async {
    if(!isLoading && (widget.controller?.position.extentAfter ?? 201) < 200) {
      isLoading = true;
      MediaPage mediaPage = await album.listMedia(skip: skipNum * page,take: takeNumb);
      
      // if(widget.onlyImage && mediaPage.items.length<20)
      // {
      //   skipNum=500;
      //   takeNumb=500;
      //     mediaPage = await album.listMedia(
      //     skip: skipNum * page,
      //     take: takeNumb
      // );
      // }

      page += 1;
      setState(() {
        if(widget.onlyImage) {
          int count=0;
          print("widget only image ");
          for (int i = 0; i < mediaPage.items.length; i++) {
            if(mediaPage.items[i].mediumType == MediumType.image){
              print("medium type image   $i : ${mediaPage.items[i].filename}");
              _media.add(mediaPage.items[i]);
              count++;
            }
          }
          print("count : $count");
        }else {
          _media.addAll(mediaPage.items);
        }
      });
      isLast = mediaPage.isLast;
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: Get.height*0.9
      ),
      decoration: BoxDecoration(
          color: ColorConstants.colorBg1,
          borderRadius: BorderRadius.only(topRight: Radius.circular(24), topLeft: Radius.circular(24))
      ),
      child: Stack(
        children: [

          Container(
            width: double.maxFinite,
              height: double.maxFinite,
              child: FutureBuilder(
                future: albumFuture,
                builder: (context, snapshot){
                  if(snapshot.hasData) {
                    return Container(
                        child: Listener(
                          onPointerDown: _detectTapedItem,
                          onPointerMove: _detectTapedItem,
                          onPointerUp: _clearSelection,
                          child: GridView.builder(
                              controller: widget.controller,
                              key: key,
                              padding: EdgeInsets.only(left: 15, right: 15, top: 40, bottom: 90),
                              physics: isStart ? NeverScrollableScrollPhysics() : null,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1.0,
                                crossAxisSpacing: 5.0,
                                mainAxisSpacing: 5.0,
                              ),
                              itemCount: _media.length,
                              itemBuilder: (context, index) {
                                return MediaItem(
                                  index: index,
                                  child: GestureDetector(
                                    onTap: () {
                                      if(selectedIndexes.contains(index)){
                                        selectedIndexes.remove(index);
                                      }else{
                                        if(selectedIndexes.length < widget.limitCnt){
                                          selectedIndexes.add(index);
                                        }
                                      }
                                    },
                                    onLongPressStart: (details){
                                      setState(() {
                                        isStart = true;
                                        startTarget = index;
                                      });
                                    },
                                    child: Container(
                                        color: Colors.grey,
                                        child: Stack(
                                          children: [
                                            Center(
                                                child: Container(
                                                  width: double.maxFinite,
                                                  height: double.maxFinite,
                                                  child: FadeInImage(
                                                    fit: BoxFit.cover,
                                                    placeholder: MemoryImage(kTransparentImage),
                                                    image: ThumbnailProvider(
                                                      mediumId: _media[index].id,
                                                      mediumType:_media[index].mediumType,
                                                      highQuality: true,
                                                    ),
                                                  ),
                                                )
                                            ),

                                            Positioned(
                                                top: 5,
                                                left: 5,
                                                child: InkWell(
                                                  onTap: (){
                                                    if(selectedIndexes.contains(index)){
                                                      selectedIndexes.remove(index);
                                                    }else{
                                                      if(selectedIndexes.length < widget.limitCnt){
                                                        selectedIndexes.add(index);
                                                      }
                                                    }
                                                  },
                                                  child: Image.asset( selectedIndexes.contains(index) || _trackTaped.contains(index) ? ImageConstants.imageChecked : ImageConstants.imageUnChecked, width: 32, height: 32,),
                                                )
                                            ),

                                            if(_media[index].mediumType == MediumType.video)
                                              Positioned(
                                                  bottom: 5,
                                                  right: 5,
                                                  child: AppText(
                                                    text: Utils.getIntToStringTime(_media[index].duration),
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                  )
                                              )
                                          ],
                                        )
                                    ),
                                  ),
                                );
                              }
                          ),
                        )
                    );
                  }

                  return  Center(
                    child: SizedBox(
                      child: Center(
                          child: CircularProgressIndicator(
                              color: ColorConstants.colorMain)
                      ),
                      height: 10.0,
                      width: 10.0,
                    ),
                  );
                },
              )
          ),

          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  width: double.maxFinite,
                  height: 40,
                  decoration: BoxDecoration(
                      color: ColorConstants.colorSub,
                      borderRadius: BorderRadius.only(topRight: Radius.circular(24), topLeft: Radius.circular(24))
                  ),
                  child: Center(
                      child: IgnorePointer(
                        child: Container(
                          width: 48,
                          height: 6,
                          decoration: BoxDecoration(
                              color: Color(0xffd9d9d9),
                              borderRadius: BorderRadius.circular(4)
                          ),
                        ),
                      )
                  ),
                ),
              )
          ),

          Positioned(
            bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 90,
                width: double.maxFinite,
                  color: ColorConstants.colorSub,
                child: Center(
                  child: AppButton(
                      text: widget.sendText.isEmpty ? "send_image".tr(args: ["${getSelectedCount()}"]) : widget.sendText,
                      disabled: getSelectedCount() == 0,
                      onTap: (){
                        List<Medium> results = [];
                        for(int i=0;i<selectedIndexes.length;i++){
                          results.add(_media[selectedIndexes.elementAt(i)]);
                        }
                        Get.back();
                        widget.onTapSend(results);
                      }
                  ),
                )
              )
          )

        ],
      )
    );
  }
}

class MediaItem extends SingleChildRenderObjectWidget {
  final int index;

  MediaItem({Widget? child, required this.index, Key? key}) : super(child: child, key: key);

  @override
  _MediaItem createRenderObject(BuildContext context) {
    return _MediaItem()..index = index;
  }

  @override
  void updateRenderObject(BuildContext context, _MediaItem renderObject) {
    renderObject..index = index;
  }
}

class _MediaItem extends RenderProxyBox {
  int? index;
}

class ViewerPage extends StatelessWidget {
  final Medium medium;

  ViewerPage(Medium medium) : medium = medium;

  @override
  Widget build(BuildContext context) {
    DateTime? date = medium.creationDate ?? medium.modifiedDate;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_ios),
          ),
          title: date != null ? Text(date.toLocal().toString()) : null,
        ),
        body: Container(
          alignment: Alignment.center,
          child: medium.mediumType == MediumType.image
              ? GestureDetector(
            onTap: () async {
              PhotoGallery.deleteMedium(mediumId: medium.id);
            },
            child: FadeInImage(
              fit: BoxFit.cover,
              placeholder: MemoryImage(kTransparentImage),
              image: PhotoProvider(mediumId: medium.id),
            ),
          )
              : VideoProvider(
            mediumId: medium.id,
          ),
        ),
      ),
    );
  }
}

class VideoProvider extends StatefulWidget {
  final String mediumId;

  const VideoProvider({
    required this.mediumId,
  });

  @override
  _VideoProviderState createState() => _VideoProviderState();
}

class _VideoProviderState extends State<VideoProvider> {
  VideoPlayerController? _controller;
  File? _file;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initAsync();
    });
    super.initState();
  }

  Future<void> initAsync() async {
    try {
      _file = await PhotoGallery.getFile(mediumId: widget.mediumId);
      _controller = VideoPlayerController.file(_file!);
      _controller?.initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    } catch (e) {
      print("Failed : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _controller == null || !_controller!.value.isInitialized
        ? Container()
        : Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
            });
          },
          child: Icon(
            _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ],
    );
  }
}
