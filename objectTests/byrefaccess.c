//
//  byrefaccess.m
//  test that byref access to locals is accurate
//  testObjects
//
//  Created by Blaine Garst on 5/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
// CONFIG

#include <stdio.h>


void callVoidVoid(void (^closure)(void)) {
    closure();
}

int main(int argc, char *argv[]) {
    __block int i = 10;
    
    callVoidVoid(^{ ++i; });
    
    if (i != 11) {
        printf("*** %s didn't update i\n", argv[0]);
        return 1;
    }
    printf("%s: success\n", argv[0]);
    return 0;
}