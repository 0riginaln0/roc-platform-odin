package platform

import "core:fmt"

import "base:runtime"
import "core:c"
import "core:mem"
import "core:os"
import "core:sys/posix"

main :: proc() {
	context = runtime.default_context()

	fmt.println("Hellope bird!")
	str: RocStr
	roc__main_for_host_1_exposed_generic(&str)

	str_len := roc_str_len(str)
	str_bytes: [^]u8

	if is_small_str(str) {
		str_bytes = cast([^]u8)&str
	} else {
		str_bytes = cast([^]u8)str.bytes
	}

	// Write to stdout (fd = 1)
	_, err := os.write(1, str_bytes[:str_len])
	if err != os.ERROR_NONE {
		fmt.eprintf("Error writing to stdout: %s\n", os.error_string(err))
		os.exit(1)
	}

	os.exit(0)
}

RocStr :: struct {
	bytes:    cstring,
	len:      c.size_t,
	capacity: c.size_t,
}

foreign _ {
	roc__main_for_host_1_exposed_generic :: proc(str: ^RocStr) ---
}


roc_str_len :: proc "c" (str: RocStr) -> c.size_t {
	bytes := transmute([^]u8)str.bytes
	last_byte: u8 = bytes[size_of(str) - 1]
	last_byte_xored := last_byte ~ 0b10000000
	small_len := c.size_t(last_byte_xored)
	big_len := str.len

	if (is_small_str(str)) {
		return small_len
	} else {
		return big_len
	}
}

is_small_str :: proc "c" (str: RocStr) -> bool {
	return c.ssize_t(str.capacity) < 0
}

roc_getppid :: proc "c" () -> c.int {
	when os.OS == .Windows {
		return 0
	} else {
		return transmute(c.int)posix.getppid()
	}
}

roc_mmap :: proc "c" (
	addr: rawptr,
	length: c.int,
	prot: c.int,
	flags: c.int,
	fd: c.int,
	offset: c.int,
) -> rawptr {
	when os.OS == .Windows {
		return addr
	} else {
		return posix.mmap(
			addr,
			uint(length),
			transmute(posix.Prot_Flags)prot,
			transmute(posix.Map_Flags)flags,
			posix.FD(fd),
			posix.off_t(offset),
		)
	}
}

roc_shm_open :: proc "c" (name: cstring, oflag: c.int, mode: c.int) -> c.int {
	when os.OS == .Windows {
		return 0
	} else {
		return(
			transmute(c.int)posix.shm_open(
				name,
				transmute(posix.O_Flags)oflag,
				transmute(posix.mode_t)mode,
			) \
		)
	}
}

roc_alloc :: proc "c" (size: int, alignment: int) -> rawptr {
	context = runtime.default_context()
	data, err := runtime.mem_alloc(size)
	return raw_data(data) if err == .None else nil
}

roc_realloc :: proc "c" (ptr: rawptr, new_size: int, old_size: int, alignment: int) -> rawptr {
	context = runtime.default_context()
	data, err := runtime.mem_resize(ptr, old_size, new_size, alignment)
	return raw_data(data) if err == .None else nil
}

roc_dealloc :: proc "c" (ptr: rawptr, alignment: int) {
	context = runtime.default_context()
	runtime.mem_free(ptr)
}

roc_panic :: proc "c" (ptr: rawptr, alignment: int) {
	context = runtime.default_context()
	msg := cast(cstring)ptr
	fmt.eprintf("Application crashed with message\n\n    %s\n\nShutting down\n", msg)
	os.exit(1)
}

roc_dbg :: proc "c" (loc, msg, src: cstring) {
	context = runtime.default_context()
	fmt.eprintf("[%s] %s = %s\n", loc, src, msg)
}

roc_memset :: proc "c" (str: rawptr, cc: c.int, n: c.size_t) -> rawptr {
	return mem.set(str, byte(cc), int(n))
}
