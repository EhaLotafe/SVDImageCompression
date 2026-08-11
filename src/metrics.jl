using LinearAlgebra

"""
Calcule l'erreur de Frobenius globale RGB.
"""
function erreur_frobenius(R, G, B, R_k, G_k, B_k)

    erreur_R = norm(R - R_k)
    erreur_G = norm(G - G_k)
    erreur_B = norm(B - B_k)

    erreur_globale = sqrt(
        erreur_R^2 +
        erreur_G^2 +
        erreur_B^2
    )

    return erreur_R, erreur_G, erreur_B, erreur_globale
end


"""
Calcule l'erreur quadratique moyenne (MSE).
"""
function calculer_mse(R, G, B, R_k, G_k, B_k)

    erreur = (
        sum((R - R_k).^2) +
        sum((G - G_k).^2) +
        sum((B - B_k).^2)
    )

    nombre_valeurs = 3 * length(R)

    return erreur / nombre_valeurs
end


"""
Calcule le PSNR.
Les pixels sont normalisés entre 0 et 1.
"""
function calculer_psnr(mse)

    if mse == 0
        return Inf
    end

    return 10 * log10(1.0 / mse)
end


"""
Calcule la réduction théorique du nombre
de paramètres grâce à la SVD tronquée.
"""
function calculer_compression(m, n, k)

    original = m * n

    compresse = k * (m + n + 1)

    ratio = original / compresse

    reduction = (1 - compresse / original) * 100

    return original, compresse, ratio, reduction
end