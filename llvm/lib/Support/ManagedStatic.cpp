//===-- ManagedStatic.cpp - Static Global wrapper -------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the ManagedStatic class and llvm_shutdown().
//
//===----------------------------------------------------------------------===//

#include "llvm/Support/ManagedStatic.h"
#include "llvm/Config/config.h"
#include "llvm/Support/Threading.h"
#include <cassert>
// #include <mutex>
using namespace llvm;

static const ManagedStaticBase *StaticList = nullptr;
static void *ManagedStaticMutex = nullptr;
static llvm::once_flag mutex_init_flag;

static void initializeMutex() {
  // ManagedStaticMutex = new std::recursive_mutex();
}

static void *getManagedStaticMutex() {
  llvm::call_once(mutex_init_flag, initializeMutex);
  return ManagedStaticMutex;
}

void ManagedStaticBase::RegisterManagedStatic(void *(*Creator)(),
                                              void (*Deleter)(void*)) const {
    Ptr = Creator();
    DeleterFn = Deleter;
    // Add to list of managed statics.
    Next = StaticList;
    StaticList = this;

}

void ManagedStaticBase::destroy() const {
  assert(DeleterFn && "ManagedStatic not initialized correctly!");
  assert(StaticList == this &&
         "Not destroyed in reverse order of construction?");
  // Unlink from list.
  StaticList = Next;
  Next = nullptr;

  // Destroy memory.
  DeleterFn(Ptr);

  // Cleanup.
  Ptr = nullptr;
  DeleterFn = nullptr;
}

/// llvm_shutdown - Deallocate and destroy all ManagedStatic variables.
void llvm::llvm_shutdown() {
  // std::lock_guard<std::recursive_mutex> Lock(*getManagedStaticMutex());

  while (StaticList)
    StaticList->destroy();
}
