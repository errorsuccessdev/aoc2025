package day3

import "core:fmt"
import os "core:os/os2"
import "core:strings"
import "core:strconv"

NUM_BATTERIES_ON :: 12

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
    for &s in str
    {
        if len(s) == 0 do continue // skip empty lines
        when ODIN_DEBUG do fmt.printfln("%v =====", s)
        // Chop at highest valid number
        start := 9
        highest, pos: int
        maxPos := len(s) - NUM_BATTERIES_ON - 1
        //fmt.printfln("maxPos is %v", maxPos)
        for
        {
            highest, pos = getHighestNumber(s, start)
            when ODIN_DEBUG do fmt.printfln("highest is %v, pos is %v", highest, pos)
            when ODIN_DEBUG do fmt.println(s[pos:])
            if pos <= maxPos do break
            start -= 1
        }
        s = s[pos:]
        when ODIN_DEBUG do fmt.printfln("s is now %v", s)

        num: [12]int
        num[0] = highest
        numIndex := 1

        // Remove n "weaker" numbers
        n := len(s) - NUM_BATTERIES_ON
        when ODIN_DEBUG do fmt.printfln("Need to remove %v weaker numbers from %v (%v)", n, s, len(s))
        x := 1
        remove: for n > 0
        {
            pos = n + 1
            start = 9
            for pos > n
            {
                highest, pos = getHighestNumber(s[x:], start)
                if highest == -1
                {
                    when ODIN_DEBUG do fmt.printfln("Passing %v to ghn produced -1! x is %v", s[x:], x)
                    s = s[0:len(s)-n]
                    break remove
                }
                start -= 1
                if start == 0 do break
            }
            when ODIN_DEBUG do fmt.printfln("Highest was %v at %v", highest, pos)
            s = strings.join({s[0:x], s[pos+x:]}, "")
            n -= pos
            x += 1
        }
         when ODIN_DEBUG do fmt.printfln("S is finally %v", s)
        res, ok := strconv.parse_int(s, 10)
        assert(ok)
        cumulativeHighest += res
        when ODIN_DEBUG do fmt.println(len(s) == NUM_BATTERIES_ON)
    }
    fmt.printfln("Answer: %v", cumulativeHighest)
    when ODIN_DEBUG do assert(cumulativeHighest == 3121910778619)
}