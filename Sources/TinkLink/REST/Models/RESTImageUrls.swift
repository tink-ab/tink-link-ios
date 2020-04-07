import Foundation

struct RESTImageUrls: Codable {

    var icon: String?
    var banner: String?

    init(icon: String?, banner: String?) {
        self.icon = icon
        self.banner = banner
    }
}

