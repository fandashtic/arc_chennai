Create Procedure sp_get_SchemeApplyON(@SchemeID Integer)  
As  
Begin  
Select Isnull(ApplyON,0) From Schemes Where SchemeID=@SchemeID  
End  
