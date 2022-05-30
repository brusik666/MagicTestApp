import Foundation
import RxCocoa
import RxSwift
import RxDataSources

enum MultipleSetionModel {
    case ChannelsSection(title: String, items: [SectionItem])
    case Playlist1Section(title: String, items: [SectionItem])
    case Playlist2Section(title: String, items: [SectionItem])
}

enum SectionItem {
    case ChannelSectionItem(image: UIImage, title: String, subscribersCount: String)
    case Playlist1SectionItem(image: UIImage, title: String, viewsCount: String)
    case Playlist2SectionItem(image: UIImage, title: String, viewsCount: String)
}



extension MultipleSetionModel: SectionModelType {
    var items: [SectionItem] {
        switch self {
        case .ChannelsSection(title: _, items: let items):
            return items.map {$0}
        case .Playlist1Section(title: _, items: let items):
            return items.map {$0}
        case .Playlist2Section(title: _, items: let items):
            return items.map {$0}
        }
    }
    
    init(original: MultipleSetionModel, items: [SectionItem]) {
        switch original {
        case let .ChannelsSection(title: title, items: _):
            self = .ChannelsSection(title: title, items: items)
        case let .Playlist1Section(title: title, items: _):
            self = .Playlist1Section(title: title, items: items)
        case let .Playlist2Section(title: title, items: _):
            self = .Playlist2Section(title: title, items: items)
        }
    }
    
    
    typealias Item = SectionItem
    
}

extension MultipleSetionModel {
    var title: String {
        switch self {
        case .ChannelsSection(title: let title, items: _):
            return title
        case .Playlist1Section(title: let title, items: _):
            return title
        case .Playlist2Section(title: let title, items: _):
            return title
        }
    }
}
