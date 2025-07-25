// This file contains defines allowing targeting byond versions newer than the supported
//Update this whenever you need to take advantage of more recent byond features
#define MIN_COMPILER_VERSION 516
#define MIN_COMPILER_BUILD 1650
#if DM_VERSION < MIN_COMPILER_VERSION || DM_BUILD < MIN_COMPILER_BUILD
//Don't forget to update this part
#error Your version of BYOND is too out-of-date to compile this project. Go to https://secure.byond.com/download and update.
#error You need version 513.1508 or higher
#endif

#if DM_VERSION == 514 && DM_BUILD >= 1585
#warn You are using BYOND 514.1585. There's a good chance that Auxtools will cause the project to compile incorrectly.area
#warn You can download an earlier version of BYOND from https://www.byond.com/download/build/514, if it doesn't work.
#endif // If this is fixed after 514.1585, please remove this warning.

#if DM_BUILD < 1540
#define AS as()
#else
#define AS as anything
#endif

// So we want to have compile time guarantees these procs exist on local type, unfortunately 515 killed the .proc/procname syntax so we have to use nameof()
#if DM_VERSION < 515
/// Call by name proc reference, checks if the proc exists on this type or as a global proc
#define PROC_REF(X) (.proc/##X)
/// Call by name proc reference, checks if the proc exists on given type or as a global proc
#define TYPE_PROC_REF(TYPE, X) (##TYPE.proc/##X)
/// Call by name proc reference, checks if the proc is existing global proc
#define GLOBAL_PROC_REF(X) (/proc/##X)
#else
/// Call by name proc reference, checks if the proc exists on this type or as a global proc
#define PROC_REF(X) (nameof(.proc/##X))
/// Call by name proc reference, checks if the proc exists on given type or as a global proc
#define TYPE_PROC_REF(TYPE, X) (nameof(##TYPE.proc/##X))
/// Call by name proc reference, checks if the proc is existing global proc
#define GLOBAL_PROC_REF(X) (/proc/##X)
#endif

// 515 split call for external libraries into call_ext
#if DM_VERSION < 515
#define LIBCALL call
#else
#define LIBCALL call_ext
#endif
