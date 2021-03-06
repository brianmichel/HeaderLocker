//
//  HelmetPlugin.m
//  HelmetPlugin
//
//  Created by Brian Michel on 10/2/14.
//    Copyright (c) 2014 BSM. All rights reserved.
//
#import <objc/runtime.h>

#import "HelmetPlugin.h"
#import "NSViewController+Helmet.h"

static HelmetPlugin *sharedPlugin;

@interface HelmetPlugin()

@property (nonatomic, strong, readwrite) NSBundle *bundle;

@end

@implementation HelmetPlugin

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = NSClassFromString(@"IDESourceCodeEditor");
        
        [[self class] swizzleClass:class exchange:@selector(setDocument:) with:@selector(hl_setDocument:)];
        [[self class] swizzleClass:class exchange:@selector(setTextView:) with:@selector(hl_setTextView:)];
    });
}

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
    }
    return self;
}

+ (void)swizzleClass:(Class)aClass exchange:(SEL)origMethod with:(SEL)altMethod
{
    method_exchangeImplementations(class_getInstanceMethod(aClass, origMethod),
                                   class_getInstanceMethod(aClass, altMethod));
}

@end
