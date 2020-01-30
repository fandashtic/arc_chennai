Create Procedure sp_Get_OLClass as 
Declare @delimeter char(1)
select @delimeter = char(15)

select Channel_Type_Desc CHANNEL, Outlet_Type_Desc OUTLET, SubOutlet_Type_Desc SUBOUTLET 
Into #tmpOLC from tbl_mERP_OLClass 
where Channel_Type_Active = 1 and Outlet_Type_Active = 1 and SubOutlet_Type_Active = 1 
And Channel_Type_Desc Not In ( select Distinct [Value] From tbl_mERP_RestrictedOLClass Where TypeName = 'Channel_Type' and Status = 1)
And Outlet_Type_Desc Not In ( select Distinct [Value] From tbl_mERP_RestrictedOLClass Where TypeName = 'Outlet_Type' and Status = 1)
And SubOutlet_Type_Desc Not In ( select Distinct [Value] From tbl_mERP_RestrictedOLClass Where TypeName = 'SubOutlet_Type' and Status = 1)
order by Channel_Type_Desc, Outlet_Type_Desc, SubOutlet_Type_Desc

select distinct CHANNEL from #tmpOLC order by CHANNEL 
select distinct CHANNEL CHANNEL_filter, OUTLET from #tmpOLC order by CHANNEL, OUTLET 
select distinct CHANNEL + @delimeter + OUTLET + @delimeter CHANNEL_OUTLET_filter, SUBOUTLET 
    from #tmpOLC order by CHANNEL + @delimeter + OUTLET + @delimeter, SUBOUTLET
