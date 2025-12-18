# 25ms Obfuscator Deobfuscation Guide -- By @Zion4Life

## What is 25ms obfuscator?
- Custom string encryption system, not your typical base64 garbage
- Uses runtime decryption so static analysis is useless
- Every string gets encrypted with unique keys
- Pretty clever actually, most people give up when they see the encrypted mess

## How to identify 25ms scripts:
- Function `R(b,z)` for string decryption 
- Function `A()` for pseudo-random number generation
- Encrypted strings look like `\165\186}s(` (complete gibberish)
- Pattern `(a)[R(`encrypted_data`,key_number)]` scattered everywhere
- 256-entry character lookup table gets created in memory

## The encryption system breakdown:
- They have a character table with all 256 possible byte values as strings
- `A()` function generates pseudo-random bytes based on the decryption key
- `R()` function takes encrypted data + key, uses `A()` to generate random sequence
- Each encrypted byte gets added to random byte + running total
- Result is used as index into character table to get actual character
- Pretty fucking smart because each string needs its specific key to decrypt

## Why you need to run the script first:
- The character table only exists after the script runs
- Encrypted strings don't get decrypted until you call `R()` with right key
- Trying to crack it statically will fail because you don't have the lookup table
- This is why most people fail - they try to reverse it without running

## Step 1: Execute and find the character table
```lua
loadstring(RAW LINK ONLYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY)()
task.wait(1)
```

Now search `getgc(true)` for tables with exactly 256 entries
The right table has single characters: `table[33] = "!"`, `table[65] = "A"`, etc
Might find multiple candidates, test each one until decryption works

## Step 2: their decryption system
Copy their `A()` function exactly - it's a complex pseudo-random generator
Copy their `R()` function exactly - it uses `A()` + character table
Don't try to simplify or "improve" it, just steal their exact code

### The A() function (pseudo-random generator):
- Takes the key and does `key % 35184372088832` and `key % 255 + 2`
- Uses complex math with bit operations and modulo
- Generates 4 random bytes at a time using sliding window
- Stores bytes in array D, removes them with `table.remove(D)`
- Each call to `A()` returns one random byte

### The R() function (string decoder):
- Takes encrypted string and key as parameters
- Calls `A()` for each character in the encrypted string
- Adds the random byte + encrypted byte + running total (starts at 79)
- Uses result % 256 as index into character table
- Concatenates characters to build final decrypted string

## Step 3: Extract every encrypted string
Search the source for patterns:
- `(a)[R(`encrypted_stuff`,key_number)]`
- `R(`encrypted_stuff`,key_number)`

Get the encrypted data AND the key number for each one
Missing even one string will break the final output

## Step 4: Decrypt systematically  
Use their own functions to decrypt each string with its key
Build a complete mapping of `key_number -> actual_string`
Test a few to make sure your decryption is working right

## Step 5: Replace and reconstruct
Replace all the encrypted references with actual decrypted strings
Start with the main functions (usually hookfunction or detection logic)
Then work through helper functions and UI code
Keep original variable names to maintain authenticity

## Step 6: Debug the broken parts
First attempt probably won't work perfectly
Find what strings you missed and decrypt them
Fix any incorrect function calls or property names
Keep iterating until the output works as intended

## Common fuck ups that will break your deobfuscation (bs i went through) :
- Using wrong character table (test multiple candidates from getgc)
- Missing encrypted strings (extract ALL patterns, not just obvious ones)
- Wrong function names or property references
- Rushing the process (this takes time, be systematic)

## What makes 25ms actually decent:
- Custom encryption instead of standard base64 that tools auto-crack
- Runtime-only decryption breaks static analysis tools
- Unique keys per string means you can't just find one decoder
- Complex pseudo-random system that most people can't reverse
- If you don't know what you're doing, the encrypted strings look impossible

## What stays consistent across all 25ms scripts:
- `R(b,z)` and `A()` function signatures and algorithms
- 256 character lookup table structure  
- `(a)[R()]` encryption pattern
- Need to execute first to populate caches
- Same decryption math and logic

## What changes per script:
- Variable names (could be a,b,c or x,y,z or whatever)
- Actual encrypted string contents
- Key numbers for each string  
- What functionality is being hidden

## The actual process:
1. Run script with loadstring, wait for caches to populate
2. Find character table in `getgc(true)`, test multiple candidates
3. Implement their `A()` and `R()` functions exactly as they wrote them
4. Extract all encrypted strings and keys from source code
5. Decrypt everything systematically and build complete mapping
6. Reconstruct functions piece by piece, replacing encrypted refs
7. Debug and fix until it works as intended

Their obfuscator is actually pretty solid, just need to use their own tools against them
