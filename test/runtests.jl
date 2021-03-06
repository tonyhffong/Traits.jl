# tests
using Base.Test
using Traits
## BUG flags: set to false once fixed to activate tests
# Julia issues:
method_exists_bug1 = false # see https://github.com/JuliaLang/julia/issues/8959
method_exists_bug2 = false # see https://github.com/JuliaLang/julia/issues/9043 and https://github.com/mauro3/Traits.jl/issues/2
# these two are not relevant anymore as method_exists is not used anymore

function_types_bug1 = true # set to false if function types get implemented in Julia
# Traits.jl issues:
dispatch_bug1 = true # in traitdispatch.jl

# how much output to print
verbose=false

# src/Traits.jl tests
type A1 end
type A2 end
@test !istraittype(A1)

# istrait helper function:
I = TypeVar(:I)
T = TypeVar(:T)
@test Traits.subs_tvar(I, Array{TypeVar(:I,Int64)}, Traits._TestTvar{1})==Array{TypeVar(:I,Int64)}
@test Traits.subs_tvar(TypeVar(:I,Int64), Array{TypeVar(:I,Int64)}, Traits._TestTvar{1})==Array{Traits._TestTvar{1}}
@test Traits.subs_tvar(T, Array, Traits._TestTvar{1})==Array{Traits._TestTvar{1}}  # this is kinda bad
f8576{T}(a::Array, b::T) = T
other_T = f8576.env.defs.tvars
@test Traits.subs_tvar(other_T, Array, Traits._TestTvar{1})==Array # f8576.env.defs.tvars looks like T but is different!

@test Traits.find_tvar( (Array, ), T)==[true]
@test Traits.find_tvar( (Array, ), other_T)==[false]
@test Traits.find_tvar( (Int, Array, ), T)==[false,true]

@test Traits.find_correponding_type(Array{Int,2}, Array{I,2}, I)==Any[Int]
@test Traits.find_correponding_type((Array{Int,2}, Float64, (UInt8, UInt16)),
                                    (Array{I,2},   I,       (String, I))    , I) == Any[Int, Float64, Traits._TestType{:no_match}, UInt16]
@test Traits.find_correponding_type((Array{Int,2}, Float64, (UInt8, UInt16)),
                                    (Array{I,2},   I,       (UInt8, I))     , I) == Any[Int, Float64, UInt16]


# manual implementations
include("manual-traitdef.jl")
include("manual-traitimpl.jl")
include("manual-traitdispatch.jl")

# test Traits.jl
#include("helpers.jl")
include("traitdef.jl")
include("traitfns.jl")
include("traitdispatch-manual-vs-auto.jl")
include("traitdispatch.jl")

# Run the performance tests as well.
include("perf/perf.jl")
