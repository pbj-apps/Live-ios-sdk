import UIKit
import SwiftUI

public class Theme: ObservableObject {

	public init() { }
	
	@Published public var isAllCaps = false

	public struct Fonts {
		public var regular: String = "HelveticaNeue"
		public var light: String = "Helvetica-Light"
	}
	public var isCustomizableInApp = false
	// all the button, cells text
	public var accentColor: Color = .black
	// all the detail text
	public var secondaryLabelColor: Color = Color(#colorLiteral(red: 0.5215686275, green: 0.5215686275, blue: 0.5215686275, alpha: 1))
	// main backgrounds color
	public var backgroundColor: Color = .white
	// all the light text placed on top of images
	public var lightForegroundColor: Color = .white
	// all the dark text placed on top of images
	public var darkForegroundColor: Color = .blue
	// placeholders color
	public var imagePlaceholderColor: Color = Color(red: 239.0/255, green: 239.0/255, blue: 239.0/255)

	public var buttonBackgroundColor = Color.clear
	public var buttonForegroundColor = Color(UIColor.label)

	public var buttonCornerRadius: CGFloat = 10
	public var landing = Landing()
	public var fonts = Fonts()
	@Published public var vod = VodTheme()
	@Published public var live = LiveTheme()
	@Published public var playlist = Playlist()
	@Published public var survey = SurveyTheme()
	public var main = Main()

	public struct Main {
		public var wordings = Wordings()
		public var tabBarImages = TabBarImages()

		public struct Wordings {
			public var live = ""
			public var vod = ""
			public var profile = ""
		}

		public struct TabBarImages {
			public lazy var live: UIImage = UIImage(named: "Live", in: .module, compatibleWith: nil)!
			public lazy var liveSelected: UIImage = UIImage(named: "LiveSelected", in: .module, compatibleWith: nil)!
			public lazy var vod: UIImage = UIImage(named: "VOD", in: .module, compatibleWith: nil)!
			public lazy var vodSelected: UIImage = UIImage(named: "VODSelected", in: .module, compatibleWith: nil)!
			public lazy var profile: UIImage = UIImage(named: "Profile", in: .module, compatibleWith: nil)!
			public lazy var profileSelected: UIImage = UIImage(named: "ProfileSelected", in: .module, compatibleWith: nil)!
		}
	}

	public struct Landing {
		public lazy var backgroundImage: UIImage = UIImage(named: "LandingBackground", in: .module, compatibleWith: nil)!
		public var titleFontSize: CGFloat = 60
		public var isTitleCentered: Bool = true
		public var hidesSignUp = false
		public var wordings = Wordings()

		public var buttonsBackgroundColor = Color.clear
		public var buttonsForegroundColor = Color.white

		public struct Wordings {
			public var title = "Anytime, Anywhere"
			public var login = "Login"
			public var signup = "Sign Up"
		}

		public var customView: AnyView?
	}

	public struct SurveyTheme {
		public var selectedColor = Color.black
		public var selectedTextColor = Color.white
	}

	public struct LiveTheme {

		public var layout: Layout = .fullBleedHeader
		public var tiles: Tiles = .regular
		public var showsInstructorAvatar: Bool = true

		public enum Layout: String, CaseIterable {
			case croppedHeader
			case fullBleedHeader
			case fullscreen
		}

		public enum Tiles: String, CaseIterable {
			case regular
			case large
		}
	}

	public struct VodTheme {

		public var headerStyle: Header = .carousel
		public var layout: Layout = .verticalCategories
		public var showFeaturedItems: Bool = true
		public var showDescription: Bool = true
		public var timeStyle: TimeStyle = .full
		public var titleLineLimit = 1
		public var descriptionLineLimit = 2

		public enum Layout: String, CaseIterable {
			case verticalCategories
			case horizontalCategories
		}

		public enum Header: String, CaseIterable {
			case carousel
			case fullBleedHeader
		}

		public enum TimeStyle: String, CaseIterable {
			case full
			case min
		}
	}

	public struct Playlist {
		public var videoRowLayout: VideoRowLayout = .regular

		public enum VideoRowLayout: String, CaseIterable {
			case regular
			case minimalist
			case large
		}
	}
}

extension UIImage {
	convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
		let rect = CGRect(origin: .zero, size: size)
		UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
		color.setFill()
		UIRectFill(rect)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		guard let cgImage = image?.cgImage else { return nil }
		self.init(cgImage: cgImage)
	}
}
