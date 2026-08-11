# ==========================================================
# SVDImageCompression
# Point d'entrée principal de l'application
# ==========================================================

include("compression.jl")
include("metrics.jl")
include("benchmark.jl")


"""
Point d'entrée principal du programme.

Pour le moment, lance le benchmark expérimental
sur l'image de test avec plusieurs valeurs de rang k.

Plus tard, ce fichier lancera l'interface graphique Windows.
"""
function main()

    println("==========================================================")
    println("       COMPRESSION D'IMAGES PAR SVD")
    println("==========================================================")
    println()

    # ------------------------------------------------------
    # Configuration du test
    # ------------------------------------------------------

    image_path = "images/test.jpg"

    valeurs_k = [
        10,
        25,
        50,
        100,
        200
    ]

    # ------------------------------------------------------
    # Vérification de l'image
    # ------------------------------------------------------

    if !isfile(image_path)
        println("ERREUR : image introuvable.")
        println("Chemin attendu : ", image_path)
        return
    end

    # ------------------------------------------------------
    # Benchmark
    # ------------------------------------------------------

    try

        lancer_benchmark(
            image_path;
            valeurs_k = valeurs_k,
            output_dir = "results"
        )

    catch erreur

        println()
        println("==========================================================")
        println("ERREUR DURANT L'EXECUTION")
        println("==========================================================")
        println()

        showerror(stdout, erreur)
        println()

        return
    end

    println()
    println("==========================================================")
    println("PROGRAMME TERMINE AVEC SUCCES")
    println("==========================================================")

end


main()