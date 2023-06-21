/* Copyright Airship and Contributors */

@objc(UAirshipCoreResources)
public class AirshipResources : NSObject {

    @objc
    public static let bundle = findBundle()

    private class func findBundle() -> Bundle {
        let mainBundle =  Bundle.main
        let sourceBundle = Bundle(for: AirshipResources.self)

        // SPM
        if let path = mainBundle.path(
            forResource: "Airship_AirshipCore",
            ofType: "bundle"
        ) {
            if let bundle = Bundle(path: path) {
                return bundle
            }
        }

        // Cocopaods (static)
        if let path = mainBundle.path(
            forResource:"AirshipResources", 
            ofType: "bundle"
        ) {
            if let bundle = Bundle(path: path) {
                return bundle
            }
        }

        // Cocopaods (framework)
        if let path = sourceBundle.path(
            forResource:"AirshipResources", 
            ofType: "bundle"
        ) {
            if let bundle = Bundle(path: path) {
                return bundle
            }
        }

        // Fallback to source
        return sourceBundle
    }
}
