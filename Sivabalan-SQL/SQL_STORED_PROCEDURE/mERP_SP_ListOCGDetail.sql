
CREATE Procedure mERP_SP_ListOCGDetail as 
Begin
    Create table #tmpOCG ( Idnt Int Identity (1,1), OCGName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, DivName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
    SubCtgName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, MktName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Product_Code nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS, Exclusion nvarchar(5) COLLATE SQL_Latin1_General_CP1_CI_AS)
    Insert Into #tmpOCG
    Select (GroupName +'-' + OCGDescription), Case Level when 2 then ProductCategoryName Else '' End as DivName,
    Case Level when 3 then ProductCategoryName Else '' End as SubCtgName,
    Case Level when 4 then ProductCategoryName Else '' End as MktName,
    Case Level when 5 then ProductCategoryName Else '' End as Product_Code, 
    (Case Exclusion when 1 then 'Yes' Else '' End) as Exclusion
    from OCG_Product Join ProductCategoryGroupAbstract on OCGCode = GroupName where 
--  OCGtype = 1 and 
    Active = 1 
    order by (GroupName +'-' + OCGDescription), Case Level when 2 then ProductCategoryName Else 'z' End,
    Case Level when 3 then ProductCategoryName Else 'z' End, Case Level when 4 then ProductCategoryName Else 'z' End, 
    Case Level when 5 then ProductCategoryName Else 'z' End
    Update #tmpOCG set OCGName = '' where Idnt not In ( Select min(Idnt) Idnt from #tmpOCG group by OCGName )

    Select OCG.OCGName, OCG.DivName, OCG.SubCtgName, OCG.MktName, IsNull(OCG.Product_Code + Isnull( ' ~ ' + Itm.productname,''), '') as Product_Code,
    OCG.Exclusion from #tmpOCG OCG Left outer Join Items Itm on OCG.product_code = Itm.product_code    
--    order by Idnt
    Drop table #tmpOCG
End  

