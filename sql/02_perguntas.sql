-- Pergunta 1: Qual é o percentual e o valor financeiro nominal economizado pelo governo
--(diferença entre valor estimado e valor homologado)?

SELECT
    SUM(valor_total_estimado) AS valor_estimado,
    SUM(valor_total_homologado) AS valor_homologado,
    SUM(valor_total_estimado - valor_total_homologado) AS economia_nominal,
    ROUND(
        100.0 * SUM(valor_total_estimado - valor_total_homologado)
        / NULLIF(SUM(valor_total_estimado), 0),
        2
    ) AS percentual_economia
FROM fato_item_contratado
WHERE comparavel = 1;

-- Pergunta 2: Quem são os maiores fornecedores em volume financeiro e qual percentual do orçamento público está concentrado neles?

WITH total_geral AS (
    SELECT
        SUM(valor_total_homologado) AS valor_total
    FROM fato_item_contratado
),
fornecedores AS (
    SELECT
        f.sk_fornecedor,
        f.ni_fornecedor,
        f.nome_fornecedor,
        SUM(ft.valor_total_homologado) AS volume_financeiro
    FROM fato_item_contratado ft
    JOIN dim_fornecedor f
        ON ft.sk_fornecedor = f.sk_fornecedor
    GROUP BY
        f.sk_fornecedor,
        f.ni_fornecedor,
        f.nome_fornecedor
)
SELECT
    fo.ni_fornecedor,
    fo.nome_fornecedor,
    ROUND(fo.volume_financeiro, 2) AS volume_financeiro,
    ROUND(
        100.0 * fo.volume_financeiro
        / NULLIF(tg.valor_total, 0),
        2
    ) AS percentual_do_total
FROM fornecedores fo
CROSS JOIN total_geral tg
ORDER BY fo.volume_financeiro DESC
LIMIT 10;

-- Pergunta 3: Quais modalidades licitatórias trazem maior deságio/economia e quais concentram o maior volume de recursos?

SELECT
    m.nome_modalidade,
    ROUND(
        100.0 * SUM(CASE WHEN f.comparavel = 1 THEN f.economia_valor END)
        / NULLIF(
            SUM(CASE WHEN f.comparavel = 1 THEN f.valor_total_estimado END),
            0
        ),
        2
    ) AS percentual_economia,
    ROUND(
        SUM(CASE WHEN f.comparavel = 1 THEN f.economia_valor END),
        2
    ) AS economia_nominal,
    ROUND(SUM(f.valor_total_homologado), 2) AS volume_financeiro
FROM fato_item_contratado f
JOIN dim_modalidade m
    ON f.sk_modalidade = m.sk_modalidade
GROUP BY m.nome_modalidade
ORDER BY volume_financeiro DESC;

-- Pergunta 4: Qual a duração média (em dias) entre o lançamento do edital e a sua homologação final, segmentada por órgão?

SELECT
    d.nome_orgao,
    COUNT(f.dias_ciclo) AS itens_com_ciclo,
    ROUND(AVG(f.dias_ciclo), 1) AS media_dias_ciclo,
    MAX(f.dias_ciclo) AS maior_ciclo_dias,
    COUNT(DISTINCT d.cnpj_orgao) AS unidades_cnpj
FROM fato_item_contratado f
JOIN dim_orgao d ON f.sk_orgao = d.sk_orgao
GROUP BY d.nome_orgao
HAVING COUNT(f.dias_ciclo) >= 5
ORDER BY AVG(f.dias_ciclo) DESC;

-- Pergunta 5: Quais estados e regiões concentram as maiores despesas e quais apresentam os melhores indicadores de desconto?

-- Distribuição por estado
 SELECT
    l.uf_sigla AS estado,
    l.regiao,
    ROUND(SUM(f.valor_total_homologado), 2) AS total_despesas,
    ROUND(
        100.0 * SUM(CASE WHEN f.comparavel = 1 THEN f.economia_valor END)
        / NULLIF(
            SUM(CASE WHEN f.comparavel = 1 THEN f.valor_total_estimado END),
            0
        ),
        2
    ) AS percentual_economia,
    ROUND(
        SUM(CASE WHEN f.comparavel = 1 THEN f.economia_valor END),
        2
    ) AS economia_nominal
FROM fato_item_contratado f
JOIN dim_localidade l
    ON f.sk_localidade = l.sk_localidade
GROUP BY
    l.uf_sigla,
    l.regiao
ORDER BY total_despesas DESC;

-- Distribuição por região
SELECT
    l.regiao,
    SUM(f.valor_total_homologado) AS volume_homologado,
    SUM(CASE WHEN f.comparavel = 1 THEN f.economia_valor ELSE 0 END) AS economia_nominal,
    100.0 * SUM(CASE WHEN f.comparavel = 1 THEN f.economia_valor ELSE 0 END) /
        NULLIF(SUM(CASE WHEN f.comparavel = 1 THEN f.valor_total_estimado ELSE 0 END), 0) AS economia_percentual
FROM fato_item_contratado f
JOIN dim_localidade l ON f.sk_localidade = l.sk_localidade
GROUP BY l.regiao
ORDER BY SUM(f.valor_total_homologado) DESC;

-- Pergunta 6: Como os recursos se distribuem entre bens, serviços e obras e engenharia?

SELECT
    f.perfil_gasto AS categoria,
    ROUND(SUM(f.valor_total_homologado), 2) AS total_homologado,
    ROUND(
        100.0 * SUM(f.valor_total_homologado)
        / NULLIF(SUM(SUM(f.valor_total_homologado)) OVER (), 0),
        2
    ) AS percentual_dos_recursos,
    COUNT(*) AS total_itens
FROM fato_item_contratado f
GROUP BY f.perfil_gasto
ORDER BY total_homologado DESC;

    

