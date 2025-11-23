-- zip.lua
-- ZIP read/write with zlib DEFLATE (LuaJIT + ffi)
-- Requires: LuaJIT (ffi) and libz available as "z" or "zlib"
-- version 2025-11-23

local bit = require("bit")
local ffi = require("ffi")

-- try load zlib (libz)
local function loadZlib()
	local names = {
		"z",          -- Linux
		"zlib",       -- Linux/Unix
		"libz",       -- Linux package name
		"zlib1",      -- Windows (MinGW build)
		"zlib1.dll",  -- Windows DLL (common)
		"z.dll"       -- Some Windows builds
	}

	for _, name in ipairs(names) do
		local ok, lib = pcall(ffi.load, name)
		if ok then
			return lib
		end
	end

	error("Cannot load zlib (libz, zlib1.dll, zlib). Install zlib or ensure DLL is accessible.")
end

local zlib = loadZlib()

-- ffi definitions matching zlib
ffi.cdef[[
typedef unsigned char Bytef;
typedef unsigned int uInt;
typedef unsigned long uLong;
typedef void *voidpf;
typedef void *voidp;

typedef struct z_stream_s {
    Bytef    *next_in;   /* next input byte */
    uInt     avail_in;   /* number of bytes available at next_in */
    uLong    total_in;   /* total nb of input bytes read so far */

    Bytef    *next_out;  /* next output byte should be put there */
    uInt     avail_out;  /* remaining free space at next_out */
    uLong    total_out;  /* total nb of bytes output so far */

    const char *msg;     /* last error message, NULL if no error */
    void *state;         /* not visible by applications */

    voidpf zalloc;
    voidpf zfree;
    voidpf opaque;

    int data_type;       /* best guess about the data type: binary or text */
    uLong adler;
    uLong reserved;
} z_stream;

int deflateInit2_(z_stream *strm, int level, int method, int windowBits,
                  int memLevel, int strategy, const char *version, int stream_size);
int deflate(z_stream *strm, int flush);
int deflateEnd(z_stream *strm);

int inflateInit2_(z_stream *strm, int windowBits, const char *version, int stream_size);
int inflate(z_stream *strm, int flush);
int inflateEnd(z_stream *strm);

uLong crc32(uLong crc, const Bytef *buf, uInt len);
]]

-- zlib constants (common values)
local Z_OK = 0
local Z_STREAM_END = 1
local Z_DEFLATED = 8
local Z_DEFAULT_COMPRESSION = -1
local Z_FINISH = 4
local Z_NO_FLUSH = 0

local zip = {}

