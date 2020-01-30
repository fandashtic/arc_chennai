
CREATE Procedure sp_Define_Beat1
as
SELECT xxx.CustomerID, sp_Def_Beat.Company_Name, sp_Def_Beat.AreaID, Areas.Area, sp_Def_Beat.BeatID, Beat.Description
FROM (sp_Def_Beat INNER JOIN Areas ON sp_Def_Beat.AreaID = Areas.AreaID) INNER JOIN Beat ON sp_Def_Beat.BeatID = Beat.BeatID;


