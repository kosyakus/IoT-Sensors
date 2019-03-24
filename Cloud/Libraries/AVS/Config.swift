import Foundation

struct Config {
    
    struct LoginWithAmazon {
        static let ClientId = "amzn1.application-oa2-client.0cc02ecd2ebb4cfeb53706aeb7e55302"
        static let ProductId = "com_yodiwo_apps_yodifinder"
        static let DeviceSerialNumber = "1000-6666-7777-9999"
    }
    
    struct Debug {
        static let General = false
        static let Errors = true
        static let HTTPRequest = false
        static let HTTPResponse = false
    }
    
    struct Error {
        static let ErrorDomain = "net.ioncannon.SimplePCMRecorderError"
        
        static let PCMSetupIncompleteErrorCode = 1
        
        static let AVSUploaderSetupIncompleteErrorCode = 2
        static let AVSAPICallErrorCode = 3
        static let AVSResponseBorderParseErrorCode = 4
    }

}
