CREATE TABLE alocacoes (
    id BIGSERIAL PRIMARY KEY,
    moto_id BIGINT NOT NULL,
    inicio TIMESTAMP NOT NULL,
    fim TIMESTAMP,
    status VARCHAR(20) NOT NULL,
    CONSTRAINT fk_alocacao_moto FOREIGN KEY (moto_id) REFERENCES motos (id)
);