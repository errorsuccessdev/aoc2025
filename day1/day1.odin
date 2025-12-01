package day1

import "core:mem"
import "core:fmt"
import os "core:os/os2"
import "core:strings"
import "core:strconv"

main :: proc()
{
    when ODIN_DEBUG 
    {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)
		defer 
        {
			if len(track.allocation_map) > 0 
            {
				for _, entry in track.allocation_map 
                {
					fmt.eprintfln("Error: %v leaked %v bytes\n", 
                                  entry.location, entry.size)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

    when ODIN_DEBUG 
    { 
        rotationsFile := "rotations_example.txt" 
    } 
    else 
    { 
        rotationsFile := "rotations.txt"
    }

    // Get rotations in a format we can use
    fp, fpErr := os.open(rotationsFile)
    assert(fpErr == nil)
    buffer: [40960]u8
    n, readErr := os.read(fp, buffer[:])
    assert(readErr == nil)
    str, strErr := strings.clone_from_bytes(buffer[:n])
    assert(strErr == nil)
    defer delete(str)
    rotations, rotErr := strings.split(str, "\n")
    assert(rotErr == nil)
    defer delete(rotations)

    // "Rotate" dial
    dial := 50
    password := 0
    for r in rotations
    {
        // Skip empty lines
        if len(r) == 0 do continue
        // Do rotation
        rotationAmount, ok := strconv.parse_int(r[1:])
        assert(ok)
        numRotations := 0
        for rotationAmount > 100
        {
            rotationAmount -= 100
            numRotations += 1
        }
        password += numRotations
        when ODIN_DEBUG do fmt.printfln("=== Rotation %v ===", r)
        if r[0] == 'L'
        {
            for i := rotationAmount; i > 0; i -= 1
            {
                dial -= 1
                if dial == 0 do password += 1
                else if dial == -1 do dial = 99
                when ODIN_DEBUG do fmt.printfln("Dial is %v", dial)
            }
        }
        else if r[0] == 'R'
        {
            for i := 0; i < rotationAmount; i += 1
            {
                dial += 1
                if dial == 100 do dial = 0
                if dial == 0 do password += 1
                when ODIN_DEBUG do fmt.printfln("Dial is %v", dial)
            }
        }
        else
        {
            fmt.eprintfln("First character of rotation not valid! %v", r)
            break
        }
    }
    fmt.printfln("Password: %v", password)
}