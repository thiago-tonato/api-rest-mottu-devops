-- Roles iniciais
INSERT INTO roles (nome) VALUES ('ROLE_ADMIN'), ('ROLE_USER');

-- Usuários iniciais
INSERT INTO usuarios (username, password, enabled)
VALUES
 ('admin', '$2a$10$3bb9jZHMXZAEgUrpPX9Lqew6E3GR1anmZTyLFY7R8myma3TIk4PU2', TRUE), -- senha: admin123
 ('user',  '$2a$10$go87qvOjXc4/JnoLLdxIyuhQHBdNGQ1ooVUg9hgkoMhGo/FNcyTZ6', TRUE); -- senha: user123

-- Relacionando usuários com roles
INSERT INTO usuarios_roles (usuario_id, role_id)
VALUES
 ((SELECT id FROM usuarios WHERE username = 'admin'), (SELECT id FROM roles WHERE nome = 'ROLE_ADMIN')),
 ((SELECT id FROM usuarios WHERE username = 'admin'), (SELECT id FROM roles WHERE nome = 'ROLE_USER')),
 ((SELECT id FROM usuarios WHERE username = 'user'), (SELECT id FROM roles WHERE nome = 'ROLE_USER'));
