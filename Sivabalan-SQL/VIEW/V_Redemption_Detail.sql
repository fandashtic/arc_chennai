CREATE VIEW [V_Redemption_Detail]
([RedemptionID],[Free_Type],[Free_ProductCode],[Free_FromPoint],[Free_ToPoint],[Free_Value])
AS select R.Docserial,
R.Type,
R.ProductCode,
R.FromPoint,
R.ToPoint,
case when R.Type = 0 then R.Value
     when R.Type = 1 then 1
end 
from Redemption R,PointsAbstract PA where PA.DocSerial = R.DocSerial and PA.DefinitionType in(0,2) and PA.Active = 1  and R.Active = 1
