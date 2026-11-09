// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import GoogleMaps
import Testing

@testable import google_maps_flutter_ios_sdk9

@MainActor struct MarkerControllerTests {

  /// Returns a simple map view for use with marker controllers.
  static func mapView() -> GMSMapView {
    let mapViewOptions = GMSMapViewOptions()
    mapViewOptions.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    mapViewOptions.camera = GMSCameraPosition(latitude: 0, longitude: 0, zoom: 0)
    return PartiallyMockedMapView(options: mapViewOptions)
  }

  /// Returns a MarkersController instance instantiated with the given map view.
  ///
  /// The mapView should outlive the controller, as the controller keeps a weak reference to it.
  func markersController(
    withMapView mapView: GMSMapView,
    eventDelegate: MapEventDelegate
  ) -> MarkersController {
    return MarkersController(
      mapView: mapView,
      eventDelegate: eventDelegate,
      clusterManagersController: nil,
      assetProvider: TestAssetProvider(),
      markerType: .marker
    )
  }

  func placeholderBitmap() -> PlatformBitmap {
    return PlatformBitmapDefaultMarker(hue: 0)
  }

  @Test func setsMarkerNumericProperties() throws {
    let mapView = MarkerControllerTests.mapView()
    let eventHandler = TestMapEventHandler()
    let controller = markersController(withMapView: mapView, eventDelegate: eventHandler)

    let markerIdentifier = "marker"
    let anchorX = 3.14
    let anchorY = 2.718
    let alpha = 0.4
    let rotation = 90.0
    let zIndex: Int64 = 3
    let latitude = 10.0
    let longitude = 20.0
    controller.add([
      PlatformMarker(
        alpha: alpha,
        anchor: PlatformPoint(x: anchorX, y: anchorY),
        consumeTapEvents: true,
        draggable: true,
        flat: true,
        icon: placeholderBitmap(),
        infoWindow: PlatformInfoWindow(
          title: "info title",
          snippet: "info snippet",
          anchor: PlatformPoint(x: 0, y: 0)
        ),
        position: PlatformLatLng(latitude: latitude, longitude: longitude),
        rotation: rotation,
        visible: true,
        zIndex: zIndex,
        markerId: markerIdentifier,
        clusterManagerId: nil,
        collisionBehavior: nil
      )
    ])

    let markerController = try #require(controller.markerIdentifierToController[markerIdentifier])
    let marker = markerController.marker

    let delta = 0.0001
    #expect(abs(Double(marker.opacity) - alpha) <= delta)
    #expect(abs(marker.rotation - rotation) <= delta)
    #expect(abs(Double(marker.zIndex) - Double(zIndex)) <= delta)
    #expect(abs(Double(marker.groundAnchor.x) - anchorX) <= delta)
    #expect(abs(Double(marker.groundAnchor.y) - anchorY) <= delta)
    #expect(abs(marker.position.latitude - latitude) <= delta)
    #expect(abs(marker.position.longitude - longitude) <= delta)
  }

  @Test func setsDraggable() throws {
    let mapView = MarkerControllerTests.mapView()
    let eventHandler = TestMapEventHandler()
    let controller = markersController(withMapView: mapView, eventDelegate: eventHandler)

    let markerIdentifier = "marker"
    controller.add([
      PlatformMarker(
        alpha: 1.0,
        anchor: PlatformPoint(x: 0, y: 0),
        consumeTapEvents: false,
        draggable: true,
        flat: false,
        icon: placeholderBitmap(),
        infoWindow: PlatformInfoWindow(
          title: "info title",
          snippet: "info snippet",
          anchor: PlatformPoint(x: 0, y: 0)
        ),
        position: PlatformLatLng(latitude: 0.0, longitude: 0.0),
        rotation: 0,
        visible: false,
        zIndex: 0,
        markerId: markerIdentifier,
        clusterManagerId: nil,
        collisionBehavior: nil
      )
    ])

    let markerController = try #require(controller.markerIdentifierToController[markerIdentifier])
    let marker = markerController.marker

    #expect(marker.isDraggable)
  }

  // Boolean properties are tested individually to ensure they aren't accidentally cross-assigned from
  // another property.
  @Test func setsFlat() throws {
    let mapView = MarkerControllerTests.mapView()
    let eventHandler = TestMapEventHandler()
    let controller = markersController(withMapView: mapView, eventDelegate: eventHandler)

    let markerIdentifier = "marker"
    controller.add([
      PlatformMarker(
        alpha: 1.0,
        anchor: PlatformPoint(x: 0, y: 0),
        consumeTapEvents: false,
        draggable: false,
        flat: true,
        icon: placeholderBitmap(),
        infoWindow: PlatformInfoWindow(
          title: "info title",
          snippet: "info snippet",
          anchor: PlatformPoint(x: 0, y: 0)
        ),
        position: PlatformLatLng(latitude: 0.0, longitude: 0.0),
        rotation: 0,
        visible: false,
        zIndex: 0,
        markerId: markerIdentifier,
        clusterManagerId: nil,
        collisionBehavior: nil
      )
    ])

    let markerController = try #require(controller.markerIdentifierToController[markerIdentifier])
    let marker = markerController.marker

    #expect(marker.isFlat)
  }

