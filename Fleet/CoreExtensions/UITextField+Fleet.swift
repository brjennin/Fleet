import UIKit

private var isFocusedAssociatedKey: UInt = 0

extension UITextField {
    fileprivate var isFocusedInField: Bool? {
        get {
            let isFocusedValue = objc_getAssociatedObject(self, &isFocusedAssociatedKey) as? NSNumber
            return isFocusedValue?.boolValue
        }

        set {
            var isFocusedValue: NSNumber?
            if let newValue = newValue {
                isFocusedValue = NSNumber(value: newValue)
            }

            objc_setAssociatedObject(self, &isFocusedAssociatedKey, isFocusedValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

public enum FLTTextFieldError: Error {
    case disabledTextFieldError
}

extension UITextField {
    /**
        Enters the text field, firing the .EditingDidBegin events. It
        does not give the text field first responder.

        - Throws: `FLTTextFieldError.DisabledTextFieldError` if the
            text field is disabled.
    */
    public func enter() throws {
        if isFocusedInField != nil && isFocusedInField! {
            Logger.logWarning("Attempting to enter a UITextField that was already entered")
            return
        }

        if !isEnabled {
            throw FLTTextFieldError.disabledTextFieldError
        }

        isFocusedInField = true
        if let delegate = delegate {
            _ = delegate.textFieldShouldBeginEditing?(self)
            _ = delegate.textFieldDidBeginEditing?(self)
        }

        self.sendActions(for: .editingDidBegin)
    }

    /**
        Enters the text field, firing the .EditingDidEnd events. It
        does make the text field resign first responder.
    */
    public func leave() {
        if isFocusedInField == nil || !isFocusedInField! {
            Logger.logWarning("Attempting to leave a UITextField that was never entered")
            return
        }

        if let delegate = delegate {
            _ = delegate.textFieldShouldEndEditing?(self)
            _ = delegate.textFieldDidEndEditing?(self)
        }

        self.sendActions(for: .editingDidEnd)
        isFocusedInField = false
    }

    /**
        Enters the text field, enters the given text, and leaves it, firing
        the .EditingDidBegin, .EditingChanged, and .EditingDidEnd events
        as appropriate. Does not manipulate first responder.

        If the text field has no delegate, the text is still entered into the
        field and the .EditingChanged event is still fired.

        - Parameter text:   The text to type into the field

        - Throws: `FLTTextFieldError.DisabledTextFieldError` if the
            text field is disabled.
    */
    public func enterText(_ text: String) throws {
        try self.enter()
        self.typeText(text)
        self.leave()
    }

    /**
        Types the given text into the text field, firing the .EditingChanged
        event once for each character, as would happen had a real user
        typed the text into the field.

        If the text field has no delegate, the text is still entered into the
        field and the .EditingChanged event is still fired.

        - Parameter text:   The text to type into the field
    */
    public func typeText(_ text: String) {
        if isFocusedInField == nil || !isFocusedInField! {
            Logger.logWarning("Attempting to type \"\(text)\" into a UITextField that was never entered")
            return
        }

        if let delegate = delegate {
            self.text = ""
            for (index, char) in text.characters.enumerated() {
                _ = delegate.textField?(self, shouldChangeCharactersIn: NSRange.init(location: index, length: 1), replacementString: String(char))
                self.text?.append(char)
                self.sendActions(for: .editingChanged)
            }
        } else {
            self.text = ""
            for (_, char) in text.characters.enumerated() {
                self.text?.append(char)
                self.sendActions(for: .editingChanged)
            }
        }
    }

    /**
        Types the given text into the text field, firing the .EditingChanged
        event just once for the entire string, as would happen had a real user
        pasted the text into the field.

        If the text field has no delegate, the text is still entered into the
        field and the .EditingChanged event is still fired.

        - Parameter text:   The text to paste into the field
    */
    public func pasteText(_ text: String) {
        if isFocusedInField == nil || !isFocusedInField! {
            Logger.logWarning("Attempting to paste \"\(text)\" into a UITextField that was never entered")
            return
        }

        if let delegate = delegate {
            let length = text.characters.count
            _ = delegate.textField?(self, shouldChangeCharactersIn: NSRange.init(location: 0, length:length), replacementString: text)
        } else {
            self.text = text
        }

        self.sendActions(for: .editingChanged)
    }

    /**
        Clears all text from the text field, firing the textFieldShouldClear?
        event as happens when the user clears the field through the UI.

        If the text field has no delegate, the text is still cleared from the
        field.
     */
    public func clearText() {
        self.text = ""
        if let delegate = delegate {
            _ = delegate.textFieldShouldClear?(self)
        }
    }
}
