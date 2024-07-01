import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

class KoreanCameraPickerTextDelegate extends CameraPickerTextDelegate {
  const KoreanCameraPickerTextDelegate();

  @override
  String get languageCode => 'ko';

  @override
  String get confirm => 'confirm'.tr();

  @override
  String get shootingTips => 'camera_description'.tr();

  @override
  String get shootingWithRecordingTips => 'camera_video_description'.tr();

  @override
  String get shootingOnlyRecordingTips => 'Long press to record video.';

  @override
  String get shootingTapRecordingTips => 'Tap to record video.';

  @override
  String get loadFailed => 'Load failed';

  @override
  String get loading => 'Loading...';

  @override
  String get saving => '저장중...';

  @override
  String get sActionManuallyFocusHint => 'manually focus';

  @override
  String get sActionPreviewHint => 'preview';

  @override
  String get sActionRecordHint => 'record';

  @override
  String get sActionShootHint => 'take picture';

  @override
  String get sActionShootingButtonTooltip => 'shooting button';

  @override
  String get sActionStopRecordingHint => 'stop recording';

  @override
  String sCameraLensDirectionLabel(CameraLensDirection value) => value.name;

  @override
  String? sCameraPreviewLabel(CameraLensDirection? value) {
    if (value == null) {
      return null;
    }
    return '${sCameraLensDirectionLabel(value)} camera preview';
  }

  @override
  String sFlashModeLabel(FlashMode mode) => 'Flash mode: ${mode.name}';

  @override
  String sSwitchCameraLensDirectionLabel(CameraLensDirection value) =>
      'Switch to the ${sCameraLensDirectionLabel(value)} camera';
}

class MyAssetPicker {
  MyAssetPicker({Key? key});

  static Future<List<AssetEntity>?> pickAssets(BuildContext context,
      {List<AssetEntity>? selectedAssets, int maxAssets = 10}) async {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
          selectedAssets: selectedAssets,
          maxAssets: maxAssets,
          textDelegate: const KoreanAssetPickerTextDelegate()),
    );
    return result;
  }

  static Future<AssetEntity?> pickCamera(BuildContext context, bool enableRecording) async {
    final AssetEntity? result = await CameraPicker.pickFromCamera(
      context,
      pickerConfig: CameraPickerConfig(
        enableRecording: enableRecording,
        textDelegate: KoreanCameraPickerTextDelegate(),
      ),
    );
    return result;
  }
}
