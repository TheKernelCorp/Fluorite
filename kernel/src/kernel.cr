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

  # Initialize stuff
  GDT.init
  Heap.init info.end_of_kernel
  PIC.remap
  PIC.enable
end

fun kmain
  kprint "Hello from Fluorite."
end
