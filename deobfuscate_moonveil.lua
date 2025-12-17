--[[
MoonVeil Obfuscator v1.4.5 - Tips to Deobfuscate It
--------------------------------------------------------

spent way too much time on this and here's what works on all moonveil scripts:

1. STRING DECRYPTION PATTERN (always present)
   every moonveil script has XOR string decoder
   
   how to find it:
   - search for "bit32.bxor" or "bit32 .bxor" in the script
   - look for function with 2 string parameters
   - will have lines like: string.char(string.byte(string.byte(...)))
   - uses repeat/until or while loops with state machine
   - example pattern: function(param1,param2)local ...repeat if _c>=... then...
   
   once found, copy the whole function and use it to decode strings
   test it on encrypted strings in the script to make sure it works

2. FINDING ENCRYPTED STRINGS
   look for patterns like:
   - Aa('encrypted','key') 
   - Ff('encrypted','key')
   - [functionname]('string1','string2')
   
   the encrypted strings look like gibberish with special chars
   example: '\246MM\236WX', '\133\57?'
   
   use your extracted decoder to turn these into readable text

3. VM PROCESSING CHAIN (structure always same)
   every script hides real code in base64 at the very end
   
   how to find the chain:
   - scroll to bottom of script, look for long base64 string
   - base64 starts after something like Ve' or lb' 
   - trace backwards to find the processing functions
   - pattern: return [function]([decoder]'base64string...')
   
   the chain always goes: base64 -> decoder -> VM setup -> parser -> executor
   function names change but you can trace the calls

4. BASE64 PAYLOAD LOCATION
   always at the very end of script, looks like:
   - ends with ')end)()(...)' 
   - before that is long string of random letters/numbers
   - starts with something like Ve'ioKGZVEA... or lb'2tLWaW1g...
   - this contains your original script compressed

5. STRING DECOMPRESSION FUNCTION
   look for function that:
   - has sliding window logic with array operations
   - does bit operations like: bit_operation(value,5) or similar
   - builds strings character by character
   - has cache/dictionary building
   - example pattern: while pos<=#input do...array operations...string building
   
   this is what decompresses your original script text

6. TABLE OVERFLOW (haven't figured out wat this is)
   happens when you try to run any moonveil script (atleast on my end)
   
   what you'll see:
   - "table overflow" error message
   - crashes when using getgc() or debug functions
   - happens every time you execute the script
   
   solution: never execute, only read the source code statically

7. VARIABLE PATTERNS TO LOOK FOR
   moonveil always uses:
   - single letter variables: a,b,c,x,y,z etc
   - random short names: qa,mb,fd,Te etc  
   - numbered arrays/tables with weird indices
   - functions with confusing nested calls
   
   but the core logic patterns stay same

8. OBFUSCATION LAYERS (same order always)
   layer 1: string encryption - find XOR decoder, easy to break
   layer 2: base64 encoding - find base64 string, easy to decode  
   layer 3: bytecode VM - hard part, need to reverse parser
   layer 4: LZ77 compression - doable if you get VM working

HOW TO ACTUALLY DO IT:
1. open, search for "bit32.bxor" to find string decoder
2. copy that whole function, test it on encrypted strings in script
3. use decoder to replace all encrypted strings with readable text
4. scroll to bottom, find the base64 payload 
5. trace the function calls to understand VM chain
6. if you want original script, need to reverse the bytecode parser (hard)

SPECIFIC THINGS THAT CHANGE PER SCRIPT:
- function names (Aa vs Ff vs whatever)
- XOR constants (different numbers each script)
- variable names 
- base64 decoder function name

THINGS THAT NEVER CHANGE:
- XOR method for strings
- base64 -> VM -> parser chain structure  
- LZ77 decompression algorithm
- table overflow when executed
- layer order and types

works on all moonveil v1.4.5, just gotta find the right functions
]]--
