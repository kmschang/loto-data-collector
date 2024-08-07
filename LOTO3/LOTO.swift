//
//  LOTO.swift
//  LOTO2
//
//  Created by Kyle Schang on 8/2/24.
//

import Foundation
import SwiftData
import SwiftUI


@Model
class LOTO:Identifiable {
    
    //ID
    @Attribute(.unique) var id:String
    
    //General Data
    var formName:String
    var formDescription:String
    var procedureNumber:String
    var facility:String
    var location:String
    var revision:String
    var revisionDate:Date
    var originDate:Date
    var isolatoinPoints:String
    var notes:String
    
    // Sources
    var sourceInfo:[SourceInfo]
    
    // Shutdown Sequence
    var machineShopSequence:String
    var isolateSequence:String
    
    // Additional Notes
    var additionalNotes:String
    
    // Completion and Approval
    var completedBy:String
    var approvedBy:String
    var approvedByCompany:String
    var approvalDate:Date
    
    // Status
    var status:Status
    
    // Favorite
    var favorite:Favorite
    
    // Dates
    var dateAdded:Date
    var dateEdited:Date
    
    // Deletion
    var deleted:Bool = false
    
    
    init(
        id: String = UUID().uuidString,
        formName: String,
        formDescription: String,
        procedureNumber: String,
        facility: String,
        location: String,
        revision: String,
        revisionDate: Date,
        originDate: Date,
        isolatoinPoints: String,
        notes: String,
        sourceInfo: [SourceInfo],
        machineShopSequence: String,
        isolateSequence: String,
        additionalNotes: String,
        completedBy: String,
        approvedBy: String,
        approvedByCompany: String,
        approvalDate: Date,
        status: Status,
        favorite: Favorite,
        dateAdded: Date,
        dateEdited: Date
    ) {
        self.id = id
        self.formName = formName
        self.formDescription = formDescription
        self.procedureNumber = procedureNumber
        self.facility = facility
        self.location = location
        self.revision = revision
        self.revisionDate = revisionDate
        self.originDate = originDate
        self.isolatoinPoints = isolatoinPoints
        self.notes = notes
        self.sourceInfo = sourceInfo
        self.machineShopSequence = machineShopSequence
        self.isolateSequence = isolateSequence
        self.additionalNotes = additionalNotes
        self.completedBy = completedBy
        self.approvedBy = approvedBy
        self.approvedByCompany = approvedByCompany
        self.approvalDate = approvalDate
        self.status = status
        self.favorite = favorite
        self.dateAdded = dateAdded
        self.dateEdited = dateEdited
    }
    
    func duplicate() -> LOTO {
        return LOTO(
            formName: self.formName + " copy",
            formDescription: self.formDescription,
            procedureNumber: self.procedureNumber,
            facility: self.facility,
            location: self.location,
            revision: self.revision,
            revisionDate: self.revisionDate,
            originDate: self.originDate,
            isolatoinPoints: self.isolatoinPoints,
            notes: self.notes,
            sourceInfo: self.sourceInfo.map { $0.duplicate() },
            machineShopSequence: self.machineShopSequence,
            isolateSequence: self.isolateSequence,
            additionalNotes: self.additionalNotes,
            completedBy: self.completedBy,
            approvedBy: self.approvedBy,
            approvedByCompany: self.approvedByCompany,
            approvalDate: self.approvalDate,
            status: self.status,
            favorite: self.favorite,
            dateAdded: Date(),
            dateEdited: Date()
        )
    }
    
    
}


enum Status: Int, Codable, Identifiable, CaseIterable, Comparable {
    static func < (lhs: Status, rhs: Status) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    case inProgress = 1, awaitingApproval, completed
    
    var id: Self {
        self
    }
    
    var statusString:String {
        switch self {
        case .inProgress:
            return "In Progress"
        case .awaitingApproval:
            return "Awaiting Approval"
        case .completed:
            return "Completed"
        }
    }
    
    var statusColor:Color {
        switch self {
        case .inProgress:
            return .red
        case .awaitingApproval:
            return .purple
        case .completed:
            return .green
        }
    }
    
