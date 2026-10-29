CREATE TABLE dim_orgao (
    sk_orgao INTEGER PRIMARY KEY,
    cnpj_orgao VARCHAR(14) NOT NULL UNIQUE,
    nome_orgao VARCHAR(300),
    poder VARCHAR(50)
);

CREATE TABLE dim_fornecedor (
    sk_fornecedor INTEGER PRIMARY KEY,
    ni_fornecedor VARCHAR(20) NOT NULL UNIQUE,
    nome_fornecedor VARCHAR(300),
    tipo_pessoa VARCHAR(50),
    porte VARCHAR(100)
);

CREATE TABLE dim_modalidade (
    sk_modalidade INTEGER PRIMARY KEY,
    modalidade_id INTEGER NOT NULL UNIQUE,
    nome_modalidade VARCHAR(150)
);

CREATE TABLE dim_localidade (
    sk_localidade INTEGER PRIMARY KEY,
    uf_sigla CHAR(2) NOT NULL UNIQUE,
    uf_nome VARCHAR(100),
    regiao VARCHAR(50)
);

CREATE TABLE fato_item_contratado (
    sk_fato BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    numero_controle_pncp VARCHAR(100) NOT NULL,
    numero_item INTEGER NOT NULL,

    sk_orgao INTEGER NOT NULL,
    sk_fornecedor INTEGER NOT NULL,
    sk_modalidade INTEGER NOT NULL,
    sk_localidade INTEGER NOT NULL,

    data_publicacao DATE NOT NULL,
    data_homologacao DATE,

    descricao_item TEXT,
    perfil_gasto VARCHAR(50) NOT NULL,
    quantidade NUMERIC(18,4) NOT NULL,

    valor_unitario_estimado NUMERIC(18,4),
    valor_total_estimado NUMERIC(18,2),
    valor_unitario_homologado NUMERIC(18,4),
    valor_total_homologado NUMERIC(18,2),

    comparavel SMALLINT NOT NULL,
    economia_valor NUMERIC(18,2),
    dias_ciclo INTEGER,

    CONSTRAINT uq_fato_controle_item
        UNIQUE (numero_controle_pncp, numero_item),

    CONSTRAINT fk_fato_orgao
        FOREIGN KEY (sk_orgao)
        REFERENCES dim_orgao (sk_orgao),

    CONSTRAINT fk_fato_fornecedor
        FOREIGN KEY (sk_fornecedor)
        REFERENCES dim_fornecedor (sk_fornecedor),

    CONSTRAINT fk_fato_modalidade
        FOREIGN KEY (sk_modalidade)
        REFERENCES dim_modalidade (sk_modalidade),

    CONSTRAINT fk_fato_localidade
        FOREIGN KEY (sk_localidade)
        REFERENCES dim_localidade (sk_localidade)
);