//
//  AnyCancellable+AnyHashable.swift
//  Depends
//
//  Created by Rob Amos on 10/11/21.
//

#if canImport(Combine)

import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension AnyCancellable {

    /// Stores this type-erasing cancellable instance in the specified set.
    ///
    /// - Parameter set: The set in which to store this ``AnyCancellable``.
    ///
    final public func store(in set: inout Set<AnyHashable>) {
        set.insert(AnyHashable(self))
    }

}

#endif
