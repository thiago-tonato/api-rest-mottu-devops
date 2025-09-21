CREATE TABLE motos (
    id BIGSERIAL PRIMARY KEY,
    identificador_uwb VARCHAR(100) NOT NULL UNIQUE,
    modelo VARCHAR(100) NOT NULL,
    cor VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL,
    sensor_id BIGINT,
    CONSTRAINT fk_sensor FOREIGN KEY (sensor_id) REFERENCES sensores(id)
);
