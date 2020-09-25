import Flutter
import UIKit
import BSImagePicker
import Photos

extension PHAsset {
    
    var originalFilename: String? {
        
        var fname:String?
        
        if #available(iOS 9.0, *) {
            let resources = PHAssetResource.assetResources(for: self)
            if let resource = resources.last {
                fname = resource.originalFilename
            }
        }
        
        if fname == nil {
            // this is an undocumented workaround that works as of iOS 9.1
            fname = self.value(forKey: "filename") as? String
        }
        
        return fname
    }
}

fileprivate extension UIViewController {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

public class SwiftMultiImagePickerPlugin: NSObject, FlutterPlugin {
    var imagesResult: FlutterResult?
    var messenger: FlutterBinaryMessenger;

    let genericError = "500"

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger;
        super.init();
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "multi_image_picker", binaryMessenger: registrar.messenger())

        let instance = SwiftMultiImagePickerPlugin.init(messenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
        case "pickImages":
            let status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
            
            if (status == PHAuthorizationStatus.denied) {
                return result(FlutterError(code: "PERMISSION_PERMANENTLY_DENIED", message: "The user has denied the gallery access.", details: nil))
            }

            let arguments = call.arguments as! Dictionary<String, AnyObject>
            let maxImages = arguments["maxImages"] as! Int
            let galleryMode = arguments["galleryMode"] as! Int
            let options = arguments["iosOptions"] as! Dictionary<String, String>
            let selectedAssets = arguments["selectedAssets"] as! Array<String>
            var totalImagesSelected = 0
            
            var vc = ImagePickerController()

            if selectedAssets.count > 0 {
                let assets: PHFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: selectedAssets, options: nil)
                var myAssets = [PHAsset]()
                assets.enumerateObjects({ (asset, idx, stop) -> Void in
                    myAssets.append(asset)
                })
                vc = ImagePickerController(selectedAssets: myAssets)
            }
            
            if #available(iOS 13.0, *) {
                // Disables iOS 13 swipe to dismiss - to force user to press cancel or done.
                vc.isModalInPresentation = true
            }
            
            vc.settings.selection.max = maxImages

            // galleryMode : 1-Images&Video;2-Images;3-Video
            if (galleryMode == 1) {
                vc.settings.fetch.assets.supportedMediaTypes = [.image, .video]
            } else if (galleryMode == 2) {
                vc.settings.fetch.assets.supportedMediaTypes = [.image]
            } else if (galleryMode == 3) {
                vc.settings.fetch.assets.supportedMediaTypes = [.video]
            }

            if let backgroundColor = options["backgroundColor"] {
                if (!backgroundColor.isEmpty) {
                    vc.settings.theme.backgroundColor = hexStringToUIColor(hex: backgroundColor)
                }
            }

            if let selectionFillColor = options["selectionFillColor"] {
                if (!selectionFillColor.isEmpty) {
                    vc.settings.theme.selectionFillColor = hexStringToUIColor(hex: selectionFillColor)
                }
            }

            if let selectionShadowColor = options["selectionShadowColor"] {
                if (!selectionShadowColor.isEmpty) {
                    vc.settings.theme.selectionShadowColor = hexStringToUIColor(hex: selectionShadowColor)
                }
            }

            if let selectionStrokeColor = options["selectionStrokeColor"] {
                if (!selectionStrokeColor.isEmpty) {
                    vc.settings.theme.selectionStrokeColor = hexStringToUIColor(hex: selectionStrokeColor)
                }
            }

            if let albumButtonTintColor = options["albumButtonTintColor"] {
                if (!albumButtonTintColor.isEmpty) {
                    vc.albumButton.tintColor = hexStringToUIColor(hex: albumButtonTintColor)
                }
            }

            if let cancelButtonTintColor = options["cancelButtonTintColor"] {
                if (!cancelButtonTintColor.isEmpty) {
                    vc.cancelButton.tintColor = hexStringToUIColor(hex: cancelButtonTintColor)
                }
            }

            if let doneButtonTintColor = options["doneButtonTintColor"] {
                if (!doneButtonTintColor.isEmpty) {
                    vc.doneButton.tintColor = hexStringToUIColor(hex: doneButtonTintColor)
                }
            }

            if let navigationBarTintColor = options["navigationBarTintColor"] {
                if (!navigationBarTintColor.isEmpty) {
                    vc.navigationBar.barTintColor = hexStringToUIColor(hex: navigationBarTintColor)
                }
            }

            if let cellsPerRow = options["cellsPerRow"] {
                if (!cellsPerRow.isEmpty) {
                    vc.settings.list.cellsPerRow = {(verticalSize: UIUserInterfaceSizeClass, horizontalSize: UIUserInterfaceSizeClass) -> Int in
                        switch (verticalSize, horizontalSize) {
                            case (.compact, .regular): // iPhone5-6 portrait
                                return 2
                            case (.compact, .compact): // iPhone5-6 landscape
                                return 2
                            case (.regular, .regular): // iPad portrait/landscape
                                return 3
                            default:
                                return Int(cellsPerRow) ?? 3
                        }
                    }
                }
            }

            if let selectionStyle = options["selectionStyle"] {
                if (!selectionStyle.isEmpty) {
                    if (selectionStyle == "checked") {
                        vc.settings.theme.selectionStyle = .checked
                    } else if (selectionStyle == "numbered") {
                        vc.settings.theme.selectionStyle = .numbered
                    }
                }
            }

            if let previewTitleAttributesFontSize = options["previewTitleAttributesFontSize"] {
                if (!previewTitleAttributesFontSize.isEmpty) {
                    vc.settings.theme.previewTitleAttributes[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: CGFloat((previewTitleAttributesFontSize as NSString).floatValue))
                }
            }

            if let previewTitleAttributesForegroundColor = options["previewTitleAttributesForegroundColor"] {
                if (!previewTitleAttributesForegroundColor.isEmpty) {
                    vc.settings.theme.previewTitleAttributes[NSAttributedString.Key.foregroundColor] = hexStringToUIColor(hex: previewTitleAttributesForegroundColor)
                }
            }

            if let previewSubtitleAttributesFontSize = options["previewSubtitleAttributesFontSize"] {
                if (!previewSubtitleAttributesFontSize.isEmpty) {
                    vc.settings.theme.previewSubtitleAttributes[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: CGFloat((previewSubtitleAttributesFontSize as NSString).floatValue))
                }
            }

            if let previewSubtitleAttributesForegroundColor = options["previewSubtitleAttributesForegroundColor"] {
                if (!previewSubtitleAttributesForegroundColor.isEmpty) {
                    vc.settings.theme.previewSubtitleAttributes[NSAttributedString.Key.foregroundColor] = hexStringToUIColor(hex: previewSubtitleAttributesForegroundColor)
                }
            }

            if let albumTitleAttributesFontSize = options["albumTitleAttributesFontSize"] {
                if (!albumTitleAttributesFontSize.isEmpty) {
                    vc.settings.theme.albumTitleAttributes[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: CGFloat((albumTitleAttributesFontSize as NSString).floatValue))
                }
            }

            if let albumTitleAttributesForegroundColor = options["albumTitleAttributesForegroundColor"] {
                if (!albumTitleAttributesForegroundColor.isEmpty) {
                    vc.settings.theme.albumTitleAttributes[NSAttributedString.Key.foregroundColor] = hexStringToUIColor(hex: albumTitleAttributesForegroundColor)
                }
            }

            UIViewController.topViewController()?.presentImagePicker(vc, animated: true,
                select: { (asset: PHAsset) -> Void in
                    totalImagesSelected += 1
                    
                    if let autoCloseOnSelectionLimit = options["autoCloseOnSelectionLimit"] {
                        if (!autoCloseOnSelectionLimit.isEmpty && autoCloseOnSelectionLimit == "true") {
                            if (maxImages == totalImagesSelected) {
                                UIApplication.shared.sendAction(vc.doneButton.action!, to: vc.doneButton.target, from: self, for: nil)
                            }
                        }
                    }
                }, deselect: { (asset: PHAsset) -> Void in
                    totalImagesSelected -= 1
                }, cancel: { (assets: [PHAsset]) -> Void in
                    result(FlutterError(code: "CANCELLED", message: "The user has cancelled the selection", details: nil))
                }, finish: { (assets: [PHAsset]) -> Void in
                    var results = [NSDictionary]();
                    for asset in assets {
                        results.append([
                            "identifier": asset.localIdentifier,
                            "width": asset.pixelWidth,
                            "height": asset.pixelHeight,
                            "name": asset.originalFilename!,
                            "isVideo": asset.mediaType == .video
                        ]);
                    }
                    result(results);
                }, completion: nil)
            break;
        case "requestThumbnail":
            let arguments = call.arguments as! Dictionary<String, AnyObject>
            let identifier = arguments["identifier"] as! String
            let width = arguments["width"] as! Int
            let height = arguments["height"] as! Int
            let quality = arguments["quality"] as! Int
            let compressionQuality = Float(quality) / Float(100)
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()

            options.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
            options.resizeMode = PHImageRequestOptionsResizeMode.exact
            options.isSynchronous = false
            options.isNetworkAccessAllowed = true
            options.version = .current

            let assets: PHFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)

            if (assets.count > 0) {
                let asset: PHAsset = assets[0];

                let ID: PHImageRequestID = manager.requestImage(
                    for: asset,
                    targetSize: CGSize(width: width, height: height),
                    contentMode: PHImageContentMode.aspectFill,
                    options: options,
                    resultHandler: {
                        (image: UIImage?, info) in
                        self.messenger.send(onChannel: "multi_image_picker/image/" + identifier + ".thumb", message: image?.jpegData(compressionQuality: CGFloat(compressionQuality)))
                        })

                if(PHInvalidImageRequestID != ID) {
                    return result(true);
                }
            }
            
            return result(FlutterError(code: "ASSET_DOES_NOT_EXIST", message: "The requested image does not exist.", details: nil))
        case "requestOriginal":
            let arguments = call.arguments as! Dictionary<String, AnyObject>
            let identifier = arguments["identifier"] as! String
            let quality = arguments["quality"] as! Int
            let compressionQuality = Float(quality) / Float(100)
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()

            options.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
            options.isSynchronous = false
            options.isNetworkAccessAllowed = true
            options.version = .current

            let assets: PHFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)

            if (assets.count > 0) {
                let asset: PHAsset = assets[0];

                let ID: PHImageRequestID = manager.requestImage(
                    for: asset,
                    targetSize: PHImageManagerMaximumSize,
                    contentMode: PHImageContentMode.aspectFill,
                    options: options,
                    resultHandler: {
                        (image: UIImage?, info) in
                        self.messenger.send(onChannel: "multi_image_picker/image/" + identifier + ".original", message: image!.jpegData(compressionQuality: CGFloat(compressionQuality)))
                })

                if(PHInvalidImageRequestID != ID) {
                    return result(true);
                }
            }
            
            return result(FlutterError(code: "ASSET_DOES_NOT_EXIST", message: "The requested image does not exist.", details: nil))
        case "requestMetadata":
            let arguments = call.arguments as! Dictionary<String, AnyObject>
            let identifier = arguments["identifier"] as! String
            let operationQueue = OperationQueue()
            
            let assets: PHFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
            operationQueue.addOperation {
                self.readPhotosMetadata(result: assets, operationQueue: operationQueue, callback: result)
            }
            break;
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    func readPhotosMetadata(result: PHFetchResult<PHAsset>, operationQueue: OperationQueue, callback: @escaping FlutterResult) {
        let imageManager = PHImageManager.default()
        result.enumerateObjects({object , index, stop in
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false
            imageManager.requestImageData(for: object, options: options, resultHandler: { (imageData, dataUTI, orientation, info) in
                operationQueue.addOperation {
                    guard let data = imageData,
                        let metadata = type(of: self).fetchPhotoMetadata(data: data) else {
                            print("metadata not found for \(object)")
                            return
                    }
                    callback(metadata)
                }
            })
        })
    }
    
    static func fetchPhotoMetadata(data: Data) -> [String: Any]? {
        guard let selectedImageSourceRef = CGImageSourceCreateWithData(data as CFData, nil),
            let imagePropertiesDictionary = CGImageSourceCopyPropertiesAtIndex(selectedImageSourceRef, 0, nil) as? [String: Any] else {
                return nil
        }
        return imagePropertiesDictionary
        
    }

    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