  // Boolean properties are tested individually to ensure they aren't accidentally cross-assigned from
  // another property.
  @Test func setsVisible() throws {
    let mapView = MarkerControllerTests.mapView()
    let eventHandler = TestMapEventHandler()
    let controller = markersController(withMapView: mapView, eventDelegate: eventHandler)

    let markerIdentifier = "marker"
    controller.add([
      PlatformMarker(
        alpha: 1.0,
        anchor: PlatformPoint(x: 0, y: 0),
        consumeTapEvents: false,
        draggable: false,
        flat: false,
        icon: placeholderBitmap(),
        infoWindow: PlatformInfoWindow(
          title: "info title",
          snippet: "info snippet",
          anchor: PlatformPoint(x: 0, y: 0)
        ),
        position: PlatformLatLng(latitude: 0.0, longitude: 0.0),
        rotation: 0,
        visible: true,
        zIndex: 0,
        markerId: markerIdentifier,
        clusterManagerId: nil,
        collisionBehavior: nil
      )
    ])

    let markerController = try #require(controller.markerIdentifierToController[markerIdentifier])
    let marker = markerController.marker

    // Visibility is controlled by being set to a map.
    #expect(marker.map != nil)
  }

  @Test func setsMarkerInfoWindowProperties() throws {
    let mapView = MarkerControllerTests.mapView()
    let eventHandler = TestMapEventHandler()
    let controller = markersController(withMapView: mapView, eventDelegate: eventHandler)

    let markerIdentifier = "marker"
    let title = "info title"
    let snippet = "info snippet"
    let anchorX = 3.14
    let anchorY = 2.718
    controller.add([
      PlatformMarker(
        alpha: 1.0,
        anchor: PlatformPoint(x: 0, y: 0),
        consumeTapEvents: true,
        draggable: true,
        flat: true,
        icon: placeholderBitmap(),
        infoWindow: PlatformInfoWindow(
          title: title,
          snippet: snippet,
          anchor: PlatformPoint(x: anchorX, y: anchorY)
        ),
        position: PlatformLatLng(latitude: 0, longitude: 0),
        rotation: 0,
        visible: true,
        zIndex: 0,
        markerId: markerIdentifier,
        clusterManagerId: nil,
        collisionBehavior: nil
      )
    ])

    let markerController = try #require(controller.markerIdentifierToController[markerIdentifier])
    let marker = markerController.marker

    let delta = 0.0001
    #expect(abs(Double(marker.infoWindowAnchor.x) - anchorX) <= delta)
    #expect(abs(Double(marker.infoWindowAnchor.y) - anchorY) <= delta)
    #expect(marker.title == title)
    #expect(marker.snippet == snippet)
  }

  @Test func updateMarkerSetsVisibilityLast() {
    let marker = PropertyOrderValidatingAdvancedMarker()
    let collisionBehavior = PlatformMarkerCollisionBehavior.requiredAndHidesOptional
    MarkerController.update(
      marker,
      from: PlatformMarker(
        alpha: 1.0,
        anchor: PlatformPoint(x: 0, y: 0),
        consumeTapEvents: true,
        draggable: true,
        flat: true,
        icon: placeholderBitmap(),
        infoWindow: PlatformInfoWindow(
          title: "info title",
          snippet: "info snippet",
          anchor: PlatformPoint(x: 0, y: 0)
        ),
        position: PlatformLatLng(latitude: 0, longitude: 0),
        rotation: 0,
        visible: true,
        zIndex: 0,
        markerId: "marker",
        clusterManagerId: nil,
        collisionBehavior: collisionBehavior
      ),
      mapView: MarkerControllerTests.mapView(),
      assetProvider: TestAssetProvider(),
      screenScale: 1,
      usingOpacityForVisibility: false
    )
    #expect(marker.hasSetMap)
  }

