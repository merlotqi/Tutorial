-- math.abs(x): absolute value
print("math.abs(-5) = ", math.abs(-5)) -- 5

-- math.acos(x): arc cosine (in radians)
print("math.acos(1) = ", math.acos(1)) -- 0

-- math.asin(x): arc sine (in radians)
print("math.asin(0) = ", math.asin(0)) -- 0

-- math.atan(x [, y]): arc tangent (in radians)
print("math.atan(1) = ", math.atan(1))       -- 0.785...
print("math.atan(1, 1) = ", math.atan(1, 1)) -- 0.785... (atan2)

-- math.ceil(x): rounds up
print("math.ceil(2.3) = ", math.ceil(2.3)) -- 3

-- math.cos(x): cosine (x in radians)
print("math.cos(math.pi) = ", math.cos(math.pi)) -- -1

-- math.deg(x): radians to degrees
print("math.deg(math.pi) = ", math.deg(math.pi)) -- 180

-- math.exp(x): e^x
print("math.exp(1) = ", math.exp(1)) -- 2.718...

-- math.floor(x): rounds down
print("math.floor(2.7) = ", math.floor(2.7)) -- 2

-- math.fmod(x, y): remainder of x/y
print("math.fmod(7, 3) = ", math.fmod(7, 3)) -- 1

-- math.huge: infinity
print("math.huge = ", math.huge) -- inf

-- math.log(x [, base]): logarithm
print("math.log(8) = ", math.log(8))       -- natural log
print("math.log(8, 2) = ", math.log(8, 2)) -- log base 2

-- math.max(...): max value
print("math.max(1, 5, 3) = ", math.max(1, 5, 3)) -- 5

-- math.maxinteger: largest integer
print("math.maxinteger = ", math.maxinteger)

-- math.min(...): min value
print("math.min(1, 5, 3) = ", math.min(1, 5, 3)) -- 1

-- math.mininteger: smallest integer
print("math.mininteger = ", math.mininteger)

-- math.modf(x): integer and fractional parts
local int, frac = math.modf(2.75)
print("math.modf(2.75) = ", int, frac) -- 2 0.75

-- math.pi: pi constant
print("math.pi = ", math.pi) -- 3.141...

-- math.rad(x): degrees to radians
print("math.rad(180) = ", math.rad(180)) -- 3.141...

-- math.random([m [, n]]): random number
print("math.random() = ", math.random())           -- [0,1)
print("math.random(1, 10) = ", math.random(1, 10)) -- integer [1,10]

-- math.randomseed(x): set random seed
math.randomseed(os.time())

-- math.sin(x): sine (x in radians)
print("math.sin(math.rad(30)) = ", math.sin(math.rad(30))) -- 0.5

-- math.sqrt(x): square root
print("math.sqrt(16) = ", math.sqrt(16)) -- 4

-- math.tan(x): tangent (x in radians)
print("math.tan(math.rad(45)) = ", math.tan(math.rad(45))) -- 1

-- math.tointeger(x): convert to integer
print("math.tointeger(3.7) = ", math.tointeger(3.7)) -- 3

-- math.type(x): type of number ('integer' or 'float')
print("math.type(3) = ", math.type(3))     -- 'integer'
print("math.type(3.5) = ", math.type(3.5)) -- 'float'

-- math.ult(m, n): unsigned less than
print("math.ult(1, 2) = ", math.ult(1, 2)) -- true
