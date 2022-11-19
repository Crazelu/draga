// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dialog_manager/flutter_dialog_manager.dart';
import 'package:draga/main.dart';
import 'package:draga/view/constants.dart';
import 'package:draga/view/drawing_canvas/models/drawing_mode.dart';
import 'package:draga/view/drawing_canvas/models/sketch.dart';
import 'package:draga/view/drawing_canvas/widgets/color_palette.dart';
import 'package:draga/view/drawing_page.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:steganograph/steganograph.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';
import 'package:image/image.dart' as im;

class CanvasSideBar extends HookWidget {
  final ValueNotifier<Color> selectedColor;
  final ValueNotifier<double> strokeSize;
  final ValueNotifier<double> eraserSize;
  final ValueNotifier<DrawingMode> drawingMode;
  final ValueNotifier<Sketch?> currentSketch;
  final ValueNotifier<List<Sketch>> allSketches;
  final GlobalKey canvasGlobalKey;
  final ValueNotifier<bool> filled;
  final ValueNotifier<int> polygonSides;
  final ValueNotifier<ui.Image?> backgroundImage;
  final ValueNotifier<double> canvasWidth;
  final ValueNotifier<double> canvasHeight;
  final ValueNotifier<Offset?> maxOffset;
  final ValueNotifier<int> imageRowCount;
  final ValueNotifier<int> imageColumnCount;
  final double defaultCanvasWidth;
  final double defaultCanvasHeight;
  final UndoRedoStack undoRedoStack;

