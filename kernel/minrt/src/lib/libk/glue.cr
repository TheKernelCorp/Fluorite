# Fluorite assembly glue

fun glue_handle_isr(frame : LibIDT::StackFrame)
  IDT.handle_isr frame
end

lib LibGlue
  fun idt_init = "glue_init_idt"
end

# This stuff is required by the Crystal runtime

fun memset(ptr : Void*, val : UInt8, count : UInt32)
  LibK.memset ptr, val, count
end
