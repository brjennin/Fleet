import XCTest
import Fleet
import Nimble

class UIViewController_FleetSpec: XCTestCase {
    private class TestViewController: UIViewController {
        var viewDidLoadCallCount: UInt = 0

        private override func viewDidLoad() {
            super.viewDidLoad()
            viewDidLoadCallCount += 1
        }
    }

    func test_presentViewController_immediatelyPresentsTheViewController() {
        let bottom = UIViewController()
        let top = UIViewController()

        bottom.presentViewController(top, animated: true, completion: nil)

        expect(bottom.presentedViewController).to(beIdenticalTo(top))
        expect(top.presentingViewController).to(beIdenticalTo(bottom))
    }

    func test_dismissViewController_immediatelyDismissesThePresentedViewController() {
        let bottom = UIViewController()
        let top = UIViewController()

        bottom.presentViewController(top, animated: true, completion: nil)

        bottom.dismissViewControllerAnimated(true, completion: nil)
        expect(bottom.presentedViewController).to(beNil())
        expect(top.presentingViewController).to(beNil())
    }

    func test_presentViewController_immediatelyExecutesTheGivenCompletionHandler() {
        let bottom = UIViewController()
        let top = UIViewController()

        var didFireCompletionHandler = false
        let completionHandler = {
            didFireCompletionHandler = true
        }

        bottom.presentViewController(top, animated: true, completion: completionHandler)

        expect(didFireCompletionHandler).to(beTrue())
    }

    func test_dismissViewController_immediatelyExecutesTheGivenCompletionHandler() {
        let bottom = UIViewController()
        let top = UIViewController()

        bottom.presentViewController(top, animated: true, completion: nil)

        var didFireCompletionHandler = false
        let completionHandler = {
            didFireCompletionHandler = true
        }

        bottom.dismissViewControllerAnimated(true, completion: completionHandler)

        expect(didFireCompletionHandler).to(beTrue())
    }

    func test_showViewController_immediatelyPresentsTheViewController() {
        let bottom = UIViewController()
        let top = UIViewController()

        bottom.showViewController(top, sender: nil)

        expect(bottom.presentedViewController).to(beIdenticalTo(top))
        expect(top.presentingViewController).to(beIdenticalTo(bottom))
    }

    func test_presentViewController_immediatelyLoadsThePresentedViewController() {
        let bottom = UIViewController()
        let top = TestViewController()

        bottom.presentViewController(top, animated: true, completion: nil)
        expect(top.viewDidLoadCallCount).to(equal(1))
    }

    func test_presentViewController_doesNotLoadPresentedViewControllerMultipleTimes() {
        let bottom = UIViewController()
        let top = TestViewController()

        bottom.presentViewController(top, animated: true, completion: nil)
        expect(top.viewDidLoadCallCount).toEventuallyNot(beGreaterThan(1))
    }
}
