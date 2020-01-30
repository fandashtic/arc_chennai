CREATE PROCEDURE sp_get_VAllocDetInfo
(         
	@VAllocID Int
)
AS  
Begin
IF (Select SUM(IsNull(SequenceNo,0)) From VAllocDetail Where VAllocID = @VAllocID ) > 0
Select 
"Outlet ID" = IA.CustomerID,
"Outlet Name" = C.Company_Name ,
"Bill Number" = IA.GSTFullDocID,
"Doc No" = IA.DocReference,
"Date" = dbo.StripTimeFromDate(IA.InvoiceDate),
"Bill Value" = IsNull(IA.NetValue,0) + IsNull(IA.RoundOffAmount,0),
"Salesman" = IsNull(S.Salesman_Name,'') ,
"Beat" = IsNull(B.Description,'') ,
"Zone" = IsNull(Z.ZoneName,'') , 
"Sequence No" = VAD.SequenceNo
From InvoiceAbstract IA
Inner Join VAllocDetail VAD On VAD.GSTFullDocID = IA.GSTFullDocID And VAD.VAllocID = @VAllocID 
Inner Join Customer C On C.CustomerID = VAD.CustomerID
Left Outer Join Salesman S On S.SalesmanID = VAD.SalesmanID
Left Outer Join Beat B On B.BeatID= VAD.BeatID
Left Outer Join tbl_mERP_Zone Z On Z.ZoneID = C.ZoneID 
Where IA.Status & 128 = 0
Order By VAD.SequenceNo
Else
Select 
"Outlet ID" = IA.CustomerID,
"Outlet Name" = C.Company_Name ,
"Bill Number" = IA.GSTFullDocID,
"Doc No" = IA.DocReference,
"Date" = dbo.StripTimeFromDate(IA.InvoiceDate),
"Bill Value" = IsNull(IA.NetValue,0) + IsNull(IA.RoundOffAmount,0),
"Salesman" = IsNull(S.Salesman_Name,'') ,
"Beat" = IsNull(B.Description,'') ,
"Zone" = IsNull(Z.ZoneName,'') , 
"Sequence No" = VAD.SequenceNo
From InvoiceAbstract IA
Inner Join VAllocDetail VAD On VAD.GSTFullDocID = IA.GSTFullDocID And VAD.VAllocID = @VAllocID 
Inner Join Customer C On C.CustomerID = VAD.CustomerID
Left Outer Join Salesman S On S.SalesmanID = VAD.SalesmanID
Left Outer Join Beat B On B.BeatID= VAD.BeatID
Left Outer Join tbl_mERP_Zone Z On Z.ZoneID = C.ZoneID 
Where IA.Status & 128 = 0
Order By dbo.StripTimeFromDate(IA.InvoiceDate), IA.GSTFullDocID 
End
