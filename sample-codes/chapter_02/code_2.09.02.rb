(~0b1010).to_s(2)         #=> "-1011"
(0b1010 & 0b1100).to_s(2) #=> "1000"
(0b1010 | 0b1100).to_s(2) #=> "1110"
(0b1010 ^ 0b1100).to_s(2) #=> "110"
(0b1010 >> 1).to_s(2)     #=> "101"
(0b1010 << 1).to_s(2)     #=> "10100"
