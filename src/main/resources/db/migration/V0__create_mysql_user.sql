-- Criar usuário MySQL para a aplicação
CREATE USER IF NOT EXISTS 'mottuadmin'@'%' IDENTIFIED BY 'QualiTracker123!';
GRANT ALL PRIVILEGES ON mottu.* TO 'mottuadmin'@'%';
FLUSH PRIVILEGES;
