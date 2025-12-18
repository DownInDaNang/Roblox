--[[
25ms Obfuscator Deobfuscation Guide ---- @VZion4
-----------------------------------

spent way too long reversing this shit, here's everything i found:

what is 25ms obfuscator?
- custom string encryption system, not your typical base64 garbage
- uses runtime decryption so static analysis is useless
- every string gets encrypted with unique keys
- pretty clever actually, most people give up when they see the encrypted mess

how to identify 25ms scripts:
- function R(b,z) for string decryption 
- function A() for pseudo-random number generation
- encrypted strings look like `\165\186}s(` (complete gibberish)
- pattern (a)[R(`encrypted_data`,key_number)] scattered everywhere
- 256-entry character lookup table gets created in memory

the encryption system breakdown:
- they have a character table with all 256 possible byte values as strings
- A() function generates pseudo-random bytes based on the decryption key
- R() function takes encrypted data + key, uses A() to generate random sequence
- each encrypted byte gets added to random byte + running total
- result is used as index into character table to get actual character
- pretty fucking smart because each string needs its specific key to decrypt

why you need to run the script first:
- the character table only exists after the script runs
- encrypted strings don't get decrypted until you call R() with right key
- trying to deofuscate it statically will fail because you don't have the lookup table
- this is why most people fail - they try to reverse it without running

step 1: execute and find the character table
loadstring(RAW LINK HEREEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE)()
task.wait(1)

now search getgc(true) for tables with exactly 256 entries
the right table has single characters: table[33] = "!", table[65] = "A", etc
might find multiple candidates, test each one until decryption works

step 2: their decryption system
copy their A() function exactly - it's a pseudo random generator
copy their R() function exactly - it uses A() + character table
don't try to "improve" it, just steal their exact code

the A() function (pseudo-random generator):
- takes the key and does key % 35184372088832 and key % 255 + 2
- uses complex math with bit operations and modulo
- generates 4 random bytes at a time using sliding window
- stores bytes in array D, removes them with table.remove(D)
- each call to A() returns one random byte

the R() function (string decoder):
- takes encrypted string and key as parameters
- calls A() for each character in the encrypted string
- adds the random byte + encrypted byte + running total (starts at 79)
- uses result % 256 as index into character table
- concatenates characters to build final decrypted string

step 3: extract every encrypted string
search the source for patterns:
- (a)[R(`encrypted_stuff`,key_number)]
- R(`encrypted_stuff`,key_number)
get the encrypted data AND the key number for each one
missing even one string will break the final output

step 4: decrypt systematically  
use their own functions to decrypt each string with its key
build a complete mapping of key_number -> actual_string
test a few to make sure your decryption is working right

step 5: replace and reconstruct
replace all the encrypted references with actual decrypted strings
start with the hookfunction (main detection logic)
then trajectory calculation (physics and math)
then helper functions (cleanup, visual effects)
keep original variable names like b,z,r to stay authentic

step 6: debug the broken parts
first attempt probably won't work perfectly
find what strings you missed and decrypt them
fix math functions (they use sin instead of cos in some places)
fix property names (power vs AutoGoal, networkOwner vs TeamGoal)
fix method calls (fromEulerAnglesXYZ vs Angles)
keep iterating until it behaves exactly like the original

common fuck-ups that will break your deobfuscation:
- using wrong character table (test multiple candidates from getgc)
- missing encrypted strings (extract ALL patterns, not just obvious ones)
- wrong math functions (sin/cos, Vector3.zero vs Vector3.new)
- incorrect property names (they're very specific)
- rushing the process (this takes time, be systematic)

what makes 25ms actually decent:
- custom encryption instead of standard base64 that tools auto-crack
- runtime-only decryption breaks static analysis tools
- unique keys per string means you can't just find one decoder
- complex pseudo-random system that most people can't reverse
- if you don't know what you're doing, the encrypted strings look impossible

what stays consistent across all 25ms scripts:
- R(b,z) and A() function signatures and algorithms
- 256 character lookup table structure  
- (a)[R()] encryption pattern
- need to execute first to populate caches
- same decryption math and logic

what changes per script:
- variable names (could be a,b,c or x,y,z or whatever)
- actual encrypted string contents
- key numbers for each string  
- what functionality is being hidden

the actual process:
1. run script with loadstring, wait for caches to populate
2. find character table in getgc(true), test multiple candidates
3. implement their A() and R() functions exactly as they wrote them
4. extract all encrypted strings and keys from source code
5. decrypt everything systematically and build complete mapping
6. reconstruct functions piece by piece, replacing encrypted refs
7. debug and fix until it works identically to original

this method works on every 25ms script if you're patient and systematic
the obfuscator is actually pretty solid, just need to use their own tools against them

example of what you'll find:
- encrypted: `\165\186}s(` with key 32490797946095 = "ankle"
- encrypted: `\b\233W\194` with key 7714410583112 = "ball"  
- encrypted: `wyR\235` with key 18114372530594 = "Head"

once you decrypt everything, you can see what the script actually does
in our case it was a football auto-goal hack that curves the ball into goals
]]--
