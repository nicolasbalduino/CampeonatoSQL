CREATE DATABASE Campeonato_Amador;
GO

USE Campeonato_Amador;
GO

CREATE TABLE Time (
    nome        VARCHAR(50) NOT NULL,
    apelido     VARCHAR(20) NOT NULL,
    dataCriacao DATE        NOT NULL,

    CONSTRAINT PK_Time          PRIMARY KEY (nome),
    CONSTRAINT UN_Time_Apelido  UNIQUE (apelido)
);
GO

CREATE TABLE Jogo (
    timeCasa    VARCHAR(50) NOT NULL,
    timeFora    VARCHAR(50) NOT NULL,
    golCasa     TINYINT     NOT NULL DEFAULT(0),
    golFora     TINYINT     NOT NULL DEFAULT(0),
    pontoCasa   TINYINT     NOT NULL DEFAULT(0),
    pontoFora   TINYINT     NOT NULL DEFAULT(0),

    CONSTRAINT PK_Jogo PRIMARY KEY (timeCasa, timeFora),
    CONSTRAINT FK_Jogo_Time_Casa FOREIGN KEY (timeCasa) REFERENCES [Time](nome),
    CONSTRAINT FK_Jogo_Time_Fora FOREIGN KEY (timeFora) REFERENCES [Time](nome),
    CONSTRAINT CK_Time_Diferente CHECK       (timeFora <> timeCasa)
);
GO

INSERT INTO [Time] VALUES 
    ('Time A', 'A', GETDATE()),
    ('Time B', 'B', GETDATE()),
    ('Time C', 'C', GETDATE()),
    ('Time D', 'D', GETDATE()),
    ('Time E', 'E', GETDATE());
GO

INSERT INTO Jogo (timeCasa, timeFora) VALUES 
    ('Time A', 'Time B'),
    ('Time B', 'Time A'),
    ('Time C', 'Time A'),
    ('Time D', 'Time A'),
    ('Time E', 'Time A'),
    ('Time A', 'Time C'),
    ('Time B', 'Time C'),
    ('Time C', 'Time B'),
    ('Time D', 'Time B'),
    ('Time E', 'Time B'),
    ('Time A', 'Time D'),
    ('Time B', 'Time D'),
    ('Time C', 'Time D'),
    ('Time D', 'Time C'),
    ('Time E', 'Time C'),
    ('Time A', 'Time E'),
    ('Time B', 'Time E'),
    ('Time C', 'Time E'),
    ('Time D', 'Time E'),
    ('Time E', 'Time D');
GO

CREATE OR ALTER TRIGGER TGR_Atualiza_Pontuacao 
ON Jogo 
AFTER UPDATE
AS
BEGIN
    IF(UPDATE(golCasa) OR UPDATE(golFora))
    BEGIN
        DECLARE @timeCasa VARCHAR(50),  @timeFora VARCHAR(50), 
                @golCasa TINYINT,       @golFora TINYINT, 
                @pontoCasa TINYINT,     @pontoFora TINYINT;

        SELECT @timeCasa = timeCasa,    @timeFora = timeFora, 
                @golCasa = golCasa,     @golFora = golFora 
        FROM inserted;

        IF(@golCasa > @golFora)
        BEGIN
            SET @pontoCasa = 3;
            SET @pontoFora = 0;
        END

        ELSE IF (@golCasa < @golFora)
        BEGIN
            SET @pontoCasa = 0;
            SET @pontoFora = 5;
        END

        ELSE
        BEGIN
            SET @pontoCasa = 1;
            SET @pontoFora = 1;
        END

        UPDATE Jogo SET pontoCasa = @pontoCasa, pontoFora = @pontoFora
        WHERE timeCasa = @timeCasa AND timeFora = @timeFora;
    END
END;
GO

