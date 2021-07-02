// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: WIHDwResult.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <Protobuf/GPBProtocolBuffers.h>
#else
 #import "GPBProtocolBuffers.h"
#endif

#if GOOGLE_PROTOBUF_OBJC_VERSION < 30002
#error This file was generated by a newer version of protoc which is incompatible with your Protocol Buffer library sources.
#endif
#if 30002 < GOOGLE_PROTOBUF_OBJC_MIN_SUPPORTED_VERSION
#error This file was generated by an older version of protoc which is incompatible with your Protocol Buffer library sources.
#endif

// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

CF_EXTERN_C_BEGIN

@class ExtendedKeyPair;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - WihdwResultRoot

/**
 * Exposes the extension registry for this file.
 *
 * The base class provides:
 * @code
 *   + (GPBExtensionRegistry *)extensionRegistry;
 * @endcode
 * which is a @c GPBExtensionRegistry that includes all the extensions defined by
 * this file and all files that it depends on.
 **/
@interface WihdwResultRoot : GPBRootObject
@end

#pragma mark - HdwResult

typedef GPB_ENUM(HdwResult_FieldNumber) {
  HdwResult_FieldNumber_Mnemonic = 1,
  HdwResult_FieldNumber_MasterKey = 2,
  HdwResult_FieldNumber_KeyPair = 3,
};

/**
 * Hierarchical deterministic wallet result.
 **/
@interface HdwResult : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *mnemonic;

@property(nonatomic, readwrite, copy, null_resettable) NSData *masterKey;

@property(nonatomic, readwrite, strong, null_resettable) ExtendedKeyPair *keyPair;
/** Test to see if @c keyPair has been set. */
@property(nonatomic, readwrite) BOOL hasKeyPair;

@end

#pragma mark - ExtendedKeyPair

typedef GPB_ENUM(ExtendedKeyPair_FieldNumber) {
  ExtendedKeyPair_FieldNumber_ExtendedPrivateKey = 1,
  ExtendedKeyPair_FieldNumber_ExtendedPublicKey = 2,
};

/**
 * Extended KeyPair.
 **/
@interface ExtendedKeyPair : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSData *extendedPrivateKey;

@property(nonatomic, readwrite, copy, null_resettable) NSData *extendedPublicKey;

@end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
