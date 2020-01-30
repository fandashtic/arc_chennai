Create View V_Reason_Master ([Reason_Type_ID],[Reason_SubType],[Reason_Description])
as
Select Reason_Type_ID, Reason_SubType, Reason_Description from ReasonMaster where Reason_SubType in (1,2) and isnull(active,0)=1
