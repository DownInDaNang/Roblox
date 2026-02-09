// written by: kaizen voss

// number (2–8 bytes)
// use when: u don’t know the exact type yet
// good for first scans when hunting a value blindly

// Unknown
// use when: exploring raw memory or reverse engineering structures
// mostly for advanced digging, not normal value scans

// short (2 bytes)
// use when: small counters, ammo, health in tiny games
// saves memory, often used for limits under 32k

// int (4 bytes)
// use when: most common game values
// money, score, health, timers, IDs
// this is your default guess most of the time

// int64 (8 bytes)
// use when: very large values
// big currency, timestamps, unique IDs
// modern games sometimes use this to prevent overflow

// float (4 bytes)
// use when: decimals that don’t need high precision
// speed, position, physics, cooldown timers

// double (8 bytes)
// use when: precise decimals
// coordinates, physics engines, calculations

// string
// use when: names, function markers, debug text
// great for finding anchors like JUST_PLAY_THE_GAME
