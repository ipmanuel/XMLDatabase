//
//  Mutex.swift
//  Commentariis
//
//  Created by Manuel Pauls on 09.01.21.
//
//  Source: https://github.com/jVirus/concurrency-kit/
//  Licence: MIT
//


import Foundation

/// Used to protect shared resources. A mutex is owned by the task that takes it. In a given region of code only one thread is active.
final public class Mutex {
    
    // MARK: - Properties
    
    private var mutex = pthread_mutex_t()
    
    // MARK: - Init & Deinit
    
    init() {
        let result = pthread_mutex_init(&mutex, nil)
        assert(result == 0, "Failed to init mutex in \(self)")
    }
    
    deinit {
        destroy()
    }
   
    // MARK: - Methods
    
    @discardableResult
    public func tryLock() -> Int32 {
        return pthread_mutex_trylock(&mutex)
    }
    
    // MARK: - Conformance to LockType protocol
    
    public func lock() {
        pthread_mutex_lock(&mutex)
    }
    
    public func unlock() {
        pthread_mutex_unlock(&mutex)
    }
   
    // MARK: - Private methods
    
    private func destroy() {
        pthread_mutex_destroy(&mutex)
    }
}

public extension Mutex {
    func withCriticalScope<R>(body: () throws -> R) rethrows -> R {
        lock()
        defer { unlock() }
        return try body()
    }
}