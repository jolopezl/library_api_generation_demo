%module library_tcl
%{
#define USE_TCL_STUBS
#include "library.h"
#include <tcl.h>
%}
#define USE_TCL_STUBS
%include "library.h"