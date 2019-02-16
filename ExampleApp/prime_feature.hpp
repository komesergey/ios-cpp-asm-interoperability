//
//  prime_feature.h
//  Example
//
//  Created by Edward Hyde on 13/02/2019.
//  Copyright © 2019 Edward Hyde. All rights reserved.
//

#ifndef prime_feature_h
#define prime_feature_h
#ifdef __cplusplus

#include <iostream>
#include <future>
#include <chrono>
#include <string>
#include <atomic>
#include <utility>

struct A { long a; long b; };
struct B { int x, y; };

inline long add(long x, long y) {
    long ret;
    asm volatile ("add %[ret], %[x], %[y]" : [ret]"=r"(ret) : [x]"r"(x), [y]"r"(y));
    return ret;
}

class prime_checker {
public:
    static bool is_prime (int x) {
        for (int i = 2; i < x; ++i) if (x % i == 0) return false;
        return true;
    }
    
    void checkIsPrime(std::string value, void(*progressCallback)(void*), void(*resultCallback)(bool result, void* target), void* target) {
        std::cout << "In c++ " << value << std::endl;
        std::future<bool> fut = std::async (std::launch::async, is_prime, std::stol(value));
        std::chrono::milliseconds span (100);
        while (fut.wait_for(span)==std::future_status::timeout)
            progressCallback(target);
        bool x = fut.get();
        resultCallback(x, target);
        std::cout << value << (x ? " is" : " is not") << " prime.\n";
    }
    
    void simpleCall(void(*function)(void* result, unsigned long resultLength, void* target), void* target){
        std::cout << "Down to c++" << std::endl;
        long b = 6;
        long f = 7;
        long res = add(f, b);
        std::cout << res << std::endl;
        std::string a = "struct A { long a; long b; };\nstruct B { int x, y; };\n";
        a = a + "std::atomic<A> is lock free? "
        + std::to_string(std::atomic<A>{}.is_lock_free()) + " " + std::to_string(sizeof(A)) + " bytes\n"
        + "std::atomic<B> is lock free? "
        + std::to_string(std::atomic<B>{}.is_lock_free()) + " " + std::to_string(sizeof(B)) + " bytes\n"
        + "After asm add(6, 7) " + std::to_string(res);
        std::cout << a << std::endl;
        char *cstr = new char[a.length() + 1];
        strcpy(cstr, a.c_str());
        function(cstr, a.length(), target);
    }
};


#endif
#endif
