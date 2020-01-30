Create Procedure mERP_Spr_ListMarginUpdationAbstract(@FromDate as datetime,@ToDate as datetime)
As
Begin
	set dateformat dmy
	Select cast(MD.MarginID as varchar) + char(15)+ I.Category_Name,"Margin Updation ID" = 'MGN' + Cast(MD.MarginID as nvarchar),
    "Margin Updation Date" = MA.DocumentDate,
    "Division Name" = (select Category_Name from ItemCategories where CategoryID=MD.ParentID),
    "Sub Category" =I.Category_Name,
    "Descriptions" = I.Description,
    "Margin %" = MD.Percentage,
    "Date" = EffectiveDate 
    from MarginDetail MD,MarginAbstract MA,ItemCategories I
    where MA.DocumentDate between  @FromDate and @ToDate
    and MD.MarginID=MA.MarginID
    and I.CategoryID=MD.CategoryID
    and MD.ParentID<>0
    order by MD.MarginID,4,5 
End