    var statusIcon:Image {
        switch self {
        case .inProgress:
            Image(systemName: "smallcircle.filled.circle")
        case .awaitingApproval:
            Image(systemName: "circle.dashed.inset.filled")
        case .completed:
            Image(systemName: "checkmark.circle.fill")
        }
    }
}


enum Source: Int, Codable, Identifiable, CaseIterable, Comparable {
    static func < (lhs: Source, rhs: Source) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    case electrical = 1, air, water, gas, gravity, other
    
    var id: Self {
        self
    }
    
    var sourceString:String {
        switch self {
        case .electrical:
            return "Electrical"
        case .air:
            return "Air"
        case .water:
            return "Water"
        case .gas:
            return "Gas"
        case .gravity:
            return "Gravity"
        case .other:
            return "Other"
        }
    }
    
    var sourceColor:Color {
        switch self {
        case .electrical:
            return .yellow
        case .air:
            return Color(UIColor.systemTeal)
        case .water:
            return .green
        case .gas:
            return .red
        case .gravity:
            return .purple
        case .other:
            return .primary
        }
    }
    
    var sourceIcon:Image {
        switch self {
        case .electrical:
            Image(systemName: "bolt.fill")
        case .air:
            Image(systemName: "wind")
        case .water:
            Image(systemName: "drop.fill")
        case .gas:
            Image(systemName: "fuelpump.fill")
        case .gravity:
            Image(systemName: "globe.americas.fill")
        case .other:
            Image(systemName: "diamond.inset.filled")
        }
    }
    
    var sourceIconString:String {
        switch self {
        case .electrical:
            return "bolt.fill"
        case .air:
            return "wind"
        case .water:
            return "drop.fill"
        case .gas:
            return "fuelpump.fill"
        case .gravity:
            return "globe.americas.fill"
        case .other:
            return "diamond.inset.filled"
        }
    }
}

enum Favorite: Codable, Identifiable, CaseIterable {
    case notFavorite, isFavorite
    
    var id: Self { self }
    
    var isTrue: Bool {
        switch self {
        case .isFavorite:
            return true
        case .notFavorite:
            return false
        }
    }
    
    var favoriteString: String {
        switch self {
        case .isFavorite:
            return "Favorite"
        case .notFavorite:
            return "Not Favorite"
        }
    }
    
    var favoriteIcon: Image {
        switch self {
        case .isFavorite:
            return Image(systemName: "star.fill")
        case .notFavorite:
            return Image(systemName: "star.slash")
        }
    }
    
    var favoriteIconOpposite: Image {
        switch self {
        case .isFavorite:
            return Image(systemName: "star.slash")
        case .notFavorite:
            return Image(systemName: "star.fill")
        }
    }
    
    var favoriteColor: Color {
        switch self {
        case .isFavorite:
            return .yellow
        case .notFavorite:
            return .gray
        }
    }
    
    var favoriteColorOpposite: Color {
        switch self {
        case .isFavorite:
            return .gray
        case .notFavorite:
            return .yellow
        }
    }
}



@Model
class SourceInfo:Identifiable {
    
    //ID
    @Attribute(.unique) var id:String
    
    // Source Info
    var source_id:String
    var source_type:Source
    var source_device:String
    var source_location:String
    var source_method:String
    var source_check:String
    var source_photo:Data?
    
    
    init(
        id: String = UUID().uuidString,
        source_id: String,
        source_type: Source,
        source_device: String,
        source_location: String,
        source_method: String,
        source_check: String,
        source_photo: Data? = nil
    ) {
        self.id = id
        self.source_id = source_id
        self.source_type = source_type
        self.source_device = source_device
        self.source_location = source_location
        self.source_method = source_method
        self.source_check = source_check
        self.source_photo = source_photo
    }
    
    func duplicate() -> SourceInfo {
        return SourceInfo(
            id: UUID().uuidString,
            source_id: self.source_id,
            source_type: self.source_type,
            source_device: self.source_device,
            source_location: self.source_location,
            source_method: self.source_method,
            source_check: self.source_check,
            source_photo: self.source_photo
        )
    }
    
}
