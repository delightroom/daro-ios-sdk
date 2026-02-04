enum DaroBannerSize {
  banner,
  mrec,
}

extension DaroBannerSizeExtension on DaroBannerSize {
  double get width {
    switch (this) {
      case DaroBannerSize.banner:
        return 320;
      case DaroBannerSize.mrec:
        return 300;
    }
  }

  double get height {
    switch (this) {
      case DaroBannerSize.banner:
        return 50;
      case DaroBannerSize.mrec:
        return 250;
    }
  }

  String get name {
    switch (this) {
      case DaroBannerSize.banner:
        return 'banner';
      case DaroBannerSize.mrec:
        return 'mrec';
    }
  }
}