  const CanvasSideBar({
    Key? key,
    required this.selectedColor,
    required this.strokeSize,
    required this.eraserSize,
    required this.drawingMode,
    required this.currentSketch,
    required this.allSketches,
    required this.canvasGlobalKey,
    required this.filled,
    required this.polygonSides,
    required this.backgroundImage,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.maxOffset,
    required this.imageRowCount,
    required this.imageColumnCount,
    required this.defaultCanvasWidth,
    required this.defaultCanvasHeight,
    required this.undoRedoStack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    final embedSketchData = useState(false);
    return Container(
      width: 300,
      height: MediaQuery.of(context).size.height < 680 ? 520 : 650,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 3,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        trackVisibility: true,
        child: ListView(
          padding: const EdgeInsets.all(10.0),
          controller: scrollController,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Shapes',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Wrap(
              alignment: WrapAlignment.start,
              spacing: 5,
              runSpacing: 5,
              children: [
                _IconBox(
                  iconData: FontAwesomeIcons.pencil,
                  selected: drawingMode.value == DrawingMode.pencil,
                  onTap: () => drawingMode.value = DrawingMode.pencil,
                ),
                _IconBox(
                  selected: drawingMode.value == DrawingMode.line,
                  onTap: () => drawingMode.value = DrawingMode.line,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 22,
                        height: 2,
                        color: drawingMode.value == DrawingMode.line
                            ? Colors.grey[900]
                            : Colors.grey,
                      ),
                    ],
                  ),
                ),
                _IconBox(
                  iconData: Icons.hexagon_outlined,
                  selected: drawingMode.value == DrawingMode.polygon,
                  onTap: () => drawingMode.value = DrawingMode.polygon,
                ),
                _IconBox(
                  iconData: FontAwesomeIcons.eraser,
                  selected: drawingMode.value == DrawingMode.eraser,
                  onTap: () => drawingMode.value = DrawingMode.eraser,
                ),
                _IconBox(
                  iconData: FontAwesomeIcons.square,
                  selected: drawingMode.value == DrawingMode.square,
                  onTap: () => drawingMode.value = DrawingMode.square,
                ),
                _IconBox(
                  iconData: FontAwesomeIcons.circle,
                  selected: drawingMode.value == DrawingMode.circle,
                  onTap: () => drawingMode.value = DrawingMode.circle,
                ),
                _IconBox(
                  iconData: FontAwesomeIcons.arrowPointer,
                  selected: drawingMode.value == DrawingMode.none,
                  onTap: () => drawingMode.value = DrawingMode.none,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Fill Shape: ',
                  style: TextStyle(fontSize: 12),
                ),
                Checkbox(
                  value: filled.value,
                  onChanged: (val) {
                    filled.value = val ?? false;
                  },
                ),
              ],
            ),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: drawingMode.value == DrawingMode.polygon
                  ? Row(
                      children: [
                        const Text(
                          'Polygon Sides: ',
                          style: TextStyle(fontSize: 12),
                        ),
                        Slider(
                          value: polygonSides.value.toDouble(),
                          min: 3,
                          max: 8,
                          onChanged: (val) {
                            polygonSides.value = val.toInt();
                          },
                          label: '${polygonSides.value}',
                          divisions: 5,
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 10),
            const Text(
              'Colors',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ColorPalette(
              selectedColor: selectedColor,
            ),
            const SizedBox(height: 20),
            const Text(
              'Size',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Row(
              children: [
                const Text(
                  'Stroke Size: ',
                  style: TextStyle(fontSize: 12),
                ),
                Slider(
                  value: strokeSize.value,
                  min: 0,
                  max: 50,
                  onChanged: (val) {
                    strokeSize.value = val;
                  },
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  'Eraser Size: ',
                  style: TextStyle(fontSize: 12),
                ),
                Slider(
                  value: eraserSize.value,
                  min: 0,
                  max: 80,
                  onChanged: (val) {
                    eraserSize.value = val;
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Actions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Wrap(
              children: [
                ValueListenableBuilder<List<Sketch>>(
                    valueListenable: allSketches,
                    builder: (_, sketches, __) {
                      return TextButton(
                        onPressed: sketches.isNotEmpty
                            ? () => undoRedoStack.undo()
                            : null,
                        child: const Text('Undo'),
                      );
                    }),
                ValueListenableBuilder<bool>(
                  valueListenable: undoRedoStack.canRedo,
                  builder: (_, canRedo, __) {
                    return TextButton(
                      onPressed: canRedo ? () => undoRedoStack.redo() : null,
                      child: const Text('Redo'),
                    );
                  },
                ),
                TextButton(
                  child: const Text('Clear'),
                  onPressed: () => undoRedoStack.clear(),
                ),
                // TextButton(
                //   onPressed: () async {
                //     if (backgroundImage.value != null) {
                //       backgroundImage.value = null;
                //     } else {
                //       backgroundImage.value = await _getImage;
                //     }
                //   },
                //   child: Text(
                //     backgroundImage.value == null
                //         ? 'Add Background'
                //         : 'Remove Background',
                //   ),
                // ),
                TextButton(
                  child: const Text('Fork on Github'),
                  onPressed: () => _launchUrl(kGithubRepo),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Export',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton(
                  child: const Text('PNG'),
                  onPressed: () async {
                    if (embedSketchData.value) {
                      await _exportSketchData(context, allSketches.value);
                    } else {
                      await _export(context, 'png');
                    }
                  },
                ),
                TextButton(
                  onPressed: embedSketchData.value
                      ? null
                      : () async {
                          await _export(context, 'jpeg');
                        },
                  child: const Text('JPEG'),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CustomCheckBox(
                        active: embedSketchData.value,
                        onTap: () {
                          embedSketchData.value = !embedSketchData.value;
                        }),
                    const SizedBox(width: 4),
                    const Text(
                      'Embed Sketch Data',
                      style: TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                    const SizedBox(width: 2),
                    Tooltip(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      message: kEmbedSketchDataTooltip,
                      child: const Icon(
                        Icons.help_outline,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // add about me button or follow buttons
            const Divider(),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                DialogManager.of(context).showDialog(
                  routeName: kLoadingDialogRoute,
                  arguments: true,
                );
                final sketches = await _getSketchData();
                allSketches.value = sketches;
                if (sketches.isNotEmpty) {
                  currentSketch.value = sketches.last;
                }
                DialogManager.of(context).dismissDialog();
              },
              child: Row(
                children: const [
                  Icon(
                    Icons.upload_file,
                    size: 14,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Import Sketch Data',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: InkWell(
                onTap: () => _launchUrl('https://github.com/Crazelu'),
                child: const Text(
                  'Crafted with 💙 by Crazelu',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Sketch>> _getSketchData() async {
    try {
      final bytes = await _getImageBytes;

      if (bytes != null) {
        final data = await Steganograph.decodeBytes(bytes: bytes);
        return List<Sketch>.from(
            jsonDecode(data!).map((e) => Sketch.fromJson(e)));
      }
    } catch (e) {
      //
    }
    return [];
  }

  Future<void> _exportSketchData(
    BuildContext context,
    List<Sketch> sketches,
  ) async {
    DialogManager.of(context).showDialog(routeName: kLoadingDialogRoute);
    Uint8List? pngBytes = await _getBytes();
    if (pngBytes != null) pngBytes = await _embedSketchData(pngBytes, sketches);
    if (pngBytes != null) await _saveFile(pngBytes, 'png');
    DialogManager.of(context).dismissDialog();
  }

  Future<void> _export(BuildContext context, String extension) async {
    DialogManager.of(context).showDialog(routeName: kLoadingDialogRoute);
    Uint8List? pngBytes = await _getBytes();
    if (pngBytes != null) await _saveFile(pngBytes, extension);
    DialogManager.of(context).dismissDialog();
  }

  Future<void> _saveFile(Uint8List bytes, String extension) async {
    if (kIsWeb) {
      var blob = html.Blob([bytes], 'image/$extension');
      html.AnchorElement()
        ..href = html.Url.createObjectUrlFromBlob(blob).toString()
        ..download =
            'Draga-${DateTime.now().toIso8601String().replaceAll(RegExp(r':'), '-')}.$extension'
        ..style.display = 'none'
        ..click();
    } else {
      await FileSaver.instance.saveFile(
        'Draga-${DateTime.now().toIso8601String().replaceAll(RegExp(r':'), '-')}',
        bytes,
        extension,
        mimeType: extension == 'png' ? MimeType.PNG : MimeType.JPEG,
      );
    }
  }

  Future<Uint8List?> _embedSketchData(
    Uint8List bytes,
    List<Sketch> sketches,
  ) async {
    try {
      return await Steganograph.encodeBytes(
        bytes: bytes,
        message: jsonEncode(sketches),
      );
    } catch (e) {
      return null;
    }
  }

  Future<ui.Image> get _getImage async {
    final completer = Completer<ui.Image>();

    final bytes = await _getImageBytes;
    if (bytes == null) {
      completer.completeError('No image selected');
    }
    im.Image? baseSizeImage = im.decodeImage(bytes!);

    if (baseSizeImage == null) {
      completer.completeError('Error decoding image');
    }

    final width = (defaultCanvasWidth / kDefaultPageCount).ceil();

    im.Image resizeImage = im.copyResize(baseSizeImage!, width: width);
    ui.Codec codec = await ui
        .instantiateImageCodec(Uint8List.fromList(im.encodePng(resizeImage)));
    ui.FrameInfo frameInfo = await codec.getNextFrame();

    completer.complete(frameInfo.image);

    return completer.future;
  }

  Future<Uint8List?> get _getImageBytes async {
    final completer = Completer<Uint8List>();
    if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
      final file = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (file != null) {
        final filePath = file.files.single.path;
        final bytes = filePath == null
            ? file.files.first.bytes
            : File(filePath).readAsBytesSync();
        if (bytes != null) {
          completer.complete(bytes);
        } else {
          completer.completeError('No image selected');
        }
      }
    } else {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        completer.complete(bytes);
      } else {
        completer.completeError('No image selected');
      }
    }

    return completer.future;
  }

  Future<void> _launchUrl(String url) async {
    if (kIsWeb) {
      html.window.open(
        url,
        url,
      );
    } else {
      if (!await launchUrl(Uri.parse(url))) {
        throw 'Could not launch $url';
      }
    }
  }

  ///Shaves off uneccessary whitespace by shrinking the size
  ///of the canvas temporarily to a size that is large enough to
  ///contain all sketches while being as small as possible.
  ///
  ///This is necessary due to the multi-page support.
  ///It's important to call [_restoreCanvasSize] after the image export is complete.
  Future<void> _shrinkCanvasSize() async {
    if (maxOffset.value == null) return;
    double maxOffsetX = maxOffset.value!.dx;
    double maxOffsetY = maxOffset.value!.dy;

    final widthPerPage = defaultCanvasWidth / kDefaultPageCount;
    final heightPerPage = defaultCanvasHeight / kDefaultPageCount;

    if (maxOffsetX < widthPerPage) {
      imageRowCount.value = 1;
      canvasWidth.value = widthPerPage;
    }
    if (maxOffsetY < heightPerPage) {
      imageColumnCount.value = 1;
      canvasHeight.value = heightPerPage;
    }

    if (maxOffsetX > widthPerPage) {
      int xPages = (maxOffsetX / widthPerPage).ceil();
      imageRowCount.value = xPages;
      canvasWidth.value = widthPerPage * xPages;
    }
    if (maxOffsetY > heightPerPage) {
      int yPages = (maxOffsetY / heightPerPage).ceil();
      imageColumnCount.value = yPages;
      canvasHeight.value = heightPerPage * yPages;
    }

    //delay to allow the UI rebuild with new canvas dimensions
    await Future.delayed(const Duration(seconds: 1));
  }

  ///Restores canvas size to default dimensions.
  void _restoreCanvasSize() {
    canvasHeight.value = defaultCanvasHeight;
    canvasWidth.value = defaultCanvasWidth;
    imageColumnCount.value = kDefaultPageCount;
    imageRowCount.value = kDefaultPageCount;
  }

  Future<Uint8List?> _getBytes() async {
    await _shrinkCanvasSize();
    RenderRepaintBoundary boundary = canvasGlobalKey.currentContext
        ?.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    _restoreCanvasSize();
    return pngBytes;
  }
}

class _IconBox extends StatelessWidget {
  final IconData? iconData;
  final Widget? child;
  final bool selected;
  final VoidCallback onTap;

  const _IconBox({
    Key? key,
    this.iconData,
    this.child,
    required this.selected,
    required this.onTap,
  })  : assert(child != null || iconData != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 35,
        width: 35,
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? Colors.grey[900]! : Colors.grey,
            width: 1.5,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        child: child ??
            Icon(
              iconData,
              color: selected ? Colors.grey[900] : Colors.grey,
              size: 20,
            ),
      ),
    );
  }
}

class _CustomCheckBox extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  const _CustomCheckBox({
    Key? key,
    required this.active,
    required this.onTap,
    this.size = 16,
    this.iconSize = 12,
  }) : super(key: key);

  BorderSide get _borderSide {
    return const BorderSide(
      width: 2,
      color: Colors.blue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: active ? Colors.blue.withOpacity(.2) : Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(5),
          border: Border(
            bottom: _borderSide,
            top: _borderSide,
            left: _borderSide,
            right: _borderSide,
          ),
        ),
        child: active
            ? Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.check,
                  size: iconSize,
                  color: Colors.blue,
                ),
              )
            : null,
      ),
    );
  }
}
