using FileIO
using Images
using ColorTypes
using Printf

include("compression.jl")
include("metrics.jl")

println("==========================================================")
println("       BENCHMARK - COMPRESSION D'IMAGES PAR SVD")
println("==========================================================")

# ---------------------------------------------------------
# 1. Chargement de l'image
# ---------------------------------------------------------

image_path = "images/test.jpg"

println("\nChargement de l'image...")

img = load(image_path)
img_rgb = RGB.(img)

m, n = size(img_rgb)

rang_max = min(m, n)

println("Image chargée avec succès.")
println("Dimensions      : ", m, " × ", n)
println("Canaux          : RGB")
println("Rang maximal    : ", rang_max)

# ---------------------------------------------------------
# 2. Extraction des canaux RGB
# ---------------------------------------------------------

println("\nExtraction des canaux RGB...")

R = Float64.(red.(img_rgb))
G = Float64.(green.(img_rgb))
B = Float64.(blue.(img_rgb))

# ---------------------------------------------------------
# 3. Calcul des SVD
# ---------------------------------------------------------

println("Calcul des trois décompositions SVD...")

temps_svd = @elapsed begin
    global F_R, F_G, F_B
    F_R, F_G, F_B = decomposer_rgb(R, G, B)
end

println(
    "SVD terminées en ",
    round(temps_svd, digits=2),
    " secondes."
)

# ---------------------------------------------------------
# 4. Valeurs de k à tester
# ---------------------------------------------------------

valeurs_k = [10, 25, 50, 100, 200]

# On évite une valeur supérieure au rang maximal
valeurs_k = filter(k -> k <= rang_max, valeurs_k)

println("\nValeurs testées : ", valeurs_k)

# ---------------------------------------------------------
# 5. Stockage des résultats
# ---------------------------------------------------------

resultats = []

# ---------------------------------------------------------
# 6. Benchmark
# ---------------------------------------------------------

println("\nDébut du benchmark...")

for k in valeurs_k

    println("\n------------------------------------------")
    println("Test avec k = ", k)
    println("------------------------------------------")

    # Reconstruction pour ce rang
    temps_reconstruction = @elapsed begin
        global R_k, G_k, B_k

        R_k, G_k, B_k = reconstruire_rgb(
            F_R,
            F_G,
            F_B,
            k
        )
    end

    # Reconstruction de l'image RGB
    img_compressee = RGB.(R_k, G_k, B_k)

    # Sauvegarde
    output_path = "results/compressed_rgb_k$(k).png"

    save(output_path, img_compressee)

    # -----------------------------------------------------
    # Métriques
    # -----------------------------------------------------

    erreur_R,
    erreur_G,
    erreur_B,
    erreur_globale = erreur_frobenius(
        R, G, B,
        R_k, G_k, B_k
    )

    mse = calculer_mse(
        R, G, B,
        R_k, G_k, B_k
    )

    psnr = calculer_psnr(mse)

    original,
    compresse,
    ratio,
    reduction = calculer_compression(
        m,
        n,
        k
    )

    # Stockage
    push!(
        resultats,
        (
            k = k,
            reduction = reduction,
            ratio = ratio,
            erreur = erreur_globale,
            mse = mse,
            psnr = psnr,
            temps = temps_reconstruction
        )
    )

    println(
        "Réduction : ",
        round(reduction, digits=2),
        " %"
    )

    println(
        "PSNR      : ",
        round(psnr, digits=2),
        " dB"
    )

    println(
        "Temps     : ",
        round(temps_reconstruction, digits=2),
        " s"
    )

    println(
        "Image     : ",
        output_path
    )
end

# ---------------------------------------------------------
# 7. Tableau final
# ---------------------------------------------------------

println()
println("==========================================================================")
println("                         RESULTATS DU BENCHMARK")
println("==========================================================================")

@printf(
    "%-6s %-12s %-10s %-14s %-14s %-12s\n",
    "k",
    "Reduction",
    "Ratio",
    "Frobenius",
    "PSNR(dB)",
    "Temps(s)"
)

println("--------------------------------------------------------------------------")

for r in resultats

    @printf(
        "%-6d %-11.2f%% %-10.2f %-14.6f %-14.2f %-12.3f\n",
        r.k,
        r.reduction,
        r.ratio,
        r.erreur,
        r.psnr,
        r.temps
    )
end

println("==========================================================================")

# ---------------------------------------------------------
# 8. Informations complémentaires
# ---------------------------------------------------------

println()
println("Temps initial des trois SVD : ",
    round(temps_svd, digits=2),
    " secondes"
)

println()
println("Images générées dans le dossier results/ :")

for k in valeurs_k
    println("  - compressed_rgb_k$(k).png")
end

println()
println("Benchmark terminé avec succès.")