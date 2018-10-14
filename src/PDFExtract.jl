module PDFExtract

include("rectangle.jl")
include("pdtext.jl")
include("pddocument.jl")

include("jats.jl")
include("tex.jl")
include("table.jl")
include("pdf2xml.jl")

function download_jar(version::String)
    jarfile = normpath(joinpath(@__DIR__,"../deps/pdfextract-$version.jar"))
    if !isfile(jarfile)
        url = "https://github.com/paperai/pdfextract/releases/download/v$version/pdfextract-$version.jar"
        println("Downloading $url")
        download(url, jarfile)
    end
    jarfile
end

using Base.Filesystem
export mvjats
function mvjats(path::String)
    for file in readdir(path)
        endswith(file,".pdf") || continue
        pdffile = file
        xmlfile = file[1:end-4] * ".xml"
        isfile(joinpath(path,xmlfile)) || continue

        dirpath = joinpath(path, file[1:end-4])
        isdir(dirpath) || mkdir(dirpath)
        mv(joinpath(path,pdffile), joinpath(dirpath,pdffile))
        sleep(0.01)
        mv(joinpath(path,xmlfile), joinpath(dirpath,xmlfile))
        sleep(0.01)
    end
end

end
