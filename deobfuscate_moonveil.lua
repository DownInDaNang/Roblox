--[[
MoonVeil Obfuscator - Tips to Deobfuscate It
---------------------------------------------------

i spent way too long on this shit and here's what i found:

1. STRING DECRYPTION (Aa function)
   so basically the string decoder uses XOR but they wrapped it in some confusing state machine bs
   
   how it works:
   - takes two encrypted strings 
   - XORs first one with 3696, second with 52399
   - uses lookup table F[] to cache stuff
   - loops through chars using (od-34) offset and rotates the key
   - exits when _c hits 31377
   
   main decode line:
   Qa=Qa..string.char(string.byte(string.byte(Kc,(od-34)+1),string.byte(m,(od-34)%#m+1)))
   
   just grab this function and use it to decode all the encrypted strings
   tested it: Aa('\246MM\236WX', '\133\57?') = "string"

2. BYTECODE CHAIN  
   real script is hidden in base64 at the end, gets processed like this:
   
   base64 -> Ve() -> Ra() -> qf() -> hb()
   
   - Ve() is base64 decoder with custom alphabet
   - Ra() sets up VM environment 
   - qf() parses bytecode, uses Bd() to read bytes
   - hb() executes instructions in massive state machine
   
   bytecode aint standard luau. header starts: 8A 82 86 65 51 00 1A 81...
   thats moonveil's custom format

3. STRING DECOMPRESSION (ib function)
   after bytecode gets parsed, strings get decompressed with LZ77
   
   - sliding window compression
   - back refs with se_(kb,Ze,Ze+Dc-1) 
   - length = xc(mf,(af-1))+3
   - builds dictionary while going
   
   your original script text is stored here compressed

4. VM INSTRUCTIONS
   qf() reads instructions like:
   - reads bytes with Bd(Aa('G','\5'),sf,qa) 
   - bit manipulation to get opcode/operands
   - state machine with tons of jumps
   - exits at W==45318
   
   instructions got:
   - opcode in lower bits
   - register/constant stuff in upper bits
   - some ref string pools

5. MEMORY BULLSHIT
   every time i tried running it live = table overflow errors
   might be protection or just VM making huge tables
   
   what happens:
   - creates massive tables during execution
   - getgc() and debug functions crash 
   - only static analysis works
   
   solution: grab functions statically, make your own decoder

6. WHAT I GOT WORKING
   managed to:
   - extract Aa string decoder
   - decode all encrypted names (string, unpack, bit32, etc)
   - find VM structure and bytecode format
   - locate compression functions
   
   couldnt:
   - get original script (your print thing)
   - do full live analysis cuz memory issues
   - reverse complete VM instruction set

HOW TO DEOBFUSCATE:
1. grab Aa function, decode strings first
2. find base64 at end (starts with Ve')
3. build custom bytecode parser from qf structure  
4. handle LZ77 decompression for strings
5. dont execute anything - static only

string layer ez but VM bytecode needs real work
most ppl gonna get stuck at bytecode part 
]]--
