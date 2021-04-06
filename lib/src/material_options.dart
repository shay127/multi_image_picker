class MaterialOptions {
  final bool? folderMode;
  final String? toolbarFolderTitle;
  final String? toolbarImageTitle;
  final String? toolbarDoneButtonText;
  final String? toolbarArrowColor; // Color.BLACK
  final bool? includeAnimation;

  const MaterialOptions({
    this.folderMode,
    this.toolbarFolderTitle,
    this.toolbarImageTitle,
    this.toolbarDoneButtonText,
    this.toolbarArrowColor,
    this.includeAnimation,
  });

  Map<String, String> toJson() {
    return {
      "folderMode": folderMode == true ? "true" : "false",
      "toolbarFolderTitle": toolbarFolderTitle ?? "",
      "toolbarImageTitle": toolbarImageTitle ?? "",
      "toolbarDoneButtonText": toolbarDoneButtonText ?? "",
      "toolbarArrowColor": toolbarArrowColor ?? "black",
      "includeAnimation": includeAnimation == true ? "true" : "false",
    };
  }
}
