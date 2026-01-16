using LinearAlgebra, DelimitedFiles, StatsBase, Interpolations, QuadGK, KernelDensity, Plots

function Maxwell(T)
    mass_neutron = 1.675e-27
    k_b = 1.380649e-23 
    sigma = sqrt(k_b * T / mass_neutron)
    return sigma .* [randn() randn() randn()]
end

function Energyzero(T)
    mass_neutron = 1.675e-27
    energy = Float64[]
    for i = 1:6000
        push!(energy, (mass_neutron * norm(Maxwell(T))^2 / 2)*6.242e+18)
    end
    return energy
end

println("=== Beggining... ===")

# 1. Reading files
data_c = readdlm("/home/alberto/Downloads/Dados/Lu6c.txt")
data_t = readdlm("/home/alberto/Downloads/Dados/Lu6t.txt")
data_c2 = readdlm("/home/alberto/Downloads/Dados/Lu5c.txt")
data_t2 = readdlm("/home/alberto/Downloads/Dados/Lu5t.txt")
energy = Float64.(readdlm("/home/alberto/Downloads/Dados/energy.txt")[:,1])
energy = energy[60001:90000,1] #30001:60000 ==> 0.2 m, 60001,90000 ==> 0.1m
#energy = Energyzero(303)

# 1.A) Preparing data
Esigma_c = Float64.(data_c[:, 1])
sigma_c = Float64.(data_c[:, 2]) .* 1e-24   # barns → cm²
Esigma_t = Float64.(data_t[:, 1])
sigma_t = Float64.(data_t[:, 2]) .* 1e-24   # barns → cm²
Esigma_c2 = Float64.(data_c2[:, 1])
sigma_c2 = Float64.(data_c2[:, 2]) .* 1e-24   # barns → cm²
Esigma_t2 = Float64.(data_t2[:, 1])
sigma_t2 = Float64.(data_t2[:, 2]) .* 1e-24   # barns → cm²

# 2. Estimating probability density p(E)
kd = kde(energy)  # (kernel Gaussiano)
E_pdf = kd.x
p_pdf = kd.density
p_interp = LinearInterpolation(E_pdf, p_pdf, extrapolation_bc=Flat())

# 3. Interpolation 
sigma_interp_c = LinearInterpolation(Esigma_c, sigma_c, extrapolation_bc=Flat())
sigma_interp_t = LinearInterpolation(Esigma_t, sigma_t, extrapolation_bc=Flat())
sigma_interp_c2 = LinearInterpolation(Esigma_c, sigma_c, extrapolation_bc=Flat())
sigma_interp_t2 = LinearInterpolation(Esigma_t, sigma_t, extrapolation_bc=Flat())

plot(E_pdf, p_pdf ./ maximum(p_pdf), label="p(E) normalizado", xlims=(0, 3))
plot!(Esigma_c,( sigma_c ./ maximum(sigma_c)), label="σc(E) normalizado", xlims=(0, 3), xlabel="E (eV)", ylabel="valor normalizado")
plot!(Esigma_t, sigma_t ./ maximum(sigma_t), label="σt(E) normalizado", xlims=(0, 3), xlabel="E (eV)", ylabel="valor normalizado")
display(current())


# 4. Phisics parameters
NRa = 2.91e22
NAm = 1.43e22
NLu5 = 2.78e22
NLu6 = 7.41e20
N = NLu6     # atm/cm³ 
N2 = NLu5
L = 0.3 #cm
F = 10^8 #neutrons/s
R = 10  #cm
h = 1 #cm
Phi = F/(2*pi*R*h) #neutrons/(s*cm^2)
###############
## Model = 1 is  for Am, Ra
## Model = 2 is for Lu5 Lu6
### Don't forget to change N and N2. 

Model = 2

if Model == 1
    # 5. function Phi(E)*f(E) 
    f(E) = Phi* (sigma_interp_c(E)/sigma_interp_t(E))*(1 - exp(-N * sigma_interp_t(E) * L)) * p_interp(E) 
    emin = max(minimum(E_pdf), minimum(Esigma_c), minimum(Esigma_t))
    emax = min(maximum(E_pdf), maximum(Esigma_c), maximum(Esigma_t))
end
if Model == 2
    # 5. function Phi(E)*f(E) 
    f(E) = Phi* (N*sigma_interp_c(E)/(N*sigma_interp_t(E)+N2*sigma_interp_t2(E)))*(1 - exp(-(N*sigma_interp_t(E)+N2*sigma_interp_t2(E)) * L)) * p_interp(E) 
    emin = max(minimum(E_pdf), minimum(Esigma_c), minimum(Esigma_t),minimum(Esigma_c2), minimum(Esigma_t2))
    emax = min(maximum(E_pdf), maximum(Esigma_c), maximum(Esigma_t), maximum(Esigma_c2), maximum(Esigma_t2))
end


println("Integration interval: [", emin, ", ", emax, "] eV")

# 6. Number integration
P, err = QuadGK.quadgk(f, emin, emax)
println("Reaction rate ≈ ", P)
println("Error ≈ ", err)

println("=== End of Calculo ===")
