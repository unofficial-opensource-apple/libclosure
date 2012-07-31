//
//  recoverextra.M
//  testObjects
//
//  Created by Blaine Garst on 10/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

// TEST_CONFIG MEM=gc rdar://6289367
// TEST_CFLAGS -framework Foundation

#import <objc/objc-auto.h>
#import <Foundation/Foundation.h>
#import <Block.h>
#import "test.h"

int constructors = 0;
int destructors = 0;


#import <Block_private.h>

void hack(void *block) {
    printf("Block_dump says: %s\n", _Block_dump(block));
}

#define CONST const

class TestObject
{
public:
	TestObject(CONST TestObject& inObj);
	TestObject();
	~TestObject();
	
	TestObject& operator=(CONST TestObject& inObj);

	int version() CONST { return _version; }
private:
	mutable int _version;
};

TestObject::TestObject(CONST TestObject& inObj)
	
{
        ++constructors;
        _version = inObj._version;
	//printf("%p (%d) -- TestObject(const TestObject&) called\n", this, _version); 
}


TestObject::TestObject()
{
        _version = ++constructors;
	//printf("%p (%d) -- TestObject() called\n", this, _version); 
}


TestObject::~TestObject()
{
	//printf("%p -- ~TestObject() called\n", this);
        ++destructors;
}


TestObject& TestObject::operator=(CONST TestObject& inObj)
{
	//printf("%p -- operator= called\n", this);
        _version = inObj._version;
	return *this;
}


void testRoutine() {
    TestObject one;
    int i = 10;
    int (^intblock)(void) = ^{ printf("have i at %d\n", i); return i; };
    void (^b)(void) = [^{ printf("my copy of one is %d, and intblock is %d\n", one.version(), intblock()); } copy];
#if 0
// just try one copy, one release
    for (int i = 0; i < 10; ++i)
        [b retain];
    for (int i = 0; i < 10; ++i)
        [b release];
    for (int i = 0; i < 10; ++i)
        Block_copy(b);
    for (int i = 0; i < 10; ++i)
        Block_release(b);
#endif
    //hack(^{ printf("my copy of one is %d\n", one.version()); });
    //hack(b);
    [b release];
}

int main() {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    for (int i = 0; i < 200; ++i)   // do enough to trigger TLC if GC is on
        testRoutine();
    objc_collect(OBJC_EXHAUSTIVE_COLLECTION | OBJC_WAIT_UNTIL_DONE);
    [pool drain];

    if ((destructors + 10) < constructors) {   // allow some GC slop
        fail("didn't recover %d const copies", constructors - destructors);
    }

    succeed(__FILE__);
}
