-- =====================================================
-- 1. CRIAÇÃO DAS TABELAS
-- =====================================================

-- Tabela: sensores
-- Descrição: Armazena informações dos sensores UWB para rastreamento
CREATE TABLE sensores (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único do sensor',
    localizacao VARCHAR(255) NOT NULL COMMENT 'Localização física do sensor no pátio'
) COMMENT 'Tabela de sensores UWB para rastreamento de motos';

-- Tabela: motos
-- Descrição: Armazena informações das motos e sua associação com sensores
CREATE TABLE motos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único da moto',
    identificador_uwb VARCHAR(100) NOT NULL UNIQUE COMMENT 'Identificador UWB único da moto',
    modelo VARCHAR(100) NOT NULL COMMENT 'Modelo da moto',
    cor VARCHAR(50) NOT NULL COMMENT 'Cor da moto',
    status VARCHAR(20) NOT NULL COMMENT 'Status atual da moto (DISPONIVEL, ALOCADA, MANUTENCAO, INDISPONIVEL)',
    sensor_id BIGINT COMMENT 'ID do sensor associado à moto',
    CONSTRAINT fk_sensor FOREIGN KEY (sensor_id) REFERENCES sensores(id) ON DELETE SET NULL
) COMMENT 'Tabela de motos com identificação UWB';

-- Tabela: roles
-- Descrição: Armazena os perfis de usuário do sistema
CREATE TABLE roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único da role',
    nome VARCHAR(50) NOT NULL UNIQUE COMMENT 'Nome da role (ROLE_ADMIN, ROLE_USER)'
) COMMENT 'Tabela de perfis de usuário';

-- Tabela: usuarios
-- Descrição: Armazena informações dos usuários do sistema
CREATE TABLE usuarios (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único do usuário',
    username VARCHAR(100) NOT NULL UNIQUE COMMENT 'Nome de usuário para login',
    password VARCHAR(255) NOT NULL COMMENT 'Senha criptografada do usuário',
    enabled BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'Indica se o usuário está ativo'
) COMMENT 'Tabela de usuários do sistema';

-- Tabela: usuarios_roles
-- Descrição: Tabela de relacionamento muitos-para-muitos entre usuários e roles
CREATE TABLE usuarios_roles (
    usuario_id BIGINT NOT NULL COMMENT 'ID do usuário',
    role_id BIGINT NOT NULL COMMENT 'ID da role',
    PRIMARY KEY (usuario_id, role_id),
    CONSTRAINT fk_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    CONSTRAINT fk_role FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
) COMMENT 'Relacionamento entre usuários e roles';

-- Tabela: alocacoes
-- Descrição: Armazena informações das alocações de motos
CREATE TABLE alocacoes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único da alocação',
    moto_id BIGINT NOT NULL COMMENT 'ID da moto alocada',
    inicio TIMESTAMP NOT NULL COMMENT 'Data e hora de início da alocação',
    fim TIMESTAMP COMMENT 'Data e hora de fim da alocação (NULL se ainda ativa)',
    status VARCHAR(20) NOT NULL COMMENT 'Status da alocação (ABERTA, FECHADA)',
    CONSTRAINT fk_alocacao_moto FOREIGN KEY (moto_id) REFERENCES motos(id) ON DELETE CASCADE
) COMMENT 'Tabela de alocações de motos';

-- Tabela: manutencoes
-- Descrição: Armazena informações das manutenções das motos
CREATE TABLE manutencoes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Identificador único da manutenção',
    moto_id BIGINT NOT NULL COMMENT 'ID da moto em manutenção',
    descricao VARCHAR(255) COMMENT 'Descrição da manutenção realizada',
    data_inicio TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data e hora de início da manutenção',
    data_fim TIMESTAMP COMMENT 'Data e hora de fim da manutenção (NULL se ainda ativa)',
    status VARCHAR(20) NOT NULL COMMENT 'Status da manutenção (ABERTA, FECHADA)',
    ativa BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'Indica se a manutenção está ativa',
    CONSTRAINT fk_manutencao_moto FOREIGN KEY (moto_id) REFERENCES motos(id) ON DELETE CASCADE
) COMMENT 'Tabela de manutenções de motos';

