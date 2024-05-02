class DownloadFile {
  final String fileName;
  final String? contentType;
  final int contentLength;

  final List<int> content;

  DownloadFile({
    required this.fileName,
    required this.contentType,
    required this.contentLength,
    required this.content,
  });
}
