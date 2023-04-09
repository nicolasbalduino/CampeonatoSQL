-- CAMPEÃO
SELECT TOP(1) t.nome, (SUM(j.pontoCasa) / 4) AS pontos_em_casa, (SUM(jj.pontoFora) / 4) AS pontos_fora_de_casa, 
    ((SUM(j.pontoCasa)/4) + (SUM(jj.pontoFora)/4)) AS total_de_pontos
FROM [Time] t
JOIN Jogo j ON t.nome = j.timeCasa
JOIN Jogo jj ON t.nome = jj.timeFora
GROUP BY t.nome
ORDER BY total_de_pontos DESC;

-- CLASSIFICAÇÃO
SELECT t.nome, (SUM(j.pontoCasa) / 4) AS pontos_em_casa, (SUM(jj.pontoFora) / 4) AS pontos_fora_de_casa, 
    ((SUM(j.pontoCasa)/4) + (SUM(jj.pontoFora)/4)) AS total_de_pontos
FROM [Time] t
JOIN Jogo j ON t.nome = j.timeCasa
JOIN Jogo jj ON t.nome = jj.timeFora
GROUP BY t.nome
ORDER BY total_de_pontos DESC;

-- TIME QUE FEZ MAIS GOLS
SELECT TOP(1) t.nome, (SUM(j.golCasa) / 4) AS gols_em_casa, (SUM(jj.golFora) / 4) AS gols_fora_de_casa, 
    ((SUM(j.golCasa) / 4) + (SUM(jj.golFora) / 4)) AS total_de_gols
FROM [Time] t
JOIN Jogo j ON t.nome = j.timeCasa
JOIN Jogo jj ON t.nome = jj.timeFora
GROUP BY t.nome
ORDER BY total_de_gols DESC;

-- TIME QUE LEVOU MAIS GOLS
SELECT TOP(1) t.nome, (SUM(j.golFora) / 4) AS gols_sofridos_em_casa, (SUM(jj.golCasa) / 4) AS gols_sofridos_fora_de_casa, 
    ((SUM(j.golFora) / 4) + (SUM(jj.golCasa) / 4)) AS total_de_gols_sofridos
FROM [Time] t
JOIN Jogo j ON t.nome = j.timeCasa
JOIN Jogo jj ON t.nome = jj.timeFora
GROUP BY t.nome
ORDER BY total_de_gols_sofridos DESC;


-- JOGO COM MAIS GOLS
SELECT TOP(1) tc.nome, tf.nome, j.golCasa, j.golFora, (j.golCasa + j.golFora) AS total_de_gols
FROM Jogo j
JOIN [Time] tc ON j.timeCasa = tc.nome
JOIN [Time] tf ON j.timeFora = tf.nome
ORDER BY total_de_gols DESC;

-- MAIOR NUMERO DE GOLS DE CADA TIME EM UM JOGO
SELECT t.nome, MAX(j.golCasa) AS maior_gol_em_casa, MAX(jj.golFora) AS maior_gol_fora_de_casa, 
    CASE WHEN (MAX(j.golCasa) > MAX(jj.golFora)) THEN MAX(j.golCasa) ELSE MAX(jj.golFora) END AS maior_numero_de_gols
FROM [Time] t
JOIN Jogo j ON t.nome = j.timeCasa
JOIN Jogo jj ON t.nome = jj.timeFora
GROUP BY t.nome;

-- TOTAL DE GOLS POR TIME
SELECT t.nome, (SUM(j.golCasa) / 4) AS gols_em_casa, (SUM(jj.golFora) / 4) AS gols_fora_de_casa, 
    ((SUM(j.golCasa) + SUM(jj.golFora)) / 4) AS total_de_gols
FROM [Time] t
JOIN Jogo j ON t.nome = j.timeCasa
JOIN Jogo jj ON t.nome = jj.timeFora
GROUP BY t.nome;