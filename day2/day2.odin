package day2

import "core:mem"
import "core:fmt"
import os "core:os/os2"
import "core:strings"
import "core:strconv"

checkIDs :: proc(start, end: u64) -> (cumulativeInvalidIDs: u64)
{    
    ret: u64
    when ODIN_DEBUG do fmt.printfln("Range: %v to %v =====", start, end)
    for id := start; id <= end; id += 1 // range is inclusive
    {
        buffer: [1024]u8
        idStr := strconv.write_uint(buffer[:], id, 10)
        idStrLen := len(idStr)
        if idStrLen % 2 != 0
        {
            when ODIN_DEBUG 
            {
                fmt.printfln("ID %v has an odd length, skipping it", id)
            }
            continue
        }
        splitPoint := idStrLen / 2
        firstHalf := idStr[:splitPoint]
        secondHalf := idStr[splitPoint:]
        when ODIN_DEBUG
        {
            fmt.printfln("First half: %v, second half: %v",
                         firstHalf, secondHalf)
        }
        if firstHalf == secondHalf
        {
            when ODIN_DEBUG do fmt.printfln("ID %v is invalid!", id)
            ret += id
        }
    }
    return ret
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
        inputFile := "ids_example.txt" 
    } 
    else 
    { 
        inputFile := "ids.txt"
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
    str, wasAlloc := strings.remove_all(rawStr, "\n")
    defer delete(str)
    productIDs, splitErr := strings.split(str, ",")
    assert(splitErr == nil)
    defer delete(productIDs)
    
    // Process product IDs
    cumulativeInvalidIDs: u64
    for id in productIDs
    {
        idRange := strings.split(id, "-")
        defer delete(idRange)
        assert(len(idRange) == 2)
        startIdStr := idRange[0]
        endIdStr := idRange[1]
        startId, startOk := strconv.parse_u64(startIdStr)
        assert(startOk)
        endId, endOk := strconv.parse_u64(endIdStr)
        assert(endOk)
        cumulativeInvalidIDs += checkIDs(startId, endId)
    }
    fmt.printfln("Cumulative invalid IDs: %v", cumulativeInvalidIDs)
}