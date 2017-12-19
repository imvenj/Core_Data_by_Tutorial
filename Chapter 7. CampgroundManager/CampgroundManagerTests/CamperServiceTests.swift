//
//  CamperServiceTests.swift
//  CampgroundManagerTests
//
//  Created by venj on 12/19/17.
//  Copyright © 2017 Razeware. All rights reserved.
//

import XCTest
import CampgroundManager
import CoreData

class CamperServiceTests: XCTestCase {

    var camperService: CamperService!
    var coreDataStack: CoreDataStack!
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        coreDataStack = TestCoreDataStack()
        camperService = CamperService(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        camperService = nil
        coreDataStack = nil
    }

    func testAddCamper() {
        let camper = camperService.addCamper("Bacon Lover", phoneNumber: "910-543-9000")
        XCTAssertNotNil(camper, "Camper should not be nil")
        XCTAssertTrue(camper?.fullName == "Bacon Lover")
        XCTAssertTrue(camper?.phoneNumber == "910-543-9000")
    }

    func testRootContextIsSavedAfterAddingCamper() {
        let derivedContext = coreDataStack.newDerivedContext()
        camperService = CamperService(managedObjectContext: derivedContext, coreDataStack: coreDataStack)
        expectation(forNotification: NSNotification.Name.NSManagedObjectContextDidSave, object: coreDataStack.mainContext) { (notification) -> Bool in
            return true
        }
        let camper = camperService.addCamper("Bacon Lover", phoneNumber: "910-543-9000")
        XCTAssertNotNil(camper, "Camper should not be nil")
        waitForExpectations(timeout: 2.0) { (error) in
            XCTAssertNil(error, "Save did not occur")
        }
    }
    
}
