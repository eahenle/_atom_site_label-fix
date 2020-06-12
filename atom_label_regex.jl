#!/usr/bin/env julia
# atom_label_regex.jl
# Adrian Henle, 2020

"""
    Uses regular expression matching to strip alphanumeric suffixes from
    _atom_site_label fields by replacement with the corresponding value from
    adjacent _atom_site_type_symbol fields.

    Regular expression identifies all cases of atoms with a site label like
    [captial letter, optional lower case letter, 1 or more numbers, optional capital letters]
    and site type symbols like [capital letter, optional lower case letter], and
    replaces the former with the latter.
"""
function atom_label_regex(file, verbose = false)
    regex = r"(?<label>[A-Z][a-z]?\d+[A-Z]*)\s(?<species>[A-Z][a-z]?)\s"

    # read file and find all instances of atom label problem
    data = readlines(file)
    println("Original data: $(file)")
    #[println(line) for line in data]
    matches = [match(regex, line) for line in data]

    # fix problems
    clean = data
    for (index, line) in enumerate(data)
        if matches[index] ≠ nothing
            println("$(index)/$(length(data)):\t$(matches[index][:label])\t→\t$(matches[index][:species])")
            clean[index] = replace(line, matches[index][:label]=>matches[index][:species])
        end
    end

    println("Cleaned data: $(split(file, ".")[1])_labelsFixed.cif")
    #[println(line) for line in clean]

    # save result
    print("Saving to file...")
    io = open("$(split(file, ".")[1])_labelsFixed.cif", "w")
    [println(io, line) for line in clean]
    close(io)
    println(" done.")
end

if (abspath(PROGRAM_FILE) == @__FILE__) || ((@isdefined Atom) && typeof(Atom) == Module)
    atom_label_regex("data/crystals/Cr-MIL-100.cif", verbose = true)
end
