**************************************
Snap packaging for gnuchess and XBoard

**************************************

To build:

 1. make snap

This will:

 1. Fetch gnuchess, xboard and the book's png files.
 2. Patch xboard to remove one syscall which has no snap interface yet.
 3. Build the book.bin, for which it needs to build gnuchess itself.
 4. Create a snap with gnuchess and xboard, and the book.bin

NOTES
=====

The patching in step 2 removes one call to nice, which issues a "setpriority"
syscall which is currently not allowed by any snap interfaces. Without this
patch, the snap would have to be installed in dev mode, which I think is
unacceptable. This is the only change required to either program's source
code prior to building the snap.
