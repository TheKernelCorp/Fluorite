lib LibBootstrap
  @[Packed]
  struct StartInfo
    multiboot_ptr : UInt32
    end_of_kernel : UInt32
  end
end

fun kmain(info: LibBootstrap::StartInfo)
    # TODO: Implement
end