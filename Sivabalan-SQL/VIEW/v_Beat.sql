CREATE VIEW  [v_Beat]
([BeatID],[Beat_Name],[Active])
AS
SELECT     BeatID, Description as Beat_Name ,Active
FROM       Beat
