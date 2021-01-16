=========================
LLVM 12.0.0 Release Notes
=========================

.. contents::
    :local:

.. warning::
   These are in-progress notes for the upcoming LLVM 12 release.
   Release notes for previous releases can be found on
   `the Download Page <https://releases.llvm.org/download.html>`_.


Introduction
============

This document contains the release notes for the LLVM Compiler Infrastructure,
release 12.0.0.  Here we describe the status of LLVM, including major improvements
from the previous release, improvements in various subprojects of LLVM, and
some of the current users of the code.  All LLVM releases may be downloaded
from the `LLVM releases web site <https://releases.llvm.org/>`_.

For more information about LLVM, including information about the latest
release, please check out the `main LLVM web site <https://llvm.org/>`_.  If you
have questions or comments, the `LLVM Developer's Mailing List
<https://lists.llvm.org/mailman/listinfo/llvm-dev>`_ is a good place to send
them.

Note that if you are reading this file from a Git checkout or the main
LLVM web page, this document applies to the *next* release, not the current
one.  To see the release notes for a specific release, please see the `releases
page <https://llvm.org/releases/>`_.

Non-comprehensive list of changes in this release
=================================================

* The ConstantPropagation pass was removed. Users should use the InstSimplify
  pass instead.


* For MinGW, references to data variables that might need to be imported
  from a dll are accessed via a stub, to allow the linker to convert it to
  a dllimport if needed.

* Added support for labels as offsets in ``.reloc`` directive.

* Support for precise identification of X86 instructions with memory operands,
  by using debug information. This supports profile-driven cache prefetching.
  It is enabled with the ``-x86-discriminate-memops`` LLVM Flag.

* Support for profile-driven software cache prefetching on X86. This is part of
  a larger system, consisting of: an offline cache prefetches recommender,
  AutoFDO tooling, and LLVM. In this system, a binary compiled with
  ``-x86-discriminate-memops`` is run under the observation of the recommender.
  The recommender identifies certain memory access instructions by their binary
  file address, and recommends a prefetch of a specific type (NTA, T0, etc) be
  performed at a specified fixed offset from such an instruction's memory
  operand. Next, this information needs to be converted to the AutoFDO syntax
  and the resulting profile may be passed back to the compiler with the LLVM
  flag ``-prefetch-hints-file``, together with the exact same set of
  compilation parameters used for the original binary. More information is
  available in the `RFC
  <https://lists.llvm.org/pipermail/llvm-dev/2018-November/127461.html>`_.

* Windows support for libFuzzer (x86_64).


Changes to the LLVM IR
----------------------

* ...

* Added the ``byref`` attribute to better represent argument passing
  for the `amdgpu_kernel` calling convention.

* Added type parameter to the ``sret`` attribute to continue work on
  removing pointer element types.

* The ``llvm.experimental.vector.reduce`` family of intrinsics have been renamed
  to drop the "experimental" from the name, reflecting their now fully supported
  status in the IR.


Changes to building LLVM
------------------------

* The internal ``llvm-build`` Python script and the associated ``LLVMBuild.txt``
  files used to describe the LLVM component structure have been removed and
  replaced by a pure ``CMake`` approach, where each component stores extra
  properties in the created targets. These properties are processed once all
  components are defined to resolve library dependencies and produce the header
  expected by llvm-config.

Changes to TableGen
-------------------

* The new "TableGen Programmer's Reference" replaces the "TableGen Language
  Introduction" and "TableGen Language Reference" documents.

* The syntax for specifying an integer range in a range list has changed.
  The old syntax used a hyphen in the range (e.g., ``{0-9}``). The new syntax
  uses the "`...`" range punctuation (e.g., ``{0...9}``). The hyphen syntax
  is deprecated.


During this release ...

Changes to the MIPS Target
--------------------------

During this release ...


Changes to the PowerPC Target
-----------------------------

During this release ...

Changes to the X86 Target
-------------------------

During this release ...

* The 'mpx' feature was removed from the backend. It had been removed from clang
  frontend in 10.0. Mention of the 'mpx' feature in an IR file will print a
  message to stderr, but IR should still compile.
* Support for ``-march=alderlake``, ``-march=sapphirerapids``,
  ``-march=znver3`` and ``-march=x86-64-v[234]`` has been added.
* The assembler now has support for {disp32} and {disp8} pseudo prefixes for
  controlling displacement size for memory operands and jump displacements. The
  assembler also supports the .d32 and .d8 mnemonic suffixes to do the same.
* A new function attribute "tune-cpu" has been added to support -mtune like gcc.
  This allows microarchitectural optimizations to be applied independent from
  the "target-cpu" attribute or TargetMachine CPU which will be used to select
  Instruction Set. If the attribute is not present, the tune CPU will follow
  the target CPU.
* Support for ``HRESET`` instructions has been added.
* Support for ``UINTR`` instructions has been added.
* Support for ``AVXVNNI`` instructions has been added.

* New AVX512F gather and scatter intrinsics were added that take a <X x i1> mask
  instead of a scalar integer. This removes the need for a bitcast in IR. The
  new intrinsics are named like the old intrinsics with ``llvm.avx512.``
  replaced with ``llvm.avx512.mask.``. The old intrinsics will be removed in a
  future release.

During this release ...

* The new ``byref`` attribute is now the preferred method for
  representing aggregate kernel arguments.

* ADCX instruction will no longer be emitted. This instruction is rarely better
  than the legacy ADC instruction and just increased code size.

During this release ...

Changes to the WebAssembly Target
---------------------------------

During this release ...

Changes to the Nios2 Target
---------------------------

* The Nios2 target was removed from this release.

Changes to the C API
--------------------

* Printed source code is now syntax highlighted in the terminal (only for C
  languages).

* The expression command now supports tab completing expressions.

Changes to the Go bindings
--------------------------


Changes to the DAG infrastructure
---------------------------------


Changes to the Debug Info
---------------------------------

During this release ...

* The DIModule metadata is extended with a field to indicate if it is a
  module declaration. This extension enables the emission of debug info
  for a Fortran 'use <external module>' statement. For more information
  on what the debug info entries should look like and how the debugger
  can use them, please see test/DebugInfo/X86/dimodule-external-fortran.ll.

Changes to the LLVM tools
---------------------------------

* llvm-readobj and llvm-readelf behavior has changed to report an error when
  executed with no input files instead of reading an input from stdin.
  Reading from stdin can still be achieved by specifying `-` as an input file.

Changes to LLDB
---------------------------------

Changes to Sanitizers
---------------------

The integer sanitizer `-fsanitize=integer` now has a new sanitizer:
`-fsanitize=unsigned-shift-base`. It's not undefined behavior for an unsigned
left shift to overflow (i.e. to shift bits out), but it has been the source of
bugs and exploits in certain codebases in the past.

Many Sanitizers (asan, cfi, lsan, msan, tsan, ubsan) have support for
musl-based Linux distributions. Some of them may be rudimentary.

External Open Source Projects Using LLVM 12
===========================================

* A project...

Additional Information
======================

A wide variety of additional information is available on the `LLVM web page
<https://llvm.org/>`_, in particular in the `documentation
<https://llvm.org/docs/>`_ section.  The web page also contains versions of the
API documentation which is up-to-date with the Git version of the source
code.  You can access versions of these documents specific to this release by
going into the ``llvm/docs/`` directory in the LLVM tree.

If you have any questions or comments about LLVM, please feel free to contact
us via the `mailing lists <https://llvm.org/docs/#mailing-lists>`_.
