import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fast_image_resizer/fast_image_resizer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:path_provider/path_provider.dart';

import '../app_text.dart';
import 'ColorConstants.dart';
import 'ImageConstants.dart';

// 이미지 WIDGET 유틸
class ImageUtils {

  // 프로필 이미지 위젯
  static Widget CommunityProfileImage(String src, double width, double height) {
    if (src.isEmpty) {
      return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(width/2),
              border: Border.all(color: ColorConstants.textGry, width: 1)
          ),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(width/2),
              child: Image.asset(ImageConstants.communityBasicProfile, width: width, height: height,)
          )
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width/2),
        border: Border.all(color: ColorConstants.textGry, width: 1)
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width/2),
        child: CachedNetworkImage(
            imageUrl: "${src}",
            errorWidget: (context, url, error) =>
                Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                      color: Color(0xffd0cdcd),
                      borderRadius: BorderRadius.circular(width/2)
                  ),
                ),
            // cacheKey: src + Constants.cachingKey,
            width: width,
            height: height,
            fit: BoxFit.fill),
      ),
    );
  }

  static Widget ProfileImage(String src, double width, double height) {
    if (src.isEmpty) {
      return Container(
        width: width,
          height: height,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(width/2),
              border: Border.all(color: ColorConstants.textGry, width: 1)
          ),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(width/2),
              child: Image.asset(ImageConstants.userProfile, width: width, height: height,)
          )
      );
    }

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(width/2),
          border: Border.all(color: ColorConstants.textGry, width: 1)
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width/2),
        child: CachedNetworkImage(
            imageUrl: "${src}",
            errorWidget: (context, url, error) =>
                Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                      color: Color(0xffd0cdcd),
                      borderRadius: BorderRadius.circular(width/2)
                  ),
                ),
            // cacheKey: src + Constants.cachingKey,
            width: width,
            height: height,
            fit: BoxFit.cover),
      ),
    );
  }

  //프로파일 이미지 샘플
  static Widget ProfileSampleImage(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          color: Color(0xffd0cdcd),
          borderRadius: BorderRadius.circular(width/2)
      ),
    );
  }

  static Widget ProfileImageFile(File? file, double width, double height) {
    return file != null ? ClipRRect(
      borderRadius: BorderRadius.circular(width/2),
      child: Image.file(
          file,
          width: width,
          height: height,
          fit: BoxFit.cover),
    ) : ImageUtils.ProfileSampleImage(width, height);
  }

  // 네트워크 이미지 위젯
  static Widget setPostNetworkImage(String src, String content, double width, double height) {
    if(src.isEmpty){
      return Container(
          width: width,
          height: height,
          padding: EdgeInsets.only(left: 10,right: 10),
          decoration: BoxDecoration(
              color: ColorConstants.white5Percent,
              borderRadius: BorderRadius.circular(8)
          ),
          child: Center(
            child: AppText(
                text: content,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w400,
                maxLine: 4,
                fontSize: 13
            ),
          )
      );
    }
    return CachedNetworkImage(
        imageUrl: "${src}",
        placeholder: (context, url) => SizedBox(
          child: Center(
              child: CircularProgressIndicator(color: ColorConstants.colorMain,)
          ),
          height: 20.0,
          width: 20.0,
        ),
        errorWidget: (context, url, error) =>
            Container(
              width: width,
              height: height,
              padding: EdgeInsets.only(left: 10,right: 10),
              decoration: BoxDecoration(
                  color: ColorConstants.white5Percent,
                  borderRadius: BorderRadius.circular(8)
              ),
              child: Center(
                child: AppText(
                  text: content,
                  textAlign: TextAlign.center,
                    fontWeight: FontWeight.w400,
                    fontSize: 13
                ),
              )
            ),
        width: width,
        height: height,
        fit: BoxFit.cover);
  }

  static Widget setGameListNetworkImage(String src) {
    if(src.isEmpty){
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
              color: ColorConstants.white5Percent,
              borderRadius: BorderRadius.circular(8)
          ),
        ),
      );
    }
    return AspectRatio(
        aspectRatio: 1,
      child: CachedNetworkImage(
          imageUrl: "${src}",
          placeholder: (context, url) => SizedBox(
            child: Center(
                child: CircularProgressIndicator(color: ColorConstants.colorMain,)
            ),
            height: 20.0,
            width: 20.0,
          ),
          errorWidget: (context, url, error) =>
              Container(
                  decoration: BoxDecoration(
                      color: ColorConstants.white5Percent,
                      borderRadius: BorderRadius.circular(8)
                  ),
              ),
          fit: BoxFit.cover),
    );
  }

  static Widget setGameListSmallNetworkImage(String src) {
    if(src.isEmpty){
      return AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          child: Container(
          decoration: BoxDecoration(
              color: ColorConstants.white5Percent,
              borderRadius: BorderRadius.circular(8)
          ),
        ),
        ),
      );
    }
    return Container(
      width: 24,
      height: 24,
      child: CachedNetworkImage(
          imageUrl: "${src}",
          placeholder: (context, url) => SizedBox(
            child: Center(
                child: CircularProgressIndicator(color: ColorConstants.colorMain,)
            ),
            height: 20.0,
            width: 20.0,
          ),
          errorWidget: (context, url, error) =>
              Container(
                decoration: BoxDecoration(
                    color: ColorConstants.white5Percent,
                    borderRadius: BorderRadius.circular(8)
                ),
              ),
          fit: BoxFit.cover),
    );
  }

  static Widget setCommunityListNetworkImage(String src, bool isTopRound) {
    if(src.isEmpty){
      return AspectRatio(
        aspectRatio: 2.55,
        child: ClipRRect(
          borderRadius: BorderRadius.only(topRight: Radius.circular(isTopRound ? 8 : 0), topLeft: Radius.circular(isTopRound ? 8 : 0)),
          child: Container(
            decoration: BoxDecoration(
                color: ColorConstants.white5Percent,
                borderRadius: BorderRadius.circular(8)
            ),
          ),
        )
      );
    }
    return AspectRatio(
      aspectRatio: 2.55,
      child: ClipRRect(
        borderRadius: BorderRadius.only(topRight: Radius.circular(isTopRound ? 8 : 0), topLeft: Radius.circular(isTopRound ? 8 : 0)),
        child: CachedNetworkImage(
            imageUrl: "${src}",
            placeholder: (context, url) => SizedBox(
              child: Center(
                  child: CircularProgressIndicator(color: ColorConstants.colorMain,)
              ),
              height: 20.0,
              width: 20.0,
            ),
            errorWidget: (context, url, error) =>
                Container(
                  decoration: BoxDecoration(
                      color: ColorConstants.white5Percent,
                      borderRadius: BorderRadius.circular(8)
                  ),
                ),
            fit: BoxFit.cover),
      )
    );
  }

  static Widget setRectNetworkImage(String src, double width, double height) {
    if(src.isEmpty){
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: ColorConstants.white5Percent,
        ),
      );
    }
    return CachedNetworkImage(
        imageUrl: "${src}",
        placeholder: (context, url) => SizedBox(
          child: Center(
              child: CircularProgressIndicator(color: ColorConstants.colorMain,)
          ),
          height: 20.0,
          width: 20.0,
        ),
        errorWidget: (context, url, error) =>
            Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                    color: ColorConstants.white5Percent,
                ),
            ),
        width: width,
        height: height,
        fit: BoxFit.cover);
  }

  // 에셋 이미지 위젯
  static Widget setImage(String src, double width,double height) {
    return Image.asset(
        src,
        width: width,
        height: height,
        fit: BoxFit.cover);
  }

  static Widget setFitImage(String src, double width,double height) {
    return Image.asset(
        src,
        width: width,
        height: height,
        fit: BoxFit.contain);
  }

  static Widget setFitImageWidth(String src, double width) {
    return Image.asset(
        src,
        width: width,
        fit: BoxFit.contain);
  }

  static Widget setFitImageHeight(String src, double height) {
    return Image.asset(
        src,
        height: height,
        fit: BoxFit.contain);
  }

  // 에셋 이미지 위젯
  static Widget setImageWithWidth(String src, double width) {
    return Image.asset(
        src,
        width: width,
        fit: BoxFit.cover);
  }

  // 에셋 이미지 위젯
  static Widget setImageWithHeight(String src, double height) {
    return Image.asset(
        src,
        height: height,
        fit: BoxFit.cover);
  }

  static Future<File> imageToFile(ByteData bytes, int index) async {
    Directory cacheDir = await getApplicationDocumentsDirectory();

    Directory localDir = Directory(cacheDir.path + "/localCachedFiles");
    if(!(await localDir.exists())) {
      await localDir.create();
    }
    File file = new File("${localDir.path}/image_${index}.png");
    await new FileImage(file).evict();
    await file.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    return file;
  }

  static Future<File> urlToFile(String imageUrl, int index) async {
    Directory cacheDir = await getApplicationDocumentsDirectory();
    Directory networkDir = Directory(cacheDir.path + "/networkCachedFiles");
    if(!(await networkDir.exists())) {
      await networkDir.create();
    }
    File file = new File("${networkDir.path}/image_${index}.png");
    await new FileImage(file).evict();
    http.Response response = await http.get(Uri.parse(imageUrl));
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  static Future<File> resizeImageFile(File file) async {
    // final size = ImageSizeGetter.getSize(FileInput(file));

    final bytes = await file.readAsBytes();
    var decodedImage = await decodeImageFromList(bytes);
    print("이미지 파일 사이즈 ${decodedImage.width} : ${decodedImage.height}");
    if(decodedImage.height > 1920){
      final resizeBytes = await resizeImage(bytes, height: 1920);
      if (resizeBytes != null) {
        File imageFile = await ImageUtils
            .imageToFile(resizeBytes, Random().nextInt(10000));
        return imageFile;
      }
    }

    return file;
  }
}