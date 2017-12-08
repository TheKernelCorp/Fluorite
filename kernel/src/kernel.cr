require "../minrt/src/prelude"

lib LibBootstrap
  @[Packed]
  struct StartInfo
    multiboot_ptr : UInt32
    end_of_kernel : UInt32
  end
end

fun kearly(info_ptr: LibBootstrap::StartInfo*)

  # Get the startup info
  info = info_ptr.value

  # Initialize heap
  Heap.init info.end_of_kernel

  # Initialize all the important stuff
  GDT.init
  PIC.remap
  PIC.enable
end

fun kmain
  kprint "Hello from Fluorite."
end
