// CONFIG GC

#import <Foundation/Foundation.h>

int GlobalInt = 0;
int GlobalInt2 = 0;

id objc_assign_weak(id value, id *location) {
    GlobalInt = 1;
    *location = value;
    return value;
}

id objc_read_weak(id *location) {
    GlobalInt2 = 1;
    return *location;
}

@interface Foo : NSObject {
@public
    void (^__weak ivar)(void);
}
@end
@implementation Foo
@end


int main(char *argc, char *argv[]) {
    // an object should not be retained within a stack Block
    __block int i = 0;
    void (^local)(void);
    Foo *foo = [[Foo alloc] init];
    foo->ivar = ^ {  ++i; };
    local = foo->ivar;
    if (GlobalInt2 == 1) {
        printf("%s: success\n", argv[0]);
        exit(0);
    }
    else {
        printf("%s: problem with weak read of ivar\n", argv[0]);
    }
    exit(1);
}
