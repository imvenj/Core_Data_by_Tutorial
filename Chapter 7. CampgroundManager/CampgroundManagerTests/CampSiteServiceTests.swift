//
//  CampSiteServiceTests.swift
//  CampgroundManagerTests
//
//  Created by venj on 12/19/17.
//  Copyright © 2017 Razeware. All rights reserved.
//

import XCTest
import CampgroundManager
import CoreData

class CampSiteServiceTests: XCTestCase {
  
    var campSiteService: CampSiteService!
    var coreDataStack: CoreDataStack!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        coreDataStack = TestCoreDataStack()
        campSiteService = CampSiteService(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        campSiteService = nil
        coreDataStack = nil
    }

    func testAddCampSite() {
        let campSite = campSiteService.addCampSite(1, electricity: true, water: true)
        XCTAssertTrue(campSite.siteNumber == 1, "Site number should be 1")
        XCTAssertTrue(campSite.electricity!.boolValue == true, "Site should have electricity")
        XCTAssertTrue(campSite.water!.boolValue == true, "Site should have water")
    }

    func testRootContextIsSavedAfterAddingCamper() {
        let derivedContext = coreDataStack.newDerivedContext()
        campSiteService = CampSiteService(managedObjectContext: derivedContext, coreDataStack: coreDataStack)
        expectation(forNotification: NSNotification.Name.NSManagedObjectContextDidSave, object: coreDataStack.mainContext) { (notification) -> Bool in
            return true
        }
        let campSite = campSiteService.addCampSite(1, electricity: true, water: true)
        XCTAssertNotNil(campSite, "Camp site should not be nil")
        waitForExpectations(timeout: 2.0) { (error) in
            XCTAssertNil(error, "Save did not occur")
        }
    }

    func testGetCampSiteWithMatchingSiteNumber() {
        _ = campSiteService.addCampSite(1, electricity: true, water: true)
        let campSite = campSiteService.getCampSite(1)
        XCTAssertNotNil(campSite, "A camp site should be returned.")
    }

    func testGetCampSiteWithNoMatchingSiteNumber() {
        _ = campSiteService.addCampSite(1, electricity: true, water: true)
        let campSite = campSiteService.getCampSite(2)
        XCTAssertNil(campSite, "No camp site should be returned.")
    }

    func testDeleteCampSiteWithMatchingSiteNumber() {
        _ = campSiteService.addCampSite(1, electricity: true, water: true)
        campSiteService.deleteCampSite(1)
        let campSite = campSiteService.getCampSite(1)
        XCTAssertNil(campSite, "Camp site should be deleted.")
    }

    func testDeleteCampSiteWithNoMatchingSiteNumber() {
        _ = campSiteService.addCampSite(1, electricity: true, water: true)
        campSiteService.deleteCampSite(2)
        let campSite = campSiteService.getCampSite(1)
        XCTAssertNotNil(campSite, "Camp site should not be deleted.")
    }

    func testGetCampSites() {
        (1...10).forEach {
            _ = campSiteService.addCampSite(NSNumber(value: $0), electricity: true, water: true)
        }

        let campSites = campSiteService.getCampSites()
        XCTAssertTrue(campSites.count == 10, "There should be 10 camp sites.")
    }

    func testGetNoCampSites() {
        let campSites = campSiteService.getCampSites()
        XCTAssertTrue(campSites.count == 0, "There should no camp site at all.")
    }

    func testGetNextSiteNumberWithCampSites() {
        (1...2).forEach {
            _ = campSiteService.addCampSite(NSNumber(value: $0), electricity: true, water: true)
        }
        let nextCampSiteNumber = campSiteService.getNextCampSiteNumber()
        XCTAssertTrue(nextCampSiteNumber == 3, "The next campsite should be 3.")
    }

    func testGetNextSiteNumberWithNoCampSite() {
        let nextCampSiteNumber = campSiteService.getNextCampSiteNumber()
        XCTAssertTrue(nextCampSiteNumber == 1, "There should be no more camp sites.")
    }


}
