Create Procedure mERP_sp_Get_DSPMetric_Period
As
Begin
Select  IsNull(Min(Cast(Mnh as DateTime)),dbo.striptimeFromDate(GetDate() - Day(GetDate())+1)), 
Case When Max(Cast(Mnh as DateTime)) < dbo.StripTimeFromDate(Getdate() - (Day(Getdate())-1)) Then dbo.StripTimeFromDate(Getdate() - (Day(Getdate())-1)) 
     When Max(Cast(Mnh as DateTime)) >= Min(Cast(Mnh as DateTime)) Then Max(Cast(Mnh as DateTime))
     When IsNull(Max(Mnh),'') = '' Then dbo.striptimeFromDate(GetDate() - Day(GetDate())+1) End
From (
Select '01' + '/' + SubString(Period,1,3) + '/' +  SubString(Period,5,4) as Mnh
From tbl_mERP_PMMaster) A
End
