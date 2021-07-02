// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: WIHDwResult.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <Protobuf/GPBProtocolBuffers_RuntimeSupport.h>
#else
 #import "GPBProtocolBuffers_RuntimeSupport.h"
#endif

#import "WihdwResult.pbobjc.h"
// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#pragma mark - WihdwResultRoot

@implementation WihdwResultRoot

// No extensions in the file and no imports, so no need to generate
// +extensionRegistry.

@end

#pragma mark - WihdwResultRoot_FileDescriptor

static GPBFileDescriptor *WihdwResultRoot_FileDescriptor(void) {
  // This is called by +initialize so there is no need to worry
  // about thread safety of the singleton.
  static GPBFileDescriptor *descriptor = NULL;
  if (!descriptor) {
    GPB_DEBUG_CHECK_RUNTIME_VERSIONS();
    descriptor = [[GPBFileDescriptor alloc] initWithPackage:@""
                                                     syntax:GPBFileSyntaxProto3];
  }
  return descriptor;
}

#pragma mark - HdwResult

@implementation HdwResult

@dynamic mnemonic;
@dynamic masterKey;
@dynamic hasKeyPair, keyPair;

typedef struct HdwResult__storage_ {
  uint32_t _has_storage_[1];
  NSString *mnemonic;
  NSData *masterKey;
  ExtendedKeyPair *keyPair;
} HdwResult__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "mnemonic",
        .dataTypeSpecific.className = NULL,
        .number = HdwResult_FieldNumber_Mnemonic,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(HdwResult__storage_, mnemonic),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "masterKey",
        .dataTypeSpecific.className = NULL,
        .number = HdwResult_FieldNumber_MasterKey,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(HdwResult__storage_, masterKey),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "keyPair",
        .dataTypeSpecific.className = GPBStringifySymbol(ExtendedKeyPair),
        .number = HdwResult_FieldNumber_KeyPair,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(HdwResult__storage_, keyPair),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[HdwResult class]
                                     rootClass:[WihdwResultRoot class]
                                          file:WihdwResultRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(HdwResult__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    NSAssert(descriptor == nil, @"Startup recursed!");
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - ExtendedKeyPair

@implementation ExtendedKeyPair

@dynamic extendedPrivateKey;
@dynamic extendedPublicKey;

typedef struct ExtendedKeyPair__storage_ {
  uint32_t _has_storage_[1];
  NSData *extendedPrivateKey;
  NSData *extendedPublicKey;
} ExtendedKeyPair__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "extendedPrivateKey",
        .dataTypeSpecific.className = NULL,
        .number = ExtendedKeyPair_FieldNumber_ExtendedPrivateKey,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(ExtendedKeyPair__storage_, extendedPrivateKey),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
      {
        .name = "extendedPublicKey",
        .dataTypeSpecific.className = NULL,
        .number = ExtendedKeyPair_FieldNumber_ExtendedPublicKey,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(ExtendedKeyPair__storage_, extendedPublicKey),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeBytes,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[ExtendedKeyPair class]
                                     rootClass:[WihdwResultRoot class]
                                          file:WihdwResultRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(ExtendedKeyPair__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    NSAssert(descriptor == nil, @"Startup recursed!");
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