  @Test func updateMarkerDownsamplesIconToScreenScale() throws {
    // The icon pipeline the app uses: a 120x140 px asset shown at width 28 pt on a 3x screen.
    // The scaling path retags the image to scale 120/84 (~4.29) instead of redrawing, so without
    // the marker opt-in the icon would keep all 120x140 px; with it the bitmap is redrawn at the
    // screen scale.
    let assetName = "fakeImageName"
    let assetProvider = TestAssetProvider(
      image: MarkerControllerTests.createImage(width: 120, height: 140), forAssetName: assetName,
      package: nil)
    let marker = GMSMarker()
    MarkerController.update(
      marker,
      from: PlatformMarker(
        alpha: 1.0,
        anchor: PlatformPoint(x: 0.5, y: 1),
        consumeTapEvents: false,
        draggable: false,
        flat: false,
        icon: PlatformBitmapAssetMap(
          assetName: assetName, bitmapScaling: .auto, imagePixelRatio: 1, width: 28, height: nil),
        infoWindow: PlatformInfoWindow(
          title: nil, snippet: nil, anchor: PlatformPoint(x: 0.5, y: 0)),
        position: PlatformLatLng(latitude: 0, longitude: 0),
        rotation: 0,
        visible: true,
        zIndex: 0,
        markerId: "marker",
        clusterManagerId: nil,
        collisionBehavior: nil
      ),
      mapView: MarkerControllerTests.mapView(),
      assetProvider: assetProvider,
      screenScale: 3,
      usingOpacityForVisibility: false
    )

    let icon = try #require(marker.icon)
    #expect(icon.scale == 3)
    #expect(abs(icon.size.width - 28) < 0.01)
    let cgImage = try #require(icon.cgImage)
    #expect(cgImage.width <= 85)
    #expect(cgImage.width >= 84)
  }

  static func createImage(width: Int, height: Int) -> UIImage {
    let size = CGSize(width: width, height: height)
    let format = UIGraphicsImageRendererFormat.default()
    format.scale = 1.0
    format.opaque = true
    let renderer = UIGraphicsImageRenderer(size: size, format: format)
    return renderer.image { context in
      UIColor.white.setFill()
      context.fill(CGRect(origin: .zero, size: size))
    }
  }

  @Test func assetProviderIsRetained() {
    var markerController: MarkersController?
    weak var weakAssetProvider: TestAssetProvider?
    autoreleasepool {
      let assetProvider = TestAssetProvider()
      weakAssetProvider = assetProvider

      markerController = MarkersController(
        mapView: MarkerControllerTests.mapView(),
        eventDelegate: TestMapEventHandler(),
        clusterManagersController: nil,
        assetProvider: assetProvider,
        markerType: .marker
      )
    }
    #expect(markerController != nil)
    #expect(weakAssetProvider != nil)
  }
}

/// A GMSAdvancedMarker that ensures that property updates are made before the map is set.
class PropertyOrderValidatingAdvancedMarker: GMSAdvancedMarker {
  var hasSetMap = false

  override var position: CLLocationCoordinate2D {
    get { super.position }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.position = newValue
    }
  }

  override var snippet: String? {
    get { super.snippet }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.snippet = newValue
    }
  }

  override var icon: UIImage? {
    get { super.icon }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.icon = newValue
    }
  }

  override var iconView: UIView? {
    get { super.iconView }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.iconView = newValue
    }
  }

  override var tracksViewChanges: Bool {
    get { super.tracksViewChanges }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.tracksViewChanges = newValue
    }
  }

  override var tracksInfoWindowChanges: Bool {
    get { super.tracksInfoWindowChanges }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.tracksInfoWindowChanges = newValue
    }
  }

  override var groundAnchor: CGPoint {
    get { super.groundAnchor }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.groundAnchor = newValue
    }
  }

  override var infoWindowAnchor: CGPoint {
    get { super.infoWindowAnchor }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.infoWindowAnchor = newValue
    }
  }

  override var appearAnimation: GMSMarkerAnimation {
    get { super.appearAnimation }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.appearAnimation = newValue
    }
  }

  override var isDraggable: Bool {
    get { super.isDraggable }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.isDraggable = newValue
    }
  }

  override var isFlat: Bool {
    get { super.isFlat }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.isFlat = newValue
    }
  }

  override var rotation: CLLocationDegrees {
    get { super.rotation }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.rotation = newValue
    }
  }

  override var opacity: Float {
    get { super.opacity }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.opacity = newValue
    }
  }

  override var panoramaView: GMSPanoramaView? {
    get { super.panoramaView }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.panoramaView = newValue
    }
  }

  override var title: String? {
    get { super.title }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.title = newValue
    }
  }

  override var isTappable: Bool {
    get { super.isTappable }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.isTappable = newValue
    }
  }

  override var zIndex: Int32 {
    get { super.zIndex }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.zIndex = newValue
    }
  }

  override var userData: Any? {
    get { super.userData }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.userData = newValue
    }
  }

  override var collisionBehavior: GMSCollisionBehavior {
    get { super.collisionBehavior }
    set {
      #expect(!hasSetMap, "Property set after map was set.")
      super.collisionBehavior = newValue
    }
  }

  override var map: GMSMapView? {
    get { super.map }
    set {
      // Don't actually set the map, since that requires more test setup.
      if newValue != nil {
        hasSetMap = true
      }
    }
  }
}
