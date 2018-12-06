//
//  CwlResult.swift
//  CwlUtils
//
//  Created by Matt Gallagher on 2015/02/03.
//  Copyright © 2015 Matt Gallagher ( https://www.cocoawithlove.com ). All rights reserved.
//
//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
//  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
//  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
//  SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
//  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
//  IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

import Foundation

public enum Result<Success, Failure> {
	case success(Success)
	case failure(Failure)
}

/// Either a Success value or an Failure error
public extension Result {
	/// Convenience tester/getter for the value
	public var value: Success? {
		switch self {
		case .success(let s): return s
		case .failure: return nil
		}
	}
	
	/// Convenience tester/getter for the error
	public var error: Failure? {
		switch self {
		case .success: return nil
		case .failure(let f): return f
		}
	}

	/// Test whether the result is an error.
	public var isSuccess: Bool {
		return !isFailure
	}

	/// Test whether the result is an error.
	public var isFailure: Bool {
		switch self {
		case .success: return false
		case .failure: return true
		}
	}

	/// Chains another Result to this one. In the event that this Result is a .Success, the provided transformer closure is used to transform the value into another value (of a potentially new type) and a new Result is made from that value. In the event that this Result is a .Failure, the next Result will have the same error as this one.
	public func map<U>(_ transform: (Success) -> U) -> Result<U, Failure> {
		switch self {
		case .success(let val): return .success(transform(val))
		case .failure(let e): return .failure(e)
		}
	}
	
	/// Chains another Result to this one. In the event that this Result is a .Success, the provided transformer closure is used to transform the value into another value (of a potentially new type) and a new Result is made from that value. In the event that this Result is a .Failure, the next Result will have the same error as this one.
	public func mapFailure<U>(_ transform: (Failure) -> U) -> Result<Success, U> {
		switch self {
		case .success(let val): return .success(val)
		case .failure(let err): return .failure(transform(err))
		}
	}
	
	/// Chains another Result to this one. In the event that this Result is a .Success, the provided transformer closure is used to generate another Result (wrapping a potentially new type). In the event that this Result is a .Failure, the next Result will have the same error as this one.
	public func flatMap<U>(_ transform: (Success) -> Result<U, Failure>) -> Result<U, Failure> {
		switch self {
		case .success(let val): return transform(val)
		case .failure(let e): return .failure(e)
		}
	}
	
	/// Chains another Result to this one. In the event that this Result is a .Success, the provided transformer closure is used to generate another Result (wrapping a potentially new type). In the event that this Result is a .Failure, the next Result will have the same error as this one.
	public func flatMapFailure<U>(_ transform: (Failure) -> Result<Success, U>) -> Result<Success, U> {
		switch self {
		case .success(let val): return .success(val)
		case .failure(let err): return transform(err)
		}
	}
}

public extension Result where Failure == Error {
	/// Construct a result from a `throws` function
	public init(_ capturing: () throws -> Success) {
		do {
			self = .success(try capturing())
		} catch {
			self = .failure(error)
		}
	}
	
	/// Adapter method used to convert a Result to a value while throwing on error.
	public func get() throws -> Success {
		switch self {
		case .success(let v): return v
		case .failure(let e): throw e
		}
	}

	/// Chains another Result to this one. In the event that this Result is a .Success, the provided transformer closure is used to transform the value into another value (of a potentially new type) and a new Result is made from that value. In the event that this Result is a .Failure, the next Result will have the same error as this one.
	public func mapThrows<U>(_ transform: (Success) throws -> U) -> Result<U, Failure> {
		switch self {
		case .success(let val): return Result<U, Failure> { try transform(val) }
		case .failure(let e): return .failure(e)
		}
	}
}
