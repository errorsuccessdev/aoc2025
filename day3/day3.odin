package day2

import "core:mem"
import "core:fmt"
import os "core:os/os2"
import "core:strings"
import "core:strconv"

getHighestNumber :: proc(str: string, start: int = 9) -> 
                        (highest: int, pos: int)
{
    for i := start; i >= 0; i -= 1
    {
        for c, cIndex in str
        {
            n := int(c - '0')
            if n == i do return n, cIndex
        }
    }
    return -1, -1
}

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
        inputFile := "batteries_example.txt" 
    } 
    else 
    { 
        inputFile := "batteries.txt"
    }

    // Get input in a format we can use
    fp, fpErr := os.open(inputFile)
    assert(fpErr == nil)
    buffer: [40960]u8
    n, readErr := os.read(fp, buffer[:])
    assert(readErr == nil)
    rawStr, strErr := strings.clone_from_bytes(buffer[:n])
    assert(strErr == nil)
    defer delete(rawStr)
    str, wasAlloc := strings.split(rawStr, "\n")
    defer delete(str)

    // Process input
    cumulativeHighest: int
    for s in str
    {
        if len(s) == 0 do continue // skip empty lines
        when ODIN_DEBUG do fmt.printfln("%v =====", s)
        highest, tensPlace, tpPos, onesPlace, opPos: int
        i := 10 // start at 10 since we decrement immediately
        for
        {
            i -= 1 // this needs to be up here for continue trickery
            tensPlace, tpPos := getHighestNumber(s, i)
            assert(tensPlace != -1 && tpPos != -1)
            if tpPos >= len(s) - 1 do continue
            else do when ODIN_DEBUG
            {
                fmt.printfln("Tens place: %v at pos %v", tensPlace, tpPos)
            }
            onesPlace, opPos = getHighestNumber(s[tpPos+1:])
            if opPos != -1
            {
                when ODIN_DEBUG
                {
                    fmt.printfln("Ones place: %v at pos %v", onesPlace, opPos)
                }
                highest = (10 * tensPlace) + onesPlace
                break
            }
        }
        when ODIN_DEBUG do fmt.printfln("Highest: %v", highest)
        cumulativeHighest += highest
    }
    fmt.printfln("Cumulative highest values: %v", cumulativeHighest)
    
    // Process batteries
   
    //fmt.printfln("Cumulative 'joltage': %v", ret)
}