UPDATE Jogo SET golCasa = 0, golFora = 3 WHERE timeCasa = 'Time A' AND timeFora = 'Time B';
UPDATE Jogo SET golCasa = 1, golFora = 2 WHERE timeCasa = 'Time A' AND timeFora = 'Time C';
UPDATE Jogo SET golCasa = 2, golFora = 1 WHERE timeCasa = 'Time A' AND timeFora = 'Time D';
UPDATE Jogo SET golCasa = 3, golFora = 0 WHERE timeCasa = 'Time A' AND timeFora = 'Time E';
UPDATE Jogo SET golCasa = 1, golFora = 1 WHERE timeCasa = 'Time B' AND timeFora = 'Time A';
UPDATE Jogo SET golCasa = 1, golFora = 2 WHERE timeCasa = 'Time B' AND timeFora = 'Time C';
UPDATE Jogo SET golCasa = 3, golFora = 2 WHERE timeCasa = 'Time B' AND timeFora = 'Time D';
UPDATE Jogo SET golCasa = 2, golFora = 2 WHERE timeCasa = 'Time B' AND timeFora = 'Time E';
UPDATE Jogo SET golCasa = 1, golFora = 4 WHERE timeCasa = 'Time C' AND timeFora = 'Time A';
UPDATE Jogo SET golCasa = 4, golFora = 1 WHERE timeCasa = 'Time C' AND timeFora = 'Time B';
UPDATE Jogo SET golCasa = 5, golFora = 3 WHERE timeCasa = 'Time C' AND timeFora = 'Time D';
UPDATE Jogo SET golCasa = 0, golFora = 3 WHERE timeCasa = 'Time C' AND timeFora = 'Time E';
UPDATE Jogo SET golCasa = 3, golFora = 2 WHERE timeCasa = 'Time D' AND timeFora = 'Time A';
UPDATE Jogo SET golCasa = 4, golFora = 5 WHERE timeCasa = 'Time D' AND timeFora = 'Time B';
UPDATE Jogo SET golCasa = 2, golFora = 1 WHERE timeCasa = 'Time D' AND timeFora = 'Time C';
UPDATE Jogo SET golCasa = 2, golFora = 2 WHERE timeCasa = 'Time D' AND timeFora = 'Time E';
UPDATE Jogo SET golCasa = 1, golFora = 0 WHERE timeCasa = 'Time E' AND timeFora = 'Time A';
UPDATE Jogo SET golCasa = 5, golFora = 2 WHERE timeCasa = 'Time E' AND timeFora = 'Time B';
UPDATE Jogo SET golCasa = 3, golFora = 4 WHERE timeCasa = 'Time E' AND timeFora = 'Time C';
UPDATE Jogo SET golCasa = 1, golFora = 2 WHERE timeCasa = 'Time E' AND timeFora = 'Time D';
GO

CREATE OR ALTER PROC MostrarClassificao @QtdClassificados INT
AS
BEGIN
    IF(@QtdClassificados IS NULL)
        SET @QtdClassificados = 1000;

    SELECT top(@QtdClassificados) t.nome AS 'classificado(s)', 
    ((SELECT SUM(pontoCasa) FROM Jogo WHERE timeCasa = t.nome) + 
     (SELECT SUM(pontoFora) FROM Jogo WHERE timeFora = t.nome)) AS total_de_pontos,

     ((SELECT COUNT(*) FROM Jogo WHERE timeCasa = t.nome AND golCasa > golFora) + 
      (SELECT COUNT(*) FROM Jogo WHERE timeFora = t.nome AND golFora > golCasa)) AS numero_vitorias,

    ((SELECT (SUM(golCasa) - SUM(golFora)) FROM Jogo WHERE timeCasa = t.nome) + 
     (SELECT (SUM(golFora) - SUM(golCasa)) FROM Jogo WHERE timeFora = t.nome)) AS saldo_de_gols
    FROM [Time] t
    ORDER BY total_de_pontos DESC, numero_vitorias DESC, saldo_de_gols DESC;
END;
GO

CREATE OR ALTER PROC TimeComMaisGols
AS
BEGIN
    SELECT top(1) t.nome AS time_com_mais_gols, 
        ((SELECT SUM(golCasa) FROM Jogo WHERE timeCasa = t.nome) + 
         (SELECT SUM(golFora) FROM Jogo WHERE timeFora = t.nome)) AS total_de_gols
    FROM [Time] t
    ORDER BY total_de_gols DESC;
END;
GO

CREATE OR ALTER PROC TimeComMaisGolsSofridos
AS
BEGIN
    SELECT top(1) t.nome AS time_que_mais_sofreu_gols, 
        ((SELECT SUM(golFora) FROM Jogo WHERE timeCasa = t.nome) + 
         (SELECT SUM(golCasa) FROM Jogo WHERE timeFora = t.nome)) AS total_de_gols_sofridos
    FROM [Time] t
    ORDER BY total_de_gols_sofridos DESC;
END;
GO

CREATE OR ALTER PROC JogoComMaisGols
AS
BEGIN
    SELECT TOP(1) CONCAT(j.timeCasa, ' x ', j.timeFora) AS jogo_com_mais_gols, (j.golCasa + j.golFora) AS total_de_gols
    FROM Jogo j
    ORDER BY total_de_gols DESC;
END;
GO

CREATE OR ALTER PROC MaiorNumeroDeGolsDoTimeEmUmJogo
AS
BEGIN
    SELECT t.nome AS maior_numero_de_gols_em_um_jogo, 
        CASE WHEN (MAX(j.golCasa) > MAX(jj.golFora)) THEN MAX(j.golCasa) ELSE MAX(jj.golFora) END AS total_de_gols
    FROM [Time] t
    JOIN Jogo j ON t.nome = j.timeCasa
    JOIN Jogo jj ON t.nome = jj.timeFora
    GROUP BY t.nome;
END;
GO

EXEC.MostrarClassificao 2;
GO

EXEC.TimeComMaisGols;
GO

EXEC.TimeComMaisGolsSofridos;
GO

EXEC.JogoComMaisGols;
GO

EXEC.MaiorNumeroDeGolsDoTimeEmUmJogo;
GO
