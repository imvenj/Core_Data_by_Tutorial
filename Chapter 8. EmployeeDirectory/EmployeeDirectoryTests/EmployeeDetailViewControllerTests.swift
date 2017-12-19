/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import XCTest
import CoreData
@testable import EmployeeDirectory

class EmployeeDetailViewControllerTests: XCTestCase {

  func testCountSales() {
    measureMetrics([XCTPerformanceMetric.wallClockTime],
                   automaticallyStartMeasuring: false) {

      let employee = self.getEmployee()
      let employeeDetails = EmployeeDetailViewController()
      self.startMeasuring()
      _ = employeeDetails.salesCountForEmployee(employee)
      self.stopMeasuring()
    }
  }

  func testCountSalesFast() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let employee = self.getEmployee()
      let employeeDetails = EmployeeDetailViewController()
      self.startMeasuring()
      _ = employeeDetails.salesCountForEmployeeFast(employee)
      self.stopMeasuring()
    }
  }

  func testCountSalesSimple() {
    measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
      let employee = self.getEmployee()
      let employeeDetails = EmployeeDetailViewController()
      self.startMeasuring()
      _ = employeeDetails.salesCountForEmployeeSimple(employee)
      self.stopMeasuring()
    }
  }

  func getEmployee() -> Employee {
    let coreDataStack = CoreDataStack(modelName: "EmployeeDirectory")

    let request: NSFetchRequest<Employee> = NSFetchRequest(entityName: "Employee")

    request.sortDescriptors = [NSSortDescriptor(key: "guid", ascending: true)]
    request.fetchBatchSize = 1
    let results: [AnyObject]?
    do {
      results = try coreDataStack.mainContext.fetch(request)
    } catch _ {
      results = nil
    }
    return results![0] as! Employee
  }
}
