using FileIO
using Images
using ColorTypes
using Printf

"""
Exécute le benchmark SVD pour plusieurs valeurs de k.

Génère :
- les images reconstruites ;
- les métriques de qualité ;
- un fichier CSV contenant les résultats.
"""
function lancer_benchmark(
    image_path::String;
    valeurs_k = [10, 25, 50, 100, 200],
    output_dir = "results"
)

    println("==========================================================")
    println("       BENCHMARK - COMPRESSION D'IMAGES PAR SVD")
    println("==========================================================")

    # ------------------------------------------------------
    # 1. Préparation
    # ------------------------------------------------------

    mkpath(output_dir)

    println("\nChargement de l'image...")

    img = load(image_path)
    img_rgb = RGB.(img)

    m, n = size(img_rgb)
    rang_max = min(m, n)

    println("Image chargée avec succès.")
    println("Dimensions      : ", m, " × ", n)
    println("Canaux          : RGB")
    println("Rang maximal    : ", rang_max)

    # ------------------------------------------------------
    # 2. Extraction RGB
    # ------------------------------------------------------

    println("\nExtraction des canaux RGB...")

    R = Float64.(red.(img_rgb))
    G = Float64.(green.(img_rgb))
    B = Float64.(blue.(img_rgb))

    # ------------------------------------------------------
    # 3. SVD
    # ------------------------------------------------------

    println("Calcul des trois décompositions SVD...")

    local F_R
    local F_G
    local F_B

    temps_svd = @elapsed begin
        F_R, F_G, F_B = decomposer_rgb(R, G, B)
    end

    println(
        "SVD terminées en ",
        round(temps_svd, digits=2),
        " secondes."
    )

    # Éliminer les k invalides
    k_valides = filter(
        k -> 1 <= k <= rang_max,
        valeurs_k
    )

    if isempty(k_valides)
        error(
            "Aucune valeur de k n'est valide pour cette image."
        )
    end

    println("\nValeurs testées : ", k_valides)

    # ------------------------------------------------------
    # 4. Résultats
    # ------------------------------------------------------

    resultats = NamedTuple[]

    println("\nDébut du benchmark...")

    for k in k_valides

        println("\n------------------------------------------")
        println("Test avec k = ", k)
        println("------------------------------------------")

        local R_k
        local G_k
        local B_k

        temps_reconstruction = @elapsed begin
            R_k, G_k, B_k = reconstruire_rgb(
                F_R,
                F_G,
                F_B,
                k
            )
        end

        # Reconstruction RGB
        img_compressee = RGB.(R_k, G_k, B_k)

        output_path = joinpath(
            output_dir,
            "compressed_rgb_k$(k).png"
        )

        save(output_path, img_compressee)

        # Erreur de Frobenius
        _, _, _, erreur_globale = erreur_frobenius(
            R,
            G,
            B,
            R_k,
            G_k,
            B_k
        )

        # MSE
        mse = calculer_mse(
            R,
            G,
            B,
            R_k,
            G_k,
            B_k
        )

        # PSNR
        psnr = calculer_psnr(mse)

        # Compression théorique
        _, _, ratio, reduction = calculer_compression(
            m,
            n,
            k
        )

        push!(
            resultats,
            (
                k = k,
                reduction = reduction,
                ratio = ratio,
                frobenius = erreur_globale,
                mse = mse,
                psnr = psnr,
                temps = temps_reconstruction
            )
        )

        println(
            "Réduction théorique : ",
            round(reduction, digits=2),
            " %"
        )

        println(
            "Erreur Frobenius     : ",
            round(erreur_globale, digits=6)
        )

        println(
            "MSE                  : ",
            round(mse, digits=8)
        )

        println(
            "PSNR                 : ",
            round(psnr, digits=2),
            " dB"
        )

        println(
            "Temps reconstruction : ",
            round(temps_reconstruction, digits=3),
            " s"
        )

        println(
            "Image                : ",
            output_path
        )
    end

    # ------------------------------------------------------
    # 5. Tableau terminal
    # ------------------------------------------------------

    println()
    println("==========================================================================================")
    println("                              RESULTATS DU BENCHMARK")
    println("==========================================================================================")

    @printf(
        "%-6s %-13s %-10s %-14s %-14s %-12s\n",
        "k",
        "Reduction",
        "Ratio",
        "Frobenius",
        "PSNR(dB)",
        "Temps(s)"
    )

    println("------------------------------------------------------------------------------------------")

    for r in resultats
        @printf(
            "%-6d %-12.2f%% %-10.2f %-14.6f %-14.2f %-12.3f\n",
            r.k,
            r.reduction,
            r.ratio,
            r.frobenius,
            r.psnr,
            r.temps
        )
    end

    println("==========================================================================================")

    # ------------------------------------------------------
    # 6. Export CSV
    # ------------------------------------------------------

    csv_path = joinpath(
        output_dir,
        "benchmark.csv"
    )

    open(csv_path, "w") do fichier

        println(
            fichier,
            "k,reduction_percent,ratio,frobenius,mse,psnr_db,reconstruction_seconds"
        )

        for r in resultats
            println(
                fichier,
                string(
                    r.k, ",",
                    r.reduction, ",",
                    r.ratio, ",",
                    r.frobenius, ",",
                    r.mse, ",",
                    r.psnr, ",",
                    r.temps
                )
            )
        end
    end

    println("\nTemps initial des trois SVD : ",
        round(temps_svd, digits=2),
        " secondes"
    )

    println("Fichier CSV                 : ", csv_path)

    println("\nBenchmark terminé avec succès.")

    return resultats
end