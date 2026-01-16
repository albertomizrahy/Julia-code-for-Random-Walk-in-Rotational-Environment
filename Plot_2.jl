using DelimitedFiles
using Plots
using Interpolations
using StatsBase

# --- Carrega os dados dos arquivos txt
Am = readdlm("/home/alberto/Downloads/Dados/Amt.txt")
Ra = readdlm("/home/alberto/Downloads/Dados/Rat.txt")
Lu5 = readdlm("/home/alberto/Downloads/Dados/Lu5t.txt")
Lu6 = readdlm("/home/alberto/Downloads/Dados/Lu6t.txt")


XLu5 = Float64.(Lu5[:,1])
XLu6 = Float64.(Lu6[:,1])
XAm = Float64.(Am[:,1])
XRa = Float64.(Ra[:,1])
YAm  = Float64.(Am[:,2]) 
YRa  = Float64.(Ra[:,2])
YLu5 = Float64.(Lu5[:,2])
YLu6 = Float64.(Lu6[:,2])

grayAm = RGBA(0.1, 0.1, 0.1, 1.0)
grayRa = RGBA(0.6, 0.6, 0.6, 1.0)
grayLu5 = RGBA(0, 0, 0, 1.0)
grayLu6 = RGBA(0.5, 0.5, 0.5, 1.0)

plot(xlabel="eV", ylabel="barns",
     title="Microscopic cross sections",
     legendfontsize=12, guidefontsize=14,
     legend=:topright)

plot!(XAm, YAm, label="241Am",
      linewidth=3, color=grayAm,
      xlims=(0,0.8), xticks=0:0.1:0.8)

plot!(XRa, YRa, label="226Ra",
      linewidth=3, color=grayRa,
      xlims=(0,0.8))

plot!(XLu5, YLu5, label="175Lu",
      linewidth=1.5, color=grayLu5,
      linestyle=:dash, linealpha=1,
      xlims=(0,0.8))

plot!(XLu6, YLu6, label="176Lu",
      linewidth=1.5, color=grayLu6,
      linestyle=:dashdot, linealpha=1,
      xlims=(0,0.8))
      
plot!(XLu6, YLu6, label = "",
      linewidth=4, color=grayLu6,
      linestyle=:dashdot, linealpha=1,
      xlims=(0,0.8))

plot!(XLu5, YLu5, label ="",
      linewidth=4, color=grayLu5,
      linestyle=:dash, linealpha=1,
      xlims=(0,0.8))



# plot(xlabel="eV",ylabel="barns",title="Microscopic cross sections",legendfontsize=12,guidefontsize=14)
# plot!(XAm, YAm, label="241Am", linewidth=3, color=grayAm,xlims=(0, 0.8),xticks=0:0.1:0.8)
# plot!(XRa, YRa, label="226Ra", linewidth=3, color=grayRa,xlims=(0, 0.8))
# plot!(XLu5, YLu5,ls=:dash, label="175Lu", linewidth=3, color=grayLu5,xlims=(0, 0.8))
# plot!(XLu6, YLu6,ls=:dashdot, label="176Lu", linewidth=3, color=grayLu6,xlims=(0, 0.8))
display(current())
savefig("Plot.png")