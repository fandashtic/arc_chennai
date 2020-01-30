CREATE VIEW [dbo].[V_LP_Target_Achievement]
(
[LP_Customer_ID] ,
[LP_Ason_Date],	
[LP_Product_Seq_No],
[LP_Product_Desc],
[LP_Target_Value],
[LP_Achievement_Value]
) 
AS
Select Distinct CustomerId,Convert(Nvarchar(10),LastDayclosedate,103) LastDayclosedate ,SeqNo,ProductDesc,Cast(Target as Decimal(18,2)) Target,Cast(Achievement as Decimal(18,2)) Achievement from Dbo.Fn_Get_V_LPTargetAchievement()
