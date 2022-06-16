//===----------------------------------------------------------------------===//
//
// This source file is part of the Depends open source project
//
// Copyright (c) 2021 Unsigned Apps
// Licensed under MIT License
//
// See LICENSE for license information
// See CONTRIBUTING.md to contribute to this project
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

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
