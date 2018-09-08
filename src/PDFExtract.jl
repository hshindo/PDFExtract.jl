module PDFExtract

include("rectangle.jl")
include("pdtext.jl")
include("pddocument.jl")
#include("pdfanno.jl")
#include("search.jl")

#include("conll.jl")
include("jats.jl")
include("tex.jl")

function download_jar(version::String)
    jarfile = normpath(joinpath(@__DIR__,"../deps/pdfextract-$version.jar"))
    if !isfile(jarfile)
        url = "https://github.com/paperai/pdfextract/releases/download/v$version/pdfextract-$version.jar"
        println("Downloading $url")
        download(url, jarfile)
    end
    jarfile
end

end
