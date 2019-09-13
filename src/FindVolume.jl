"""
# module FindVolume



# Examples

```jldoctest
julia>
```
"""
module FindVolume

using Statistics: median

using Roots: find_zero,
             AbstractBracketing,
             AbstractNonBracketing,
             AbstractHalleyLikeMethod,
             AbstractNewtonLikeMethod,
             AbstractAlefeldPotraShi,
             AbstractBisection,
             AbstractSecant,
             Brent,
             Newton,
             ConvergenceFailed

using EquationsOfState
using EquationsOfState.Collections

export findvolume

function findvolume(
    form::EquationOfStateForm,
    eos::EquationOfState,
    y::Real,
    domain::Union{AbstractVector,Tuple},
    method::AbstractBracketing
)
    f(v) = apply(form, eos, v) - y
    return find_zero(f, (minimum(domain), maximum(domain)), method)
end # function findvolume
function findvolume(
    form::EquationOfStateForm,
    eos::EquationOfState,
    y::Real,
    domain::Union{AbstractVector,Tuple},
    method::Union{AbstractNonBracketing,AbstractHalleyLikeMethod,AbstractNewtonLikeMethod}
)
    f(v) = apply(form, eos, v) - y
    return find_zero(f, median(domain), method)
end # function findvolume
function findvolume(
    form::EquationOfStateForm,
    eos::EquationOfState,
    y::Real,
    domain::Union{AbstractVector,Tuple}
)
    for T in [
        subtypes(AbstractAlefeldPotraShi);
        subtypes(AbstractBisection);
        Brent;
        subtypes(AbstractHalleyLikeMethod);
        Newton;
        subtypes(AbstractSecant)
    ]
        try
            findvolume(form, eos, y, domain, T())
        catch
            BoundsError, ConvergenceFailed
            @info("Method \"$T\" failed!")
            continue
        end
    end
end # function findvolume

end
