DROP TABLE IF EXISTS tic_tac_toe CASCADE;

CREATE TABLE tic_tac_toe (
    x INT NOT NULL CHECK (x BETWEEN 1 AND 3),
    y INT NOT NULL CHECK (y BETWEEN 1 AND 3),
    val CHAR(1) CHECK (val IN ('X','O')),
    PRIMARY KEY (x, y)
);

CREATE OR REPLACE VIEW tic_tac_toe_view AS
WITH c1 AS (
    SELECT val, ROW_NUMBER() OVER (ORDER BY y) AS rn
    FROM tic_tac_toe WHERE x = 1
),
c2 AS (
    SELECT val, ROW_NUMBER() OVER (ORDER BY y) AS rn
    FROM tic_tac_toe WHERE x = 2
),
c3 AS (
    SELECT val, ROW_NUMBER() OVER (ORDER BY y) AS rn
    FROM tic_tac_toe WHERE x = 3
)
SELECT
    COALESCE(c1.val,' ') AS cell_1,
    COALESCE(c2.val,' ') AS cell_2,
    COALESCE(c3.val,' ') AS cell_3
FROM c1
JOIN c2 ON c1.rn = c2.rn
JOIN c3 ON c1.rn = c3.rn
ORDER BY c1.rn;

CREATE OR REPLACE FUNCTION NewGame()
RETURNS TABLE(cell_1 CHAR, cell_2 CHAR, cell_3 CHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM tic_tac_toe;

    INSERT INTO tic_tac_toe (x,y,val)
    SELECT i, j, NULL
    FROM generate_series(1,3) i,
         generate_series(1,3) j;

    RETURN QUERY
    SELECT * FROM tic_tac_toe_view;
END;
$$;

CREATE OR REPLACE FUNCTION NextMove(p_x INT, p_y INT)
RETURNS TABLE(cell_1 CHAR, cell_2 CHAR, cell_3 CHAR)
LANGUAGE plpgsql
AS $$
DECLARE
    current_val CHAR;
    moves INT;
    winner CHAR;
BEGIN
    LOCK TABLE tic_tac_toe IN ROW EXCLUSIVE MODE;

    IF p_x NOT BETWEEN 1 AND 3 OR p_y NOT BETWEEN 1 AND 3 THEN
        RAISE EXCEPTION 'Coordinates out of range (1..3)';
    END IF;

    IF (SELECT val FROM tic_tac_toe WHERE x = p_x AND y = p_y) IS NOT NULL THEN
        RAISE EXCEPTION 'Cell already occupied';
    END IF;

    SELECT COUNT(val) INTO moves FROM tic_tac_toe WHERE val IS NOT NULL;
    current_val := CASE WHEN moves % 2 = 0 THEN 'X' ELSE 'O' END;

    UPDATE tic_tac_toe SET val = current_val WHERE x = p_x AND y = p_y;

    
    winner := NULL; -- проверка победы по линии
    FOR i IN 1..3 LOOP
        IF (SELECT COUNT(*) FROM tic_tac_toe WHERE x=i AND val=current_val) = 3 THEN
            winner := current_val;
        ELSIF (SELECT COUNT(*) FROM tic_tac_toe WHERE y=i AND val=current_val) = 3 THEN
            winner := current_val;
        END IF;
    END LOOP;
    IF winner IS NULL THEN -- проверка победы по диагоналям
        IF (SELECT COUNT(*) FROM tic_tac_toe WHERE (x,y) IN ((1,1),(2,2),(3,3)) AND val = current_val) = 3 THEN
            winner := current_val;
        ELSIF (SELECT COUNT(*) FROM tic_tac_toe WHERE (x,y) IN ((1,3),(2,2),(3,1)) AND val = current_val) = 3 THEN
            winner := current_val;
        END IF;
    END IF;

    IF winner IS NOT NULL THEN
        RAISE NOTICE 'Winner: %', winner;
        PERFORM NewGame(); 
    ELSIF (SELECT COUNT(*) FROM tic_tac_toe WHERE val IS NULL) = 0 THEN
        RAISE NOTICE 'Draw.';
        PERFORM NewGame();
    END IF;

    RETURN QUERY
    SELECT * FROM tic_tac_toe_view;
END;
$$;


-- Пример использования
SELECT * FROM NewGame();
SELECT * FROM NextMove(1,1);
SELECT * FROM NextMove(2,2);
SELECT * FROM NextMove(1,2);
SELECT * FROM NextMove(3,3);
SELECT * FROM NextMove(3,1);
SELECT * FROM NextMove(2,3);
SELECT * FROM NextMove(1,3);