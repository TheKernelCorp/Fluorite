# Alignment constants
private ADDRESS_ALIGNMENT   = 8_u32
private BLOCK_SIZE_MULTIPLE = 8_u32

# Guards to check for heap corruption
private GUARD1 = 0x464c554f_u32 # FLUO
private GUARD2 = 0x52495445_u32 # RITE

# Alias block to make it easer to use
private alias Block = LibHeap::Block

# Low level stuff
private lib LibHeap
  @[Packed]
  struct Block
    bsize : UInt32
    bnext : Block*
    bdata : UInt8*
  end
end

# Generic heap allocator
module HeapAllocator(T)
  extend self

  # Allocates a block of uninitialized memory.
  def kalloc : T*

    # Allocate memory
    block = Heap.kalloc sizeof(T).to_u32

    # Cast allocated block to target type
    block.as T*
  end
end

module Heap
  extend self

  # Module variables
  @@next_addr = Pointer(UInt8).null # free_addr
  @@next_free = Pointer(Block).null # free_top
  @@last_used = Pointer(Block).null # used_top

  def init(end_of_kernel : UInt32)

    # Align starting address
    next_addr_aligned = align_address end_of_kernel

    # Create pointer to aligned starting address
    @@next_addr = Pointer(UInt8).new next_addr_aligned.to_u64
  end

  # Validates the heap.
  # Iterates over all used blocks and tests guard integrity.
  def validate
    
    # Get the last used block
    current_block = @@last_used

    # Loop while the current block is valid
    while current_block

      # Get the guard values
      guard1 = (current_block.value.bdata - sizeof(GUARD1)).as(UInt32*).value
      guard2 = (current_block.value.bdata + current_block.value.bsize).as(UInt32*).value

      # Validate guard integrity
      raise "HEAP_VALIDATE_FAIL_GUARD1" unless guard1 == GUARD1
      raise "HEAP_VALIDATE_FAIL_GUARD2" unless guard2 == GUARD2

      # Get the next block
      current_block = current_block.value.bnext
    end
  end

  def kalloc(size : UInt32) : Void*

    # Allocate a block
    block = alloc size

    # Return the user data
    block.value.bdata.as Void*
  end

  # Allocates a block.
  private def alloc(size : UInt32) : Block*

    # Align the block size to the block size multiple
    size = align_block_size size

    # Try to find an existing block of sufficient size.
    # If that fails, allocate a new block.
    block = find_or_alloc_block size

    # Raise if the block is invalid
    raise "Unable to allocate memory!" unless block

    # Link the block to the last used one
    block.value.bnext = @@last_used

    # Mark this block as the last used one
    @@last_used = block

    # Return the block
    block
  end

  # Tries to find a block of sufficient size.
  # If no block is found, a new one is allocated.
  private def find_or_alloc_block(size : UInt32) : Block* | Nil
    
    # Try finding a block of sufficient size
    block = find_block size

    # If no block was found
    unless block

      # Allocate space for a new block structure
      block_size = align_block_size sizeof(Block).to_u32
      block_data = alloc_block block_size

      # Cast the allocated space to a block pointer
      block = block_data.as Block*

      # Return Nil if the allocation failed
      return unless block
      
      # Set the block size
      block.value.bsize = size

      # Allocate the actual data block
      user_data = alloc_block size

      # If the data block allocation failed
      unless user_data

        # Deallocate the previously allocated block
        block_size_total_aligned = align_address calc_block_size block_size
        @@next_addr -= block_size_total_aligned.to_i32

        # Return Nil
        return
      end

      # Set the block data pointer
      block.value.bdata = user_data
    end

    # Return the block
    block
  end

  # Attempts to find a fitting block.
  # Uses first-fit linear search.
  private def find_block(size : UInt32) : Block* | Nil
    # TODO
  end

  # Allocates a raw data block.
  # Adds guards before and after the block.
  # Returns the data chunk.
  private def alloc_block(size : UInt32) : UInt8*

    # Get the next unused address
    addr = @@next_addr

    # Write the first guard
    addr.as(UInt32*).value = GUARD1

    # Get the start of the data block
    addr_data_start = addr.offset sizeof(GUARD1)

    # Skip behind the data block
    addr = addr_data_start.offset size

    # Write the second guard
    addr.as(UInt32*).value = GUARD2

    # Offset the next unused address
    @@next_addr += align_address calc_block_size size
    
    # Return the allocated data block
    addr_data_start
  end

  private def realloc(ptr : _*, size : UInt32) : UInt8*
    # TODO
    raise "Heap#realloc not implemented!"
  end

  private def free(ptr : _*)
    # TODO
    raise "Heap#free not implemented!"
  end

  # Calculates the total size of a block.
  # Includes guards and data chunk.
  @[AlwaysInline]
  private def calc_block_size(size : UInt32) : UInt32
    size + sizeof(GUARD1) + sizeof(GUARD2)
  end

  # Rounds a number up to a specific nearest multiple.
  @[AlwaysInline]
  private def align(num : UInt32, multiple : UInt32) : UInt32
    t = num + multiple - 1
    t - t % multiple
  end

  # Aligns an address.
  @[AlwaysInline]
  private def align_address(addr : UInt32) : UInt32
    align addr, ADDRESS_ALIGNMENT
  end

  # Aligns the size of a block.
  @[AlwaysInline]
  private def align_block_size(size : UInt32) : UInt32
    align size, BLOCK_SIZE_MULTIPLE
  end
end
