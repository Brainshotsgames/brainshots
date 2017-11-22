//
//  Profile+CoreDataProperties.swift
//  
//
//  Created by Amritpal Singh on 30/01/17.
//
//

import Foundation
import CoreData


extension Profile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Profile> {
        return NSFetchRequest<Profile>(entityName: "Profile");
    }

    @NSManaged public var country: String?
    @NSManaged public var date: String?
    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var gender: String?
    @NSManaged public var image: NSData?
    @NSManaged public var lastName: String?
    @NSManaged public var nickname: String?

}