-- =====================================================
-- 2. ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índices para melhorar performance das consultas
CREATE INDEX idx_motos_identificador_uwb ON motos(identificador_uwb);
CREATE INDEX idx_motos_status ON motos(status);
CREATE INDEX idx_motos_sensor_id ON motos(sensor_id);
CREATE INDEX idx_alocacoes_moto_id ON alocacoes(moto_id);
CREATE INDEX idx_alocacoes_status ON alocacoes(status);
CREATE INDEX idx_alocacoes_inicio ON alocacoes(inicio);
CREATE INDEX idx_manutencoes_moto_id ON manutencoes(moto_id);
CREATE INDEX idx_manutencoes_status ON manutencoes(status);
CREATE INDEX idx_manutencoes_ativa ON manutencoes(ativa);

-- =====================================================
-- 3. DADOS INICIAIS
-- =====================================================

-- Inserir sensores iniciais
INSERT INTO sensores (localizacao) VALUES
('Setor A - Coluna 1'),
('Setor B - Coluna 2'),
('Setor C - Coluna 3');

-- Inserir motos iniciais
INSERT INTO motos (identificador_uwb, modelo, cor, status, sensor_id) VALUES
('UWB001', 'Honda CG 160', 'Preto', 'DISPONIVEL', 1),
('UWB002', 'Yamaha Fazer 250', 'Azul', 'DISPONIVEL', 2),
('UWB003', 'Honda Biz 125', 'Vermelho', 'DISPONIVEL', 3);

-- Inserir roles iniciais
INSERT INTO roles (nome) VALUES 
('ROLE_ADMIN'), 
('ROLE_USER');

-- Inserir usuários iniciais (senhas criptografadas com BCrypt)
INSERT INTO usuarios (username, password, enabled) VALUES
('admin', '$2a$10$3bb9jZHMXZAEgUrpPX9Lqew6E3GR1anmZTyLFY7R8myma3TIk4PU2', TRUE), -- senha: admin123
('user',  '$2a$10$go87qvOjXc4/JnoLLdxIyuhQHBdNGQ1ooVUg9hgkoMhGo/FNcyTZ6', TRUE); -- senha: user123

-- Relacionar usuários com roles
INSERT INTO usuarios_roles (usuario_id, role_id) VALUES
((SELECT id FROM usuarios WHERE username = 'admin'), (SELECT id FROM roles WHERE nome = 'ROLE_ADMIN')),
((SELECT id FROM usuarios WHERE username = 'admin'), (SELECT id FROM roles WHERE nome = 'ROLE_USER')),
((SELECT id FROM usuarios WHERE username = 'user'), (SELECT id FROM roles WHERE nome = 'ROLE_USER'));

-- =====================================================
-- 4. COMENTÁRIOS SOBRE A ARQUITETURA
-- =====================================================

/*
ARQUITETURA DO SISTEMA:

1. SENSORES UWB: Dispositivos fixos que detectam a presença de motos
2. MOTOS: Veículos com identificadores UWB únicos
3. ALOCAÇÕES: Controle de uso das motos pelos usuários
4. MANUTENÇÕES: Controle de manutenção preventiva e corretiva
5. USUÁRIOS: Sistema de autenticação e autorização

FLUXO DE DADOS:
- Sensores detectam motos via UWB
- Motos são alocadas para usuários
- Sistema controla status (disponível, alocada, manutenção)
- Manutenções são agendadas e executadas
- Relatórios são gerados para gestão

BENEFÍCIOS:
- Controle preciso de localização via UWB
- Redução de perdas e roubos
- Otimização da frota
- Manutenção preventiva
- Relatórios gerenciais
*/
