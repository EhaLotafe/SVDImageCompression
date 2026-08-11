using LinearAlgebra

"""
Calcule la décomposition SVD complète d'un canal.
"""
function decomposer_canal(A)
    return svd(A)
end


"""
Reconstruit un canal à partir d'une SVD
en conservant seulement les k premières composantes.
"""
function reconstruire_canal(F, k)

    k_effectif = min(k, length(F.S))

    U_k = F.U[:, 1:k_effectif]
    S_k = F.S[1:k_effectif]
    V_k = F.V[:, 1:k_effectif]

    A_k = U_k * Diagonal(S_k) * V_k'

    return clamp.(A_k, 0.0, 1.0)
end


"""
Calcule une seule fois les SVD
des trois canaux RGB.
"""
function decomposer_rgb(R, G, B)

    F_R = decomposer_canal(R)
    F_G = decomposer_canal(G)
    F_B = decomposer_canal(B)

    return F_R, F_G, F_B
end


"""
Reconstruit les trois canaux RGB
pour une valeur donnée de k.
"""
function reconstruire_rgb(F_R, F_G, F_B, k)

    R_k = reconstruire_canal(F_R, k)
    G_k = reconstruire_canal(F_G, k)
    B_k = reconstruire_canal(F_B, k)

    return R_k, G_k, B_k
end