#import "TQNodeString.h"
#import "../TQProgram.h"

using namespace llvm;

@implementation TQNodeString
@synthesize value=_value;

+ (TQNodeString *)nodeWithString:(NSString *)aStr
{
    TQNodeString *node = [[self alloc] init];
    node.value = aStr;
    return [node autorelease];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<str@ \"%@\">", _value];
}

- (void)dealloc
{
    [_value release];
    [super dealloc];
}

- (TQNode *)referencesNode:(TQNode *)aNode
{
    // All string refs must be unique since they are mutable
    return nil;
}


- (llvm::Value *)generateCodeInProgram:(TQProgram *)aProgram block:(TQNodeBlock *)aBlock error:(NSError **)aoError
{
    Module *mod = aProgram.llModule;
    IRBuilder<> *builder = aBlock.builder;

    // Returns [NSMutableString stringWithUTF8String:_value]
    Value *selector = builder->CreateLoad(mod->getOrInsertGlobal("TQStringWithUTF8StringSel", aProgram.llInt8PtrTy));
    Value *klass    = mod->getOrInsertGlobal("OBJC_CLASS_$_NSMutableString", aProgram.llInt8Ty);

    Value *strValue = [aProgram getGlobalStringPtr:_value inBlock:aBlock];

    return builder->CreateCall3(aProgram.objc_msgSend, klass, selector, strValue);
}
@end
