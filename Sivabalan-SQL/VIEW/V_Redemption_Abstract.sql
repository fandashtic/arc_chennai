CREATE VIEW   [V_Redemption_Abstract]
([RedemptionID],[Definition_Type],[ProductCode],[Point_Type],[Definition_Value],[Definition_Points])
AS 
select PA.DocSerial,
PA.DefinitionType,
PD.Product_Code,
case when PA.DefinitionType= 0 then PD.PointsType
     when PA.DefinitionType= 2 then 0 end,
case when PA.DefinitionType= 0 then PD.value
     when PA.DefinitionType= 2 then PA.value end,
case when PA.DefinitionType= 0 then PD.Points
     when PA.DefinitionType= 2 then PA.points end
from pointsabstract PA
left outer join pointsdetail PD on PA.DocSerial = PD.DocSerial  and PD.Active=1  
where PA.DefinitionType in(0,2) and PA.Active=1 