-- CRC32 wrapper
local function crc32_lua(data, crc)
    crc = crc or 0
    if #data == 0 then return crc end
    -- allocate c buffer and copy
    local buf = ffi.new("unsigned char[?]", #data)
    ffi.copy(buf, data, #data)
    local res = zlib.crc32(crc, buf, #data)
    return tonumber(res)
end

-- DOS date/time
local function toDosTime(timestamp)
    local t = os.date("*t", timestamp or os.time())
    local year = t.year
    if year < 1980 then year = 1980 end
    local dosDate = bit.bor(
        bit.lshift(year - 1980, 9),
        bit.lshift(t.month, 5),
        t.day
    )
    local dosTime = bit.bor(
        bit.lshift(t.hour, 11),
        bit.lshift(t.min, 5),
        math.floor(t.sec / 2)
    )
    return dosTime, dosDate
end

-- Little-endian writers
local function writeUInt16(n)
    n = n % 0x10000
    return string.char(bit.band(n, 0xFF), bit.band(bit.rshift(n, 8), 0xFF))
end
local function writeUInt32(n)
    n = n % 0x100000000
    return string.char(
        bit.band(n, 0xFF),
        bit.band(bit.rshift(n, 8), 0xFF),
        bit.band(bit.rshift(n, 16), 0xFF),
        bit.band(bit.rshift(n, 24), 0xFF)
    )
end

local function readUInt16(data, offset)
    offset = offset or 1
    local a, b = data:byte(offset, offset + 1)
    return bit.bor(a or 0, bit.lshift(b or 0, 8))
end
local function readUInt32(data, offset)
    offset = offset or 1
    local a,b,c,d = data:byte(offset, offset + 3)
    return bit.bor(a or 0, bit.lshift(b or 0, 8), bit.lshift(c or 0, 16), bit.lshift(d or 0, 24))
end

-- compress using zlib (raw deflate: windowBits = -15)
local function compress(data)
    if #data == 0 then return "" end

    local stream = ffi.new("z_stream")
    -- zero init
    stream.zalloc = nil
    stream.zfree = nil
    stream.opaque = nil

    -- prepare input buffer and copy
    local inbuf = ffi.new("unsigned char[?]", #data)
    ffi.copy(inbuf, data, #data)
    stream.next_in = inbuf
    stream.avail_in = #data

    -- init
    local ret = zlib.deflateInit2_(stream, Z_DEFAULT_COMPRESSION, Z_DEFLATED, -15, 8, 0, "1.2.11", ffi.sizeof(stream))
    if ret ~= Z_OK then
        error("deflateInit2_ failed: " .. tostring(ret))
    end

    local out_chunks = {}
    local out_size = 32768
    local outbuf = ffi.new("unsigned char[?]", out_size)

    repeat
        stream.next_out = outbuf
        stream.avail_out = out_size

        ret = zlib.deflate(stream, Z_FINISH)
        if ret ~= Z_OK and ret ~= Z_STREAM_END then
            zlib.deflateEnd(stream)
            error("deflate failed: " .. tostring(ret))
        end

        local have = out_size - tonumber(stream.avail_out)
        if have > 0 then
            table.insert(out_chunks, ffi.string(outbuf, have))
        end
    until ret == Z_STREAM_END

    zlib.deflateEnd(stream)
    return table.concat(out_chunks)
end

-- decompress raw deflate (windowBits = -15)
local function decompress(data, expected_size)
    if #data == 0 then return "" end

    local stream = ffi.new("z_stream")
    stream.zalloc = nil
    stream.zfree = nil
    stream.opaque = nil

    -- copy input
    local inbuf = ffi.new("unsigned char[?]", #data)
    ffi.copy(inbuf, data, #data)
    stream.next_in = inbuf
    stream.avail_in = #data

    local ret = zlib.inflateInit2_(stream, -15, "1.2.11", ffi.sizeof(stream))
    if ret ~= Z_OK then
        error("inflateInit2_ failed: " .. tostring(ret))
    end

    local out_chunks = {}
    local out_size = 32768
    if expected_size and expected_size < out_size then out_size = expected_size end
    local outbuf = ffi.new("unsigned char[?]", out_size)

    repeat
        stream.next_out = outbuf
        stream.avail_out = out_size

        ret = zlib.inflate(stream, Z_NO_FLUSH)
        if ret ~= Z_OK and ret ~= Z_STREAM_END then
            zlib.inflateEnd(stream)
            error("inflate failed: " .. tostring(ret))
        end

        local have = out_size - tonumber(stream.avail_out)
        if have > 0 then
            table.insert(out_chunks, ffi.string(outbuf, have))
        end
    until ret == Z_STREAM_END

    zlib.inflateEnd(stream)
    return table.concat(out_chunks)
end

-- Public API: create new archive (table)
function zip.new()
    return { entries = {}, comment = "" }
end

-- Add file to archive (compress_data true/false)
function zip.addFile(archive, filename, data, compress_data)
    compress_data = (compress_data == nil) and true or compress_data
    local entry = {
        filename = filename,
        data = data,
        uncompressed_size = #data,
        crc32 = crc32_lua(data),
        compress = compress_data
    }

    if compress_data then
        entry.compressed_data = compress(data)
        entry.compressed_size = #entry.compressed_data
        entry.compression_method = 8 -- DEFLATE
    else
        entry.compressed_data = data
        entry.compressed_size = #data
        entry.compression_method = 0 -- STORE
    end

    table.insert(archive.entries, entry)
end

-- Write archive to a single string (ZIP file)
function zip.write(archive)
    local parts = {}
    local offset = 0
    local central_dir_parts = {}

    local dos_time, dos_date = toDosTime()

    for _, entry in ipairs(archive.entries) do
        -- local header
        local local_header = {}
        table.insert(local_header, "\x50\x4b\x03\x04") -- sig
        table.insert(local_header, writeUInt16(20)) -- version needed
        table.insert(local_header, writeUInt16(0))  -- flags
        table.insert(local_header, writeUInt16(entry.compression_method))
        table.insert(local_header, writeUInt16(dos_time))
        table.insert(local_header, writeUInt16(dos_date))
        table.insert(local_header, writeUInt32(entry.crc32))
        table.insert(local_header, writeUInt32(entry.compressed_size))
        table.insert(local_header, writeUInt32(entry.uncompressed_size))
        table.insert(local_header, writeUInt16(#entry.filename))
        table.insert(local_header, writeUInt16(0)) -- extra len
        table.insert(local_header, entry.filename)

        local header_data = table.concat(local_header)
        table.insert(parts, header_data)
        table.insert(parts, entry.compressed_data)

        entry.local_header_offset = offset
        offset = offset + #header_data + entry.compressed_size

        -- central directory entry
        local cd = {}
        table.insert(cd, "\x50\x4b\x01\x02") -- cd sig
        table.insert(cd, writeUInt16(20)) -- version made by
        table.insert(cd, writeUInt16(20)) -- version needed
        table.insert(cd, writeUInt16(0))  -- flags
        table.insert(cd, writeUInt16(entry.compression_method))
        table.insert(cd, writeUInt16(dos_time))
        table.insert(cd, writeUInt16(dos_date))
        table.insert(cd, writeUInt32(entry.crc32))
        table.insert(cd, writeUInt32(entry.compressed_size))
        table.insert(cd, writeUInt32(entry.uncompressed_size))
        table.insert(cd, writeUInt16(#entry.filename))
        table.insert(cd, writeUInt16(0)) -- extra len
        table.insert(cd, writeUInt16(0)) -- file comment len
        table.insert(cd, writeUInt16(0)) -- disk number start
        table.insert(cd, writeUInt16(0)) -- internal attrs
        table.insert(cd, writeUInt32(0)) -- external attrs
        table.insert(cd, writeUInt32(entry.local_header_offset))
        table.insert(cd, entry.filename)

        table.insert(central_dir_parts, table.concat(cd))
    end

    local cd_offset = offset
    local cd_data = table.concat(central_dir_parts)
    table.insert(parts, cd_data)
    offset = offset + #cd_data

    -- End of central dir
    local eocd = {}
    table.insert(eocd, "\x50\x4b\x05\x06")
    table.insert(eocd, writeUInt16(0)) -- disk
    table.insert(eocd, writeUInt16(0)) -- cd start disk
    table.insert(eocd, writeUInt16(#archive.entries)) -- num records this disk
    table.insert(eocd, writeUInt16(#archive.entries)) -- total records
    table.insert(eocd, writeUInt32(#cd_data)) -- size of central dir
    table.insert(eocd, writeUInt32(cd_offset)) -- offset of central dir
    table.insert(eocd, writeUInt16(#archive.comment)) -- comment length
    table.insert(eocd, archive.comment)

    table.insert(parts, table.concat(eocd))

    return table.concat(parts)
end

-- Read ZIP from string (simple implementation)
function zip.read(data)
    local archive = zip.new()

    -- find EOCD within last 64KB
    local eocd_sig = "\x50\x4b\x05\x06"
    local start_search = math.max(1, #data - 65536)
    local eocd_pos = data:find(eocd_sig, start_search, true)
    if not eocd_pos then error("EOCD not found") end

    local num_entries = readUInt16(data, eocd_pos + 10)
    local cd_size = readUInt32(data, eocd_pos + 12)
    local cd_offset = readUInt32(data, eocd_pos + 16)

    local pos = cd_offset + 1
    for i = 1, num_entries do
        local sig = data:sub(pos, pos + 3)
        if sig ~= "\x50\x4b\x01\x02" then error("Invalid CD signature at pos "..pos) end

        local compression_method = readUInt16(data, pos + 10)
        local crc = readUInt32(data, pos + 16)
        local compressed_size = readUInt32(data, pos + 20)
        local uncompressed_size = readUInt32(data, pos + 24)
        local filename_len = readUInt16(data, pos + 28)
        local extra_len = readUInt16(data, pos + 30)
        local comment_len = readUInt16(data, pos + 32)
        local local_header_offset = readUInt32(data, pos + 42)

        local filename = data:sub(pos + 46, pos + 45 + filename_len)

        -- read local header to find data offset
        local lh_pos = local_header_offset + 1
        local lh_sig = data:sub(lh_pos, lh_pos+3)
        if lh_sig ~= "\x50\x4b\x03\x04" then error("Invalid local header signature") end
        local lh_name_len = readUInt16(data, lh_pos + 26)
        local lh_extra_len = readUInt16(data, lh_pos + 28)
        local data_pos = lh_pos + 30 + lh_name_len + lh_extra_len

        local compressed_data = data:sub(data_pos, data_pos + compressed_size - 1)
        local file_data
        if compression_method == 8 then
            file_data = decompress(compressed_data, uncompressed_size)
        elseif compression_method == 0 then
            file_data = compressed_data
        else
            error("Unsupported compression method: " .. tostring(compression_method))
        end

        table.insert(archive.entries, {
            filename = filename,
            data = file_data,
            compressed_size = compressed_size,
            uncompressed_size = uncompressed_size,
            compression_method = compression_method,
            crc32 = crc
        })

        pos = pos + 46 + filename_len + extra_len + comment_len
    end

    return archive
end

-- Save/load convenience
function zip.save(archive, filename)
    local f = io.open(filename, "wb")
    if not f then error("Cannot open file for writing: "..filename) end
    f:write(zip.write(archive))
    f:close()
end

function zip.load(filename)
    local f = io.open(filename, "rb")
    if not f then error("Cannot open file: "..filename) end
    local data = f:read("*all")
    f:close()
    return zip.read(data)
end

return zip
