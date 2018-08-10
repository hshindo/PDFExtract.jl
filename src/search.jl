using CodecZlib

function search!(query::String, pdf)
    open(s -> readlines(GzipDecompressorStream(s)), path)
end
