package day2

import "core:mem"
import "core:fmt"
import os "core:os/os2"
import "core:strings"
import "core:strconv"

removeSmallestNumbers :: proc(str: string, removeMe: string,
                              removeMax: int) -> 
                             (new: string, numRemoved: int)
{
    nr: int
    s := str
    for i in 0..<removeMax
    {
        sTemp, _ := strings.remove(s, removeMe, 1)
        if len(sTemp) == len(s) do break
        nr += 1
        s = sTemp
    }
    return s, nr
}

intToString :: proc(i: int) -> string
{
    ensure(i >= 1 && i <= 9)
    switch i
    {
        case 1: return "1"
        case 2: return "2"
        case 3: return "3"
        case 4: return "4"
        case 5: return "5"
        case 6: return "6"
        case 7: return "7"
        case 8: return "8"
        case 9: return "9"
    }
    return "unimplemented"
}

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
    /*
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
    */

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
    BATTERIES_TO_TURN_ON :: 12
    cumulativeHighest: int
    for s in str
    {
        if len(s) == 0 do continue // skip empty lines
        when ODIN_DEBUG do fmt.printfln("%v =====", s)
        removeMax := len(s) - BATTERIES_TO_TURN_ON
        when ODIN_DEBUG do fmt.printfln("Remove max is %v", removeMax)
        numRemoved, highest, pos: int
        highestStr, endStr: string
        for i := 9; i > 0; i -= 1
        {
            highest, pos = getHighestNumber(s, i)
            if pos < removeMax
            {
                highestStr = intToString(highest)
                break
            }
        }
        subStr := s[pos+1:]
        removeMax = len(subStr) - BATTERIES_TO_TURN_ON + 1
        for i in 1..<10
        {
            when ODIN_DEBUG do fmt.printfln("Remove max is %v", removeMax)
            r := intToString(i)
            s2, nr := removeSmallestNumbers(subStr, r, removeMax)
            numRemoved += nr
            removeMax -= nr
            when ODIN_DEBUG
            {
                fmt.printfln("Removed %v %v times", r, nr)
                fmt.println(subStr)
                fmt.println(s2)
            }
            if removeMax == 0
            {
                endStr = s2
                break
            }
            subStr = s2
        }
        finalStr := strings.join({highestStr, endStr}, "")
        when ODIN_DEBUG do fmt.printfln("Final string %v", finalStr)
        if len(finalStr) != BATTERIES_TO_TURN_ON
        {
            fmt.printfln("Final string %v (from %v) not correct length!", finalStr, s)
            return
        }
        finalStrInt, ok := strconv.parse_int(finalStr, 10)
        assert(ok)
        cumulativeHighest += finalStrInt
    }
    fmt.printfln("Cumulative highest values: %v", cumulativeHighest)
}