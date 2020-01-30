Create Procedure spr_DS_Update_Info
(
@Date DateTime
)
As

BEGIN

set dateformat dmy
Declare @WDCode nVarchar(255)
Declare @WDDest nVarchar(255)
Declare @CompaniesToUploadCode nVarchar(255)

Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload
Select Top 1 @WDCode = RegisteredOwner From Setup

If @CompaniesToUploadCode='ITC001'
Set @WDDest= @WDCode
Else
Begin
Set @WDDest= @WDCode
Set @WDCode= @CompaniesToUploadCode
End

Select  1, "WD_Code" = @WDCode, "WD_Dest_Code" = @WDDest, "From_Date" = @Date, "To_Date" = @Date,
"P_ID" = SM.SalesManID,
"P_HH" = IsNull((Select DM.DSTypeValue From DSType_Master DM, DSType_Details DD
Where DD.SalesmanID  = SM.SalesmanID
and DD.DSTypeID = DM.DSTypeID
and DM.DSTypeCtlPos = 2), 'No'),
"P_SMS" = Case SM.SMSAlert When 1 Then 'Yes' Else 'No' End,
"P_MODDT" = cast (CONVERT(VARCHAR(10), SM.ModifiedDate, 103) + ' '  + convert(VARCHAR(8), SM.ModifiedDate, 14) as varchar),
"P_Active" = Case SM.Active When 0 Then 'No' Else 'Yes' End,
"P_Name" = Salesman_Name,
"P_Type" = DM.DSTypeValue,
"P_MobileNo" = MobileNumber
From SalesMan SM
Inner Join DSType_Details DD on SM.SalesManID = DD.Salesmanid And DSTypeCtlPos = 1
Inner Join DSType_Master DM on DD.DSTYpeID = DM.DSTypeID
Where dbo.StripTimeFromDate(SM.ModifiedDate) = @Date or dbo.StripTimeFromDate(SM.CreationDate) = @Date
Order By SM.SalesManID

End
