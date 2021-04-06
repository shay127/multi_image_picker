class CupertinoOptions {
  final String? selectionStyle; // checked or numbered
  final String? albumButtonTintColor;
  final String? cancelButtonTintColor;
  final String? doneButtonTintColor;
  final String? navigationBarTintColor;
  final String? backgroundColor;
  final String? selectionFillColor;
  final String? selectionStrokeColor;
  final String? selectionShadowColor;
  final String? previewTitleAttributesFontSize;
  final String? previewTitleAttributesForegroundColor;
  final String? previewSubtitleAttributesFontSize;
  final String? previewSubtitleAttributesForegroundColor;
  final String? albumTitleAttributesFontSize;
  final String? albumTitleAttributesForegroundColor;
  final String? cellsPerRow;

  const CupertinoOptions({
    this.selectionStyle,
    this.albumButtonTintColor,
    this.cancelButtonTintColor,
    this.doneButtonTintColor,
    this.navigationBarTintColor,
    this.backgroundColor,
    this.selectionFillColor,
    this.selectionStrokeColor,
    this.selectionShadowColor,
    this.previewTitleAttributesFontSize,
    this.previewTitleAttributesForegroundColor,
    this.previewSubtitleAttributesFontSize,
    this.previewSubtitleAttributesForegroundColor,
    this.albumTitleAttributesFontSize,
    this.albumTitleAttributesForegroundColor,
    this.cellsPerRow,
  });

  Map<String, String> toJson() {
    return {
      "selectionStyle": selectionStyle ?? "",
      "albumButtonTintColor": albumButtonTintColor ?? "",
      "cancelButtonTintColor": cancelButtonTintColor ?? "",
      "doneButtonTintColor": doneButtonTintColor ?? "",
      "navigationBarTintColor": navigationBarTintColor ?? "",
      "backgroundColor": backgroundColor ?? "",
      "selectionFillColor": selectionFillColor ?? "",
      "selectionStrokeColor": selectionStrokeColor ?? "",
      "selectionShadowColor": selectionShadowColor ?? "",
      "previewTitleAttributesFontSize": previewTitleAttributesFontSize ?? "",
      "previewTitleAttributesForegroundColor":
          previewTitleAttributesForegroundColor ?? "",
      "previewSubtitleAttributesFontSize":
          previewSubtitleAttributesFontSize ?? "",
      "previewSubtitleAttributesForegroundColor":
          previewSubtitleAttributesForegroundColor ?? "",
      "albumTitleAttributesFontSize": albumTitleAttributesFontSize ?? "",
      "albumTitleAttributesForegroundColor":
          albumTitleAttributesForegroundColor ?? "",
      "cellsPerRow": cellsPerRow ?? "",
    };
  }
}
